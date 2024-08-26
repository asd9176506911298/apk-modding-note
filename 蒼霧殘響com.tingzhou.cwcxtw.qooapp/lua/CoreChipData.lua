---@class CoreChipData 核心碎片数据
CoreChipData = Class("CoreChipData",ItemDataBase)
-------------构造方法-------------
function CoreChipData:ctor()
    CoreChipData.super.ctor(self)
    ---@type goods 物品goods
    self.goods = {}
    self.uid = 0            ---uid
    self.id = 0             ---物品配置ID
    self.count = 0          ---数量
    self.goodsType = 0      ---goods类型
    self.group = 0          ---物品组别
    self.quality = 0        ---物品品质
    self.star = 0           ---物品星级
    self.icon = ""          ---物品图标
    self.iconFrame = ""     ---物品边框
    self.channel = ""       ---物品获取途径
    self.checkpoint = ""    ---物品掉落关卡
    self.use = 0            ---能否使用
    self.name = ""          ---物品名称
    self.txt = ""           ---物品介绍
    self.consumeCount = 0   ---合成所需的数量
end
-------------数据操作方法-------------
---@param goods goods 覆盖数据
---@param pushType number 填充类型
function CoreChipData:PushData(goods,pushType)
    local config = CorechipLocalData.tab[goods.goodsID]
    if config == nil then
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
    self.group = 0
    self.quality = config.quality
    self.star = config.itemstar
    self.icon = "Item/"..config.icon
    self.iconFrame = string.format("Item/Rank/ItemRank_%s",config.quality)
    self.channel = config.channel
    self.checkpoint = config.checkpoint
    self.use = config.use
    self.name = config.name
    self.txt = config.txt
    self.consumeCount = self:GetConsumeCount(goods.goodsID)
end

function CoreChipData:GetConsumeCount(id)
    print(id)
    return SynthesisLocalData.tab[id][2]
end

return CoreChipData