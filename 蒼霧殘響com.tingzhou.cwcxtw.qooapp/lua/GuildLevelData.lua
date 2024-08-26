---@class GuildLevelData 物品数据
GuildLevelData = Class("GuildLevelData")
-------------构造方法-------------
function GuildLevelData:ctor(id)
    local cfg = GuildlevelLocalData.tab[id]
    if cfg == nil then
        return
    end
    self.id = cfg.id
    self.level = cfg.level                              ---当前等级
    self.maxlevel = cfg.maxlevel                        ---最大等级
    self.experience = cfg.experience                    ---升级经验
    self.membernum = cfg.membernum                      ---公会成员数量
    self.vicepresidentnum = cfg.vicepresidentnum        ---公会副会长数量
    self.levellimit = cfg.levellimit                    ---公会技能等级
end

return GuildLevelData