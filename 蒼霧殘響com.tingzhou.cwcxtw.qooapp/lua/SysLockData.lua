---@class SysLockData
SysLockData = Class('SysLockData')

function SysLockData:ctor(id)
    local config = SystemopenLocalData.tab[id]
    self.sysId = config[2]      --系统ID
    self.sysName = config[3]    --系统名字
    self.sysLockLv = config[4]  --系统解锁的等级
    self.sysLockPointId = config[8]     --系统解锁前提关卡
end

return SysLockData