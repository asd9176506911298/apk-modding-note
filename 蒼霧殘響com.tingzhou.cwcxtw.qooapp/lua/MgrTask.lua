-- 任务管理器
MgrTask = {}
MgrTask.PrintProfile = false -- 打印性能
MgrTask.TaskList = {} -- 任务集列表
MgrTask.RunningList = {} -- 正在执行中的任务集
MgrTask.TaskMode = {
    Serial      = 1, -- 串行执行任务
    Parallel    = 2, -- 并行执行任务
}
-- 初始化任务集，pTaskName任务集名称
function MgrTask.Init(pTaskName)
    MgrTask.TaskList[pTaskName] = {}
    MgrTask.TaskList[pTaskName].OnUpdate = nil
    MgrTask.TaskList[pTaskName].OnFinish = nil
    MgrTask.TaskList[pTaskName].List = {}
    MgrTask.TaskList[pTaskName].Cost = {}
    MgrTask.TaskList[pTaskName].Total = 0
    MgrTask.TaskList[pTaskName].Per = 0
    MgrTask.TaskList[pTaskName].IdCounter = 0
end
-- 结束停止任务集
function MgrTask.UnInit(pTaskName)
    if pTaskName == nil or #pTaskName == 0 then
        for k,v in pairs(MgrTask.TaskList) do     
            for i,t in ipairs(v.List) do
                if t.Finish then
                    Event.Remove(t.Listen, t.Finish)
                end
            end 
            MgrTask.RunningList[k] = nil
            MgrTimer.Cancel(k)
            MgrUI.UnLock(k)
            MgrTask.TaskList[k] = nil
        end
     
    else
        local v = MgrTask.TaskList[pTaskName].List
        for i,t in ipairs(v) do
            if t.Finish then
                Event.Remove(t.Listen, t.Finish)
            end
        end 
        MgrTask.RunningList[pTaskName] = nil
        MgrTimer.Cancel(pTaskName)
        MgrUI.UnLock(pTaskName)
        MgrTask.TaskList[pTaskName] = nil
    end
end
-- 向任务集中添加单个任务
--  @TaskName任务集名称
--  @Fun任务块
--  @EventListener任务回调监听（如果nil表示该任务没有回调，执行即完成该任务；有就开启监听，获取监听回调即完成该任务）
--  @Weight任务配重，用于整个任务集的完成度回调
function MgrTask.AddTask(pTaskName, pFun, pEventListener, pWeight, pItemName)
    pWeight = pWeight or 1
    if not MgrTask.TaskList[pTaskName] then return end
    MgrTask.TaskList[pTaskName].IdCounter = MgrTask.TaskList[pTaskName].IdCounter + 1
    pItemName = pItemName or tostring(MgrTask.TaskList[pTaskName].IdCounter)
    local t = {Id = MgrTask.TaskList[pTaskName].IdCounter, Fun =  pFun, Listen = pEventListener, Weight = pWeight, IsRunning = false, Name = pItemName}
    table.insert(MgrTask.TaskList[pTaskName].List, t)
    MgrTask.TaskList[pTaskName].Total =  MgrTask.TaskList[pTaskName].Total + pWeight
end
function MgrTask.GetTaskLen(pTaskName)
    local len = 0
    if MgrTask.TaskList[pTaskName] then
        return #MgrTask.TaskList[pTaskName].List
    end
end
-- 开启任务执行 
-- OnUpdate(per) 任务更新回调 传百分比Per
-- OnFinish 任务集完成回调
-- Mode 任务执行方式，Serial 串行执行 一个执行完成才执行下一个任务；Parallel 并行 一次开启所有任务
function MgrTask.Start(pTaskName, pOnUpdate, pOnFinish, pMode, pUnLock)
    if not pUnLock then
        MgrUI.Lock(pTaskName)
    end
    -- same task is running
    if MgrTask.RunningList[pTaskName] then
        return
    end
    MgrTimer.AddRepeat(pTaskName, 0, function()
        MgrTask.OnUpdate(pTaskName)
    end, -1, nil)
    MgrTask.RunningList[pTaskName] = true
    MgrTask.TaskList[pTaskName].OnUpdate = pOnUpdate
    MgrTask.TaskList[pTaskName].OnFinish = pOnFinish
    if pMode == nil or pMode == MgrTask.TaskMode.Serial then
        MgrTask.TaskList[pTaskName].Mode = MgrTask.TaskMode.Serial
    else
        MgrTask.TaskList[pTaskName].Mode = MgrTask.TaskMode.Parallel
    end
