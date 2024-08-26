---@class SkillAtlasData
SkillAtlasData = Class('SkillAtlasData')

function SkillAtlasData:ctor(id)
    local config = SkilldexLocalData.tab[id]
    self.id = id
    self.type1 = config[2]            ---主类型
    self.type1Name = config[3]        ---主类型名字
    self.type2 = config[4]            ---子类型
    self.type2Name = config[5]        ---子类型名字
    self.skillId = config[6]          ---技能ID
    self.skillText = config[7]        ---技能描述
    self.Owner = config[8]            ---拥有角色
    self.Sort = config[9]             ---排序
end

return SkillAtlasData