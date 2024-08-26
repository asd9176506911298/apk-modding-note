require("Model/Equip/Data/EquipData")
require("LocalData/RoleequipmentLocalData")
---物品管理器
EquipControl = {}

---@type EquipData[] 共鸣装备数据
local EquipDataList = {}

-------------提供接口-------------
---创建所有共鸣装备
function EquipControl.CreateAllEquip()
    for i, v in pairs(RoleequipmentLocalData.tab) do
        EquipDataList[i] = EquipData.New(i)
    end
end

---@return EquipData 获取单个共鸣装备
function EquipControl.GetSingleEquips(id)
    if id == nil then
        return nil
    end
    return EquipDataList[id]
end
---@param equipGroup EquipInfo[] 填充多个物品到道具背包
function EquipControl.PushGroupEquipData(equipGroup)
    if not equipGroup then
        print("推送装备为空")
        return
    end
    for idx, equip in pairs(equipGroup) do
        EquipControl.PushSingleEquipData(equip)---添加到道具背包
    end
end
---@param equip EquipInfo 添加单个共鸣装备到背包
function EquipControl.PushSingleEquipData(equip)
    if not EquipDataList[equip.equipID] then
        ---背包没有装备直接添加
        EquipDataList[equip.equipID] = EquipData.New(equip.equipID)
    end
    ---刷新数据
    EquipDataList[equip.equipID]:PushData(equip)
    ItemControl.PushSingleItemData({
        goodsID = equip.equipID,
        goodsNum = 1,
        goodsType = 5
    }, ItemControl.PushEnum.add)
end
---@param id number 装备id
---@param level number 装备等级
---@return EquipData
function EquipControl.CreateSingleEquip(id,level)
    ---@type EquipData
    local data = EquipData.New(id)
    data:PushData({equipLevel = level})
end

function EquipControl.ReturnSingleEquip(id,level)
    ---@type EquipData
    local data = EquipData.New(id)
    data:PushData({equipLevel = level})
    return data
end

function EquipControl.Clear()
    EquipDataList = {}
end

return EquipControl