end
function MgrTask.IsRunning()
    for k,v in pairs(MgrTask.RunningList) do
        if v then
            return true
        end
    end
    return false
end
function MgrTask.OnUpdate(pTaskName)
    local t = MgrTask.TaskList[pTaskName].List
    if MgrTask.TaskList[pTaskName].Mode == MgrTask.TaskMode.Serial then
        if #t > 0 then
            if t[1].IsRunning then
                return
            else
                if t[1].Listen then
                    t[1].Finish = function()
                        if not t[1] or not t[1].Listen or not t[1].Finish then return end
                        Event.Remove(t[1].Listen, t[1].Finish)
                        if t[1].Lock then
                            MgrTimer.AddDelay(pTaskName..#t, 0, function()
                                MgrTask.OnItemFinish(pTaskName)
                            end, nil)
                        else
                            MgrTask.OnItemFinish(pTaskName)
                        end
                    end
                    Event.Add(t[1].Listen, t[1].Finish)
                    t[1].Lock = true
                    t[1].IsRunning = true
                    t[1].StartTime = os.clock()
                    t[1].Fun()
                    t[1].Lock = false
                else
                    t[1].StartTime = os.clock()
                    t[1].Fun()
                    MgrTask.OnItemFinish(pTaskName)
                end
            end
        else
            MgrTask.TaskList[pTaskName].OnFinish()
            if MgrTask.PrintProfile then
                if MgrTask.TaskList[pTaskName].Cost then
                    for i,v in ipairs(MgrTask.TaskList[pTaskName].Cost) do
                        print(string.format( "Task %s Item %s Cost %s", pTaskName, v.Name, v.Cost))
                    end
                end
            end
            MgrTask.RunningList[pTaskName] = nil
            MgrTask.UnInit(pTaskName)
        end
    else
        for k,v in pairs(t) do
            if not v.IsRunning then
                if v.Listen then
                    Event.Add(v.Listen, function()
                        MgrTask.OnItemFinish(pTaskName, v)
                    end)
                    v.Fun()
                    v.IsRunning = true
                else
                    v.Fun()
                    MgrTask.OnItemFinish(pTaskName, v)
                end
            end
        end
        if #t == 0 then
            --print("pTaskName：",pTaskName)
            if MgrTask.TaskList[pTaskName] and MgrTask.TaskList[pTaskName].OnFinish  then
                MgrTask.TaskList[pTaskName].OnFinish()
            end
            MgrTask.RunningList[pTaskName] = nil
            MgrTask.UnInit(pTaskName)
        end
    end
end

function MgrTask.SkipCurTaskItem(pTaskName)
    local t = MgrTask.TaskList[pTaskName].List
    if t and t[1] then
        if t[1].IsRunning then
            t[1].Fun()
            MgrTask.OnItemFinish(pTaskName)
            if t[1] then
                Event.Remove(t[1].Listen, t[1].Finish)
            end
        end
    end
end

function MgrTask.OnItemFinish(pTaskName, pTaskItem)
    if MgrTask.TaskList[pTaskName] == nil then return end
    if MgrTask.TaskList[pTaskName].Mode == MgrTask.TaskMode.Serial then
        if #MgrTask.TaskList[pTaskName].List > 0 then
            MgrTask.TaskList[pTaskName].Per = MgrTask.TaskList[pTaskName].Per + MgrTask.TaskList[pTaskName].List[1].Weight
            local pass = os.clock() - MgrTask.TaskList[pTaskName].List[1].StartTime
            table.insert(MgrTask.TaskList[pTaskName].Cost, {Name = MgrTask.TaskList[pTaskName].List[1].Name, Cost = pass})
            table.remove(MgrTask.TaskList[pTaskName].List, 1)
        end
        local percent = MgrTask.TaskList[pTaskName].Per / MgrTask.TaskList[pTaskName].Total
        if MgrTask.TaskList[pTaskName].OnUpdate then
            MgrTask.TaskList[pTaskName].OnUpdate(percent)
        end
    else
        MgrTask.TaskList[pTaskName].Per = MgrTask.TaskList[pTaskName].Per + pTaskItem.Weight
        for i,v in ipairs(MgrTask.TaskList[pTaskName].List) do
            if v.Id == pTaskItem.Id then
                table.remove(MgrTask.TaskList[pTaskName].List, i)
            end
        end
        local percent = MgrTask.TaskList[pTaskName].Per / MgrTask.TaskList[pTaskName].Total
        if MgrTask.TaskList[pTaskName].OnUpdate then
            MgrTask.TaskList[pTaskName].OnUpdate(percent)
        end
    end
end


