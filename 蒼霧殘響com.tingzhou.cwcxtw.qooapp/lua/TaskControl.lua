require("Model/Task/Data/DayTaskData")
require("Model/Task/Data/IntegralTaskData")
require("Model/Task/Data/ActiveTaskData")
require("Model/Task/Data/AchievementTaskData")
require("Model/Task/Data/NoviceActivityStageData")
require("LocalData/DaytaskLocalData")
require("LocalData/Daytask_rewardLocalData")
require("LocalData/ActiveLocalData")
require("LocalData/RecruitactivityLocalData")
require("LocalData/TacticsguideactivityLocalData")
---物品管理器
TaskControl = {}

TaskControl.UpdatePanel = nil

TaskControl.AckError = false
---新手任务活动信息
local noviceTaskInfo = nil
---@type AchievementTaskData[]  新手任务
TaskControl.NoviceDataList = {}
---@type NoviceActivityStageData[]  新手阶段
local noviceStage = nil

---@type AchievementTaskData[]  引导任务
TaskControl.GuideDataList = {}
---@type AchievementTaskData[]  剧情活动任务
TaskControl.EventRaidDataList = {}
---@type AchievementTaskData[]  成就任务
TaskControl.AchievementDataList = {}
---成就任务数量
TaskControl.maxAchievement = 0
---已完成成就任务数量
TaskControl.completeAchievement = 0
---@type DayTaskData[]  每日通行证任务
TaskControl.ActivityDayTaskDataList = {}
---@type DayTaskData[]  每周通行证任务
TaskControl.ActivityWeekTaskDataList = {}
---@type DayTaskData[]  每日任务
TaskControl.DayTaskDataList = {}
---@type DayTaskData[]  每周任务
TaskControl.WeekTaskDataList = {}
---@type DayTaskData[]  每月任务
TaskControl.MonthTaskDataList = {}
---@type DayTaskData[]  剧情活动任务
TaskControl.EventRaidTaskDataList = {}
---@type IntegralTaskData[]  每日积分奖励任务
TaskControl.DayIntegralDataList = {}
---@type IntegralTaskData[]  每周积分奖励任务
TaskControl.WeekIntegralDataList = {}
---@type IntegralTaskData[]  每月积分奖励任务
TaskControl.MonthIntegralDataList = {}
---任务完成数据
TaskControl.CompleteTaskData = {}
---每日积分
TaskControl.dayScore = 0
---已领取的每日活跃度奖励
TaskControl.AchievedDayRewardList= {}
---每周积分
TaskControl.weekScore = 0
---已领取的每周活跃度奖励
TaskControl.AchievedWeekRewardList= {}
---每月积分
TaskControl.monthScore = 0
---已领取的每月活跃度奖励
TaskControl.AchievedMonthRewardList= {}
---已领取活跃度奖励
TaskControl.AchievedRewardData = {}
---每日统计数据
TaskControl.dayStatistics= {}
---每周统计数据
TaskControl.weekStatistics= {}
---每月统计数据
TaskControl.monthStatistics= {}
---成就统计数据
TaskControl.gloryStatistics= {}
---通行证每日统计数据
TaskControl.activityDayStatistics= {}
---通行证每周统计数据
TaskControl.activityWeekStatistics= {}
---剧情活动统计数据
TaskControl.EventRaidStatistics = {}
---日常任务类型枚举
TaskControl.DayTaskType = {
    DAILY = 1001,
    WEEKLY = 1002,
    MONTHLY = 1003,
    DAILY_SCORE = 1,
    WEEKLY_SCORE = 2,
    MONTHLY_SCORE = 3,
    EVENT_RAID = 51,
    ACTIVITY_DAILY = 61,
    ACTIVITY_WEEKLY = 62,
}
---成就任务类型
TaskControl.AchievementTaskType = {
    FIGHT = 1,
    COLLECTION = 2,
    SPEND = 3,
    GROW = 4,
    ACTIVITY_STORY = 5,
    PASSPORT = 6,
    NOVICE = 9,
    GUIDE = 10,
}
---成就系统类型
TaskControl.AchievementSystemType = {
    Achieve = 1,
    Passport = 2,
    YongZhanHuoDong = 5,
    Novice = 9,
    ZhanShuZhiDao = 10
}
---任务刷新计时
TaskControl.FreshTime = 0
---战术指导奖励领取状态（true为全部完成)
TaskControl.AllGuideRewardReceived = true
-------------提供接口-------------
---创建所有活动任务
--function TaskControl.CreateAllActivityTask()
--    for i, v in pairs(DaytaskLocalData.tab) do
--        if v[2] == TaskControl.DayTaskType.ACTIVITY_DAILY then
--            TaskControl.ActivityDayTaskDataList[i] = DayTaskData.New(i)
--        elseif v[2] == TaskControl.DayTaskType.ACTIVITY_WEEKLY then
--            TaskControl.ActivityWeekTaskDataList[i] = DayTaskData.New(i)
--        end
--    end
--end
---创建所有任务
function TaskControl.CreateAllTask(tab)
    for i, v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.DAILY then
            TaskControl.DayTaskDataList[i] = DayTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.WEEKLY then
            TaskControl.WeekTaskDataList[i] = DayTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.MONTHLY then
            TaskControl.MonthTaskDataList[i] = DayTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.EVENT_RAID then
            TaskControl.EventRaidTaskDataList[i] = DayTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.ACTIVITY_DAILY then
            TaskControl.ActivityDayTaskDataList[i] = DayTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.ACTIVITY_WEEKLY then
            TaskControl.ActivityWeekTaskDataList[i] = DayTaskData.New(i)
        end
    end
    ---日常积分
    for i, v in pairs(Daytask_rewardLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.DAILY_SCORE then
            TaskControl.DayIntegralDataList[i] = IntegralTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.WEEKLY_SCORE then
            TaskControl.WeekIntegralDataList[i] = IntegralTaskData.New(i)
        elseif v[2] == TaskControl.DayTaskType.MONTHLY_SCORE then
            TaskControl.MonthIntegralDataList[i] = IntegralTaskData.New(i)
        end
    end
    ---成就任务/新兵训练任务/剧情活动任务
    for i, v in pairs(ActiveLocalData.tab) do
        if v[2] == TaskControl.AchievementTaskType.NOVICE then              ---新兵训练任务提取
            TaskControl.NoviceDataList[i] = AchievementTaskData.New(i)
        --elseif v[2] == TaskControl.AchievementTaskType.ACTIVITY_STORY then  ---剧情活动任务提取
            --TaskControl.EventRaidDataList[i] = AchievementTaskData.New(i)
        elseif v[2] == TaskControl.AchievementTaskType.GUIDE then           ---战术指导任务
            TaskControl.GuideDataList[i] = AchievementTaskData.New(i)
        else                                                                ---成就任务提取/剧情活动任务提取
            TaskControl.AchievementDataList[i] = AchievementTaskData.New(i)
        end
    end
    ---新兵训练阶段
    noviceStage = {}
    for i, v in pairs(RecruitactivityLocalData.tab) do
        noviceStage[i] = NoviceActivityStageData.New(i)
    end
    ---每日每周每月 积分
    TaskControl.dayScore = tab.dayScore
    TaskControl.weekScore = tab.weekScore
    TaskControl.monthScore = tab.monthScore
    local isRecord = false
    if tab.day then
        for i, v in pairs(tab.day) do
            if v.statisticID >= 80000 then
                TaskControl.activityDayStatistics[v.statisticID]= v.statisticValue
            elseif v.statisticID >= 70000 then
                TaskControl.EventRaidStatistics[v.statisticID]= v.statisticValue
            else
                TaskControl.dayStatistics[v.statisticID]= v.statisticValue
                if v.statisticID == 11011 then
                    local tStr = string.format("EveryDayTask_%d", PlayerControl.GetPlayerData().UID)
                    UnityEngine.PlayerPrefs.SetInt(tStr,v.statisticValue)
                    isRecord = true
                end
            end
        end
    end
    if tab.week then
        for i, v in pairs(tab.week) do
            if v.statisticID >= 80000 then
                TaskControl.activityWeekStatistics[v.statisticID]= v.statisticValue --通行证数据统计
            else
                TaskControl.weekStatistics[v.statisticID]= v.statisticValue
            end
        end
    end
    if tab.month then
        for i, v in pairs(tab.month) do
            TaskControl.monthStatistics[v.statisticID]= v.statisticValue
        end
    end
    if tab.glory then
        for i, v in pairs(tab.glory) do
            TaskControl.gloryStatistics[v.statisticID]= v.statisticValue
        end
    end
    if tab.dayReward then
        for i, v in pairs(tab.dayReward) do
          --  TaskControl.AchievedDayRewardList[v]= v
            TaskControl.AchievedRewardData[v]= v
        end
    end
    if tab.weekReward then
        for i, v in pairs(tab.weekReward) do
          --  TaskControl.AchievedWeekRewardList[v]= v
            TaskControl.AchievedRewardData[v]= v
        end
    end
    if tab.monthReward then
        for i, v in pairs(tab.monthReward) do
           -- TaskControl.AchievedMonthRewardList[v]= v
            TaskControl.AchievedRewardData[v]= v
        end
    end
    if tab.task then
        for i, v in pairs(tab.task) do
            TaskControl.CompleteTaskData[v.taskID]= v.taskID    ---已完成的任务
        end
    end
    if not isRecord then
        local tStr = string.format("EveryDayTask_%d", PlayerControl.GetPlayerData().UID)
        UnityEngine.PlayerPrefs.SetInt(tStr, 0)
    end
end

function TaskControl.ClearAllTaskDataAndBuyTimes()
    ---刷新每日任务
    TaskControl.ClearDayTask()
    ---刷新活动每日任务
    TaskControl.ClearEventRaidDayTask()
    ---刷新通行证每日任务
    TaskControl.ClearPassportDayTask()
    ---刷新每周任务(包括通行证)
    local weekDay = os.date("!*t", Global.GetCurTime()).wday
    if weekDay == 1 then
        TaskControl.ClearWeekTask()
        TaskControl.ClearPassportWeekTask()
    end
    ---刷新每月任务
    local monthTime = ActivationTaskViewModel.GetLastTime("MONTH")  ---本月剩余秒数
    local monthDay = math.floor(monthTime/86400)
    if monthDay == Global.GetTotalDays() then
        TaskControl.ClearMonthTask()
        PlayerControl.GetPlayerData().monthSign = 0
        SignViewModel.SignData = PlayerControl.GetMonthSignData()
    end
    if TaskControl.UpdatePanel ~= nil then
        TaskControl.UpdatePanel()
    end
    ---PVP购买次数重置
    PlayerControl.BuyNumber = 0
    PlayerControl.BigPVPBuyNumber = 0
end

function TaskControl.RegisterClearTaskToC()
    local time = string.split(SteamLocalData.tab[112000][2],":")
    local totalSec = tonumber(time[1])*3600 + tonumber(time[2])*60 + tonumber(time[3])
    CMgrTimer.Instance:RegisterRefreshMissionFunc(totalSec,TaskControl.ClearAllTaskDataAndBuyTimes)
end
---清理每日任务
function TaskControl.ClearDayTask()
    --每日登录清零
    TaskControl.dayStatistics[11001] = 0
    --每日积分清0
    TaskControl.dayScore = 0
    --每日统计清0
    for i,v in pairs(TaskControl.dayStatistics) do
        TaskControl.dayStatistics[i] = 0
    end
    --每日积分任务未完成
    for i,v in pairs(TaskControl.DayIntegralDataList) do
        TaskControl.DayIntegralDataList[i].isComplete = 0
        TaskControl.DayIntegralDataList[i].isReceive = 0
    end
    --每日积分任务清理
    local dayReward = {}
    for i,v in pairs(Daytask_rewardLocalData.tab) do
        if v[2] == 1 then
            table.insert(dayReward,v)
        end
    end
    for i,v in pairs(dayReward) do
        if TaskControl.AchievedRewardData[v[1]] then
            TaskControl.AchievedRewardData[v[1]] = nil
        end
    end
    --清理已完成的每日任务
    for i,v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.DAILY then
            if TaskControl.CompleteTaskData[v[1]] then
                TaskControl.CompleteTaskData[v[1]] = nil
            end
        end
    end
end
---清理每周任务
function TaskControl.ClearWeekTask()
    --每周积分清0
    TaskControl.weekScore = 0
    --每周统计清0
    for i,v in pairs(TaskControl.weekStatistics) do
        TaskControl.weekStatistics[i] = 0
    end
    --每周积分任务未完成
    for i,v in pairs(TaskControl.WeekIntegralDataList) do
        TaskControl.WeekIntegralDataList[i].isComplete = 0
        TaskControl.WeekIntegralDataList[i].isReceive = 0
    end
    --每周积分任务清理
    local weekReward = {}
    for i,v in pairs(Daytask_rewardLocalData.tab) do
        if v[2] == 2 then
            table.insert(weekReward,v)
        end
    end
    for i,v in pairs(weekReward) do
        if TaskControl.AchievedRewardData[v[1]] then
            TaskControl.AchievedRewardData[v[1]] = nil
        end
    end
    --清理已完成的每周任务
    for i,v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.WEEKLY then
            if TaskControl.CompleteTaskData[v[1]] then
                TaskControl.CompleteTaskData[v[1]] = nil
            end
        end
    end
end
---清理每月任务
function TaskControl.ClearMonthTask()
    --每周积分清0
    TaskControl.monthScore = 0
    --每周统计清0
    for i,v in pairs(TaskControl.monthStatistics) do
        TaskControl.monthStatistics[i] = 0
    end
    --每月积分任务未完成
    for i,v in pairs(TaskControl.MonthIntegralDataList) do
        TaskControl.MonthIntegralDataList[i].isComplete = 0
        TaskControl.MonthIntegralDataList[i].isReceive = 0
    end
    --每月积分任务清理
    local monthReward = {}
    for i,v in pairs(Daytask_rewardLocalData.tab) do
        if v[2] == 3 then
            table.insert(monthReward,v)
        end
    end
    for i,v in pairs(monthReward) do
        if TaskControl.AchievedRewardData[v[1]] then
            TaskControl.AchievedRewardData[v[1]] = nil
        end
    end
    --清理已完成的每月任务
    for i,v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.MONTHLY then
            if TaskControl.CompleteTaskData[v[1]] then
                TaskControl.CompleteTaskData[v[1]] = nil
            end
        end
    end
end
---清理剧情活动每日任务
function TaskControl.ClearEventRaidDayTask()
    --每日统计清0
    for i,v in pairs(TaskControl.EventRaidStatistics) do
        TaskControl.EventRaidStatistics[i] = 0
    end
    --每日任务未完成
    for i,v in pairs(TaskControl.EventRaidTaskDataList) do
        TaskControl.EventRaidTaskDataList[i].isComplete = 0
        TaskControl.EventRaidTaskDataList[i].isReceive = 0
    end
    --清理已完成的每日任务
    for i,v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.EVENT_RAID then
            if TaskControl.CompleteTaskData[v[1]] then
                TaskControl.CompleteTaskData[v[1]] = nil
            end
        end
    end
end
---清理通行证每日任务
function TaskControl.ClearPassportDayTask()
    --每日统计清0
    for i,v in pairs(TaskControl.activityDayStatistics) do
        TaskControl.activityDayStatistics[i] = 0
    end
    --每日任务未完成
    for i,v in pairs(TaskControl.ActivityDayTaskDataList) do
        TaskControl.ActivityDayTaskDataList[i].isComplete = 0
        TaskControl.ActivityDayTaskDataList[i].isReceive = 0
    end
    --清理已完成的每日任务
    for i,v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.ACTIVITY_DAILY then
            if TaskControl.CompleteTaskData[v[1]] then
                TaskControl.CompleteTaskData[v[1]] = nil
            end
        end
    end
end
---清理通行证每周任务
function TaskControl.ClearPassportWeekTask()
    --每周统计清0
    for i,v in pairs(TaskControl.activityWeekStatistics) do
        TaskControl.activityWeekStatistics[i] = 0
    end
    --每日任务未完成
    for i,v in pairs(TaskControl.ActivityWeekTaskDataList) do
        TaskControl.ActivityWeekTaskDataList[i].isComplete = 0
        TaskControl.ActivityWeekTaskDataList[i].isReceive = 0
    end
    --清理已完成的每周任务
    for i,v in pairs(DaytaskLocalData.tab) do
        if v[2] == TaskControl.DayTaskType.ACTIVITY_WEEKLY then
            if TaskControl.CompleteTaskData[v[1]] then
                TaskControl.CompleteTaskData[v[1]] = nil
                --table.RemoveElementByKey(TaskControl.CompleteTaskData,v[1])
            end
        end
    end
end

function TaskControl.CheckPassesRewardReceived_RedDot()
    RedDotControl.GetDotData("ActivityTaskReward"):SetState(false)
    local receivedReward = PassportControl.GetReceivedReward()                          --以获取的奖励的列表
    --if receivedReward == nil then
    --    return false
    --end
    local passportlv = math.modf(PassportControl.GetPassportData().score / 1000)    --通行证等级
    if passportlv == 0 then
        return false
    end
    passportlv = (passportlv >= tonumber(SteamLocalData.tab[111008][2])) and tonumber(SteamLocalData.tab[111008][2]) or passportlv
    for i=1 ,passportlv do
        if receivedReward == nil or receivedReward[tostring(i)] == nil or (receivedReward[tostring(i)] == 0 and PassportViewModel.CheckSeniorLock()) then
            RedDotControl.GetDotData("ActivityTaskReward"):SetState(true)
            break
        end
    end
    return true
end

---检查红点
function TaskControl.CheckDotReceived()
    RedDotControl.GetDotData("DayIntegralTask"):SetState(false)
    RedDotControl.GetDotData("WeekIntegralTask"):SetState(false)
    RedDotControl.GetDotData("MonthIntegralTask"):SetState(false)
    RedDotControl.GetDotData("DayTask"):SetState(false)
    RedDotControl.GetDotData("WeekTask"):SetState(false)
    RedDotControl.GetDotData("MonthTask"):SetState(false)
    RedDotControl.GetDotData("AchieveTask"):SetState(false)
    RedDotControl.GetDotData("AchieveTask1"):SetState(false)
    RedDotControl.GetDotData("AchieveTask2"):SetState(false)
    RedDotControl.GetDotData("AchieveTask3"):SetState(false)
    RedDotControl.GetDotData("AchieveTask4"):SetState(false)
    RedDotControl.GetDotData("Passes"):SetState(false)
    RedDotControl.GetDotData("ActivityTask"):SetState(false)
    RedDotControl.GetDotData("ActivityDayTask"):SetState(false)
    RedDotControl.GetDotData("ActivityWeekTask"):SetState(false)
    RedDotControl.GetDotData("ActivityPhaseTask"):SetState(false)
    RedDotControl.GetDotData("NoviceTask"):SetState(false)
    --RedDotControl.GetDotData("EventRaidTask"):SetState(false)
    --RedDotControl.GetDotData("EventRaidTaskDaily"):SetState(false)
    --RedDotControl.GetDotData("EventRaidTaskTotal"):SetState(false)

    ---每日统计检查
    for i, v in pairs(TaskControl.DayTaskDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("DayTask"):SetState(true)
                    break
                end
            end
        end
    end
    ---每周统计检查
    for i, v in pairs(TaskControl.WeekTaskDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("WeekTask"):SetState(true)
                    break
                end
            end
        end
    end
    ---每月统计检查
    for i, v in pairs(TaskControl.MonthTaskDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("MonthTask"):SetState(true)
                    break
                end
            end
        end
    end
    ---不同类型成就检查
    local tCurLoopList = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.FIGHT,true)
    for k, v in pairs(tCurLoopList) do
        if not TaskControl.CheckComplete(v.id) then
            if TaskControl.CheckAchieveReceived(v) then
                RedDotControl.GetDotData("AchieveTask1"):SetState(true)     --战斗
                break
            end
        end
    end
    tCurLoopList = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.COLLECTION,true)
    for k, v in pairs(tCurLoopList) do
        if not TaskControl.CheckComplete(v.id) then
            if TaskControl.CheckAchieveReceived(v) then
                RedDotControl.GetDotData("AchieveTask2"):SetState(true)     --收集
                break
            end
        end
    end
    tCurLoopList = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.SPEND,true)
    for k, v in pairs(tCurLoopList) do
        if not TaskControl.CheckComplete(v.id) then
            if TaskControl.CheckAchieveReceived(v) then
                RedDotControl.GetDotData("AchieveTask3"):SetState(true)     --消费
                break
            end
        end
    end
    tCurLoopList = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.GROW,true)
    for k, v in pairs(tCurLoopList) do
        if not TaskControl.CheckComplete(v.id) then
            if TaskControl.CheckAchieveReceived(v) then
                RedDotControl.GetDotData("AchieveTask4"):SetState(true)     --养成
                break
            end
        end
    end
    ---每日积分检查
    for i, v in pairs(TaskControl.DayIntegralDataList) do
        if not TaskControl.AchievedRewardData[v.id] then
            if TaskControl.CheckCanReceive(1,v.id) then
                RedDotControl.GetDotData("DayIntegralTask"):SetState(true)
                break
            end
        end
    end
    ---每周积分检查
    for i, v in pairs(TaskControl.WeekIntegralDataList) do
        if not TaskControl.AchievedRewardData[v.id] then
            if TaskControl.CheckCanReceive(2,v.id) then
                RedDotControl.GetDotData("WeekIntegralTask"):SetState(true)
                break
            end
        end
    end
    ---每月积分检查
    for i, v in pairs(TaskControl.MonthIntegralDataList) do
        if not TaskControl.AchievedRewardData[v.id] then
            if TaskControl.CheckCanReceive(3,v.id) then
                RedDotControl.GetDotData("MonthIntegralTask"):SetState(true)
                break
            end
        end
    end
    ---每日通行证检查
    for i, v in pairs(TaskControl.ActivityDayTaskDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("ActivityDayTask"):SetState(true)
                    break
                end
            end
        end
    end
    ---每周通行证检查
    for i, v in pairs(TaskControl.ActivityWeekTaskDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("ActivityWeekTask"):SetState(true)
                    break
                end
            end
        end
    end
    ---通行证当期任务检查
    for i, v in pairs(TaskControl.AchievementDataList) do
        if v.type == TaskControl.AchievementTaskType.PASSPORT and v.activeId == TaskControl.AchievementSystemType.Passport then
            if TaskControl.CheckTaskLock(v) then
                if not TaskControl.CheckComplete(v.id) then
                    if TaskControl.CheckAchieveReceived(v) then
                        RedDotControl.GetDotData("ActivityPhaseTask"):SetState(true)
                        break
                    end
                end
            end
        end
    end
    ---新手任务检查
    TaskControl.CheckNoviceSign()
    TaskControl.GetGuideTask()
--[[    ---新手任务检查
    for i, v in pairs(TaskControl.NoviceDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("NoviceTask"):SetState(true)
                    break
                end
            end
        end
    end
    ---活动任务检查
    for i, v in pairs(TaskControl.EventRaidTaskDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("EventRaidTaskDaily"):SetState(true)
                    break
                end
            end
        end
    end
    ---活动成就任务检查
    for i, v in pairs(TaskControl.AchievementDataList) do
        if v.type == TaskControl.AchievementTaskType.ACTIVITY_STORY then
            if TaskControl.CheckTaskLock(v) then
                if not TaskControl.CheckComplete(v.id) then
                    if TaskControl.CheckAchieveReceived(v) then
                        RedDotControl.GetDotData("EventRaidTaskTotal"):SetState(true)
                        break
                    end
                end
            end
        end
    end]]
end
---获取活动任务
function TaskControl.GetEventRaidTaskData(_groupTaskID)
    if _groupTaskID == nil then
        _groupTaskID = 0
    end
    local array = {}
    for i, v in pairs(TaskControl.EventRaidTaskDataList) do
        if v.dayTaskID == _groupTaskID then
            table.insert(array,v)
        end
    end
    local t = {}
    for i, v in pairs(array) do
        if TaskControl.CheckComplete(v.id) then
            v.isComplete = 1
        else
            v.isComplete = 0
        end
        if TaskControl.CheckTaskReceived(v) then
            v.isReceive = 1
        else
            v.isReceive = 0
        end
        if v.isComplete == 0 then
            if TaskControl.CheckTaskLock(v) then
                table.insert(t,v)
            end
        else
            table.insert(t,v)
        end
    end
    return t
end
---获取日常任务/通行证任务
function TaskControl.GetDayTaskData(type)
    local array = {}
    local t = {}
    if type == TaskControl.DayTaskType.DAILY then
        array = TaskControl.DayTaskDataList
    elseif type == TaskControl.DayTaskType.WEEKLY then
        array = TaskControl.WeekTaskDataList
    elseif type == TaskControl.DayTaskType.MONTHLY then
        array = TaskControl.MonthTaskDataList
    elseif type == TaskControl.DayTaskType.ACTIVITY_DAILY then
        array = TaskControl.ActivityDayTaskDataList
    elseif type == TaskControl.DayTaskType.ACTIVITY_WEEKLY then
        array = TaskControl.ActivityWeekTaskDataList
    end
    for i, v in pairs(array) do
        if TaskControl.CheckComplete(v.id) then
            v.isComplete = 1
        else
            v.isComplete = 0
        end
        if TaskControl.CheckTaskReceived(v) then
            v.isReceive = 1
        else
            v.isReceive = 0
        end
        if v.isComplete == 0 then
            if TaskControl.CheckTaskLock(v) then
                if v.openCopy == 0 and TaskControl.GetInMiddle(v) then
                    table.insert(t,v)
                else
                    if StormControl.CheckPointPass(v.openCopy) and TaskControl.GetInMiddle(v) then
                        table.insert(t,v)
                    end
                end
            end
        else
            if v.openCopy == 0 and TaskControl.GetInMiddle(v) then
                table.insert(t,v)
            else
                if StormControl.CheckPointPass(v.openCopy) and TaskControl.GetInMiddle(v) then
                    table.insert(t,v)
                end
            end
        end
    end
    return t
end
---获取成就任务
function TaskControl.GetAchievementData(type)
    local t = {}
    TaskControl.completeAchievement = 0
    TaskControl.maxAchievement = 0
    for i, v in pairs(TaskControl.AchievementDataList) do
        if v.type == type or type == 0 then
            TaskControl.maxAchievement = TaskControl.maxAchievement + 1
            if TaskControl.CheckComplete(v.id) then
                v.isComplete = 1
            else
                v.isComplete = 0
            end
            if TaskControl.CheckAchieveReceived(v) then
                v.isReceive = 1
            else
                v.isReceive = 0
            end
            if v.isComplete == 0 then
                if TaskControl.CheckTaskLock(v) then
                    table.insert(t,v)
                end
            else
                TaskControl.completeAchievement = TaskControl.completeAchievement + 1
                table.insert(t,v)
            end
        end
    end
    return t
end
---检查任务是否解锁
---@param data DayTaskData
function TaskControl.CheckTaskLock(data)
    if PlayerControl.GetPlayerData().level >= data.frontLevel then
        if data.frontTaskId ~= "0" then
            if TaskControl.CheckComplete(tonumber(data.frontTaskId)) then
                return true
            else
                return false
            end
        else
            return true
        end
    else
        return false
    end
end
---获取日常积分任务
function TaskControl.GetIntegralTaskData(type)
    local array = {}
    local t = {}
    if type == TaskControl.DayTaskType.DAILY_SCORE then
        t = TaskControl.DayIntegralDataList
    elseif type == TaskControl.DayTaskType.WEEKLY_SCORE then
        t = TaskControl.WeekIntegralDataList
    elseif type == TaskControl.DayTaskType.MONTHLY_SCORE then
        t = TaskControl.MonthIntegralDataList
    end
    for i, v in pairs(t) do
        if TaskControl.CheckReceived(v.id) then
            v.isComplete = 1
        end
        if TaskControl.CheckCanReceive(type,v.id) then
            v.isReceive = 1
        else
            v.isReceive = 0
        end
        table.insert(array,v)
    end
    return array
end
---检查任务是否已完成
function TaskControl.CheckComplete(id)
    if TaskControl.CompleteTaskData[id] then
        return true
    else
        return false
    end
end
---检查每日任务是否可领取
function TaskControl.CheckTaskReceived(taskData)
    if taskData.isComplete == 1 then    --已领取
        return false
    end
    local progressStr = JNStrTool.strSplit("_",taskData.complete)

    local value = ActivationTaskViewModel.GetStatisticValue(taskData.type,tonumber(progressStr[1]))
    if value >= tonumber(progressStr[3]) then
        return true
    else
        return false
    end
end
---检查成就是否可领取
function TaskControl.CheckAchieveReceived(taskData)
    ---完成进度
    local progressStr = JNStrTool.strSplit("_",taskData.complete)
    local value = AchievementViewModel.GetStatisticValue(tonumber(progressStr[1]))
    local complete = string.split(taskData.complete,"_")
    if complete[2] == ">=" then
        if taskData.isComplete == 1 then
            return false
        end
        if value >= tonumber(progressStr[3]) then
            return true
        else
            return false
        end
    else
        if value == 0 then
            return false
        end
        if value <= tonumber(progressStr[3]) then
            return true
        else
            return false
        end
    end
end
---检查活跃度奖励是否已领取
function TaskControl.CheckReceived(id)
    if TaskControl.AchievedRewardData[id] then
        return true
    else
        return false
    end
end
---检查活跃度奖励是否可领取
function TaskControl.CheckCanReceive(type,id)
    local canReceive = false
    if type == TaskControl.DayTaskType.DAILY_SCORE then
        canReceive = TaskControl.DayIntegralDataList[id].num <= TaskControl.dayScore
    elseif type == TaskControl.DayTaskType.WEEKLY_SCORE then
        canReceive = TaskControl.WeekIntegralDataList[id].num <= TaskControl.weekScore
    elseif type == TaskControl.DayTaskType.MONTHLY_SCORE then
        canReceive = TaskControl.MonthIntegralDataList[id].num <= TaskControl.monthScore
    end
    return canReceive
end
---获取任务数据返回
function TaskControl.GetTaskDataACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientTaskGetACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("taskcontrol_tips1"),2},true)
    end
end
function TaskControl.GetTaskDataNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientTaskGetNTF',buffer))
    ---任务完成数据
    TaskControl.CompleteTaskData = {}
    ---每日统计数据
    TaskControl.dayStatistics= {}
    ---每周统计数据
    TaskControl.weekStatistics= {}
    ---每月统计数据
    TaskControl.monthStatistics= {}
    ---已领取的每日活跃度奖励
    TaskControl.AchievedDayRewardList= {}
    ---已领取的每周活跃度奖励
    TaskControl.AchievedWeekRewardList= {}
    ---已领取的每月活跃度奖励
    TaskControl.AchievedMonthRewardList= {}
    ---已领取活跃度奖励
    TaskControl.AchievedRewardData = {}
    if tab.dayScore then
        TaskControl.dayScore = tab.dayScore
    end
    if tab.weekScore then
        TaskControl.weekScore = tab.weekScore
    end
    if tab.monthScore then
        TaskControl.monthScore = tab.monthScore
    end

    if tab.day then
        for i, v in pairs(tab.day) do
            TaskControl.dayStatistics[v.statisticID] = v.statisticValue
        end
    end
    if tab.week then
        for i, v in pairs(tab.week) do
            TaskControl.weekStatistics[v.statisticID] = v.statisticValue
        end
    end
    if tab.month then
        for i, v in pairs(tab.month) do
            TaskControl.monthStatistics[v.statisticID]= v.statisticValue
        end
    end
    if tab.dayReward then
        for i, v in pairs(tab.dayReward) do
            --  TaskControl.AchievedDayRewardList[v]= v
            TaskControl.AchievedRewardData[v]= v
        end
    end
    if tab.weekReward then
        for i, v in pairs(tab.weekReward) do
            --  TaskControl.AchievedWeekRewardList[v]= v
            TaskControl.AchievedRewardData[v]= v
        end
    end
    if tab.monthReward then
        for i, v in pairs(tab.monthReward) do
            -- TaskControl.AchievedMonthRewardList[v]= v
            TaskControl.AchievedRewardData[v]= v
        end
    end
    if tab.task then
        for i, v in pairs(tab.task) do
            TaskControl.CompleteTaskData[v.taskID]=  v.taskID
        end
    end
    if ActivationTaskViewModel.ReceivedCallBack then
        ActivationTaskViewModel.ReceivedCallBack()
    end
    if PassportViewModel.ReceivedCallBack then
        PassportViewModel.ReceivedCallBack()
    end
    if AchievementViewModel.ReceivedCallBack then
        AchievementViewModel.ReceivedCallBack()
    end
    if NoviceControl.UpdateNoviceActivityUI then
        NoviceControl.UpdateNoviceActivityUI()
    end
    if TaskControl.UpdatePanel then
        TaskControl.UpdatePanel()
    end
end
---重载任务数据
function TaskControl.GetTaskData()
    local BaseREQ  =
    {
        index = "1"
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientTaskGetREQ',BaseREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_TASK_GET_REQ,bytes,0,nil, TaskControl.GetTaskDataACK,TaskControl.GetTaskDataNTF)
end
---统计数据变化
function TaskControl.ChangeStatistics(day,week,month,glory)

    if day then
        for i, v in pairs(day) do
            if v.statisticID >= 80000 then
                if TaskControl.activityDayStatistics[v.statisticID] then
                    TaskControl.activityDayStatistics[v.statisticID] = TaskControl.activityDayStatistics[v.statisticID] + v.statisticValue
                else
                    TaskControl.activityDayStatistics[v.statisticID] = v.statisticValue
                end
            elseif v.statisticID >= 70000 then
                if TaskControl.EventRaidStatistics[v.statisticID] then
                    TaskControl.EventRaidStatistics[v.statisticID] = TaskControl.EventRaidStatistics[v.statisticID] + v.statisticValue
                else
                    TaskControl.EventRaidStatistics[v.statisticID]= v.statisticValue
                end
            else
                if TaskControl.dayStatistics[v.statisticID] then
                    TaskControl.dayStatistics[v.statisticID] = TaskControl.dayStatistics[v.statisticID] + v.statisticValue
                else
                    TaskControl.dayStatistics[v.statisticID] = v.statisticValue
                end
            end
        end
    end
    if week then
        for i, v in pairs(week) do
            if v.statisticID >= 80000 then
                if TaskControl.activityWeekStatistics[v.statisticID] then
                    TaskControl.activityWeekStatistics[v.statisticID] =TaskControl.activityWeekStatistics[v.statisticID] + v.statisticValue
                else
                    TaskControl.activityWeekStatistics[v.statisticID] = v.statisticValue
                end

            elseif v.statisticID >= 70000 then
                if TaskControl.EventRaidStatistics[v.statisticID] then
                    TaskControl.EventRaidStatistics[v.statisticID] =TaskControl.EventRaidStatistics[v.statisticID] + v.statisticValue
                else
                    TaskControl.EventRaidStatistics[v.statisticID] = v.statisticValue
                end
            else
                if TaskControl.weekStatistics[v.statisticID] then
                    TaskControl.weekStatistics[v.statisticID] =TaskControl.weekStatistics[v.statisticID] + v.statisticValue
                else
                    TaskControl.weekStatistics[v.statisticID] = v.statisticValue
                end
            end

        end
    end
    if month then
        for i, v in pairs(month) do
            if TaskControl.monthStatistics[v.statisticID] then
                TaskControl.monthStatistics[v.statisticID] =TaskControl.monthStatistics[v.statisticID] + v.statisticValue
            else
                TaskControl.monthStatistics[v.statisticID] = v.statisticValue
            end
        end
    end
    if glory then
        for i, v in pairs(glory) do
            if TaskControl.gloryStatistics[v.statisticID] then
                TaskControl.gloryStatistics[v.statisticID] =TaskControl.gloryStatistics[v.statisticID] + v.statisticValue
            else
                TaskControl.gloryStatistics[v.statisticID] = v.statisticValue
            end
        end
    end
    TaskControl.CheckDotReceived()
    ---检查体力,是否要跳联合讨伐提示
    EventRaidControl.LHTFPopCheck(day)
end

---查询联合讨伐体力消耗
function TaskControl.CheckLHTFVigor()
    if TaskControl.dayStatistics[tonumber(SteamLocalData.tab[109004][2])] ~= nil then
        local times = math.floor(TaskControl.dayStatistics[tonumber(SteamLocalData.tab[109004][2])] / 100)
        local limit = tonumber(SteamLocalData.tab[109000][2])
        return  times > limit and limit or times
    else
        return 0
    end
end

---今日体力消耗
function TaskControl.CheckTodayVigorExpend()
    local num = TaskControl.dayStatistics[tonumber(SteamLocalData.tab[109004][2])]
    if num == nil then
        return 0
    end
    return num
end

------------------------------新手活动任务----------------------------------
---设置新手活动数据
function TaskControl.SetNoviceData()
    noviceTaskInfo = ActivityControl.GetActivityInfo(ActivityControl.activityTypeEnum.NOVICE_TRAIN)
end

---获取新手活动信息
function TaskControl.GetNoviceData()
    return noviceTaskInfo
end
---获得新手活动已领取奖励
function TaskControl.GetReceivedReward()
    local tab = {}
    if noviceTaskInfo ~= nil and noviceTaskInfo.reward then
        tab = RapidJson.decode(noviceTaskInfo.reward)
    end
    return tab
end
---检查新手任务完成到第几阶段
function TaskControl.NoviceStage()
    --判断奖励领了多少个
    local receivedReward = TaskControl.GetReceivedReward()
    if receivedReward then
        local length = 1
        for i,v in pairs(receivedReward) do
            if v == 0 then
                length = length + 1
            end
        end
        return length
    else
        return 1
    end

end
---获得新手任务阶段
function TaskControl.GetNoviceActivityStageInfo(stageNum)
    for i,v in pairs(noviceStage) do
        if v.id == stageNum then
            return v
        end
    end
    return nil
end
---获取新手任务奖励
function TaskControl.AcceptReward(taskID,parent)
    local noviceRewardReq  =
    {
        taskType = 0,
        taskID = taskID,
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientTaskPerformREQ',noviceRewardReq))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_TASK_PERFORM_REQ,bytes,0,nil,TaskControl.RewardSendACK,function(...)
        TaskControl.RewardSendNTF(...,parent)
    end)
end
function TaskControl.RewardSendACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        ItemControl.AckError = true
        if tab.errNo == 2003 then
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips1"),2},true)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips2"),2},true)
        end
    end
