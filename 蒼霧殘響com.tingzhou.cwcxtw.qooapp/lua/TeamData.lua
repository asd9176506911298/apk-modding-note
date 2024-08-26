---阵容数据
---@class TeamData
---@field info FighterBase[] 阵容数据
TeamData = Class('TeamData')
---@param index number 构造方法
function TeamData:ctor(index)
    ---阵容索引
    self.index = index
    ---阵容名称
    self.name = MgrLanguageData.GetLanguageByKey("teamdata_formation")..index
    ---阵容数据
    self.info = {}
end
---@class TeamInfo 服务器定义的阵容通信结构
---@field data FighterBase[] 阵容数据(是个数组,数组先后顺序即为行动顺序)
local TeamInfo = {
    index = 1,
    name = 2,
    data = 3,
}
---@class FighterBase 服务器定义的阵容通信结构2
local FighterBase = {
    index = 1,           ---位置信息
    roleID = 2,          ---角色id
}
---@param team TeamInfo 覆盖卷数据
function TeamData:PushData(team)
    self.name = team.name == "" and self.name or team.name
    self.info = team.data
end
---设置名称
function TeamData:SetName(name)
    self.name = name
end
---@param info FighterBase[] 设置阵型
function TeamData:SetInfo(info)
    self.info = info
end
return TeamData