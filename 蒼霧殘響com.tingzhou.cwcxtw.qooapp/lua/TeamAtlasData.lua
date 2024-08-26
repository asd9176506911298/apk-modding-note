---@class TeamAtlasData
TeamAtlasData = Class('TeamAtlasData')

function TeamAtlasData:ctor(id)
    local config = TeamdexnewLocalData.tab[id]
    self.id = config.id
    self.AreaType = config.areatype          ---地区类型
    self.AreaName = config.areatxt           ---地区名
    self.AreaTitle = config.area_txtname           ---地区标题
    self.AreaTxt = config.area_txt           ---地区简介
    self.AreaBg = config.areapng           ---地区背景
    self.TeamName = config.typename           ---队伍名
    self.AreaSort = config.areatype_withinnumber           ---地区内小队排序
    self.characterID = config.characterid           ---小队包含角色
    self.visible = config.visiable           ---是否显示 0不显示 1显示 2拥有时显示
    self.TeamType = config.camp_type         ---阵营类型
end

---检查是否显示小队
function TeamAtlasData:GetShowState()
    ---不显示
    if self.visible == 0 then
        return false
    elseif self.visible == 1 then
        ---一直显示
        return true
    end
    local str = string.split(self.characterID,",")
    local isHave = false
    for k,v in pairs(str) do
        ---如果拥有
        if HeroControl.GetRoleDataByID(tonumber(v)).lockState == true then
            isHave = true
            break
        end
    end
    ---拥有角色时显示
    if self.visible == 2 then
        return isHave
    end
    ---其余默认不显示
    return false
end

---获取小队图标
function TeamAtlasData:GetTeamIcon()
    local str = string.split(self.characterID,",")
    local roleData = HeroControl.GetRoleDataByID(tonumber(str[1]))
    if roleData == nil or roleData.CampiconName == nil then
        return ""
    end
    return roleData.CampiconName
end

return TeamAtlasData