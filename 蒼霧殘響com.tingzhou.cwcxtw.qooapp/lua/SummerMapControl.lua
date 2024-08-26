require("Model/Summer/Data/SummerMapData")
---配置表
require("LocalData/SummermapLocalData")

---数据管理器
SummerMapControl = {}
SummerMapControl.CS = CMgrLogicMap.Instance
---逻辑格约定11*11
SummerMapControl.MapSize = Vector2(11,11)
---逻辑格初始点坐标
SummerMapControl.StartPos = Vector2(-100,65)
---逻辑格大小
SummerMapControl.LogicSize = Vector2(200,130)
---偏移
SummerMapControl.SetOff = 102
---逻辑格类型
SummerMapControl.LogicType = {
    ---普通格
    normal = 0,
    ---普通战斗格
    battle = 1,
    ---路障格
    roadblock = 2,
    ---陷阱格
    trap = 3,
    ---对话
    dialog = 4,
    ---宝箱怪
    treasure = 5,
    ---BOSS战
    boss = 6,
    ---剧情
    plot = 7
}
---事件触发效果
SummerMapControl.EventEff = {
    ---无效
    normal = 0,
    ---事件可以重复触发
    keep = 2,
}
---夏活地图信息
local SummerMapDataList = {}
---夏活地图坐标信息
local SummerMapPos = {}
---夏活地图路径
local SummerMapMark = {}
local SummerMapMarkStr = nil
---夏活地图关卡信息
local MapPointList = {}
---是否为任务目标
local IsTarget = false
---当前走格子地图的目标关卡ID
local TargetPointID = 0
---触发解锁路障的关卡ID
local BlockPointID = 0
---当前解锁的路障表
local RoadblockList = nil

function SummerMapControl.Init()
    ---夏活地图
    for i, v in pairs(SummermapLocalData.tab) do
        if SummerMapDataList[v.maptype] == nil then
            SummerMapDataList[v.maptype] = {}
        end
        SummerMapDataList[v.maptype][v.location] = SummerMapData.New()
        SummerMapDataList[v.maptype][v.location]:PushData(v)

        if v.eventid ~= "0" then
            local tStr = string.split(v.eventid,'_')
            MapPointList[tonumber(tStr[2])] = v
        end
    end

    SummerMapControl.UpdataMap()
end
---更新地图信息
function SummerMapControl.UpdataMap()
    ---根据关卡id,判断地图事件是否已触发
    local tActivityData = StormControl.GetActivityLevelData()
    for pointID, mapData in pairs(SummerMapDataList) do
        for i, v in pairs(mapData) do
            local tEventId = v.eventid[0]
            local tActLevelData = tActivityData[tEventId]
            if tActLevelData then
                SummerMapControl.ChangeLogicState({ v.floorid }, tActLevelData.levelStar, tActLevelData.levelID)
            end
        end
    end
end
---获取当前地图信息
function SummerMapControl.GetMapData(_pointID)
    return SummerMapDataList[_pointID]
end

function SummerMapControl.GetPlotData()
    local arr = {}
    for k,v in pairs(ChapterLocalData.tab) do
        if v.type == 100 then
            table.insert(arr,StormControl.GetStormScrollById(k))
        end
    end
    return arr
end

---将当前地图数据发给C#
function SummerMapControl.CreateMapDataToCS(_pointID)
    if SummerMapDataList[_pointID] == nil then
        return
    end
    ---清理地图数据
    local isClear = CMgrLogicMap.ClearLogicMapDatas(_pointID)
    if isClear then
        ---设置逻辑格相关参数
        CMgrLogicMap.SetDefaultValue(SummerMapControl.MapSize, SummerMapControl.StartPos, SummerMapControl.LogicSize, SummerMapControl.SetOff)
        for i, v in pairs(SummerMapDataList[_pointID]) do
            CMgrLogicMap.Creat_Id_Data(v.floorid, v.nextfloorid, v.extraType, v.location)
        end
    end
end
---设置各地图,玩家所在位置信息
function SummerMapControl.SetMapPos(_flooridList)
    if _flooridList == nil then
        return
    end
    for i, v in ipairs(_flooridList) do
        local tMapData = SummermapLocalData.tab[v]
        if tMapData then
            SummerMapPos[tMapData.maptype] = v
        end
    end
