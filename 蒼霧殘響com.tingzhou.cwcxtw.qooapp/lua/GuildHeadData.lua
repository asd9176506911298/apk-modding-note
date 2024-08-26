---@class GuildHeadData 物品数据
GuildHeadData = Class("GuildHeadData")
-------------构造方法-------------
function GuildHeadData:ctor(id)
    local cfg = GuildheadLocalData.tab[id]
    if cfg == nil then
        return
    end
    self.id = cfg.id
    self.name = cfg.name                    ---头像名称
    self.icon = cfg.icon                    ---头像图片
    self.type = cfg.type                    ---解锁条件
    self.open = cfg.open                    ---是否显示
end

return GuildHeadData