end
---一键领取所有奖励
function TaskControl.RewardSendNTF(buffer,tag,parent)
    ---解析活动奖励
    local tab = assert(pb.decode('PBClient.ClientTaskPerformNTF',buffer))
    if tab.medal then
        ItemControl.PushGroupItemData(tab.medal,ItemControl.PushEnum.add)
    end
    for i, v in pairs(tab.taskID) do        ---记录完成的任务数据
        TaskControl.CompleteTaskData[v] = v
    end
    ---统计分数
    if tab.dayScore then
        TaskControl.dayScore = tab.dayScore
    end
    if tab.weekScore then
        TaskControl.weekScore = tab.weekScore
    end
    if tab.monthScore then
        TaskControl.monthScore = tab.monthScore
    end
    TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
    if tab.reward then
        ---将奖励推送进背包
        ItemControl.PushGroupItemData(tab.reward,ItemControl.PushEnum.add)
        ---弹出奖励弹窗
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.reward},true)
    end
    ---刷新背包缓存数据
    BagViewModel.ReloadCacheData()
    ---更新新手活动已领取的奖励
    TaskControl.RefreshReceivedReward(tab.reward)
    ---刷新界面
    parent:InitUI()
end
---更新已领取的奖励
function TaskControl.RefreshReceivedReward(reward)
    noviceTaskInfo.reward = reward
