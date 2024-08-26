---@class RolePlotAtlasData
RolePlotAtlasData = Class('RolePlotAtlasData')

function RolePlotAtlasData:ctor(id)
    local config = RoleprofileLocalData.tab[id]
    self.id = config[1]       ---id
    self.favor = config[2]     ---好感度
    self.roleId = config[8]     ---角色id
    self.roleCover = config[9]    ---角色封面
    self.roleBg = config[10]    ---角色背景
    self.plotName = config[11]    ---剧情名字
    self.plot = config[12]    ---剧情
    self.appear = config[13]     ---是否显示
    self.order = config[14]    ---剧情排序
end

---获取是否显示状态 返回1显示 2上锁 0不显示
function RolePlotAtlasData:GetShowState()
    local role = HeroControl.GetRoleDataByID(self.roleId)
    if self.appear == 1 then
        ---如果角色已解锁
        if role.lockState == true then
            return 1
        else
            return 2
        end
    elseif self.appear == 0 then
        ---如果角色已解锁
        if role.lockState == true then
            return 1
        else
            return 0
        end
    end
    return 0
end

---获取当前角色好感是否满足剧情解锁
function RolePlotAtlasData:GetUnlockState()
    local role = HeroControl.GetRoleDataByID(self.roleId)
    if role.favor >= self.favor then
        return true
    end
    return false
end

function RolePlotAtlasData:GetRoleData()
    return HeroControl.GetRoleDataByID(self.roleId)
end

return RolePlotAtlasData