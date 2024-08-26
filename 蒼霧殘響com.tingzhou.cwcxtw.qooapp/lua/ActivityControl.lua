require("LocalData/ActivityLocalData")
require("LocalData/FirstchargeawardLocalData")
require("Model/Activity/ActivityData/ActivityData")
---活动管理器
ActivityControl = {}

---@type ActivityData[] 表中的活动信息
local CacheActivityData = {}
---缓存来自服务器的所有活动信息
---@type ActivityData
local AllActivityInfo = {}
---收到所有活动信息标志
ActivityControl.AllActivityInfoGet = false
ActivityControl.PageType = nil  ---打开活动界面开启的页签

---@class activityTypeEnum 活动类型枚举
ActivityControl.activityTypeEnum = {
    ---月冕
    EVENT = 1,
    ---通行证
    PASSPORT = 2,
    ---活动预热
    PREHEAT = 400,
    ---预热2
    WarmUP2 = 401,
    ---夏活
    SUMMER = 500,
    ---基金
    FUND = 993,
    ---战术指导
    GUIDE = 994,
    ---签到
    SIGN = 995,
    --联合讨伐
    LIANHETAOFA = 996,
    ---七日签到
    SIGNDAY = 997,
    ---首充
    FIRSTCHARGE = 998,
    ---新兵训练
    NOVICE_TRAIN = 999,
}
local FirstChargeCfg = {}
local IsReqData = false
local FirstChargeState = 0

---从服务器获取通行证数据
function ActivityControl.PushData(callBack)
    local ExpReq = {
        rev = "1";
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientActivityGetREQ',ExpReq))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_ACTIVITY_GET_REQ,bytes,0,nil,ActivityControl.ActivityACK,function(...)
        ActivityControl.ActivityNTF(...)
        if callBack then
            callBack()
        end
    end)
end
---获得玩家活动ACK
function ActivityControl.ActivityACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("activityCcontrol_tips1"),2},true)
    end
end
---获得玩家活动NTF(包含userID，活动ID，活动版本号，分数，更新时间，已领奖励)
function ActivityControl.ActivityNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetNTF',buffer))
    for i,v in pairs(tab.events) do
        if AllActivityInfo[v.activityId] == nil then
            AllActivityInfo[v.activityId] = ActivityData.New(v.activityId)
        end
        AllActivityInfo[v.activityId]:PushData(v)
    end
    PassportControl.SetPassportData()   --通行证信息刷新
    TaskControl.SetNoviceData()         --新手任务信息刷新
    EventRaidControl.SetEventRaidData()  --剧情活动信息刷新
    ActivityControl.AllActivityInfoGet = true
    ---首充红点
    ActivityControl.CheckFirstCharge()
end

---登录初始化活动
function ActivityControl.InitActivity(events)    
    for i, v in pairs(ActivityLocalData.tab) do
        if AllActivityInfo[v[1]] == nil then
            AllActivityInfo[v[1]] = ActivityData.New(v[1])
        end
    end
    for i,v in pairs(events) do
        if AllActivityInfo[v.activityId] ~= nil then
            AllActivityInfo[v.activityId]:PushData(v)
        end
    end
    PassportControl.SetPassportData()   --通行证信息刷新
    TaskControl.SetNoviceData()         --新手任务信息刷新
    EventRaidControl.SetEventRaidData()  --剧情活动信息刷新
    FundControl.SetFundData()           ---基金信息刷新
    ActivityControl.AllActivityInfoGet = true

    ActivityControl.InitFirstCharge()
    ---首充红点
    ActivityControl.CheckFirstCharge()
    Event.Add("ActivityReq",Handle(ActivityControl,ActivityControl.ActivityReq))
end

function ActivityControl.ActivityReq()
    if IsReqData then
        ActivityControl.PushData()
    end
end

---更新部分活动信息
function ActivityControl.SetActivityInfo(activityId,tab)
    if tab.version then
        AllActivityInfo[activityId].version = tab.version
    end
    if tab.score then
        AllActivityInfo[activityId].score = tab.score
    end
    if tab.uTime then
        AllActivityInfo[activityId].uTime = tab.uTime
    end
    PassportControl.SetPassportData()   --通行证信息刷新
    TaskControl.SetNoviceData()         --新手任务信息刷新
    EventRaidControl.SetEventRaidData()  --剧情活动信息刷新