end
---获得当阶段的新手奖励
function TaskControl.GetNoviceReward(parentUI,taskID)
    local noviceRewardReq = {
        activityId = TaskControl.GetNoviceData().activityId,
        rewardId = taskID,
        rewardType = 0,
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientActivityGetRewardREQ',noviceRewardReq))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_ACTIVITY_GET_REWARD_REQ,bytes,0,nil,TaskControl.NoviceRewardACK,function(...)
        TaskControl.NoviceRewardNTF(...)
        parentUI:InitUI()
    end)
end
function TaskControl.NoviceRewardACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        ItemControl.AckError = true
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips2")..tab.errNo,2},true)
    end
end
function TaskControl.NoviceRewardNTF(buffer,tag,parentUI)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardNTF',buffer))
    if tab.reward ~= "{}" then
        TaskControl.RefreshReceivedReward(tab.reward)
    end
    if tab.goods then
        ---添加任务奖励
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
        ---弹出奖励窗口
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
    end
end
---新手小任务奖励
function TaskControl.GetNoviceItemReward(data,parentUI)
    local req = {
        taskType = 0,
        taskID = data.id
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientTaskPerformREQ',req))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_TASK_PERFORM_REQ,bytes,0,nil,TaskControl.GetNoviceItemRewardACK,
            function(...)
                TaskControl.GetNoviceItemRewardNTF(...)
                parentUI:InitUI()
            end)
