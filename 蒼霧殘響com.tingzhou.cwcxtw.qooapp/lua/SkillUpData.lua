---@class SkillUpData 技能描述信息

SkillUpData = Class('SkillUpData')
---构造方法
function SkillUpData:ctor()
    self.rank = 0                   ---稀有度
    self.skillLv = 0                ---技能等级
    self.cost = nil                 ---技能消耗
    self.ortherCost = nil           ---技能其他消耗
end

function SkillUpData:PushData(_cfg)
    if _cfg == nil then
        return
    end
    self.rank = _cfg[2]
    self.skillLv = _cfg[3]
    self.cost = string.split(_cfg[4], "_")
    self.ortherCost = string.split(_cfg[5], "_")
end

return SkillUpData