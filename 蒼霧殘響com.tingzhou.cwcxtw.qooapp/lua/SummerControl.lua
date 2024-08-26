require("Model/Summer/Data/SummerData")
require("Model/Summer/Data/SummerPreheaData")
require("Model/Summer/Data/SummerTalkData")
---配置表
require("LocalData/SummerlogawardLocalData")
require("LocalData/SummerlogdialogueLocalData")
require("LocalData/SummermazetalkLocalData")

---数据管理器
SummerControl = {}
---@type ActivechapterLocalData
---BOSS模式(根据字段"levels"填入的先后顺序,决定难度)
SummerControl.BossMode = {
    ---普通
    Normal = 1,
    ---困难
    Hard = 2
}
---夏活关卡卷ID
SummerControl.LevelScroll = {
    Scroll1 = 1,
    Scroll2 = 2,
    Scroll3 = 3
}
SummerControl.TaskType = {
    daily = 1,
    achievement = 2
}
local PreheatList = {}  ---预热表
local CurAward = nil    ---当天的预热签到奖励
local IsFirst = false   ---是否首次登录

local SummerInfo = nil          ---夏活数据
local ChapterData = {}          ---夏活章数据
local CurPageID = 1             ---当前分章ID
local CurSelectID = nil         ---当前关卡ID
local CurBossIndex = 1             ---当前BOSS界面index
local CurBossMode = SummerControl.BossMode.Normal   ---当前BOSS的难度
local CurBossLevel = nil        ---当前BOSS关卡

local SummerTalkInfo = {}       ---夏活对话数据

SummerControl.curShopType = nil   ---当前商店类型
SummerControl.curTaskType = nil   ---当前任务类型
SummerControl.TaskType = {
     daily = 0,       --每日
     achievement = 1,  --成就
}

local IsGetBossData = true      ---是否获取BOSS数据
local BossLevelList = {}        ---BOSS关卡ID列表
local IsLogin = true

function SummerControl.Init(_awardData)
    ---夏活预热数据
    for i = 1, #SummerlogawardLocalData.tab do
        PreheatList[i] = SummerPreheaData.New(i)
    end
    CurAward = _awardData
    if _awardData then
        ---更新物品奖励
        ItemControl.PushGroupItemData(_awardData,ItemControl.PushEnum.consume)
    end
    ---夏活数据
    SummerControl.InitSummerData()
    ---夏活对话数据
    SummerControl.InitTalkData()
end

------------------------夏活预热------------------------
---获取预热表数据
function SummerControl.GetPreheaData()
    local tData = nil
    local tCurTime = PlayerControl.GetPlayerData().curLoginTime
    for i, v in ipairs(PreheatList) do
        local tOpenTime = Global.GetTimeStamp(v.open_time)
        local tEndTime = Global.GetTimeStamp(v.end_time)
        if tCurTime >= tOpenTime and tCurTime < tEndTime then
            tData = v
            break
        end
    end
    if tData then
        tData:PushData(CurAward)
    end
    return tData
end

---夏活预热开启
function SummerControl.OpenXiahuoYure()
    IsLogin = false
    local tData = SummerControl.GetPreheaData()
    if tData and tData.awards and not IsFirst and NoviceViewModel.Noviceing == false then
        MgrUI.Pop(UID.XiahuoyurePop_UI,{ tData },true)
        IsFirst = true
    end
end

function SummerControl.GetLoginState()
    return IsLogin
end
------------------------夏活数据------------------------
function SummerControl.InitSummerData()
    for k,v in pairs(ActivityLocalData.tab) do
        if v[2] == ActivityControl.activityTypeEnum.SUMMER then
            SummerInfo = EventRaidData.New()
            SummerInfo:PushData(v[1])
        end
    end
end
function SummerControl.GetSummerData()
    if SummerInfo == nil then
        SummerControl.InitSummerData()
    end
    
    return SummerInfo
end
---夏活商店数据
function SummerControl.GetShopData()
    local arr = {}
    for k,v in pairs(SummerInfo.shopType) do
        local shopData = ShopControl.GetCertainTypeShopData(v)
        arr[v] = shopData
    end
    return arr
