---@class RandomItemData:ItemDataBase 物品数据
RandomItemData = Class("RandomItemDataData",ItemDataBase)
-------------构造方法-------------
function RandomItemData:ctor()
    RandomItemData.super.ctor(self)
    ---@type goods 物品goods
    self.goods = {}
    self.uid = 0        ---uid
    self.id = 0         ---物品配置ID
    self.count = 0      ---数量
    self.goodsType = 0  ---goods类型
    self.itemType = 0   ---物品类型
    self.group = 0      ---物品组别
    self.quality = 0    ---物品品质
    self.itemstar = 0       ---物品星级
    self.icon = ""      ---物品图标
    self.iconFrame = "" ---物品边框
    self.channel = ""   ---物品获取途径
    self.checkpoint = ""---物品掉落关卡
    self.use = 0        ---能否使用
    self.fall = 0       ---使用后获得物品
    self.name = ""      ---物品名称
    self.txt = ""       ---物品介绍
    self.notify = {}    ---通知
end

-------------数据操作方法-------------
---@param goods goods 覆盖数据
---@param pushType number 填充类型
function RandomItemData:PushData(goods,pushType)
    --local config0 = RandomshopLocalData.tab[goods.id]
    local config1 = RoleequipmentLocalData.tab[goods.goodsID]
    if --[[config0 == nil or]] config1 == nil then
        Log.Error(string.format("未找到物品配置类型,Id:%s, Type:%s",goods.goodsID,goods.goodsType))
        return
    end
    self.goods = goods
    self.id = goods.goodsID
    if pushType == ItemControl.PushEnum.none or pushType == ItemControl.PushEnum.cover or not pushType then
        ---覆盖
        self.count = goods.goodsNum
    elseif pushType == ItemControl.PushEnum.add then
        ---添加
        self.count = self.count + goods.goodsNum
    elseif pushType == ItemControl.PushEnum.consume then
        ---消耗
        self.count = self.count - goods.goodsNum
        if self.count <= 0 then
            ItemControl.RemoveItem(goods.goodsID,goods.goodsType)
        end
    else
        Log.Error("无效的数据操作类型")
    end
    self.goodsType = goods.goodsType
    --self.itemType = math.ceil(config.group/1000)
    --self.group = config.group
    self.quality = config1[6]
    self.itemstar = 0
    self.icon = string.format("Equip/%s",config1[4])
    self.iconFrame = string.format("Item/Rank/ItemRank_%s",config1[6])
    --self.channel = config.channel
    --self.checkpoint = config.checkpoint
    --self.use = config.use
    --self.fall = config.fall
    self.name = config1[2]
    self.txt = config1[3]
    ---通知
    self:Notify()
end
---添加监听
function RandomItemData:AddNotify(tag, _func)
    self.notify[tag] = _func
end
---状态更新
function RandomItemData:Notify()
    for tag,_func in pairs(self.notify) do
        ---通知更新
        if _func ~= nil then
            if pcall(_func) then
                ---无异常不处理
            else
                ---异常则移除
                _func = nil
            end
        end
    end
end

return RandomItemData