---@class ShopChildData 子商店数据
---@field id number 子商店id
---@field name string 子商店名称
---@field shopItems ShopItemData[] 子商店商品
ShopChildData = Class('ShopChildData')
---构造方法
function ShopChildData:ctor()
    self.id = 0
    self.name = MgrLanguageData.GetLanguageByKey("shopdata_tips1")
    self.Childtype = 0
    self.ChildSystemOpen = 0
    self.shopItems = {}
end

---@param config ShopLocalData 配置子商店
function ShopChildData:PushConfig(config)
    self.id = config.type_2
    local shoptypeCfg = ShoptypeLocalData.tab[config.type_2]
    self.Childtype = shoptypeCfg.type
    self.ChildSystemOpen = shoptypeCfg.systemopen
    local name = shoptypeCfg.name
    if name ~= nil and name ~= "" and name ~= "0" then
        self.name = name
    end
    self:PushShopItem(config)
end

---@param config ShopLocalData 添加商品
function ShopChildData:PushShopItem(config)
    if self.shopItems[config.id] == nil then
        self.shopItems[config.id] = ShopItemData.New()
        self.shopItems[config.id]:PushConfig(config)
        local shoptypeCfg = ShoptypeLocalData.tab[config.type_2]
        ---活动商城品质框图片不同
        if shoptypeCfg and shoptypeCfg.type == 6 then
            self.shopItems[config.id].rankIcon = string.format("Activity/HaiYue/shangpingkuang%s", config.rank)
        end
    else
        Log.Error(string.format("子商店id:%s,添加了相同的商品,id:%s",self.id,config.id))
    end
end

return ShopChildData