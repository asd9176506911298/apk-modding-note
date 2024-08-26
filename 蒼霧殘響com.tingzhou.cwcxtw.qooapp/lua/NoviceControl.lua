require("LocalData/TutorialLocalData")
require("Model/Novice/Data/NoviceData")
NoviceControl = {}

---@type NoviceData[] 引导节点缓存
local CacheNoviceList = {}
---@type NoviceData[] 新手战斗节点缓存
local CacheBattleList = {}
---当前ID
local CurID = nil
---新手战斗开始
NoviceControl.battleStart = false

---读取配置表加载并创建所有的引导数据逻辑
function NoviceControl.Init()
    CurID = nil
    NoviceControl.localValue = ""
    for k,v in pairs(TutorialLocalData.tab) do
        CacheNoviceList[v[1]] = NoviceData.New(k)
    end
end

---判断目标引导组是否全完成
function NoviceControl.GroupsIsTrigger(groupNum)
    local d_count = 0
    local triggerNum = 0
    for _, data in pairs(CacheNoviceList) do
        if data.group == groupNum then
            d_count = d_count + 1
            if data.isTrigger == true then
                triggerNum = triggerNum + 1
            end
        end
    end
    return triggerNum >= d_count
end

function NoviceControl.GroupsIsDone(groupNum)
    local d_count = 0
    local num = 0
    for _, data in pairs(CacheNoviceList) do
        if data.group == groupNum then
            d_count = d_count + 1
            if data.isDone == true then
                num = num + 1
            end
        end
    end
    return num >= d_count
end

---通过推送更新所有引导数据状态逻辑
function NoviceControl.PushNoviceData(tutorial)
    --UnityEngine.PlayerPrefs.DeleteKey("Novice"..PlayerControl.GetPlayerData().UID)
	--临时跳过新手
    --UnityEngine.PlayerPrefs.SetString("Novice"..PlayerControl.GetPlayerData().UID,"50002,50135,50201,50331,50401,50540,50601,50712,50818,50901,51001,51101,51208")

    ---如果服务器没有记录
    if tutorial == nil then
        ---从第一步指导id
        CurID = 50001
    else
        ---推送功能引导
        for k,v in pairs(tutorial) do
            for id,data in pairs(CacheNoviceList) do
                if TutorialLocalData.tab[v] then
                    if data.group == TutorialLocalData.tab[v][2] then
                        data.isTrigger = true
                        data.isDone = true
                    end
                end
            end
        end
    end
    ---从本地推送功能引导
    if UnityEngine.PlayerPrefs.HasKey("Novice"..PlayerControl.GetPlayerData().UID) then
        local value =  UnityEngine.PlayerPrefs.GetString("Novice"..PlayerControl.GetPlayerData().UID)
        print("value "..value)
        local str = string.split(value,",")
        NoviceControl.localValue = value == nil and "" or value
        for k,v in pairs(str) do
            for id,data in pairs(CacheNoviceList) do
                if v ~= "" and TutorialLocalData.tab[tonumber(v)] then
                    if data.group == TutorialLocalData.tab[tonumber(v)][2] then
                        data.isTrigger = true
                        data.isDone = true
                    end
                end
            end
        end
    end
    NoviceControl.JumpNoviceGuide()
    NoviceControl.GetCurNovice()
end

---改变单个数据的完成状态
function NoviceControl.PushSingleData(id,state,callBack)
    if id == nil then
        return
    end
    if CacheNoviceList[id] ~= nil then
        CacheNoviceList[id].isDone = state
        UnityEngine.DebugEx.Log("当前ID"..id.."状态为"..tostring(state))
    end
    ---如果指导类型是战术引导
    if CacheNoviceList[id].type == 5 then
    ---如果类型是新手战斗
    elseif CacheNoviceList[id].type == 7 then
        if CacheNoviceList[id].endSign == 3 and state == true and CacheNoviceList[id].isTrigger == false then
            UnityEngine.PlayerPrefs.SetString("Novice"..PlayerControl.GetPlayerData().UID,NoviceControl.localValue..tostring(id)..",")
            NoviceControl.localValue = UnityEngine.PlayerPrefs.GetString("Novice"..PlayerControl.GetPlayerData().UID)
            NoviceViewModel.Noviceing = false
            if callBack then
                callBack()
            end
        end
    elseif CacheNoviceList[id].type == 8 then
        ---如果指导类型是教学关 不做处理
    else
        ---如果是组中最后一个任务就保存进度
        if CacheNoviceList[id].endSign == 1 and state == true and CacheNoviceList[id].isTrigger == false then
            MgrUI.Lock("Novice_LastStep")
            NoviceControl.PushNoviceData({id})
            NoviceControl.ChangeCurNovice(id,callBack)
            NoviceViewModel.Noviceing = false
        elseif CacheNoviceList[id].endSign == 2 and state == true then
            MgrUI.Lock("Novice_LastStep")
            ---如果是2就上报服务器但是不标记为已完成
            NoviceControl.ChangeCurNovice(id,callBack)
        elseif CacheNoviceList[id].endSign == 0 and state == true then
            if callBack then
                callBack()
            end
        end
    end
    if CacheNoviceList[id].EndGroupId ~= "0" and CacheNoviceList[id].EndGroupId ~= nil then
        local str = string.split(CacheNoviceList[id].EndGroupId,",")
        for k,v in pairs(str) do
            if v ~= "," then
                if CacheNoviceList[id].type == 7 then
                    UnityEngine.PlayerPrefs.SetString("Novice"..PlayerControl.GetPlayerData().UID,NoviceControl.localValue..v..",")
                    NoviceControl.localValue = UnityEngine.PlayerPrefs.GetString("Novice"..PlayerControl.GetPlayerData().UID)
                    CacheNoviceList[tonumber(v)].isDone = true
                    UnityEngine.DebugEx.Log("引导ID"..v.."也被记录完成")
                end
            end
        end
    end