end
---根据活动类型获得活动信息
function ActivityControl.GetActivityInfo(activityType)
    for i,v in pairs(ActivityLocalData.tab) do
        if v[2] == activityType then
            if AllActivityInfo[v[1]] ~= nil then
                return AllActivityInfo[v[1]]
            end
        end
    end
    ---未找到
    return nil
end

---获取所有存在活动期间的数据
function ActivityControl.GetAllActivityData()
    local tAllData = {}
    ---@type ActivityData[] AllActivityInfo
    for i, v in pairs(AllActivityInfo) do
        if v.isShow == 1 then
            local isOpen = false
            ---是否在开放时间内
            if v.timeType == 999    --永久开放
            then
                if Global.GetCreateRoleDays() <= v.dayTime or v.dayTime == -1 then
                    if v.activityType == ActivityControl.activityTypeEnum.FIRSTCHARGE then
                        ---首充判定状态
                        if FirstChargeState ~= 2 then
                            isOpen = true
                        end
                    elseif v.activityType == ActivityControl.activityTypeEnum.SIGNDAY then
                        ---如果创角时间超过七日签到的长度,则隐藏
                        local tIsSignFull = false
                        SignViewModel.WeekSignData,tIsSignFull = PlayerControl.GetWeekSignData()
                        if not tIsSignFull or SignViewModel.lastWeekSign then --如果未签满或最后一天签到
                            isOpen = true
                        end
                    elseif v.activityType == ActivityControl.activityTypeEnum.NOVICE_TRAIN then
                        if TaskControl.NoviceStage() <= #RecruitactivityLocalData.tab then
                            isOpen = true
                        end
                    elseif v.activityType == ActivityControl.activityTypeEnum.FUND then
                        --基金
                        if not FundControl.GetFundRecState() then
                            isOpen = true
                        end
                    elseif v.activityType == ActivityControl.activityTypeEnum.GUIDE then  --战术指导
                        if not TaskControl.AllGuideRewardReceived then
                            isOpen = true
                        end
                    else
                        isOpen = true
                    end
                end
            elseif Global.isMiddleTime(v.beginTime,v.endTime) then
                isOpen = true
            elseif v.beginTime == "0" and v.endTime == "0" then
                isOpen = true
            end
            if isOpen then
                table.insert(tAllData,v)
            end
        end
    end
    Global.Sort(tAllData, { "sort" },false)
    
    return tAllData
end

---根据type获取活动期间的数据
function ActivityControl.GetCurActivityByType(_type)
    local tData = {}
    local tActivity =  ActivityControl.GetAllActivityData()
    for i, v in pairs(tActivity) do
        if v.activityType == _type then
            table.insert(tData,v)
        end
    end
    
    return tData
end

---根据activityID获取活动期间的数据
function ActivityControl.GetCurActivityByID(activityID)
    local tActivity =  ActivityControl.GetAllActivityData()
    for i, v in pairs(tActivity) do
        if v.activityId == activityID then
            return v
        end
    end
    return nil
end

---给所有活动推送充值金额
function ActivityControl.PushActivityRecharge(recharge)
    for k,v in pairs(AllActivityInfo) do
        v.recharge = v.recharge + recharge
    end
end

---初始化活动数据
function ActivityControl.InitActivityData()
    for k,v in pairs(ActivityLocalData.tab) do
        table.insert(CacheActivityData,ActivityData.New(k))
    end
    ActivityControl.PushData()
end

---检查活动是否有满足前置条件
function ActivityControl.CheckActivity()
    for k,v in pairs(CacheActivityData) do
        if v.front ~= "0" and v.front ~= nil then
            if PlayerControl.GetPlayerData().level >= v.openLevel and StormControl.CheckPointPass(tonumber(v.front)) then
                return true
            end
        end
    end
    return false