end
---获取当前地图,玩家所在位置
function SummerMapControl.GetMapPos(_pointID)
    local tCfg = SummermapLocalData.tab[SummerMapPos[_pointID]]
    if tCfg then
        if tCfg.floortype == SummerMapControl.LogicType.trap then
            return nil
        end
        return tCfg.location
    end
    return nil
end
---导入当前地图走过的格子
function SummerMapControl.LoadCurMapMark()
    local tPoint = SummerControl.GetSelectID()
    local tKey = "SummerMapMark"..PlayerControl.GetPlayerData().UID..tPoint
    local tStr = UnityEngine.PlayerPrefs.GetString(tKey)
    local tStrList = string.split(tStr,',')
    for i = 1, #tStrList do
        SummerMapControl.SetMapMark(tonumber(tStrList[i]))
    end
end
---记录当前地图走过的格子
function SummerMapControl.SetMapMark(_floorid)
    local tMapData = SummermapLocalData.tab[_floorid]
    if tMapData then
        if SummerMapMark[_floorid] == nil then
            SummerMapMark[_floorid] = tMapData.location

            SummerMapMarkStr = SummerMapMarkStr and tostring(SummerMapMarkStr)..","..tostring(_floorid) or tostring(_floorid)
        end
    end
end
---保存当前地图走过的格子到本地
function SummerMapControl.SaveMapMark()
    local tPoint = SummerControl.GetSelectID()
    local tKey = "SummerMapMark"..PlayerControl.GetPlayerData().UID..tPoint
    UnityEngine.PlayerPrefs.SetString(tKey,SummerMapMarkStr)
end
---获取当前地图走过的格子
function SummerMapControl.GetMapMark()
    return SummerMapMark
end
---根据网格id获取网格的逻辑坐标
function SummerMapControl.GetLogicPos(_location)
    local tPos = Vector2(0,0)
    local temp = _location / SummerMapControl.MapSize.y;

    tPos.x = (_location-1) % SummerMapControl.MapSize.x;
    tPos.y = math.ceil(temp) - 1;

    return tPos;
end