end
function TaskControl.GetNoviceItemRewardACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientTaskPerformACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        TaskControl.AckError = true
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips2") .. tab.errNo,2},true)
        if tab.errNo == 560 then
            TaskControl.GetTaskData()
        end
    end
end
function TaskControl.GetNoviceItemRewardNTF(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientTaskPerformNTF',buffer))
    ---推送奖励进入背包
    if tab.reward then
        ItemControl.PushGroupItemData(tab.reward,ItemControl.PushEnum.add)
        ---弹出奖励窗口
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.reward},true)
    end
    ---推送勋章
    if tab.medal then
        ItemControl.PushGroupItemData(tab.medal,ItemControl.PushEnum.add)
    end
    if tab.taskID then
        for i, v in pairs(tab.taskID) do
            TaskControl.CompleteTaskData[v]=  v
        end
    end
    ---统计数据变化
    TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
    ---活动分数变化
    ActivityControl.SetActivityInfo(noviceTaskInfo.activityId,tab)

    Event.Go("RefreshCoinCount")
end

---检查新手红点
function TaskControl.CheckNoviceSign()
    ---新手任务第几阶段
    local stageNumber = TaskControl.NoviceStage()
    if TaskControl.NoviceStage() > #RecruitactivityLocalData.tab or not SysLockControl.CheckSysLock(1802) then
        RedDotControl.GetDotData("NoviceTask"):SetState(false)
        return
    end
    local taskGroupID = TaskControl.GetNoviceActivityStageInfo(stageNumber).taskId
    --现阶段9个任务
    ---@type AchievementTaskData[]  本阶段所有新手任务
    local isReward = true
    for i, v in pairs(TaskControl.NoviceDataList) do
        if taskGroupID == v.taskGroupID and TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                isReward = false
            end
        end
    end

    for i, v in pairs(TaskControl.NoviceDataList) do
        if taskGroupID == v.taskGroupID and TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("NoviceTask"):SetState(true)
                    break
                end
            end
        end
    end

    if RedDotControl.GetDotData("NoviceTask").State == false and isReward then
        RedDotControl.GetDotData("NoviceTask"):SetState(true)
    end
    Event.Go("ActivityDot")
