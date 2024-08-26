---@class SynthesisData
SynthesisData = Class('SynthesisData')
require("LocalData/RoleequipmentLocalData")
---@param id number 构造方法
function SynthesisData:ctor(id,type)
    local dataType = 1
    local config = nil
    -- if EnergysynthesisLocalData.tab[id] then
    --     dataType = 1
    --     config = EnergysynthesisLocalData.tab[id]
    -- elseif SkillitemsynthesisLocalData.tab[id] then
    --     dataType = 2
    --     config = SkillitemsynthesisLocalData.tab[id]
    -- else
    --     dataType = 3
    --     config = RoleeqsynthesisLocalData.tab[id]
    -- end

    if type == 1 then
        dataType = 1
        config = EnergysynthesisLocalData.tab[id]
    elseif type == 2 then
        dataType = 2
        config = SkillitemsynthesisLocalData.tab[id]
    else
        dataType = 3
        config = EnergysynthesisLocalData.tab[id]
    end

    self.id = id                               ---ID
    self.synthesisItem = nil            ---合成目标
    if dataType == 1 then self.synthesisItem = config[2] end
    if dataType == 2 then self.synthesisItem = config[3] end
    if dataType == 3 then self.synthesisItem = config[2] end

    self.synthesisCost = nil          ---合成花费
    if dataType == 1 then self.synthesisCost = config[3] end
    if dataType == 2 then self.synthesisCost = config[4]..","..config[5] end
    if dataType == 3 then self.synthesisCost = config[3] end

    self.type = nil                   ---类型
    if dataType == 1 then self.type = config[4] end
    if dataType == 2 then self.type = config[6] end
    if dataType == 3 then self.type = config[4] end
    self.quality = nil                         ---品质
    --区分数据来源是那张表
    self.dataType = dataType

    self.display = 1
    if dataType == 2 then self.display = config[7] end
    if dataType == 3 then self.display = config[5] end

    self.roleid = 0
    if dataType == 2 then self.roleid = config[2] end
    if dataType == 3 then self.roleid = config[6] end
end

---获取合成目标和数量
function SynthesisData:GetSynthesisItem()
    local str = string.split(self.synthesisItem,"_")
    local item = nil
    if tonumber(str[1]) == 5 then
        local data = RoleequipmentLocalData.tab[tonumber(str[2])]
        item = ItemControl.GetItemByID(tonumber(str[2]))
        item.id = data[1]
        item.name = data[2]
        item.icon = "Equip/"..data[4]
    else
        item = ItemControl.GetItemByID(tonumber(str[2]))
    end
    item.needCount = tonumber(str[3])
    return item
end
---获得合成花费物品和数量
function SynthesisData:GetSynthesisCost()
    local str = string.split(self.synthesisCost,",") --123
    local array = {}
    for k,v in pairs(str) do
        if v == "," or v == 0 or v == "0" then
            break
        end
        local itemStr = string.split(v,"_")
        local item =  ItemControl.GetItemByID(tonumber(itemStr[2]))
        item.needCount = tonumber(itemStr[3])
        table.insert(array,item)
    end
    return array
end

return SynthesisData