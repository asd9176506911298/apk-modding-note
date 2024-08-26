---@class ArtGuideData
ArtGuideData = Class('ArtGuideData')

function ArtGuideData:ctor(id)
    local config = ArtguideLocalData.tab[id]
    self.id = config.sortid       ---id
    self.type = config.typeid      ---类型
    self.name = config.name      ---名字
    self.systemId = config.systemopen    ---系统解锁id
    self.visible = config.systemappear     ---是否显示 0不显示 1显示
end

---是否解锁
function ArtGuideData:GetUnlockState()
    if self.systemId == 0 then
        return true
    end
    return SysLockControl.CheckSysLock(self.systemId)
end

return ArtGuideData