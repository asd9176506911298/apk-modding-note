require("Model/Role/Data/RoleData")
require("Model/Role/Data/RoleSkinData")
require("Model/Hero/Data/RoleFavorData")
require("LocalData/RoleattributeLocalData")
require("LocalData/RoleattrilevelLocalData")
require("LocalData/RolefavorabilityLocalData")
require("LocalData/UiskinlockLocalData")
require("LocalData/RoleuiskinLocalData")
require("LocalData/MainuiskinLocalData")

---物品管理器
HeroControl = {}

HeroControl.AckError = false

---@type RoleData[] 角色数据
local HeroDataList = {}

---@type RoleSkinData[] 角色皮肤数据
local HeroSkinDataList = {}

local AllHeroOriginalDataList = {}

-------------提供接口-------------
---@return RoleData
function HeroControl.GetRoleDataByID(roleId)
    return HeroDataList[roleId]
end

function HeroControl.SetRoleFavorByID(roleId,favor)
    HeroDataList[roleId].favor = favor
end

function HeroControl.CreateAllOriginalHeroData()
    for id, v in pairs(RoleattributeLocalData.tab) do
        if v[72] == 1 then
            ---没有角色且加入游戏才创建
            AllHeroOriginalDataList[id] = RoleData.New(id)
        end
    end
end
function HeroControl.GetOriginalHero(id)
    return AllHeroOriginalDataList[id]
end
---创建所有角色皮肤数据
function HeroControl.CreateAllSkinData()
    for skinId, v in pairs(RoleuiskinLocalData.tab) do
        if not HeroSkinDataList[skinId] then
            ---创建所有皮肤数据
            HeroSkinDataList[skinId] = RoleSkinData.New(skinId)
        end
        for i, v in pairs(HeroSkinDataList) do
            if v.unlock.goodsID ~= nil and ItemControl.GetItemByIdAndType(v.unlock.goodsID, v.unlock.goodsType).count >= v.unlock.goodsNum then
                v:SetLockState(true)
            end
        end
    end
end
---根据皮肤ID获取皮肤数据
function HeroControl.GetSkinDataBySkinId(skinId)
    if HeroSkinDataList[skinId] then
        return HeroSkinDataList[skinId]
    end
    return nil
end
---获取角色当前皮肤
function HeroControl.GetSkinDataByRoleID(roleId)
    for i,v in pairs(HeroSkinDataList) do
        if v.id == HeroDataList[roleId].skin then
            return v
        end
    end
    return nil
end

function HeroControl.GetAllSkinByRoleID(roleId)
    local allSkins = {}
    for i,v in pairs(HeroSkinDataList) do
        if v.roleId == roleId then
            table.insert(allSkins,v)
        end
    end
    table.sort(allSkins,function(a,b)
        if a.id <= b.id then
            return true
        else
            return false
        end
    end)
    return allSkins
end

function HeroControl.CheckSkinUnlocked(skinID)
    if HeroSkinDataList[skinID] then
        return HeroSkinDataList[skinID].unlockState
    end
    return false
end

function HeroControl.ChangeSkinLockState(skinID,tOrf)
    if HeroSkinDataList[skinID] then
        HeroSkinDataList[skinID].unlockState = tOrf
    end
    return false
end

function HeroControl.ClearSkin()
    HeroSkinDataList = {}
end

---创建所有角色数据
function HeroControl.CreateAllHeroData()
    for id, v in pairs(RoleattributeLocalData.tab) do
        if not HeroDataList[id] and v[72] == 1 then
            ---没有角色且加入游戏才创建
            HeroDataList[id] = RoleData.New(id)
        end
    end
end

---@return RoleData[] 获取所有游戏中的角色缓存
function HeroControl.GetAllHero()
    local array = {}
    for i, v in pairs(HeroDataList) do
        table.insert(array,v)
    end
    return array
end
---@return RoleData[] 获取已拥有角色缓存
function HeroControl.GetHaveHero()
    local array = {}
    for i, v in pairs(HeroDataList) do
        if v.lockState then
            table.insert(array,v)
        end
    end
    return array
end
function HeroControl.CheckLockById(id)
    if HeroDataList[id].lockState then
        return true
    else
        return false
    end
end
---获取游戏中的角色最大数量
function HeroControl.GetRoleMax()
    local len = 0
    for i, v in pairs(HeroDataList) do
        len = len + 1
    end
    return len
end
---@param heroGroup ---HeroInfo[] 填充角色数据到角色池
---@param heroGroup HeroInfo2[] 填充角色数据到角色池
function HeroControl.PushGroupHeroData(heroGroup)
    if not heroGroup then
        print("推送角色为空")
        return
    end
    for idx, hero in pairs(heroGroup) do
        HeroControl.PushSingleHeroData(hero)---添加到角色池
    end