end

---批量更改引导状态
function NoviceControl.PushGroupStateByGroupID(groupId,state)
    for _, data in pairs(CacheNoviceList) do
        if data.group == groupId then
            data.isDone = state
        end
    end
end

function NoviceControl.JumpNoviceGuide()
    if NoviceControl.GroupsIsTrigger(tonumber(SteamLocalData.tab[120001][2])) then
        local arr = SteamLocalData.tab[120002][2]
        local str = string.split(arr,",")
        for k,v in pairs(str) do
            if v ~= "," then
                if CacheNoviceList[tonumber(v)].isTrigger == false then
                    UnityEngine.PlayerPrefs.SetString("Novice"..PlayerControl.GetPlayerData().UID,NoviceControl.localValue..v..",")
                    NoviceControl.localValue = UnityEngine.PlayerPrefs.GetString("Novice"..PlayerControl.GetPlayerData().UID)
                    for id,data in pairs(CacheNoviceList) do
                        if data.group == TutorialLocalData.tab[tonumber(v)][2] then
                            data.isTrigger = true
                            data.isDone = true
                        end
                    end
                end
            end
        end
    end
end

---清理要重打引导的状态
function NoviceControl.ClearNoviceState(id)
    local curData = NoviceControl.GetNoviceDataByID(id)
    local nextId = nil
    for k,v in pairs(CacheNoviceList) do
        if v.group == curData.group then
            v.isDone = false
            --if v.nextId ~= 0 and v.nextId ~= -1 then
            --    nextId = v.nextId
            --end
        end
    end

    --local groupId = NoviceControl.GetNoviceDataByID(nextId).group
    --for k,v in pairs(CacheNoviceList) do
    --    if v.group == curData.group or v.group == groupId then
    --        v.isDone = false
    --    end
    --end
end

---检查新手引导是否完成
function NoviceControl.CheckGuideFinish()
    return NoviceControl.GroupsIsTrigger(tonumber(SteamLocalData.tab[120001][2]))
end

---新手引导
function NoviceControl.GoGuide()
    ---引导最后一步未完成
    if NoviceControl.GroupsIsTrigger(131) and not NoviceControl.GroupsIsTrigger(132) then
        ---打开大厅UI
        MgrUI.GoFirst(UID.Home_UI,function()
            ---在主界面完成引导
            NoviceViewModel.Check(51201)
        end)
    else
        ---加载选关界面
        StormViewModel.ReloadStormData()
        StormViewModel.OpenStormPointUI(StormControl.GetStormScrollById(999999),StormViewModel.PointType.main)
        ---新手第一关是否完成
        if NoviceControl.GetNoviceState(tonumber(SteamLocalData.tab[120004][2])) then
            ---进度到取名但取名未完成
            if NoviceControl.GetNoviceState(50901) and NoviceControl.GetNoviceState(51001) == false then
                MgrUI.GetCurUI().ObjRoot:SetActive(false)
                ---去取名
                NoviceViewModel.Check(51001)
            else
                ---直接进入选关界面
                MgrUI.GetCurUI().ObjRoot:SetActive(true)
            end
        else
            ---新手动画是否完成
            if NoviceControl.GetNoviceState(tonumber(SteamLocalData.tab[120009][2])) then
                ---新手动画已完成但第一关未完成
                MgrUI.GetCurUI().ObjRoot:SetActive(false)
                NoviceViewModel.Check(tonumber(SteamLocalData.tab[120004][2]))
            else
                ---新手动画未完成去看新手动画
                MgrUI.GetCurUI().ObjRoot:SetActive(false)
                NoviceViewModel.Check(tonumber(SteamLocalData.tab[120009][2]))
            end
        end
    end