---修改逻辑格状态
function SummerMapControl.ChangeLogicState(_flooridList, _levelStar, _eventID)
    local tCfg = SummermapLocalData.tab[_flooridList[1]]
    local tNeedRefresh = false
    local tBlockData = {}
    
    if tCfg then
        local tMapData = SummerMapDataList[tCfg.maptype]
        local tLogicData = tMapData[tCfg.location]
        local RefreshLogicList = { tLogicData }   ---需要刷新的格子列表
        if tLogicData.floortype == SummerMapControl.LogicType.trap then
            tLogicData.extraType = 1
            tNeedRefresh = true
        elseif _levelStar > 0  then
            if tLogicData.eventeffect ~= SummerMapControl.EventEff.keep then
                tLogicData.floortype = SummerMapControl.LogicType.normal
            end
            ---判断路障的前置事件
            for i, v in pairs(tMapData) do
                if v.floortype == SummerMapControl.LogicType.roadblock and v.passcondition then
                    if v.passcondition.type == "!" then
                        local tid = nil
                        for i = 1, #v.passcondition.event do
                            if v.passcondition.event[i] == _eventID then
                                tid = i
                            end
                        end
                        if tid then
                            table.remove(v.passcondition.event, tid)
                        end
                        if #v.passcondition.event == 0 then
                            v.floortype = SummerMapControl.LogicType.normal
                            ---添加入刷新的格子列表
                            RefreshLogicList[#RefreshLogicList+1] = v
                            tBlockData[#tBlockData+1] = v
                        end
                    elseif v.passcondition.type == "#" then
                        for i = 1, #v.passcondition.event do
                            if v.passcondition.event[i] == _eventID then
                                v.floortype = SummerMapControl.LogicType.normal
                                ---添加入刷新的格子列表
                                RefreshLogicList[#RefreshLogicList+1] = v
                                tBlockData[#tBlockData+1] = v
                            end
                        end
                    end
                    
                    if SummerMapControl.GetBlockPointID() == _eventID then
                        SummerMapControl.SetDeblockLogic(tBlockData)
                    end
                end
            end
            tNeedRefresh = true
        end
        ---刷新的格子
        if tNeedRefresh then
            Event.Go("MapRefresh", RefreshLogicList)
        end
    end
end
---设置额外类型给C#
function SummerMapControl.SetExtraType(_logic, _extraType)
    CMgrLogicMap.SetExtraType(_logic, _extraType)
end
---设置逻辑格类型
function SummerMapControl.SetLogicType(_location, _type)
    local tPoint = SummerControl.GetSelectID()
    SummerMapDataList[tPoint][_location].floortype = _type
end

function SummerMapControl.GetPointData(_pointID)
    return MapPointList[_pointID]
end
---将走过的格子上传给服务端(只前端做判断,后端只做保存)
function SummerMapControl.SendMoveIDREQ(_floorid)
    local ClientFloorREQ = {
        id = _floorid,
    }
    ---组装数据
    local bytes = assert(pb.encode('PBClient.ClientActivityMoveREQ',ClientFloorREQ))

    MgrNet.SendReq(MID.CLIENT_ACTIVITY_MOVE_REQ,bytes,0,nil,SummerMapControl.MoveIDACK,SummerMapControl.MoveIDNTF)
end
function SummerMapControl.MoveIDACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientActivityMoveACK',buffer))
    if tab.errNo ~= 0 then
    end
end
function SummerMapControl.MoveIDNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientActivityMoveNTF',buffer))
    ---设置各地图,玩家所在位置
    SummerMapControl.SetMapPos({tab.id})
    ---保存当前地图走过的格子到本地
    SummerMapControl.SaveMapMark()
end
---触发非战斗和非剧情事件
function SummerMapControl.SendEventREQ(_eventID)
    local tActivityData = StormControl.GetActivityLevelData()
    if tActivityData[_eventID] and tActivityData[_eventID].levelStar > 0 then
        return
    end
    local ClientSetLevelStarREQ = {
        levelID = _eventID,
        teamID = 0,
        heroID = {},
    }
    local bytes = assert(pb.encode('PBClient.ClientSetLevelStarREQ',ClientSetLevelStarREQ))
    MgrNet.SendReq(MID.CLIENT_SET_LEVEL_STAR_REQ,bytes,0,nil,SummerMapControl.EventACK,SummerMapControl.EventNTF)
end
function SummerMapControl.EventACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientSetLevelStarACK',buffer))
    if tab.errNo ~= 0 then
    end
end
function SummerMapControl.EventNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientSetLevelStarNTF',buffer))
    ---更新数据统计
    TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
    ---设置地图,玩家所在位置
    if tab.activityPos then
        ---获取关卡数据
        local pointData = StormControl.GetStormPointByID(tab.levelID)
        ---@type LevelInfo 更新关卡数据
        local levelInfo = {
            levelStar = tab.levelStar > pointData.star and tab.levelStar or pointData.star,
            levelCount = pointData.count + 1,
        }
        pointData:PushData(levelInfo)
        ---设置各地图,玩家所在位置
        SummerMapControl.SetMapPos(tab.activityPos)
        ---修改逻辑格状态
        SummerMapControl.ChangeLogicState(tab.activityPos, tab.levelStar, tab.levelID)
        ---设置额外类型给C#
        local tMapData = SummermapLocalData.tab[tab.activityPos[1]]
        if tMapData and tMapData.floortype == SummerMapControl.LogicType.trap then
            SummerMapControl.SetExtraType(tMapData.location, 1)
        end
        ---保存当前地图走过的格子到本地
        SummerMapControl.SaveMapMark()
    end
end
---触发目标格后,将关卡ID记下来
function SummerMapControl.SetTargetPointID(_targetPointID)
    TargetPointID = _targetPointID
end
function SummerMapControl.GetTargetPointID()
    return TargetPointID
end
---触发解锁路障事件,将关卡ID记下来
function SummerMapControl.SetBlockPointID(_blockPointID)
    BlockPointID = _blockPointID
end
function SummerMapControl.GetBlockPointID()
    return BlockPointID
end
---保存当前路障格数据
function SummerMapControl.SetDeblockLogic(_data)
    RoadblockList = _data
end
---获取当前解锁路障
function SummerMapControl.GetDeblockLogic()
    return RoadblockList
end

function SummerMapControl.SaveTargetState(_curPintID)
    local tKey = "SummerMapTarget"..PlayerControl.GetPlayerData().UID.._curPintID
    UnityEngine.PlayerPrefs.SetString(tKey,"true")
end

function SummerMapControl.Clear()
    SummerMapDataList = {}
    SummerMapPos = {}
    SummerMapMark = {}
    MapPointData = {}
    IsTarget = false
    TargetPointID = 0
    BlockPointID = 0
    RoadblockList = nil
end

return SummerMapControl