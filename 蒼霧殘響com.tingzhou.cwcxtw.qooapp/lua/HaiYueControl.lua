---数据管理器
HaiYueControl = {}
---@type ActivechapterLocalData
HaiYueControl.TaskType = {
    daily = 1,
    achievement = 2
}

local HaiYueInfo = nil          ---海月活动数据
local ChapterData = {}          ---海月章数据
local CurLvDetail = nil         ---当前打开的关卡详情
local CurContent = nil          ---当前打开的关卡Content
local CurSelect = nil           ---当前选中的关卡
local CurSelectID = nil         ---当前关卡ID
local CurSelectPage = 1       ---当前选择的页签

HaiYueControl.curShopType = nil   ---当前商店类型
HaiYueControl.curTaskType = nil   ---当前任务类型
HaiYueControl.TaskType = {
     daily = 0,       --每日
     achievement = 1,  --成就
}

function HaiYueControl.Init()
    for k,v in pairs(ActivityLocalData.tab) do
        if v[2] == ActivityControl.activityTypeEnum.EVENT then
            HaiYueInfo = EventRaidData.New()
            HaiYueInfo:PushData(v[1])
        end
    end
end
---打开月冕活动界面
function HaiYueControl.OpenUI()
    local isSysOpen,str = ActivityControl.CheckActiveOpen(ActivityControl.activityTypeEnum.EVENT)
    if not isSysOpen then
        MgrUI.Pop(UID.PopTip_UI, { str, 1 }, true)
        return
    end
    local tData = HaiYueControl.GetHaiYueInfo()
    if not Global.isMiddleTime(tData.beginTime,tData.endTime) then
        MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("ui_juqinghuodong_text5"), 1 }, true)
        return
    end
    MgrUI.GoHide(UID.HaiYueHuanShuo_UI)
end
---打开任务界面
function HaiYueControl.OpenTask()
    MgrUI.GoHide(UID.HaiYueTask_UI)
end
---打开商店界面
function HaiYueControl.OpenShop()
    MgrUI.GoHide(UID.HaiYueShop_UI)
end

function HaiYueControl.GetHaiYueInfo()
    if HaiYueInfo == nil then
        HaiYueControl.Init()
    end
    return HaiYueInfo
end
---海月章数据
function HaiYueControl.GetChapterData()
    if #ChapterData == 0 then
        ChapterData = ActiveChapterControl.GetChapterData(HaiYueInfo.chapterId)
    end

    return ChapterData
end
---海月商店数据
function HaiYueControl.GetShopData()
    local arr = {}
    for k,v in pairs(HaiYueInfo.shopType) do
        local shopData = ShopControl.GetCertainTypeShopData(v)
        arr[v] = shopData
    end
    return arr
end
---活动剩余时间
function HaiYueControl.GetEndTime(_strType)
    local tData = HaiYueControl.GetHaiYueInfo()
    ---活动结束提醒
    local serverTime = MgrNet.GetServerTime()
    ---兑换时间
    local tEndTime = Global.GetTimeByStr(tData.endTime)
    if _strType == "battle" then
        ---作战时间
        tEndTime = Global.GetTimeByStr(tData.battleEndTime)
    end
    local remainTime = tEndTime - serverTime

    return remainTime
end
---月冕每日任务数据
function HaiYueControl.GetDailyTaskData()
    local array = TaskControl.GetEventRaidTaskData(HaiYueInfo.dayTaskId)    --附带判断任务是否解锁
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
---月冕成就任务数据
function HaiYueControl.GetTaskData()
    local tAchieviment = AchievementViewModel.GetTask(TaskControl.AchievementTaskType.ACTIVITY_STORY,false,HaiYueInfo.taskId)

    return tAchieviment
end

---设置当前打开的关卡详情
function HaiYueControl.SetCurLvDetail(_LvObj)
    CurLvDetail = _LvObj
end
---获取当前打开的关卡详情
function HaiYueControl.GetCurLvDetail()
    return CurLvDetail
end
---设置当前打开的关卡Content
function HaiYueControl.SetCurContent(_Content)
    CurContent = _Content
end
---获取当前打开的关卡Content
function HaiYueControl.GetCurContent()
    return CurContent
end
---设置当前选中的关卡
function HaiYueControl.SetCurSelect(_Select)
    CurSelect = _Select
end
---获取当前选中的关卡
function HaiYueControl.GetCurSelect()
    return CurSelect
end
---设置关卡ID
function HaiYueControl.SetSelectID(_id)
    CurSelectID = _id
end
function HaiYueControl.GetSelectID()
    return CurSelectID
end
---设置当前选择的页签
function HaiYueControl.SetSelectPage(_page)
    CurSelectPage = _page
end
function HaiYueControl.GetSelectPage()
    return CurSelectPage
end

---检查任务相关红点
function HaiYueControl.CheckTaskRedPoint()
    RedDotControl.GetDotData("HaiYueDailyTask"):SetState(false)
    RedDotControl.GetDotData("HaiYueAchievement"):SetState(false)
    
    if not ActivityControl.CheckActiveOpen(ActivityControl.activityTypeEnum.EVENT) then
        return
    end
    ---遍历任务
    local tData = HaiYueControl.GetHaiYueInfo()
    if Global.isMiddleTime(tData.beginTime,tData.battleEndTime) then
        for k,v in pairs(HaiYueControl.GetDailyTaskData()) do
            local progressStr = JNStrTool.strSplit("_", v.complete)
            local value = ActivationTaskViewModel.GetStatisticValue(v.type, tonumber(progressStr[1]))
            if v.isComplete ~= 1 and value >= tonumber(progressStr[3]) then
                RedDotControl.GetDotData("HaiYueDailyTask"):SetState(true)
                break
            end
        end
    end
    
    ---遍历成就
    for k,v in pairs(HaiYueControl.GetTaskData()) do
        local progressStr = JNStrTool.strSplit("_", v.complete)
        local value = ActivationTaskViewModel.GetStatisticValue(v.type, tonumber(progressStr[1]))
        if v.isComplete ~= 1 and value >= tonumber(progressStr[3]) then
            RedDotControl.GetDotData("HaiYueAchievement"):SetState(true)
            break
        end
    end
end

function HaiYueControl.Clear()
    HaiYueInfo = nil
    ChapterData = {}
    CurLvDetail = nil
    CurContent = nil
    CurSelectID = nil
    CurSelect = nil
    CurSelectPage = 1
    HaiYueControl.curShopType = nil
    HaiYueControl.curTaskType = nil
end
return HaiYueControl