end

---@type NoviceData[] 获取id的引导完成状态
function NoviceControl.GetNoviceState(id)
    return CacheNoviceList[id].isDone
end

function NoviceControl.ChangeNoviceState(id)
    CacheNoviceList[id].isDone = true
end

---获取指定ID的下一步引导id
function NoviceControl.GetNoviceNextID(id)
    local targetId = nil
    if CacheNoviceList[id].nextId == -1 then
        return nil
    else
        if CacheNoviceList[id].nextId == 0 then
            targetId = id + 1
        else
            return CacheNoviceList[id].nextId
        end
    end
    return targetId
end

---@return NoviceData
function NoviceControl.GetNoviceDataByID(id)
    return CacheNoviceList[id]
end

---获取解锁条件是等级的引导
function NoviceControl.GetForceGuides()
    local arr = {}
    for k,v in pairs(CacheNoviceList) do
        if next(v.condition) then
            table.insert(arr,v)
        end
    end
    return arr
end

---@param id number 引導id
---@return NoviceData
function NoviceControl.GetCurNovice(id)
    if id ~= nil then
        CurID = id
        return CacheNoviceList[id]
    else
        if CurID ~= nil and CacheNoviceList[CurID] == nil then
            CurID = nil
            return CurID
        end
        if CurID ~= nil and CacheNoviceList[CurID].isDone == false then
            return CacheNoviceList[CurID]
        else
            local curId = CurID == nil and 50001 or CurID
            local JumpId = 0     ---下一步ID
            local NextId = 0     ---跳转ID
            local IdBool = true
            while(IdBool) do
                ---如果当前没完成 直接返回
                if CacheNoviceList[curId].isDone == false  then
                    CurID = curId
                    return CacheNoviceList[curId]
                else
                    ---拿到当前的跳转id
                    NextId = tonumber(CacheNoviceList[curId].nextId)
                    ---跳转id如果是0就累加1，否则赋值给下一步id
                    if NextId == 0 then
                        JumpId = curId + 1
                    elseif NextId == -1 then
                        return nil
                    else
                        JumpId = NextId
                    end
                    ---如果已完成 将当前ID设置为下一步ID
                    if CacheNoviceList[curId].isDone == true then
                        curId = JumpId
                    else
                        CurID = curId
                        return CacheNoviceList[CurID]
                    end
                end
            end
        end
    end
end

---告知服务器变更引导
function NoviceControl.ChangeCurNovice(id,callBack)
    local BaseREQ  =
    {
        progress = id
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientSaveProgressREQ',BaseREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_SAVE_PROGRESS_REQ,bytes,0,nil, NoviceControl.ChangeCurNoviceAck,function(...)
        NoviceControl.ChangeCurNoviceNtf(...,nil,callBack)
    end)
end

---打印消息
function NoviceControl.ChangeCurNoviceAck(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientSaveProgressACK',buffer))
    if tab.errNo ~= 0 then
        MgrUI.UnLock("Novice_LastStep")
        UnityEngine.DebugEx.LogError("提交引导进度失败,错误码"..tab.errNo)
    end
end

---更新缓存数据状态
function NoviceControl.ChangeCurNoviceNtf(buffer, tag,callBack)
    local tab = assert(pb.decode('PBClient.ClientSaveProgressNTF',buffer))
    MgrUI.UnLock("Novice_LastStep")
    ---添加奖励
    if tab.goods then
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
    end
    if tab.email ~= 0  then
        MailControl.EmailDataClick()
    end
    local curData =  NoviceControl.GetNoviceDataByID(tab.progress)
    ---如果流程结束并且是末尾标记为1且点击位置不为0
    if curData.nextId == -1  and curData.endSign == 1 and curData.coordinate ~= 0 then
        ---关闭引导界面
        MgrUI.PopHide(UID.NoviceFrame_UI)
        NoviceViewModel.Noviceing = false
    end
    if callBack then
        callBack()
    end
end

function NoviceControl.ChangeCurNoviceREQ(err,msgId)
    if not err then
        MgrSdk.BackToLogin()
    end
end

function NoviceControl.Clear()
    CacheNoviceList = {}
    CacheBattleList = {}
    CurID = nil
    NoviceControl.battleStart = false
end

return NoviceControl