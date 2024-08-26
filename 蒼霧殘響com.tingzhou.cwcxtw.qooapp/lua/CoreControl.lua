require("Model/Core/Data/CoreData")
require("Model/Core/Data/CoreAttrData")
require("Model/Core/Data/CoreDecomposeData")
require("LocalData/CoreLocalData")
require("LocalData/CorestrengthenLocalData")
require("LocalData/CorerestructureLocalData")
require("LocalData/ArmoredcoreLocalData")
require("LocalData/DecomposeLocalData")

---核心管理器
CoreControl = {}

---@type CoreData[] 核心数据
local CoreDataList = {}

---@return CoreData[] 获取核心缓存
function CoreControl.GetCores(isList)
    if isList then
        return CoreDataList
    else
        local array = {}
        for i, v in pairs(CoreDataList) do
            table.insert(array,v)
        end
        return array
    end
end

---@param CoreGoods goods[] 移除核心
function CoreControl.DeleteCore(CoreGoods)
    for m, n in pairs(CoreGoods) do
        for i, v in pairs(CoreDataList) do
            if n.goodsID  == v.uid  then
                CoreDataList[i] = nil
                if UnityEngine.PlayerPrefs.HasKey(tostring(n.goodsID)) then
                    UnityEngine.PlayerPrefs.DeleteKey(tostring(n.goodsID))
                end
                break
            end
        end
    end
end

---@return CoreData 获取单个核心
function CoreControl.GetSingleCoreData(uid)
    if uid == nil then
        return nil
    end
    for i, data in pairs(CoreDataList) do
        if data.uid == uid then
            return data
        end
    end
    return nil
end
---@param armorsGroup armors[] 覆盖填充多个核心
function CoreControl.PushGroupCoreData(armorsGroup)
    if not armorsGroup then
        Log.Error("添加的核心数据为空")
        return
    end
    for idx, armors in pairs(armorsGroup) do
        CoreControl.PushSingleCoreData(armors)
    end
end
---@param armors armors 填充单个核心
function CoreControl.PushSingleCoreData(armors)
    if not CoreDataList[armors.ID] then
        ---不存在核心时创建
        CoreDataList[armors.ID] = CoreData.New()
    end
    ---刷新数据
    CoreDataList[armors.ID]:PushData(armors)
end
---@return CoreData 创建单个核心
function CoreControl.CreateSingleCore(id,properties,skill)
    ---@type CoreData
    local core = CoreData.New()
    core:PushConfig(id,properties,skill)
    return core
end

---保存装备锁状态
function CoreControl.SaveCoreLock(CoreUid,lock)
    ---以装备Uid来保存装备是否上锁
    UnityEngine.PlayerPrefs.SetInt(string.format("%s",CoreUid),lock)
end
---读取装备锁状态
function CoreControl.GetCoreLock(CoreUid)
    ---以装备Uid来保存装备是否上锁
    return UnityEngine.PlayerPrefs.GetInt(string.format("%s",CoreUid))
end
---删除装备锁数据
function CoreControl.DeleteCoreLock(CoreUid)
    UnityEngine.PlayerPrefs.DeleteKey(string.format("%s",CoreUid))
end

function CoreControl.CheckCorelevel(core,exp)
    local thisQuality = {}
    for i,v in pairs(CorestrengthenLocalData.tab) do
        if core.quality == v[3] and core.star == v[2] then
            table.insert(thisQuality,v)
        end
    end
    table.sort(thisQuality,function(a,b)
        if a[4] < b[4] then
            return true
        else
            return false
        end
    end)
    for i, v in ipairs(thisQuality) do
        if exp >= v[5] then
            core.level = v[4] + 1
        end
    end
end

function CoreControl.Clear()
    CoreDataList = {}
end
return CoreControl