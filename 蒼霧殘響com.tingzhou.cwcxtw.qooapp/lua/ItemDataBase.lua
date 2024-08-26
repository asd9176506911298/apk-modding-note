---@class ItemDataBase 物品数据
ItemDataBase = Class("ItemDataBase")
-------------构造方法-------------
function ItemDataBase:ctor()
    ---@type goods 物品goods
    self.goods = {}
    self.id = 0         ---物品配置ID
    self.count = 0      ---数量
    self.goodsType = 0  ---goods类型
    self.itemType = 0   ---物品类型
    self.group = 0      ---物品组别
    self.quality = 0    ---物品品质
    self.star = 0       ---物品星级
    self.icon = ""      ---物品图标
    self.channel = ""   ---物品获取途径
    self.checkpoint = ""---物品掉落关卡
    self.use = 0        ---能否使用
    self.name = ""      ---物品名称
    self.txt = ""       ---物品介绍
end
---@class goods 服务器定义的物品类型
local goods = {
    goodsType = 0,
    goodsID = 0,
    goodsNum = 0,
}

return ItemDataBase