require("Model/SysLock/Data/SysLockData")
require("LocalData/SystemopenLocalData")
require("LocalData/CheckpointLocalData")
---加锁管理器
SysLockControl = {}
---@type SysLockData[]
local SysLockMap = {}
local SysLockNameMap = {}

function SysLockControl.InitSysLock()
    for i, v in ipairs(SystemopenLocalData.tab) do
        SysLockMap[v[2]] = SysLockData.New(i)
    end
    for i, v in ipairs(SystemopenLocalData.tab) do
        SysLockNameMap[v[3]] = SysLockData.New(i)
    end
end
---根据ID检查该系统是否解锁
function SysLockControl.CheckSysLock(sysId)
    local playerData = PlayerControl.GetPlayerData()
    if SysLockMap[sysId] == nil or playerData.level >= SysLockMap[sysId].sysLockLv and StormControl.CheckPointPass(SysLockMap[sysId].sysLockPointId) then
        return true
    else
        return false
    end
end
---根据系统名称检查该系统是否解锁
function SysLockControl.CheckSysLockByName(sysName)
    if SysLockNameMap[sysName] == nil then
        return true
    end
    local playerData = PlayerControl.GetPlayerData()
    if playerData.level >= SysLockNameMap[sysName].sysLockLv and StormControl.CheckPointPass(SysLockNameMap[sysName].sysLockPointId) then
        return true
    else
        return false
    end
end

---传入ID返回对应解锁需求等级
function SysLockControl.GetUnlockLevel(sysId)
    return SysLockMap[sysId].sysLockLv
end
---传入系统名称返回对应解锁需求等级
function SysLockControl.GetUnlockLevelByName(sysName)
    return SysLockNameMap[sysName].sysLockLv
end

---传入ID返回对应解锁需求关卡名称
function SysLockControl.GetUnlockPoint(sysId)
    for i,v in pairs(CheckpointLocalData.tab) do
        if v.id == SysLockMap[sysId].sysLockPointId then
            return v.name
        end
    end
    return nil
end
---传入系统名称返回对应解锁需求关卡名称
function SysLockControl.GetUnlockPointByName(sysName)
    if SysLockNameMap[sysName] == nil then
        return nil
    end
    for i,v in pairs(CheckpointLocalData.tab) do
        if v.id == SysLockNameMap[sysName].sysLockPointId then
            return v.name
        end
    end
    return nil
end
---传入ID返回对应系统名称
function SysLockControl.GetSystemName(sysId)
    return SysLockMap[sysId].sysName
end

---传入ID返回未解锁tips文本
function SysLockControl.GetSystemLockTips(sysId)
    local playerData = PlayerControl.GetPlayerData()
    if playerData.level >= SysLockMap[sysId].sysLockLv and StormControl.CheckPointPass(SysLockMap[sysId].sysLockPointId) then
        return
    end
    ---如果解锁等级和解锁关卡都存在
    if SysLockMap[sysId].sysLockLv ~= 1 and SysLockMap[sysId].sysLockPointId ~= 0 then
        return string.format(MgrLanguageData.GetLanguageByKey("syslockcontrol_tips1"),SysLockControl.GetSystemName(sysId),SysLockControl.GetUnlockLevel(sysId),SysLockControl.GetUnlockPoint(sysId))
    end
    ---如果解锁等级存在
    if SysLockMap[sysId].sysLockLv ~= 1 and SysLockMap[sysId].sysLockPointId == 0 then
        return string.format(MgrLanguageData.GetLanguageByKey("syslockcontrol_tips2"),SysLockControl.GetSystemName(sysId),SysLockControl.GetUnlockLevel(sysId))
    end
    ---如果解锁关卡存在
    if SysLockMap[sysId].sysLockLv == 1 and SysLockMap[sysId].sysLockPointId ~= 0 then
        return string.format(MgrLanguageData.GetLanguageByKey("syslockcontrol_tips3"),SysLockControl.GetSystemName(sysId),SysLockControl.GetUnlockPoint(sysId))
    end
    return nil
end

function SysLockControl.Clear()
    SysLockMap = {}
    SysLockNameMap = {}
end

return SysLockControl
