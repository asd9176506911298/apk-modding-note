require("Model/Storm/Data/StormScrollData")
require("Model/Storm/Data/StormPointData")
require("Model/Storm/Data/StormBossData")
require("LocalData/ChapterLocalData")
require("LocalData/CheckpointLocalData")
require("LocalData/TimeLocalData")
require("LocalData/RedtowerLocalData")
require("LocalData/JcbossLocalData")
require("LocalData/ChapterboxLocalData")
require("LocalData/TacticsguideLocalData")
require("LocalData/TermdescLocalData")
require("LocalData/DropLocalData")
---战役管理器
StormControl = {}

---@type StormScrollData[] 卷信息
local StormScrollDataList = {}
---@type StormPointData[] 关卡信息
local StormPointDataList = {}


---@type StormScrollData[] 挑战红巨卷信息
local StormTowerScrollDataList = {}
---@type StormPointData[] 挑战红巨关卡信息
local StormTowerPointDataList = {}
---@type StormScrollData[] 挑战战术指导卷信息
local StormGuideScrollDataList = {}
---@type StormPointData[] 挑战战术指导关卡信息
local StormGuidePointDataList = {}

---@type StormBossData[] 联合讨伐（世界boss）信息
local StormBossList = {}
StormControl.sortChild = {
    EASY = 0,       ---简单
    DIFF = 1,       ---困难
    COLL = 10,      ---收集
    CORE = 12,      ---核心
    INTENSIFY = 13, ---突破
}
StormControl.raidType = {
    MAIN = 0,
    MAIN_DIFF = 1,
    DAILY_COLL = 10,
    DAILY_CORE = 11,
    DAILY_INTENSIFY = 12,
    RAID_EASY = 100,
    RAID_DIFF = 101,
    RAID_BOSS = 102
}