end
---@param ---hero HeroInfo 添加单个角色到角色池
---@param hero HeroInfo2 添加单个角色到角色池
function HeroControl.PushSingleHeroData(hero)
    if hero.heroID == 0 then
        Log.Error("推送存在数据为0的英雄，请检查")
        return
    end
    if hero.heroID == 19000 then
        Log.Error("吉雅不需要添加到英雄池")
        return
    end
    print("推送角色！！！",hero.heroID)
    if not HeroDataList[hero.heroID] then
        HeroDataList[hero.heroID] = RoleData.New(hero.heroID)
    end
    ---刷新数据
    HeroDataList[hero.heroID]:PushHeroData(hero)
end
function HeroControl.PushGroupHeroSkinsData(skins)
    if not skins then
        print("没有已购买的皮肤")
        return
    end
    for i,skin in pairs(skins) do
        HeroControl.PushSingleHeroSkinData(skin)
    end
end
function HeroControl.PushSingleHeroSkinData(skin)
    if UiskinlockLocalData.tab[skin] == nil then
        print("没有找到该皮肤")
        return
    end
    ---查看背包中有没有对应的皮肤
    if UiskinlockLocalData.tab[skin].unlock == "0" then
        print("换装原皮")
        local hero = HeroDataList[UiskinlockLocalData.tab[skin].roleid]
        hero:PushSkinData(skin)
    else
        local unlock = UiskinlockLocalData.tab[skin].unlock
        local unlockstr = string.split(unlock,"_")
        local item = ItemControl.GetItemByIdAndType(tonumber(unlockstr[2]), tonumber(unlockstr[1]))
        if item.count > 0 then
            local hero = HeroDataList[UiskinlockLocalData.tab[skin].roleid]
            hero:PushSkinData(skin)
        else
            print("尚未拥有该皮肤")
        end
    end
end
function HeroControl.ChangeHeroSkin(skin,callback)
    local tab = {
        skin = skin.id
    }
    local bytes = assert(pb.encode('PBClient.ClientChangeSkinREQ',tab))
    MgrNet.SendReq(MID.CLIENT_CHANGE_SKIN_REQ, bytes,0,nil,function(buffer,tag)
        local tab = assert(pb.decode('PBClient.ClientChangeSkinACK',buffer))
        if tab.errNo ~= 0 then
            print("换皮肤失败"..tab.errNo)
            return
        end
    end,function(buffer,tag)
        local tab = assert(pb.decode('PBClient.ClientChangeSkinNTF',buffer))
        HeroControl.PushSingleHeroSkinData(tab.skin)
        if callback then
            callback()
        end
    end)
end
---获取角色最高星级
function HeroControl.GetHeroStarMax()
    local maxStar = 0
    for i, v in pairs(RoleattrilevelLocalData.tab) do
        if v[3] > maxStar then
            maxStar = v[3]
        end
    end
    return maxStar
end
---根据等级获取角色当前等级最大经验
function HeroControl.GetMaxExpByLevel(targetLv,id,lv,star,skillLevel,awaken)
    local role = ReadData.GetRoleAttr(id,lv,star,skillLevel,awaken)
    local maxExp = BattleRole.ReturnExp(role,targetLv)
    return maxExp
end
---@param FighterAttr FighterAttr2 角色属性
---@return RoleData 单独创建角色
function HeroControl.CreateSingleHero(FighterAttr,skinId)
    print(">>>>>>>>>>>>>>>>>",FighterAttr.base.roleID)
    local data = RoleData.New(FighterAttr.base.roleID)
    if skinId then
        data:PushSingleHeroData(FighterAttr,skinId)
    else
        data:PushSingleHeroData(FighterAttr)
    end
    return data
end
---@param FighterAttr FighterAttr2 角色属性
---@return RoleData 单独创建好友支援角色
function HeroControl.CreateSingleFriendHeroData(FighterAttr)
    local data = RoleData.New(FighterAttr.roleID)
    data:PushSingleFriendHeroData(FighterAttr)
    return data
end

---获取角色好感度信息
function HeroControl.GetFavorAbility(roleID)
    local array = {}
    for i,v in pairs(RolefavorabilityLocalData.tab) do
        if v[2] == roleID then
            local data = RoleFavorData.New()
            data:PushData(v)
            table.insert(array,data)
        end
    end
    return array
end
---获取对应好感等级的属性
function HeroControl.GetCurFavorAbility(roleID,favor)
    local favorData = HeroControl.GetFavorAbility(roleID)
    Global.Sort(favorData,{"favorAbility"},false)
    
    local curFavorLv = nil
    ---回放需要根据当时的好感度来判定
    if favor then
        curFavorLv = Global.CheckFavorLv(favor)
    else
        local tRoleData = HeroControl.GetRoleDataByID(roleID)
        curFavorLv = Global.CheckFavorLv(tRoleData.favor)
    end
    
    if curFavorLv == 1 then
        return RoleFavorData.New()
    end
    return favorData[curFavorLv-1]
end

function HeroControl.Clear()
    HeroDataList = {}
end

return HeroControl