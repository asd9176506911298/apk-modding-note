---@class EquipData 共鸣装备数据
---@field attrs CoreAttrData[] 共鸣装备属性
EquipData = Class("EquipData")
-------------构造方法-------------
function EquipData:ctor(id)
    self.equipID = id       ---装备id
    self.level = 0          ---装备等级
    self.lockState = false  ---是否已解锁
    local config = RoleequipmentLocalData.tab[id]
    if not config[8] then
        print(id)
    end
    self.attribute = config[8]                              ---装备配置属性
    self.maxLevel = tonumber(config[11])                    ---装备最大等级
    self.position = config[7]                               ---装备部位
    self.name = config[2]                                   ---装备名称
    self.txt = config[3]                                    ---装备文本
    self.quality = config[6]                                ---装备品质
    self.icon = string.format("Equip/%s",config[4])  ---装备图标
    self.iconFrame = "Equip/Rank/VoidGearRank_0" ---装备边框图标
    self.iconBFrame = string.format("Equip/Rank/VoidGearRankBig_%s",config[6]) ---装备边框大
    self.iconLFrame = string.format("Equip/Rank/VoidGearRankLarge_%s",config[6]) ---装备边框巨大
    self.attrs = self:LoadAttrs()                                         ---共鸣装备实际属性
    self.keepSake = config[10]                              ---重复材料
end
---@class EquipInfo 服务器定义的共鸣装备结构
local EquipInfo = {
    equipID = 1,
    equipLevel = 2,
}
---@param equip EquipInfo 覆盖装备数据
function EquipData:PushData(equip)
    self.level = equip.equipLevel
    self.lockState = true
    self.iconFrame = string.format("Equip/Rank/VoidGearRank_%s",self.quality)  ---装备边框图标
    ---更新属性
    self.attrs = self:LoadAttrs()
end

---@return CoreAttrData[] 根据服务器给的properties按万分位覆盖核心属性
function EquipData:LoadAttrs()
    ---清空已有数值
    local attrs = {}
    local config = RoleequipmentLocalData.tab[self.equipID]
    ---重新添加核心数据(配置完善后下面两列还原)
    local attrs_str =string.split(config[8],',')
    for i = 1, #attrs_str do
        local attr_str = string.split(attrs_str[i],'_')
        ---@type CoreAttrData
        local attrData = CoreAttrData.New()
        local attrId = tonumber(attr_str[1])    ---属性配置表id
        local attrEnum = (attr_str[1] == "1" or attr_str[1] == "3") and 1 or 0  ---属性类型 0值 1百分比
        local attr = self.level * tonumber(string.split(attr_str[2],"*")[2])  ---属性具体数值
        if attrId ~= 0 or attrId ~= 2 then
            attr = attr * 0.01
        end
        attrData:PushData(i,attrId,attrEnum,attr)
        attrs[attrData.attrUID] = attrData
    end
    return attrs
end
---@return RoleData 查找装备所属角色
function EquipData:GetRole()
    for i, v in pairs(HeroControl.GetAllHero()) do
        for i, id in pairs(v.equipArr) do
            if id == self.equipID then
                return v
            end
        end
    end
    return nil
end
return EquipData