end
---首充红点
function ActivityControl.CheckFirstCharge()
    local tData = AllActivityInfo[99998]
    if tData == nil then
        return
    end
    if tData.recharge >= FirstChargeCfg[tData.activityId][5] and tData.reward == "" then
        ---首充红点
        RedDotControl.GetDotData("FirstCharge"):SetState(true)
        FirstChargeState = 1
    elseif tData.reward ~= "" then
        ---首充红点
        RedDotControl.GetDotData("FirstCharge"):SetState(false)
        FirstChargeState = 2
    else
        IsReqData = true
    end
end
---首充领取状态(0.未满足充值限额 1.可领取 2.已领取)
function ActivityControl.GetFirstChargeState()
    return FirstChargeState
end
function ActivityControl.SetFirstChargeState(_state)
    FirstChargeState = _state
    ---首充红点
    if _state == 1 then
        RedDotControl.GetDotData("FirstCharge"):SetState(true)
    elseif _state == 2 then
        RedDotControl.GetDotData("FirstCharge"):SetState(false)
    end
end
function ActivityControl.RewardSendReq(actId,awardId,type,func)
    local activityRewardReq = {
        activityId = actId,
        rewardId = awardId == nil and 0 or awardId,
        rewardType = type == nil and 2 or type,
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientActivityGetRewardREQ',activityRewardReq))
    ItemControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_ACTIVITY_GET_REWARD_REQ,bytes,0,nil,ActivityControl.RewardACK,
            function (...)
                ActivityControl.RewardNTF(...)
                if func then
                    func()
                end
            end)
end
function ActivityControl.RewardACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        ItemControl.AckError = true
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips2")..tab.errNo,2},true)
    end
end
function ActivityControl.RewardNTF(buffer,tag,parentUI)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardNTF',buffer))
    if tab.goods then
        ---添加任务奖励
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
        ---弹出奖励窗口
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
    end
    ActivityControl.PushActivityReward(tab.activityId,tab.reward)
    TaskControl.CheckGuide()
    Event.Go("ActivityDot")
end
function ActivityControl.InitFirstCharge()
    for i, v in ipairs(FirstchargeawardLocalData.tab) do
        FirstChargeCfg[v[2]] = v
    end
end

---推送活动奖励状态
function ActivityControl.PushActivityReward(id,reward)
    if AllActivityInfo[id] == nil then
        return
    end
    AllActivityInfo[id]:PushRewardData(reward)
end
---@type activityTypeEnum
---打开活动界面 
function ActivityControl.OpenHuoDong(_type)
    local activityData = ActivityControl.GetAllActivityData()
    local isOpen = false
    
    ---是否已经解锁
    for i, v in pairs(activityData) do
        if v.activityType == _type then
            if v.systemopen == 0 or SysLockControl.CheckSysLock(v.systemopen) then
                isOpen = true
            else
                MgrUI.Pop(UID.PopTip_UI,{ SysLockControl.GetSystemLockTips(v.systemopen),2 },true)
            end
            break
        end
    end
    if isOpen or _type == nil then
        ActivityControl.PageType = _type
        MgrUI.GoHide(UID.HuoDongPop_UI)
    end
end

---@type activityTypeEnum
---根据类型查询该活动是否开启
function ActivityControl.CheckActiveOpen(_type)
    local tActiveData = ActivityControl.GetCurActivityByType(_type)
    if #tActiveData == 0 or (tActiveData[1].systemopen ~= 0 and not SysLockControl.CheckSysLock(tActiveData[1].systemopen)) or not StormControl.CheckPointPass(tonumber(tActiveData[1].front)) then
        local str = MgrLanguageData.GetLanguageByKey("activityCcontrol_tips1")
        if #tActiveData ~= 0 and tActiveData[1].systemopen ~= 0 and not SysLockControl.CheckSysLock(tActiveData[1].systemopen) then
            str = SysLockControl.GetSystemLockTips(tActiveData[1].systemopen)
        end
        return false,str
    end
    
    return true
end

function ActivityControl.Clear()
    CacheActivityData = {}
    AllActivityInfo = {}
    FirstChargeCfg = {}
    IsReqData = false
    FirstChargeState = 0
    ActivityControl.AllActivityInfoGet = false
    ActivityControl.PageType = nil
end

return ActivityControl