local ActivityLevels = {}         ---活动关卡数据
---战斗相关初始化
function StormControl.CreateAllStorm()
    ---初始化关卡
    for id, config in pairs(CheckpointLocalData.tab) do
        StormPointDataList[id] = StormPointData.New(id)
        StormPointDataList[id]:PushConfig(config)
    end
    ---初始化卷
    for id, config in pairs(ChapterLocalData.tab) do
        StormScrollDataList[id] = StormScrollData.New(id)
        StormScrollDataList[id]:PushConfig(config)
    end
    ---初始化挑战红巨关卡
    local pointIDStr = ""
    for id, config in pairs(RedtowerLocalData.tab) do
        StormTowerPointDataList[id] = StormPointData.New(id)
        StormTowerPointDataList[id]:PushTowerConfig(config)
        pointIDStr = pointIDStr..id..","
    end
    ---初始化挑战红巨卷
    StormTowerScrollDataList[1] = StormScrollData.New(1)
    StormTowerScrollDataList[1]:PushTower(string.sub(pointIDStr,1,#pointIDStr - 1))
    ---初始化挑战战术指导关卡
    pointIDStr = ""
    for id, config in pairs(TacticsguideLocalData.tab) do
        StormGuidePointDataList[id] = StormPointData.New(id)
        StormGuidePointDataList[id]:PushGuideConfig(config)
        pointIDStr = pointIDStr..id..","
    end
    ---初始化挑战战术指导卷
    StormGuideScrollDataList[1] = StormScrollData.New(1)
    StormGuideScrollDataList[1]:PushGuide(string.sub(pointIDStr,1,#pointIDStr - 1))
    ---初始化世界boss
    for id, config in pairs(JcbossLocalData.tab) do
        if StormBossList[id] == nil then
            StormBossList[id] = StormBossData.New(id)
            StormBossList[id]:PushConfig(config)
        end
    end
end

function StormControl.GetStormScrollById(id)
    return StormScrollDataList[id]
end
---@param type number 根据卷类型获取活动卷数据
function StormControl.GetEventRaidScrollData()
    local array = {}
    for id, data in pairs(StormScrollDataList) do
        ---@type StormScrollData data
        if data.type == 3 then
            if data.raidType == StormControl.raidType.RAID_EASY then    ---活动本简单
                array[data.index] = data
            end
            if data.raidType == StormControl.raidType.RAID_DIFF then    ---活动本困难
                array[#array + 1] = data
            end
            if data.raidType == StormControl.raidType.RAID_BOSS then    ---活动本Boss
                array[#array + 1] = data
            end
        end
    end
    return array
end
---获取活动关卡数据
function StormControl.GetEventRaidPointData()
    local array = {}
    for i,data in pairs(StormScrollDataList) do
        for idx,data2 in pairs(StormPointDataList) do
            if data.id == data2.scrollID and data.type == 3 then   ---卷ID == 关卡对应的卷ID
                array[#array + 1] = data2
            end
        end
    end
    table.sort(array,function(a,b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)
    return array
end
---@param type number 根据卷类型获取卷数据
function StormControl.GetStormScrollData(type)
    local array = {}
    for id, data in pairs(StormScrollDataList) do
        if data.type == type then
            if type == StormControl.raidType.MAIN then
                array[data.index] = data
            elseif type == 2 then
                array[data.index] = data
            else
                array[#array + 1] = data
            end
        end
    end
    return array
end

---获取困难卷数据
function StormControl.GetStormHardScrollData()
    local array = {}
    for i,data in pairs(StormScrollDataList) do
        if data.raidType == 1 then
            array[#array + 1] = data
        end
        table.sort(array,function(a,b)
            if a.index < b.index then
                return true
            else
                return false
            end
        end)
    end
    return array
end

---获取困难关卡数据
function StormControl.GetStormHardPointData()
    local array = {}
    for i,data in pairs(StormScrollDataList) do
        for idx,data2 in pairs(StormPointDataList) do
            if data.id == data2.scrollID and data.raidType == 1 then
                array[#array + 1] = data2
            end
        end
    end
    return array
end

---@return StormScrollData[] 获取红巨卷
function StormControl.GetStormTowerScrollData()
    return StormTowerScrollDataList
end
---@return StormPointData[] 获取红巨关卡
function StormControl.GetStormTowerPointData()
    return StormTowerPointDataList
end
---@return StormScrollData[] 获取战术指导卷
function StormControl.GetStormGuideScrollData()
    return StormGuideScrollDataList
end
---@return StormPointData[] 获取战术指导关卡
function StormControl.GetStormGuidePointData()
    return StormGuidePointDataList
end
---@return StormPointData[] 获取所有关卡数据
function StormControl.GetStormPointData()
    return StormPointDataList
end
---@param pointID number 关卡id获取关卡
---@return StormPointData
function StormControl.GetStormPointByID(pointID)
    return StormPointDataList[pointID]
end
---@return StormBossData[] 获取所有世界boss关卡
function StormControl.GetAllStormBoss()
    local arr = {}
    for i, v in pairs(StormBossList) do
        arr[#arr + 1] = v
    end
    return arr
end
---@return StormBossData 获取世界boss关卡，为空则没有任何boss开启
function StormControl.GetStormBoss(id)
        for i, boss in pairs(StormBossList) do
        if id == boss.id then
            return boss
        end
    end
    Log.Error("boss不存在,id:"..id)
end

function StormControl.GetStormBoss2(activityid)
    for i, boss in pairs(StormBossList) do
        if activityid == boss.activityid then
            return boss
        end
    end
    Log.Error("boss不存在,activityID:"..type)
end

---@return  StormPointData 获取玩家当前主线剧情最高关卡数据
function StormControl.GetHighestPoint()
    ---@type StormPointData[]
    local dataArr = {}
    local index = 0
    ---检查主线卷是否解锁
    for i,v in pairs(StormScrollDataList) do
        if(StormControl.CheckScrollLock(v.id) and v.type == 0) then
            ---防止重复遍历 小的盖了大的
            if(v.id > index) then
                index = StormScrollDataList[i].id
            end
        end
    end
    if index == 0 then
        return "1-1"
    end

    for i, v in pairs(StormScrollDataList[index].points) do
        dataArr[StormPointDataList[v].index] = StormPointDataList[v]
    end

    ---检查关卡是否解锁
    local curIndex = 1
    for i = 1, #dataArr do
        if StormControl.CheckPointLock(dataArr[i].id) then
            curIndex = i
        end
    end
    return dataArr[curIndex]
end

---@return StormPointData,number 获取当前卷进度所在关卡数据及最大数
function StormControl.GetCurPointByScroll(scrollID)
    ---@type StormPointData[]
    local dataArr = {}
    for i, v in pairs(StormScrollDataList[scrollID].points) do
        if StormPointDataList[v].index then
            dataArr[StormPointDataList[v].index] = StormPointDataList[v]
        else
            print("关卡索引为空")
        end
    end
    local curIndex = 1
    for i = 1, #dataArr do
        if StormControl.CheckPointLock(dataArr[i].id) then
            curIndex = i
        end
    end
    return dataArr[curIndex],#dataArr
end
---更新红巨状态
function StormControl.PushTowerData(towers)
    if towers ~= nil then
        for _, tower in pairs(towers) do
            if tower ~= nil then
                for i, v in pairs(tower.reward) do
                    StormTowerPointDataList[tower.towerID].towerReward[i].isGet = v ~= 0
                end
            end
        end
    end
end
---更新战术指导状态
function StormControl.PushGuideData(guides)
    if guides ~= nil then
        for _, guide in pairs(guides) do
            if guide ~= nil and guide ~= 0 then
                StormGuidePointDataList[guide].star = 1
            end
        end
    end
end

---@param scrollBox number[] 更新章节宝箱
function StormControl.PushScrollBox(scrollBox)
    ---更新章节宝箱
    if not scrollBox then
        Log.Error("章节宝箱为空")
    else
        for i, boxId in pairs(scrollBox) do
            for i, data in pairs(StormScrollDataList) do
                data:PushBox(boxId)
            end
        end
    end
end

---@param levels LevelInfo[] 更新一组关卡数据
function StormControl.PushGroupPointData(levels)
    if not levels then
        Log.Error("关卡数据为空")
    else
        for i, level in pairs(levels) do
            StormControl.PushSinglePointData(level)
        end
    end
end

---@param level LevelInfo 关卡信息类型
function StormControl.PushSinglePointData(level)
    ---临时存储当前Push关卡对应父卷信息的关卡信息表
    if not StormPointDataList[level.levelID] then
        ---当前卷还未添加
        Log.Error("请勿添加游戏外的卷ID")
        return
    end
    StormPointDataList[level.levelID]:PushData(level)
end

function StormControl.PushActivityPointData(levels)
    if not levels then
        Log.Error("关卡数据为空")
    else
        for i, level in pairs(levels) do
            StormControl.PushSinglePointData(level)
            ActivityLevels[level.levelID] = level
        end
    end
end
---@param id number 卷id 检查当前卷是否解锁
---@return boolean 卷是否解锁
function StormControl.CheckScrollLock(id)
    local scrollData = StormScrollDataList[id]
    if scrollData == nil then
        Log.Error("找不到对应卷,ID:"..id)
        return false
    end
    --for idx, pointId in ipairs(scrollData.points) do
    --    ---若卷下有任一关卡解锁则解锁卷
    --    if StormControl.CheckPointLock(pointId) then
    --        return true
    --    end
    --end
    if StormControl.CheckPointLock(scrollData.points[1]) then
        return true
    end
    return false
end

---@param id number 关卡id 检查当前关卡是否解锁
---@return boolean 关卡是否解锁
function StormControl.CheckPointLock(id)
    if id == 0 then
        return true
    end
    local pointData = nil
    ---战术指导
    if BattleManager.GameMode == BattleManager.GameModeType.Guide then
        pointData = StormGuidePointDataList[id]
    ---红巨    
    elseif BattleManager.GameMode == BattleManager.GameModeType.RedTower then
        pointData = StormTowerPointDataList[id]
    else
        pointData = StormPointDataList[id]
    end
    if pointData == nil then
        Log.Error("找不到对应关卡,ID:"..id)
        return false
    end
    return pointData:CheckLock()
end
---@param id number 关卡id 检查当前关卡是否完成
---@param pointType number 关卡类型 区分关卡类型1-常规关卡 2-红色巨塔 3-战术指导 4-新手关卡 不填默认是1
---@return boolean 关卡是否完成
function StormControl.CheckPointPass(id,pointType)
    if id == 0 then
        return true
    end
    local type = pointType == nil and 1 or pointType

    if type == 1 then
        if StormPointDataList[id] == nil then
            return false
        end
        local str = string.split(StormPointDataList[id].o_fronts,"_")
        if tonumber(str[1]) == 100000 then
            return false
        end
        local pointData = StormPointDataList[id]
        return pointData:CheckStar()
    elseif type == 2 then
        if StormTowerPointDataList[id] == nil then
            return false
        end
        local clear = true
        for i, v in ipairs(StormTowerPointDataList[id]:CheckTowerTask()) do
            if v ~= true then
                clear = false
                break
            end
        end
        return clear
    elseif type == 3 then
        if StormGuidePointDataList[id] == nil then
            return false
        end
        return StormGuidePointDataList[id]:CheckGuideLock()
    elseif type == 4 then
        local novice = NoviceControl.GetNoviceDataByID(StormPointDataList[id].teacheID)
        if novice then
            if NoviceControl.GroupsIsDone(novice.group) then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    return false
end

---是否有未领取的宝箱
function StormControl.WhetherUnReceiveBox()
    local CanReceive = false
    if next(StormScrollDataList) then
        for k,scroll in pairs(StormScrollDataList) do
            ---只判断主线关卡
            if scroll.type == 0 then
                ---如果本章节有可领取宝箱
                if scroll:IsGetBoxStar() == true then
                    CanReceive = true
                end
            end
        end
    end
    RedDotControl.GetDotData("ScrollBox"):SetState(CanReceive)
    return CanReceive
end

function StormControl.GetActivityLevelData()
    return ActivityLevels
end

function StormControl.Clear()
    ---@type StormScrollData[] 卷信息
    StormScrollDataList = {}
    ---@type StormPointData[] 关卡信息
    StormPointDataList = {}
    ---@type StormScrollData[] 挑战红巨卷信息
    StormTowerScrollDataList = {}
    ---@type StormPointData[] 挑战红巨关卡信息
    StormTowerPointDataList = {}
    ---@type StormScrollData[] 挑战战术指导卷信息
    StormGuideScrollDataList = {}
    ---@type StormPointData[] 挑战战术指导关卡信息
    StormGuidePointDataList = {}
    ---@type StormBossData[] 联合讨伐（世界boss）信息
    StormBossList = {}
    ---活动关卡ID
    ActivityLevels = {}
end

return StormControl
