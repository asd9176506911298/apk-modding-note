OriginalControl = {}
require("LocalData/MonsterdexLocalData")
require("Model/Illustration/Data/OriginalAtlasData")

---@type OriginalAtlasData[] 所有原罪数据
local AllOriginalData = {}
---@type OriginalAtlasData[] 原罪主页签数据
local SwitchData = {}
---@type OriginalAtlasData[] 当前已解锁的原罪数据
local DetailedData = {}

function OriginalControl.Init()
    for k,v in pairs(MonsterdexLocalData.tab) do
        table.insert(AllOriginalData,OriginalAtlasData.New(v[1]))
    end

    for k,v in pairs(AllOriginalData) do
        if SwitchData[v.type] == nil and v:GetShowState() == true then
            SwitchData[v.type] = v
        end
        if v:GetLockState() == true then
            ---已解锁的不显示红点
            v.showRedDot = false
        else
            v.showRedDot = true
        end
        if DetailedData[v.type] == nil then
            DetailedData[v.type] = {}
        end
    end

    for k,v in pairs(AllOriginalData) do
        for i,switch in pairs(DetailedData) do
            if v.type == i then
                table.insert(DetailedData[i],v)
            end
        end
    end
end

---@return OriginalAtlasData[] 获取主页签数据
function OriginalControl.GetSwitchData()
    local arr = {}
    for k,v in pairs(SwitchData) do
        table.insert(arr,v)
    end
    Global.Sort(arr,{"type"},false)
    return arr
end

---@return OriginalAtlasData[] 传入类型获取所有该类型的原罪数据
function OriginalControl.GetOriginalDataByType(type)
    local arr = {}
    for k,v in pairs(AllOriginalData) do
        if v.type == type then
            table.insert(arr,v)
        end
    end
    Global.Sort(arr,{"sort"},false)
    return arr
end

---@return OriginalAtlasData[] 传入类型获取所有该类型的解锁原罪数据
function OriginalControl.GetUnlockOriginalDataByType(type)
    local arr = {}
    for k,v in pairs(AllOriginalData) do
        if v.type == type then
            table.insert(arr,v)
        end
    end
    Global.Sort(arr,{"sort"},false)
    return arr
end

---刷新是否解锁数据
function OriginalControl.RefreshUnlock()
    for k,v in pairs(AllOriginalData) do
        if v.showRedDot == true and v:GetLockState() == true then
            v.showRedDot = true
        else
            v.showRedDot = false
        end
    end
end

---获取类型红点状态
function OriginalControl.GetTypeState(type)
    for k,v in pairs(DetailedData[type]) do
        if v.showRedDot == true then
            return true
        end
    end
    return false
end

function OriginalControl.Clear()
    AllOriginalData = {}
    SwitchData = {}
    DetailedData = {}
end

return OriginalControl