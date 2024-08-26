
require("Model/Role/Data/RoleData")
require("LocalData/MonsterLocalData")
---物品管理器
MonsterControl = {}

---@type --MonsterData[] 怪数据
---@type RoleData[] 怪数据
local MonsterDataList = {}

-------------提供接口-------------
---创建所有配置怪物信息
function MonsterControl.CreateAllMonster()
    for i, v in pairs(MonsterLocalData.tab) do
        --MonsterDataList[i] = MonsterData.New(i)
        MonsterDataList[i] = RoleData.New(i)
    end
end
---@return --MonsterData 获取配置怪物信息
---@return RoleData 获取配置怪物信息
function MonsterControl.GetMonster(ID)
    return MonsterDataList[ID]
end

---@return --MonsterData 获取一个怪物数据
---@return RoleData 获取一个怪物数据
function MonsterControl.CreateSingleMonster(id,star,level,isAwaken,skillLv,sIndex,scale,isBoss,core1Id,core1properties,core1skill,core2Id,core2properties,core2skill,atkOrder)
    ---@type --MonsterData
    --local data = MonsterData.New(id)
    --data:SetData(star,level,isAwaken,skillLv,sIndex,scale,isBoss,core1Id,core1properties,core1skill,core2Id,core2properties,core2skill,atkOrder)
    ---@type RoleData
    local data = RoleData.New(id)
    data:SetMonsterData(star,level,isAwaken,skillLv,sIndex,scale,isBoss,core1Id,core1properties,core1skill,core2Id,core2properties,core2skill,atkOrder)
    return data
end

function MonsterControl.Clear()
    MonsterDataList = {}
end

return MonsterControl