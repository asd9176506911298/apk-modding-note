---@class SummerMapData 物品数据
SummerMapData = Class("SummerMapData")
-------------构造方法-------------
function SummerMapData:ctor()
    self.floorid = 0                ---逻辑格ID
    self.nextfloorid = {}           ---可通行的格子ID
    self.maptype = 0                ---探索章节ID
    self.floortype = 0              ---格子类型
    self.eventid = {}               ---事件ID
    self.eventeffect = 0            ---事件触发效果(暂无类型3)
    self.passcondition = { type="",event={} }        ---格子可通行的前置事件(0 无条件通行 -1 永远不可通行 !:事件id1,事件id2 同时满足1和2个可通行 #:事件id1,事件id2 1和2满足任意一个可通行)
    self.special = 0                ---特殊格(0 普通 1 起始点 2 终点)
    self.discover = 0               ---高亮格(0 不亮 1 高亮)
    self.location = 0               ---显示格
    self.firsttalk = 0              ---战前对话ID
    self.lasttalk = 0               ---战后对话ID
    self.roadblock = 0              ---路障用对话ID
    self.mapping = ""               ---格子外观
    self.eventpic = ""              ---事件图标icon
    self.roleid = 0                 ---角色ID(用于添加头像)
    self.showfloor = {}             ---隐藏和显示格
    self.extraType = 0              ---额外类型(0 无事件 1 陷阱被触发)
end

function SummerMapData:PushData(_data)
    self.floorid = _data.floorid
    local tList = string.split(_data.nextfloorid,",")
    for i = 1, #tList do
        table.insert(self.nextfloorid,tonumber(tList[i]))
    end
    self.maptype = _data.maptype
    self.floortype = _data.floortype
    ---事件ID
    tList = string.split(_data.eventid,";")
    for i = 1, #tList do
        local tEvent = string.split(tList[i],"_")
        self.eventid[tonumber(tEvent[1])] = tonumber(tEvent[2])
    end
    ---事件触发效果(暂无类型3)
    self.eventeffect = tonumber(_data.eventeffect)
    ---格子可通行的前置事件(0 无条件通行 -1 永远不可通行 !:事件id1,事件id2 同时满足1和2个可通行 #:事件id1,事件id2 1和2满足任意一个可通行)
    tList = string.split(_data.passcondition,":")
    if #tList > 1 then
        self.passcondition.type = tList[1]
        if self.passcondition.type ~= "0" and self.passcondition.type ~= "-1" then
            local tEvent = string.split(tList[2],",")
            for i = 1, #tEvent do
                table.insert(self.passcondition.event,tonumber(tEvent[i]))
            end
        end
    else
        self.passcondition = nil
    end
    ---特殊格(0 普通 1 起始点 2 终点)
    self.special = _data.special
    ---高亮格(0 不亮 1 高亮)
    self.discover = _data.discover
    ---显示格
    self.location = _data.location
    ---战前对话ID
    self.firsttalk = _data.firsttalk
    ---战后对话ID
    self.lasttalk = _data.lasttalk
    ---路障用对话ID
    self.roadblock = _data.roadblock
    ---格子外观
    self.mapping = _data.mapping
    ---事件图标icon
    self.eventpic = _data.eventpic
    ---角色ID(用于添加头像)
    self.roleid = _data.roleid
    ---隐藏和显示格
    tList = string.split(_data.showfloor,",")
    for i = 1, #tList do
        table.insert(self.showfloor,tonumber(tList[i]))
    end
end

return SummerMapData