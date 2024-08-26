require("Model/Fund/Data/FundData")
---配置表
require("LocalData/FundrebateLocalData")
require("LocalData/FundawardLocalData")
---管理器
FundControl = {}

local FundDataList = {}
local FundInfo = nil
local isCompleted = true    ---基金是否全部领完

function FundControl.Init()
    for i, v in pairs(FundrebateLocalData.tab) do
        FundDataList[v[2]] = FundData.New(v[1])
    end
end

---设置基金数据
function FundControl.SetFundData()
    FundInfo = ActivityControl.GetActivityInfo(ActivityControl.activityTypeEnum.FUND)
end
function FundControl.ResetFundData()
    if FundInfo == nil then
        FundControl.SetFundData()
    end
    
    return FundInfo
end
---获得已领取奖励
function FundControl.GetReceivedReward()
    if FundInfo == nil then
        return nil
    end
    local tab = RapidJson.decode(FundInfo.reward)
    return tab
end
---更新已领取的奖励
function FundControl.RefreshReceivedReward(reward)
    FundInfo.reward = reward
end

---
function FundControl.GetFundByActivityId(_activityId)
    return FundDataList[_activityId]
end

function FundControl.GetPointGroup(_activityId)
    local tData = FundControl.GetFundByActivityId(_activityId)
    if tData then
        ---已领取的奖励
        local receivedReward = FundControl.GetReceivedReward()
        local pointCount = FundControl.GetPointCount(_activityId)
        
        for i,reward in ipairs(tData.PointGroup) do
            if pointCount >= tonumber(reward.factor[3]) then
                reward.canReceive = 1
                if FundControl.CheckSeniorLock() then
                    reward.highCanReceive = 1
                end
                if receivedReward then
                    for k,v in pairs(receivedReward) do
                        if i == tonumber(k) then
                            reward.canReceive = 2
                            if v == 2 then
                                reward.highCanReceive = 2
                            end
                        end
                    end
                end
            end
        end
        
        return tData.PointGroup
    end
    
    return nil
end
---获取任务数据
function FundControl.GetTaskGroup(_activityId)
    local tData = FundControl.GetFundByActivityId(_activityId)
    if tData then
        local tAchieviment = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.ACTIVITY_STORY,false,tData.taskID)
        
        return tAchieviment
    end

    return nil
end
---获取积分数
function FundControl.GetPointCount(_activityId)
    local tData = FundControl.GetFundByActivityId(_activityId)
    if tData then
        local BagItemData = ItemControl.GetItemByIdAndType(tonumber(tData.pointItem[2]),tonumber(tData.pointItem[1]))
        
        return BagItemData.count
    end
    
    return 0
end

---一键领取所有
function FundControl.AcceptAll(_activityId, _rewardId, callback)
    local activityRewardReq  =
    {
        activityId = _activityId,
        rewardId = _rewardId,
        rewardType = 1
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientActivityGetRewardREQ',activityRewardReq))
    ItemControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_ACTIVITY_GET_REWARD_REQ,bytes,0,nil,FundControl.ActivityRewardSendACK,function(...)
        FundControl.ActivityRewardSendNTF(...)
        if callback then
            callback()
        end
    end)
end
---领取活动奖励ACK
function FundControl.ActivityRewardSendACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        if tab.errNo == 2003 then
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips1"),2},true)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips2"),2},true)
        end
    end
end
---领取通行证活动奖励NTF
function FundControl.ActivityRewardSendNTF(buffer, tag)
    ---解析活动奖励
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardNTF',buffer))
    if tab.goods then
        ---将奖励推送进背包
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
        ---弹出奖励弹窗
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
    else
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips3"),2},true)
    end
    if tab.reward then
        ---更新已领取的奖励
        FundControl.RefreshReceivedReward(tab.reward)
    end
    
    ---刷新背包缓存数据
    BagViewModel.ReloadCacheData()
end

---是否包含指定元素
function FundControl.Contains(target,table)
    if table == nil then
        return false
    end
    for k,v in pairs(table) do
        if target == tonumber(k) then
            return true
        end
    end
    return false
end

---是否包含高级奖励
function FundControl.ContainsSeniorReward(target,receivedReward)
    if receivedReward == nil then
        return false
    end
    for k,v in pairs(receivedReward) do
        if v == 2 and target == tonumber(k) then
            return true
        end
    end
    return false
end

---检查玩家是否已解锁高级基金
function FundControl.CheckSeniorLock()
    local playerData = PlayerControl.GetPlayerData()
   
    if playerData.fundVersion == nil or playerData.fundVersion == 0 or playerData.fundVersion ~= FundInfo.version then
        return false
    end
    
    return true
end

---获取基金领取状态
function FundControl.GetFundRecState()
    return isCompleted
end
---基金红点刷新
function FundControl.RefreshRedPoint()
    RedDotControl.GetDotData("FundPoint"):SetState(false)
    RedDotControl.GetDotData("FundTask"):SetState(false)
    
    FundControl.ResetFundData()
    if FundInfo == nil then
        return
    end
    ---遍历积分
    local tData = FundControl.GetPointGroup(FundInfo.activityId)
    if tData then
        for i, v in pairs(tData) do
            if v.canReceive == 1 or v.highCanReceive == 1 then
                RedDotControl.GetDotData("FundPoint"):SetState(true)
                isCompleted = false
                break
            elseif v.canReceive == 0 or v.highCanReceive == 0 then
                isCompleted = false
            end
        end
    end

    if FundControl.CheckSeniorLock() and isCompleted then
        return
    else
        isCompleted = false
    end
    ---遍历成就任务
    tData = FundControl.GetTaskGroup(FundInfo.activityId)
    if tData then
        for k,v in pairs(tData) do
            local progressStr = JNStrTool.strSplit("_", v.complete)
            local value = ActivationTaskViewModel.GetStatisticValue(v.type, tonumber(progressStr[1]))
            if v.isComplete ~= 1 and value >= tonumber(progressStr[3]) then
                RedDotControl.GetDotData("FundTask"):SetState(true)
                break
            end
        end
    end
end

function FundControl.Clear()
    FundDataList = {}
    FundInfo = nil
    isCompleted = true
end

return FundControl