TeamAtlasControl = {}
require("LocalData/TeamdexnewLocalData")
require("LocalData/ActorLinesLocalData")
require("Model/Illustration/Data/TeamAtlasData")


---@type TeamAtlasData[] 所有队伍数据
local AllTeamData = {}
---@type TeamAtlasData[] 地区数据(已筛选)
local RegionData = {}
---@type TeamAtlasData[] 当前地区数据
local CurRegionData = {}
---当前角色id
local CurRoleId = nil

---初始化
function TeamAtlasControl.Init()
    ---灌注所有队伍数据
    for k,v in pairs(TeamdexnewLocalData.tab) do
        table.insert(AllTeamData,TeamAtlasData.New(v.id))
    end
end

---筛选地区数据
function TeamAtlasControl.ScreenTeamData()
    local arr = {}
    RegionData = {}
    for k,v in pairs(AllTeamData) do
        if arr[v.AreaType] == nil then
            arr[v.AreaType] = {}
        end
        ---如果表不为空
        if arr[v.AreaType] ~= nil then
            ---如果小队可显示
            if v:GetShowState() == true then
                table.insert(arr[v.AreaType],v)
            end
        end
    end
    ---如果地区内小队数量为0则不显示
    for k,v in pairs(arr) do
        if #v ~= 0 then
            table.insert(RegionData,v)
        end
    end
end

---获取所有小队数据
function TeamAtlasControl.GetAllTeamData()
    return AllTeamData
end

---获取地区数据
function TeamAtlasControl.GetRegionData()
    return RegionData
end

---获取所有可显示的队伍数据
function TeamAtlasControl.GetFilteredTeamDate()
    local arr = {}
    for k,v in pairs(AllTeamData) do
        if v:GetShowState() == true then
            table.insert(arr,v)
        end
    end
    ---排序
    Global.Sort(arr,{"id"},false)
    return arr
end

---传入地区类型获取所有该类型的队伍数据
function TeamAtlasControl.GetSingleRegionData(areaType)
    local arr = {}
    for k,v in pairs(RegionData) do
        if v[1].AreaType == areaType then
            arr = v
            break
        end
    end
    Global.Sort(arr,{"AreaSort"},false)
    return arr
end

---传入角色id获取该角色小队数据
function TeamAtlasControl.GetSingleTeamData(roleId)
    local roleData = HeroControl.GetRoleDataByID(roleId)
    for k,v in pairs(AllTeamData) do
        ---找到相同的阵营类型
        if v.TeamType == roleData.CampType then
           return v
        end
    end
    return nil
end

---获取角色档案当前的地区数据
function TeamAtlasControl.GetCurRegionData()
    return CurRegionData
end
---推送角色档案当前的地区数据
function TeamAtlasControl.PushCurRegionData(data)
    CurRegionData = data
end
---清理角色档案当前的地区数据
function TeamAtlasControl.ClearCurRegionData()
    CurRegionData = {}
end

---获取当前角色id
function TeamAtlasControl.GetCurRoleId()
   return CurRoleId
end
---清理当前角色id
function TeamAtlasControl.ClearCurRoleId()
    CurRoleId = nil
end

---传入角色id打开角色档案外部调用
function TeamAtlasControl.OpenRoleArchive(roleId)
    ---默认展示第一个队伍第一个角色
    if roleId == nil then
        local str = string.split(AllTeamData[1].characterID,",")
        roleId = tonumber(str[1])
    end

    local roleData = HeroControl.GetRoleDataByID(roleId)
    local arr = nil
    for k,v in pairs(AllTeamData) do
        ---找到相同的阵营类型
        if v.TeamType == roleData.CampType then
            ---获取该阵营类型的地区数据
            arr = TeamAtlasControl.GetSingleRegionData(v.AreaType)
            break
        end
    end
    ---改变当前角色id
    CurRoleId = roleId
    ---推送角色档案当前的地区数据
    TeamAtlasControl.PushCurRegionData(arr)
    MgrUI.GoHide(UID.RoleArchive_UI)

end

---传入角色id获取个人简介数据
function TeamAtlasControl.GetProfileData(id)
    local arr = {}
    local hero = HeroControl.GetRoleDataByID(id)
    local tCurFavorLv = Global.CheckFavorLv(hero.favor)
    ---角色背景
    local _InfoDocTab=JNStrTool.strSplit(",",hero.briefintroduction)
    for i, n in ipairs(_InfoDocTab) do
        local _TempInfoTab = JNStrTool.strSplit("_",n)
        local t =
        {
            favor = tonumber(_TempInfoTab[1]),
            id = tonumber(_TempInfoTab[2]),
            isLock = false
        }
        if tonumber(_TempInfoTab[1]) <= tCurFavorLv  then
            ---角色好感度不足
            t.isLock = true
        else
            ---角色好感度满足
            t.isLock = false
        end
        table.insert(arr,t)
    end
    return arr
end

---传入id获取角色语音数据
function TeamAtlasControl.GetVoiceData(id)
    local arr = {}
    local hero = HeroControl.GetRoleDataByID(id)
    local skin = HeroControl.GetSkinDataBySkinId(hero.skin)

    for i, n in pairs(ActorLinesLocalData.tab) do
        -- 匹配到对应的组别
        if n[2] == tonumber(skin.interaction) then      --匹配当前角色的语音
            if string.sub(n[5], 1, 1) == "1" then
                local str = JNStrTool.strSplit("_",n[5])
                local t =
                {
                    favor =  tonumber(str[3]),
                    type = n[3],
                    jpPath = n[13],
                    id = n[1],
                    isLock = false
                }
                if hero.favor >= tonumber(str[3]) then
                    t.isLock = true
                else
                    t.isLock = false
                end
                table.insert(arr,t)
            else
                local t =
                {
                    favor = 0,
                    type = n[3],
                    jpPath = n[13],
                    id = n[1],
                    isLock = true
                }
                table.insert(arr,t)
            end
        end
    end

    table.sort(arr, function(a,b)
        return a.id < b.id
    end)
    return arr
end

function TeamAtlasControl.Clear()
    AllTeamData = {}
    RegionData = {}
    CurRegionData = {}
    CurRoleId = nil
end

return TeamAtlasControl