end
---夏活每日任务数据
function SummerControl.GetDailyTaskData()
    local array = TaskControl.GetEventRaidTaskData(SummerInfo.dayTaskId)    --附带判断任务是否解锁
    table.sort(array, function(a,b)     --按照是否已完成和已领取排序
        if a.isComplete > b.isComplete then
            return false
        elseif a.isComplete < b.isComplete then
            return true
        else
            if a.isReceive > b.isReceive then
                return true
            elseif a.isReceive < b.isReceive then
                return false
            else
                return a.id < b.id
            end
        end
    end)
    return array
end
---夏活成就任务数据
function SummerControl.GetTaskData()
    local tAchieviment = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.ACTIVITY_STORY,false,SummerInfo.taskId)
    
    return tAchieviment
end
---夏活章数据
function SummerControl.GetChapterData()
    if #ChapterData == 0 then
        ChapterData = ActiveChapterControl.GetChapterData(SummerInfo.chapterId)
    end
    
    return ChapterData
end
---夏活卷数据(_index 为活动的章ID)
function SummerControl.GetChaptersDataById(_index)
    local PointData = {}      
    local tChapterData = SummerControl.GetChapterData()
    PointData = tChapterData[_index]
    
    Global.Sort(PointData, {"chapterid"}, false)
    return PointData
end
---获取当前卷数据
function SummerControl.GetCurChaptersData()
    return SummerControl.GetChaptersDataById(CurPageID)
end
function SummerControl.GetLastChaptersData(_type)
    local tChapterData = SummerControl.GetChapterData()
    for i, v in ipairs(tChapterData) do
        if v.Chaptertype == _type then
            for j ,value in ipairs(v) do
                if ActiveChapterControl.CheckScrollLock(value.chapterid) then
                    SummerControl.SetPageID(i)
                end
            end
        end
    end
    return SummerControl.GetChaptersDataById(CurPageID)
end
---获取当前章数据
function SummerControl.GerCurChapterData()
    local tData = SummerControl.GetCurChaptersData()
    for i, v in ipairs(tData) do
        if v.chapterid == CurSelectID then
            return v
        end
    end
end
---设置卷index
function SummerControl.SetPageID(_id)
    CurPageID = _id
end
function SummerControl.GetPageID()
    return CurPageID
end
---设置关卡ID
function SummerControl.SetSelectID(_id)
    CurSelectID = _id
end
function SummerControl.GetSelectID()
    return CurSelectID
end
---设置BOSS界面index
function SummerControl.SetBossIndex(_index)
    CurBossIndex = _index
end
function SummerControl.GetBossIndex()
    return CurBossIndex
end
---设置BOSS难道
function SummerControl.SetBossMode(_Mode)
    CurBossMode = _Mode
end
function SummerControl.GetBossMode()
    return CurBossMode
end
---设置BOSS关卡
function SummerControl.SetBossLevel(_level)
    CurBossLevel = _level
end
function SummerControl.GetBossLevel()
    return CurBossLevel
end

function SummerControl.InitBossLevelID(_levelData)
    local num = 0
    for i, v in pairs(BossLevelList) do
        num = num + 1
    end
    if num == 0 then
        for i, v in ipairs(_levelData) do
            for i, level in pairs(v.levels) do
                BossLevelList[level] = {
                    levelId = level,
                    nowHp = 0,
                    totalHp= 0,
                    levelStar = 0,
                    levelCount = 0,
                    levelPerfectCount = 0
                }
            end
        end
    end
end
---请求BOSS数据
function SummerControl.GetBossData(callBack)
    if BossLevelList[CurBossLevel] and not IsGetBossData and BossLevelList[CurBossLevel].totalHp ~= 0 then
        BattleManager.CurActivityBossHp = BossLevelList[CurBossLevel].nowHp==0 or BossLevelList[CurBossLevel].totalHp and BossLevelList[CurBossLevel].nowHp
        BattleManager.CurActivityBossPointInfo = BossLevelList[CurBossLevel]
        if callBack then
            callBack(BossLevelList[CurBossLevel])
        end
        return
    end
    IsGetBossData = false
    
    local req = {
        type = -1
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientLevelInfoREQ',req))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_LEVEL_INFO_REQ,bytes,1,nil,SummerControl.GetBossDataACK,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientLevelInfoNTF', buffer))
        local info = SummerControl.GetBossDataNTF(tab)

        BattleManager.CurActivityBossHp = info.nowHp
        BattleManager.CurActivityBossPointInfo = info
        
        if callBack then
            callBack(info)
        end
    end)
