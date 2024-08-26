---@class GuildDonateData 物品数据
GuildDonateData = Class("GuildDonateData")
-------------构造方法-------------
function GuildDonateData:ctor(id)
    local cfg = GuilddonateLocalData.tab[id]
    if cfg == nil then
        return
    end
    self.id = cfg.id
    self.icon = cfg.icon                            ---捐献图片
    self.type = cfg.type                            ---捐献类型
    self.cost = cfg.cost                            ---捐献消耗
    self.maxnumber = cfg.maxnumber                  ---最大捐献次数
    self.reward = cfg.reward                        ---捐献奖励
    self.guildobtain = cfg.guildobtain              ---公会获得
end

return GuildDonateData