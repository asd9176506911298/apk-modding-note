---@class OriginalAtlasData
OriginalAtlasData = Class('OriginalAtlasData')

---@param id number 构造方法
function OriginalAtlasData:ctor(id)
    local config = MonsterdexLocalData.tab[id]
    self.id = config[1]
    self.type = config[2]        ---类型
    self.typeName = config[3]     ---类型名
    self.sort = config[4]    ---类型内排序
    self.monsterId = config[5]   ---怪物id
    self.name = config[6]     ---怪物名字
    self.details = config[8]    ---怪物介绍
    self.cv = config[10]    ---CV
    self.unlockId = config[12]    ---是否解锁ID
    self.smallIcon = config[14]   ---小图标
    self.visible = config[16]   ---是否显示
    self.showRedDot = true     ---是否显示红点
end

function OriginalAtlasData:GetShowState()
    if self.visible == 0 then
        return false
    elseif self.visible == 1 then
        return true
    end

    if self.visible == 2 then
        return StormControl.CheckPointPass(self.unlockId)
    end
    return false
end

---获取是否解锁
function OriginalAtlasData:GetLockState()
    return StormControl.CheckPointPass(self.unlockId)
end

return OriginalAtlasData