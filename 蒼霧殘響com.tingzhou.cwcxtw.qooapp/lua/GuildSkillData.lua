---@class GuildSkillData 物品数据
GuildSkillData = Class("GuildSkillData")
-------------构造方法-------------
function GuildSkillData:ctor(id)
    local cfg = GuildskillLocalData.tab[id]
    if cfg == nil then
        return
    end
    self.id = cfg.id
    self.frontid = cfg.frontid                      ---需要解锁的前置ID
    self.type = cfg.type                            ---科技类型
    self.level = cfg.level                          ---当前等级
    self.name = cfg.name                            ---技能名称
    self.text = cfg.text                            ---效果描述
    self.skilleffect = cfg.skilleffect              ---技能效果
    self.openlevel = cfg.openlevel                  ---解锁等级
    self.cost = cfg.cost                            ---升级消耗
    self.icon = cfg.icon1                           ---科技图片
    self.bgIcon = cfg.icon2                         ---科技底图
end

---检查是否是满级科技
function GuildSkillData:WhetherMaxLevel()
    if self.level == tonumber(SteamLocalData.tab[115015][2]) then
        return true
    end
    return false
end

---获取技能增幅百分比
function GuildSkillData:GetPercentage()
    local str = string.split(self.skilleffect,"_")
    return tonumber(str[2]) * 0.0001 * 100
end

return GuildSkillData