require("Model/CardDraw/Data/RoleDrawData")
require("Model/CardDraw/Data/EquipDrawData")
require("LocalData/RolerecruitLocalData")
require("LocalData/EquipmentsupplyLocalData")

CardDrawControl = {}
---@type RoleDrawData[] 所有抽角色数据
local CacheRoleDrawList = {}
---@type EquipDrawData[] 所有抽装备数据
local CacheEquipDrawList = {}
---所有抽取数据
local AllCacheDrawList = {}

---初始化数据
function CardDrawControl.Init()
    ---初始化抽角色数据
    for id,config in pairs(RolerecruitLocalData.tab) do
        CacheRoleDrawList[id] = RoleDrawData.New(id)
    end
    ---初始化装备数据
    for id,config in pairs(EquipmentsupplyLocalData.tab) do
        CacheEquipDrawList[id] = EquipDrawData.New(id)
    end
    ---初始化所有抽取数据
    Global.Sort(CacheRoleDrawList,{"sort"} ,false)
    Global.Sort(CacheEquipDrawList,{"sort"} ,false)
    local aa = PlayerControl.GetPlayerData().lotterys
    for k,v in pairs(CacheRoleDrawList) do
        AllCacheDrawList[#AllCacheDrawList + 1] = v
    end
    for k,v in pairs(CacheEquipDrawList) do
        AllCacheDrawList[#AllCacheDrawList + 1] = v
    end
end

---获取抽卡数据传入id
function CardDrawControl.GetDataById(id)
    for k,v in pairs(AllCacheDrawList) do
        if id == v.id then
            return v
        end
    end
    return nil
end

---获取所有抽卡数据
function CardDrawControl.GetAllDrawData()
    return AllCacheDrawList
end

---获取除了新手卡池外的所有卡池(不含未解锁卡池)
function CardDrawControl.GetAllCanDrawData()
    local arr = {}
    if NoviceViewModel.CurTaskId == 52405 then
        return CardDrawControl.GetNoviceDrawData()
    end
    for k,v in pairs(AllCacheDrawList) do
        if v.id ~= 999999 and v:WhetherIsOpen() then
            if v.cardType == 1 and v:WhetherMaxCount() == false and v:WhetherShow() then
                table.insert(arr,v)
            elseif v.cardType == 2 and v:WhetherShow() then
                table.insert(arr,v)
            end
        end
    end
    return arr
end

---获取所有卡池(不含新手池)
function CardDrawControl.GetAllNormalDrawData()
    local arr = {}
    for k,v in pairs(AllCacheDrawList) do
        ---如果是角色池且不是新手池且池子未过期
        if v.id ~= 999999 and v:WhetherIsOpen() then
            if v.cardType == 1 and v:WhetherMaxCount() == false and v:WhetherShow() then
                table.insert(arr,v)
            elseif v.cardType == 2 and v:WhetherShow() and SysLockControl.CheckSysLock(1302) then
                table.insert(arr,v)
            end
        end
    end
    return arr
end

---获取新手卡池
function CardDrawControl.GetNoviceDrawData()
    local arr = {}
    for k,v in pairs(AllCacheDrawList) do
        if v.id == 999999 then
            table.insert(arr,v)
        end
    end
    return arr
end

---获取所有装备卡池
function CardDrawControl.GetEquipDrawData()
    return CacheEquipDrawList
end

---获取UP角色
function CardDrawControl.GetUpRole()
    local arr = {}
    for k,v in pairs(CacheRoleDrawList) do
        arr[v.id] = v.UpRole
    end
    return arr
end

---推送卡池数据
function CardDrawControl.PushCardPoolData(data)
    if data == nil then
        return
    end
    for k,v in pairs(data) do
        for i,pool in pairs(CacheRoleDrawList) do
            if pool.id == v.lotteryID then
                pool:PushData(v)
            end
        end
    end
end

---推送单独卡池数据
function CardDrawControl.PushSinglePoolData(id,count)
    for k,v in pairs(CacheRoleDrawList) do
        if v.id == id then
            v.count = count
            break
        end
    end
end

function CardDrawControl.Clear()
    CacheRoleDrawList = {}
    CacheEquipDrawList = {}
    AllCacheDrawList = {}
end

return CardDrawControl