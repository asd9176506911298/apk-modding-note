---@class ShopData 商店数据
---@field id number 商店id
---@field cnName string 商店中文名
---@field enName string 商店英文名
---@field childShop ShopChildData[] 子商店
ShopData = Class('ShopData')
---构造方法
function ShopData:ctor()
    self.id = 0
    self.cnName = MgrLanguageData.GetLanguageByKey("shopdata_tips1")
    self.enName = "Normal"
    self.childShop = {}
end
---@param config ShopLocalData 配置商店
function ShopData:PushConfig(config)
    self.id = config.type_1
    local name = SteamLocalData.tab[config.type_1][2]
    if name ~= nil and name ~= "" and name ~= "0" then
        self.cnName = name
    end
    self:PushShopChild(config)
end
---@param config ShopLocalData 添加子商店
function ShopData:PushShopChild(config)
    if self.childShop[config.type_2] == nil then
        ---不存在子商店则新增
        self.childShop[config.type_2] = ShopChildData.New()
        self.childShop[config.type_2]:PushConfig(config)
    else
        ---存在子商店则添加商品
        self.childShop[config.type_2]:PushShopItem(config)
    end
end

return ShopData