require("Model/Activity/ActivityData/EventRaidData")
require("Model/Boss/BossData/BossActivityData")

EventRaidControl = {}
--required int32 userId = 1;
--required int32 activityId = 2;
--required int32 version = 3;
--required int32 score = 4;
--required int64 uTime = 5;     结束时间
--required string reward = 6;   转成表
---活动剧情信息
local eventRaidInfo = nil
---@type EventRaidData 活动剧情数据
local eventRaidData = nil
---@type BossActivityData 联合讨伐数据
local LHTFRaidData = nil
---联合讨伐次数
local LHTFTimes = 0

------------------剧情活动EventRaid--------------------
function EventRaidControl.SetEventRaidData()  --剧情活动信息刷新
    eventRaidInfo = ActivityControl.GetActivityInfo(ActivityControl.activityTypeEnum.EVENT)
    for k,v in pairs(ActivityLocalData.tab) do
        if v[2] == ActivityControl.activityTypeEnum.EVENT then
            eventRaidData = EventRaidData.New()
            eventRaidData:PushData(v[1])
        end
    end
end

---获取剧情活动表数据
function EventRaidControl.GetEventData()
    if eventRaidData == nil then
        for k,v in pairs(ActivityLocalData.tab) do
            if v[2] == ActivityControl.activityTypeEnum.EVENT then
                eventRaidData = EventRaidData.New()
                eventRaidData:PushData(v[1])
                return eventRaidData
            end
        end
    end
    return eventRaidData
end

---获取联合讨伐活动数据
function EventRaidControl.GetLIANHETAOFAData(activityId)
    if LHTFRaidData == nil then
        for k,v in pairs(ActivityLocalData.tab) do
            if v[2] == ActivityControl.activityTypeEnum.LIANHETAOFA then
                LHTFRaidData = BossActivityData.New()
                LHTFRaidData:PushData(v[1])
                return LHTFRaidData
            end
        end
    end
    return LHTFRaidData
end

function EventRaidControl.GetEventRaidData()  --剧情活动信息刷新
    EventRaidControl.SetEventRaidData()
    if eventRaidInfo then
        return eventRaidInfo
    end
    return nil
end
function EventRaidControl.ClearEventRaidData()
    eventRaidInfo = nil
end
---剧情活动数据
function EventRaidControl.CreateEventRaidData(test)
    if eventRaidInfo then
        eventRaidData = EventRaidData.New()
        eventRaidData:PushData(eventRaidInfo.activityId)
        return eventRaidData
    end
    if test then
        eventRaidData = EventRaidData.New()
        eventRaidData:PushData(test.activityId)
        return eventRaidData
    end

    return nil
end

---获取剧情活动是否在时间内
function EventRaidControl.GetIsInMiddle()
    local datas = StormControl.GetEventRaidScrollData()
    if datas then
        local inMiddle = Global.isMiddleTime(eventRaidData.beginTime, eventRaidData.endTime)
        print("GetEventRaidScrollData", serpent.block(datas))
        return inMiddle
    end
    return false
end

---活动结束提醒
function EventRaidControl.EventEndTip()
    ---活动结束提醒
    local remainTime = Global.GetTimeStamp(EventRaidControl.CreateEventRaidData(EventRaidControl.GetEventRaidData()).endTime)
    if remainTime < (3*86400) then    ---当前时间在活动时间区间内但是小于3天
    MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("eventraidcontrol_tips1"),2},true)
    end
end

---活动结束提醒
function EventRaidControl.GetEventEndTime()
    ---活动结束提醒
    local serverTime = MgrNet.GetServerTime()
    local tEndTime = Global.GetTimeByStr(EventRaidControl.GetEventData().endTime)
    local remainTime = tEndTime - serverTime
    return remainTime
end

---联合讨伐活动结束提醒
function EventRaidControl.GetLHETFEndTime()
    ---活动结束提醒
    local serverTime = MgrNet.GetServerTime()
    local tEndTime = Global.GetTimeByStr(EventRaidControl.GetLIANHETAOFAData().endTime)
    local remainTime = tEndTime - serverTime
    return remainTime
end

function EventRaidControl.LHTFPop(BossID,params)
    MgrUI.Pop(UID.GoToWBPop_UI,{BossID,params},true)
end

function EventRaidControl.LHTFPopCheck(dayStatistic)
    local dayVigorChanged = false   --当日体力是否变化
    if dayStatistic then
        for i, v in pairs(dayStatistic) do
            if v.statisticID == tonumber(SteamLocalData.tab[109004][2]) and v.statisticValue ~= 0 and LHTFTimes ~= TaskControl.CheckLHTFVigor() then
                LHTFTimes = TaskControl.CheckLHTFVigor()
                dayVigorChanged = true
                break
            end
        end
    end
    local data = ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId)
    local dataLHTF = EventRaidControl.GetLIANHETAOFAData()
    if StormViewModel.CurStormBossId ~= 0 and dayVigorChanged and SysLockControl.CheckSysLock(dataLHTF.sysLockNum) then
        if dataLHTF ~= nil and Global.isMiddleTime(dataLHTF.beginTime,dataLHTF.battleEndTime) then
            if TaskControl.CheckLHTFVigor() - data.count > 0 then
                Event.Add("LHTFPOP",EventRaidControl.LHTFPop)
                --EventRaidControl.LHTFPop(StormViewModel.CurStormBossId,{TaskControl.CheckTodayVigorExpend(),data.activityId})
            else
                Event.Remove("LHTFPOP",EventRaidControl.LHTFPop)
            end
        end
    end
end