end
function SummerControl.GetBossDataACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientLevelInfoACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("eventraidviewmodel_tips1"),2},true)
    end
end
function SummerControl.GetBossDataNTF(tab)
    if tab.hp then
        for i, v in pairs(tab.hp) do
            if BossLevelList[v.levelId] then
                BossLevelList[v.levelId].nowHp = v.nowHp==0 and v.totalHp or v.nowHp
                BossLevelList[v.levelId].totalHp = v.totalHp
            end
        end
        for i, v in pairs(tab.activity) do
            if BossLevelList[v.levelID] then
                BossLevelList[v.levelID].levelStar = v.levelStar
                BossLevelList[v.levelID].levelCount = v.levelCount
                BossLevelList[v.levelID].levelPerfectCount = v.levelPerfectCount
            end
        end
    end
    return BossLevelList[CurBossLevel]
end
---下次需要获取BOSS数据
function SummerControl.ChangeBossData()
    IsGetBossData = true
end

function SummerControl.ResetType(_type)
    local tChapterData = SummerControl.GetChapterData()
    for i, v in ipairs(tChapterData) do
        if _type == v.Chaptertype then
            SummerControl.SetPageID(i)
            break
        end
    end
end
------------------------夏活对话数据------------------------
function SummerControl.InitTalkData()
    for k,v in ipairs(SummermazetalkLocalData.tab) do
        if SummerTalkInfo[v.groupid] == nil then
            SummerTalkInfo[v.groupid] = {}
        end
        SummerTalkInfo[v.groupid][#SummerTalkInfo[v.groupid]+1] = SummerTalkData.New()
        SummerTalkInfo[v.groupid][#SummerTalkInfo[v.groupid]]:PushData(v)
    end
end

function SummerControl.GetTalkData(_groupID)
    return SummerTalkInfo[_groupID]
end

------------------------红点相关------------------------
---检查夏活任务相关红点
function SummerControl.CheckTaskRedPoint()
    if not ActivityControl.CheckActiveOpen(ActivityControl.activityTypeEnum.SUMMER) then
        return
    end
    
    RedDotControl.GetDotData("SummerDailyTask"):SetState(false)
    RedDotControl.GetDotData("SummerAchievement"):SetState(false)
    ---遍历夏活任务
    local isOpen = SummerControl.CheckChapterTimeOpen(ActiveChapterControl.ChapterType.Logic)
    if isOpen then
        for k,v in pairs(SummerControl.GetDailyTaskData()) do
            local progressStr = JNStrTool.strSplit("_", v.complete)
            local value = ActivationTaskViewModel.GetStatisticValue(v.type, tonumber(progressStr[1]))
            if v.isComplete ~= 1 and value >= tonumber(progressStr[3]) then
                RedDotControl.GetDotData("SummerDailyTask"):SetState(true)
                break
            end
        end
    end
    ---遍历夏活成就
    for k,v in pairs(SummerControl.GetTaskData()) do
        local progressStr = JNStrTool.strSplit("_", v.complete)
        local value = ActivationTaskViewModel.GetStatisticValue(v.type, tonumber(progressStr[1]))
        if v.isComplete ~= 1 and value >= tonumber(progressStr[3]) then
            RedDotControl.GetDotData("SummerAchievement"):SetState(true)
            break
        end
    end
end

---检查夏活所有红点
function SummerControl.CheckAllRedPoint()
    SummerControl.CheckTaskRedPoint()
end
---打开夏活主界面
function SummerControl.OpenSummerHome()
    local remainTime = SummerControl.GetEndTime() - 1
    local tActivityData = ActivityControl.GetCurActivityByID(SummerInfo.activityID)
    if remainTime > 0 and SysLockControl.CheckSysLock(tActivityData.systemopen) then
        MgrUI.GoHide(UID.SummerHome_UI)
    end
end
---打开夏活关卡界面
function SummerControl.OpenSummerLevel()
    if not SummerControl.CheckChapterTimeOpen(ActiveChapterControl.ChapterType.Logic) then
        return
    end
    SummerControl.ResetType(ActiveChapterControl.ChapterType.Logic)
    MgrUI.GoHide(UID.SummerLevels_UI)
end
---打开夏活BOSS界面
function SummerControl.OpenSummerBoss()
    local tIsBossOpen = SummerControl.CheckChapterTimeOpen(ActiveChapterControl.ChapterType.Boss)
    if tIsBossOpen then
        tIsBossOpen = SummerControl.CheckChapterLock(ActiveChapterControl.ChapterType.Boss)
    end
    if not tIsBossOpen then
        return
    end
    SummerControl.ResetType(ActiveChapterControl.ChapterType.Boss)
    MgrUI.GoHide(UID.SummerLevels_UI)
end
---打开夏活商店
function SummerControl.OpenSummerShop()
    local remainTime = SummerControl.GetEndTime() - 1
    local tActivityData = ActivityControl.GetCurActivityByID(SummerInfo.activityID)
    if remainTime > 0 and SysLockControl.CheckSysLock(tActivityData.systemopen) then
        MgrUI.GoHide(UID.SummerHome_UI,function()
            MgrUI.GoHide(UID.SummerShop_UI)
        end)
    end
end
---活动剩余时间
function SummerControl.GetEndTime()
    local tData = SummerControl.GetSummerData()
    ---活动结束提醒
    local serverTime = MgrNet.GetServerTime()
    local tEndTime = Global.GetTimeByStr(tData.endTime)
    local remainTime = tEndTime - serverTime

    return remainTime
end
---活动挑战剩余时间
function SummerControl.GetBattleEndTime()
    local tData = ActivityControl.GetActivityInfo(ActivityControl.activityTypeEnum.SUMMER)
    ---活动结束提醒
    local serverTime = MgrNet.GetServerTime()
    local tEndTime = Global.GetTimeByStr(tData.battleEndTime)
    local remainTime = tEndTime - serverTime

    return remainTime
end
---检测关卡是否在活动期间
function SummerControl.CheckChapterTimeOpen(_type,_scrollid)
    local isOpen = false
    local tChapterData = SummerControl.GetChapterData()
    if _scrollid then
        tChapterData = SummerControl.GetChapterData()[_scrollid]
    end
    for i, chapterData in ipairs(tChapterData) do
        if chapterData.Chaptertype and chapterData.Chaptertype == _type then
            for i, v in ipairs(chapterData) do
                if Global.CheckOnTime(TimeLocalData.tab[v.chaptertime]) then
                    isOpen = true
                    break
                end
            end
        elseif chapterData.Chaptertype == nil then
            if Global.CheckOnTime(TimeLocalData.tab[chapterData.chaptertime]) then
                isOpen = true
                break
            end
        end
    end
    return isOpen
end

function SummerControl.CheckChapterLock(_type)
    local isOpen = false
    local tChapterData = SummerControl.GetChapterData()
    for i, chapterData in ipairs(tChapterData) do
        if chapterData.Chaptertype and chapterData.Chaptertype == _type then
            --for i, v in ipairs(chapterData) do
                --if Global.CheckOnTime(TimeLocalData.tab[v.chaptertime]) then
                --    isOpen = true
                --    break
                --end-
            --end
            local tCurLevelData = StormControl.GetStormPointByID(chapterData[1].levels[SummerControl.BossMode.Normal])
            isOpen = tCurLevelData:CheckLock()
        end
    end
    return isOpen
end

function SummerControl.Clear()
    PreheatList = {}
    IsFirst = false
    SummerInfo = nil
    ChapterData = {}
    CurPageID = 1
    CurSelectID = nil
    CurBossIndex = 1
    CurBossMode = SummerControl.BossMode.Normal
    CurBossLevel = nil
    SummerTalkInfo = {}
    SummerControl.curShopType = nil
    IsGetBossData = true
    BossLevelList = {}
    SummerControl.curTaskType = nil
    IsLogin = true
end
return SummerControl