end

function TaskControl.CheckWarmUp()

end

---检查战术指导红点
function TaskControl.CheckGuide()
    RedDotControl.GetDotData("TacticalGuidance"):SetState(false)
    for k,v in pairs(TaskControl.GuideDataList) do
        if TaskControl.CheckTaskLock(v) then
            if not TaskControl.CheckComplete(v.id) then
                if TaskControl.CheckTaskReceived(v) then
                    RedDotControl.GetDotData("TacticalGuidance"):SetState(true)
                    break
                end
            end
        end
    end

    local ActivityReward = RapidJson.decode(ActivityControl.GetActivityInfo(994).reward)

    for i = 1, #TacticsguideactivityLocalData.tab do
        local needItemStr = string.split(TacticsguideactivityLocalData.tab[i][7],"_")
        local needItem = ItemControl.GetItemByIdAndType(tonumber(needItemStr[2]),tonumber(needItemStr[1]))

        local rewardData = nil
        if ActivityReward == nil then
            rewardData = nil
        else
            rewardData = ActivityReward[tostring(i)]
        end

        if needItem.count >= tonumber(needItemStr[3])  and rewardData == nil then
            RedDotControl.GetDotData("TacticalGuidance"):SetState(true)
        end
        ---奖励领取状态
        if (rewardData and rewardData ~= 0) or rewardData == nil then
            TaskControl.AllGuideRewardReceived = false
        end
    end

    if SysLockControl.CheckSysLock(1109) == false then
        RedDotControl.GetDotData("TacticalGuidance"):SetState(false)
    end
