---@class RoleFavorData 角色好感数据
RoleFavorData = Class("RoleFavorData")
-------------构造方法-------------
function RoleFavorData:ctor(Id)
    self.ID = 0
    self.HeroId = 0
    self.favorAbility = 0
    self.hp = 0           ---生命值
    self.atk = 0          ---攻击
    self.support = 0          ---支援
    self.defense = 0          ---装甲
    self.crit = 0          ---暴击
    self.dodge = 0          ---闪避
    self.criticaldamage = 0          ---暴击伤害
end

function RoleFavorData:PushData(config)
    self.ID = config[1]
    self.HeroId = config[2]
    self.favorAbility = config[3]           ---好感度等级划分
    self.hp = tonumber(config[4])           ---生命值
    self.atk = tonumber(config[5])          ---攻击
    self.support = tonumber(config[6])          ---支援
    self.defense = tonumber(config[7])          ---装甲
    self.crit = tonumber(config[8])          ---暴击
    self.dodge = tonumber(config[9])          ---闪避
    self.criticaldamage = tonumber(config[10])          ---暴击伤害
end

return RoleFavorData