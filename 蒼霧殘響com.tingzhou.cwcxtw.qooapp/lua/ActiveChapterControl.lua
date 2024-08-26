require("Model/Activity/ActivityData/ActiveChapterData")
require("LocalData/ActivechapterLocalData")

ActiveChapterControl = {}
local ChapterData = {}
---活动章节类型
ActiveChapterControl.ChapterType = {
    ---走格子探索关卡
    Logic = 1,
    ---boss关卡章节
    Boss = 2,
    ---活动剧情章节
    Plot = 3,
    ---活动门票章节
    Ticket = 4,
    ---活动挑战章节
    Challege = 5,
}
---地图类型(用于走格子)
ActiveChapterControl.LogicMapType = {
    ---普通地图，全亮
    Nomal = 0,
    ---全暗地图，记住行进路线
    Mark = 1,
    ---全暗地图，不记行进路线
    Untag = 2
}

function ActiveChapterControl.Init()
    if #ChapterData == 0 then
        for i, v in pairs(ActivechapterLocalData.tab) do
            ChapterData[i] = ActiveChapterData.New(i)
        end
    end
end

function ActiveChapterControl.GetChapterData(_group)
    local t = {}
    for i, v in ipairs(_group) do
        if ChapterData[v] ~= nil then
            if t[ChapterData[v].scrollid] == nil then
                t[ChapterData[v].scrollid] = { 
                    Chaptertype = ChapterData[v].chaptertype,
                    ChapterBG = ChapterData[v].chapterpicture,
                    ChapterMusic = ChapterData[v].chaptermusic
                }
            end
            table.insert(t[ChapterData[v].scrollid], ChapterData[v])
        end
    end
    
    return t
end

---@param id number 卷id 检查当前卷是否解锁
---@return boolean 卷是否解锁
function ActiveChapterControl.CheckScrollLock(id)
    local scrollData = ChapterData[id]
    if scrollData == nil then
        Log.Error("找不到对应卷,ID:"..id)
        return false
    end
    if not Global.CheckOnTime(TimeLocalData.tab[scrollData.chaptertime]) then
        return false
    end
    for idx, pointId in ipairs(scrollData.levels) do
        ---若卷下有任一关卡解锁则解锁卷
        if StormControl.CheckPointLock(pointId) then
            return true
        end
    end
    return false
end

function ActiveChapterControl.CheckScrollPass(id)
    local scrollData = ChapterData[id]
    if scrollData == nil then
        Log.Error("找不到对应卷,ID:"..id)
        return false
    end
    if not Global.CheckOnTime(TimeLocalData.tab[scrollData.chaptertime]) then
        return false
    end
    local allPass = true
    for idx, pointId in ipairs(scrollData.levels) do
        ---若卷下有任一关卡未通关
        if not StormControl.CheckPointPass(pointId) then
            allPass = false
            break
        end
    end
    return allPass
end

---传入分卷id获取当前分卷是否解锁
function ActiveChapterControl.CheckScrollLockByScrollID(scrollId)
    for k,v in pairs(ChapterData) do
        if v.scrollid == scrollId then
            if not Global.CheckOnTime(TimeLocalData.tab[v.chaptertime]) then
                return false
            end
            for idx, pointId in ipairs(v.levels) do
                ---若卷下有任一关卡解锁则解锁卷
                if StormControl.CheckPointLock(pointId) then
                    return true
                end
            end
        end
    end
    return false
end
---卷当前状态(0.地图未通关 1.地图通关,但还有剩余关卡未通 2.通关该地图上所有关卡)
function ActiveChapterControl.CheckScrollState(id)
    local scrollData = ChapterData[id]
    if scrollData == nil then
        Log.Error("找不到对应卷,ID:"..id)
        return 0
    end
    if not Global.CheckOnTime(TimeLocalData.tab[scrollData.chaptertime]) then
        return 0
    end
    local tState = 0
    local tAllPass = true
    for idx, pointId in ipairs(scrollData.levels) do
        local tPointType = SummerMapControl.GetPointData(pointId)
        ---除去路障和陷阱
        if tPointType and tPointType.floortype ~= SummerMapControl.LogicType.roadblock and tPointType.floortype ~= SummerMapControl.LogicType.trap then
            ---若卷下有任一关卡未通关
            if StormControl.CheckPointPass(pointId) and tPointType.special == 2 then
                tState = 1
            elseif not StormControl.CheckPointPass(pointId) then
                tAllPass = false
            end
        end
    end
    
    tState = tAllPass and 2 or tState
    
    return tState
end

function ActiveChapterControl.Clear()
    ChapterData = {}
end
return ActiveChapterControl