end

function TaskControl.GetGuideTask()
    local arr = {}
    for k,v in pairs(TaskControl.GuideDataList) do
        if TaskControl.CheckComplete(v.id) then
            v.isComplete = 1
        else
            v.isComplete = 0
        end
        if TaskControl.CheckAchieveReceived(v) then
            v.isReceive = 1
        else
            v.isReceive = 0
        end
        table.insert(arr,v)
    end
    Global.Sort(arr,{"id"},false)
    return arr
end

---获取战术指导任务是否全部完成
function TaskControl.WhetherGuideTaskReceived()
    local count = 0
    local totalCount = 0
    for k,v in pairs(TaskControl.GuideDataList) do
        totalCount = totalCount + 1
        if v.isComplete == 1 then
            count = count + 1
        end
    end
    local rewardCount = 0
    local totalRewardCount = 0
    for k,v in pairs(TacticsguideactivityLocalData.tab) do
        totalRewardCount = totalRewardCount + 1
        local needItem = ItemControl.GetItemByIdAndType(tonumber(string.split(v[7],"_")[2]),tonumber(string.split(v[7],"_")[1]))
        if needItem.count >= tonumber(string.split(v[7],"_")[3]) then
            rewardCount = rewardCount + 1
        end
    end

    return count == totalCount and rewardCount == totalRewardCount
end

---获取任务是否在开启时间内
---@param task DayTaskData
function TaskControl.GetInMiddle(task)
    if task.openTime == 0 then
        return true
    end
    return Global.CheckOnTime(TimeLocalData.tab[task.openTime])
end

function TaskControl.Clear()
    ---新手任务活动信息
    noviceTaskInfo = nil
    ---@type AchievementTaskData[]  新手任务
    TaskControl.NoviceDataList = {}
    ---@type NoviceActivityStageData[]  新手阶段
    noviceStage = nil

    TaskControl.GuideDataList = {}
    ---@type AchievementTaskData[]  剧情活动任务
    TaskControl.EventRaidDataList = {}
    ---@type AchievementTaskData[]  成就任务
    TaskControl.AchievementDataList = {}
    ---成就任务数量
    TaskControl.maxAchievement = 0
    ---已完成成就任务数量
    TaskControl.completeAchievement = 0
    ---@type DayTaskData[]  每日通行证任务
    TaskControl.ActivityDayTaskDataList = {}
    ---@type DayTaskData[]  每周通行证任务
    TaskControl.ActivityWeekTaskDataList = {}
    ---@type DayTaskData[]  每日任务
    TaskControl.DayTaskDataList = {}
    ---@type DayTaskData[]  每周任务
    TaskControl.WeekTaskDataList = {}
    ---@type DayTaskData[]  每月任务
    TaskControl.MonthTaskDataList = {}
    ---@type DayTaskData[]  剧情活动任务
    TaskControl.EventRaidTaskDataList = {}
    ---@type IntegralTaskData[]  每日积分奖励任务
    TaskControl.DayIntegralDataList = {}
    ---@type IntegralTaskData[]  每周积分奖励任务
    TaskControl.WeekIntegralDataList = {}
    ---@type IntegralTaskData[]  每月积分奖励任务
    TaskControl.MonthIntegralDataList = {}
    ---任务完成数据
    TaskControl.CompleteTaskData = {}
    ---每日积分
    TaskControl.dayScore = 0
    ---已领取的每日活跃度奖励
    TaskControl.AchievedDayRewardList= {}
    ---每周积分
    TaskControl.weekScore = 0
    ---已领取的每周活跃度奖励
    TaskControl.AchievedWeekRewardList= {}
    ---每月积分
    TaskControl.monthScore = 0
    ---已领取的每月活跃度奖励
    TaskControl.AchievedMonthRewardList= {}
    ---已领取活跃度奖励
    TaskControl.AchievedRewardData = {}
    ---每日统计数据
    TaskControl.dayStatistics= {}
    ---每周统计数据
    TaskControl.weekStatistics= {}
    ---每月统计数据
    TaskControl.monthStatistics= {}
    ---成就统计数据
    TaskControl.gloryStatistics= {}
    ---通行证每日统计数据
    TaskControl.activityDayStatistics= {}
    ---通行证每周统计数据
    TaskControl.activityWeekStatistics= {}
    ---剧情活动统计数据
    TaskControl.EventRaidStatistics = {}
    ---指导任务是否全部完成
    TaskControl.AllGuideRewardReceived = true
end

return TaskControl