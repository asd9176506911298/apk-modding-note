---@class RoleData 角色数据
RoleData = Class("RoleData")
----------------构造方法--------------------
function RoleData:ctor(id)
    self.id = id                    ---id
    self.armor1 = 0                 ---符文1id
    self.armor1Pro = 0              ---符文1占比
    self.armor1Skill = 0            ---符文1技能
    self.armor2 = 0                 ---符文2id
    self.armor2Pro = 0              ---符文2占比
    self.armor2Skill = 0            ---符文2技能
    self.core1 = nil
    self.core2 = nil
    self.type = 1                   ---类型1：玩家角色，类型2：Npc
    local config = nil
    if id > 199999 then
        config = MonsterLocalData.tab[id]
        if config == nil then
            Log.Error("怪物id不存在:"..id)
            return
        end
        self.name = config[2]           ---角色名称
        self.occupation = config[3] > 5 and 5 or config[3]     ---角色职业
        self.iconCareer = "Attribute/ProIcon_"..self.occupation  ---角色职业图标
        self.iconBattleFrame = "Quality/RoleRankN_4"   ---角色头像边框(BattleUI)
        self.skillDir = config[60]
        self.atkDescription = config[21]                                     ---角色攻击简介
        self.atkOrder = 1
    else
        config = RoleattributeLocalData.tab[id]
        if config == nil then
            Log.Error("人物id不存在:"..id)
            return
        end
        self.level = 1                  ---等级
        self.exp = 0                    ---经验
        self.star = config[21]          ---星级
        self.maxStar = config[22]       ---最大星级
        self.awaken = false             ---是否觉醒(true为已觉醒)
        self.awakenStar = config[52]    ---觉醒星级
        self.CostIcon = config[53]      ---技能升级材料(重复角色转换材料)
        self.skillLevel = 0             ---技能等级
        self.skillDir = config[81]      ---技能方向
        self.cTime = 0                  ---获得时间
        self.favor = 0                  ---好感度
        self.lockState = false          ---角色是否解锁(true为已解锁角色)
        self.skin = id                 ---该角色使用中的皮肤
        self.isNew = false              ---是否为新获取(待完善)
        ---角色拥有的共鸣装备id
        self.equipArr = {
            [1] = nil,
            [2] = nil,
            [3] = nil
        }
        ---角色共鸣装备等级（按照角色配置表的顺序依次填写）
        self.equipLvArr = {
            [1] = 0,
            [2] = 0,
            [3] = 0
        }
        local equipStrArr = string.split(config[73],",")
        for i = 1, #equipStrArr do
            self.equipArr[i] = tonumber(equipStrArr[i])
        end
        --阵营图标
        self.CampiconName=config[58]                                        ---角色阵营图标
        self.CampTxt=config[57]                                             ---角色阵营文本
        self.CampType=config[56]                                            ---角色阵营类型
        self.name = config[2]                                               ---角色名称
        self.briefintroduction = config[4]                                  ---角色背景
        self.Interaction = RoleuiskinLocalData.tab[self.skin].interaction   ---台词组别
        self.career = config[5]                                             ---角色职业
        self.painter = config[66]                                           ---角色画师
        self.voice = config[67]                                             ---角色声优
        self.rank = config[6]                                               ---角色稀有度
        self.iconFrame = "Quality/RoleRank_"..self.rank   ---角色头像边框
        self.iconCareer = "Attribute/ProIcon_"..self.career  ---角色职业图标
        self.iconBattleFrame = "Quality/RoleRankN_"..self.rank   ---角色头像边框(BattleUI)
        self.atkDescription = config[26]                                    ---角色攻击简介
        self.label = config[84]                                             ---角色定位
        self.cgSpine = config[85]                                           ---CG切换 填0没有切换填1可以切换
    end
end
---@class HeroInfo2 服务器定义的共鸣装备结构
local EquipInfo = {
    heroID = 1,         ---id
    heroLevel = 2,      ---等级
    heroExp = 3,        ---经验
    heroStar = 4,       ---星级
    heroAwaken = 5,     ---是否觉醒
    heroSkillLevel = 6, ---技能等级
    heroArmor1 = 7,     ---符文id
    heroArmor2 = 8,     ---符文id
    heroCTime = 9,      ---获得时间
    heroFavor = 10      ---好感度
}
---@class FighterAttr2 服务器定义的其他玩家数据结构
---@field base FighterBase 位置信息
local FighterAttr = {
    --- 基础角色数据
    base = 1,            --- 基础数据(站位 及 编号)
    star = 2,            --- 星级
    level = 3,           --- 等级
    awaken = 4,          --- 是否觉醒
    skill = 5,           --- 技能等级
    body = 6,            --- 体型大小(默认为1 前端自己读配表)
    boss = 7,            --- 是否为BOSS(默认为0 天梯中不会有boss)
    --- 核心数据
    armorID1 = 8,        --- 核心1ID
    armorRatio1 = 9,     --- 核心1占比
    armorSkill1 = 10,    --- 核心1技能
    armorID2 = 11,       --- 核心2ID
    armorRatio2 = 12,    --- 核心2占比
    armorSkill2 = 13,    --- 核心2技能
    --- 共鸣装备数据
    equipLevel = 14,     --- 共鸣装备等级(按照角色配置表的顺序依次填写)
}
---@class FighterAttr3 服务器定义的好友支援角色数据结构
local FriendAttr = {
    userID = 1,          ---用戶id
    roleID = 2,          ---角色id
    heroLevel = 3,       ---等级
    heroStar = 4,        ---星级
    heroAwaken = 5,      ---是否觉醒
    heroSkillLevel = 6,  ---技能等级
    heroArmor1 = 7,      ---符文id
    heroArmor2 = 8,      ---符文id
    heroEquip = 9,       ---此英雄的三件共鸣装备的等级
    heroFavor = 10,      ---英雄好感度
    friend = 11,         ---是否是好友 0 不是 1 是
    armorID = 12,        ---核心ID
    skillID = 13,        ---核心技能ID
    attr = 14,           ---属性占比
}
---@class FriendSupportInfo 服务器定义的好友支援角色数据结构
local FriendSupportInfo = {
    heroID = 1,
    heroLevel = 2,
    heroExp = 3,
    heroStar = 4,
    heroAwaken = 5,
    heroSkillLevel = 6,
    heroArmor1 = 7,
    heroArmor2 = 8,
    heroCTime = 9,
    heroFavor = 10,
    slot = 11,
    equip = 12,
}
---------------------------------怪物相关----------------------------------
---设置怪物数据
function RoleData:SetMonsterData(star,level,isAwaken,skillLv,sIndex,scale,isBoss,core1Id,core1properties,core1skill,core2Id,core2properties,core2skill,atkOrder)
    self.star = star          ---星级
    self.level = level        ---等级
    self.awaken = isAwaken      ---是否觉醒
    self.skillLevel = skillLv   ---技能等级
    self.sIndex = sIndex      ---位置索引
    self.scale = scale        ---体型比
    self.isBoss = isBoss      ---是否是Boss
    self.armor1 = core1Id
    self.armor1Pro = core1properties * 0.01
    self.armor1Skill = core1skill
    self.armor2 = core2Id
    self.armor2Pro = core2properties * 0.01
    self.armor2Skill = core2skill
    self.atkOrder = atkOrder
end
---获取怪物当前属性
function RoleData:GetMonsterAttr()
    if self.star ~= nil and self.skillLevel ~= nil and self.awaken ~= nil then
        return ReadData.GetMonsterAttr(self.id,self.star,self.skillLevel,self.awaken)
    else
        Log.Error("属性缺失无法获取当前属性")
        return nil
    end
end
---获取怪物最大属性
function RoleData:GetMonsterMaxAttr()
    return ReadData.GetMonsterAttr(self.id,tonumber(SteamLocalData.tab[118001][2]),tonumber(SteamLocalData.tab[105008][2]),true,tonumber(SteamLocalData.tab[118000][2]))
end

function RoleData:GetBossInfoAttr()
    return ReadData.GetBossAttr(self.id,self.star,self.level,9,true)
end

---@return CoreData 获取怪物核心(槽位1，槽位2)
function RoleData:GetMonsterCore(index)
    if self[string.format("core%s",index)] ~= nil then
        return self[string.format("core%s",index)]
    end
    local id = self[string.format("armor%s",index)]
    local properties = self[string.format("armor%sPro",index)]
    local skill = self[string.format("armor%sSkill",index)]
    if id == nil or id == 0 then
        return nil
    end
    if properties == nil or properties == 0 then
        return nil
    end
    self[string.format("core%s",index)] = CoreControl.CreateSingleCore(id,properties,skill)
    return self[string.format("core%s",index)]
end
---@return EquipData 获取怪物共鸣装备(有用勿删)
function RoleData:GetMonsterEquip(index)
    return nil
end
---获取怪物技能等级
function RoleData:GetMonsterSkillLevel()
    return self.skillLevel
end

---------------------------------英雄相关----------------------------------

---@param hero RoleData 覆盖装备数据并解锁角色
function RoleData:PushHeroData(hero)
    self.id = hero.heroID
    self.level = hero.heroLevel
    self.exp = hero.heroExp
    self.star = hero.heroStar
    self.awaken = hero.heroAwaken == 1
    self.skillLevel = hero.heroSkillLevel
    self.armor1 = hero.heroArmor1
    self.armor2 = hero.heroArmor2
    self.cTime = hero.heroCTime
    self.favor = hero.heroFavor
    self.lockState = true
end
function RoleData:PushSkinData(skin)
    self.skin = skin
end
---@param fighterAttr FighterAttr2 创建单独使用的角色数据
function RoleData:PushSingleHeroData(fighterAttr,skinId)
    self.id = fighterAttr.base.roleID
    self.index = fighterAttr.base.index
    self.level = fighterAttr.level
    self.star = fighterAttr.star
    self.awaken = fighterAttr.awaken == 1
    self.skillLevel = fighterAttr.skill
    self.body = fighterAttr.body
    self.boss = fighterAttr.boss
    self.armor1 = fighterAttr.armorID1
    self.armor1Pro = fighterAttr.armorRatio1
    self.armor1Skill = fighterAttr.armorSkill1
    self.armor2 = fighterAttr.armorID2
    self.armor2Pro = fighterAttr.armorRatio2
    self.armor2Skill = fighterAttr.armorSkill2
    if fighterAttr.equipLevel ~= nil then       ---如果服务器传了装备等级，就记录下来
        self.equipLvArr = fighterAttr.equipLevel
    end
    if skinId then
        self.skin = skinId
    else
        self.skin = fighterAttr.base.roleID
    end
end

---@param fighterAttr FighterAttr3 创建单独使用的好友支援角色数据，用在战斗
function RoleData:PushSingleFriendHeroData(fighterAttr)
    self.userID = fighterAttr.userID
    self.id = fighterAttr.roleID
    self.level = fighterAttr.heroLevel
    self.star = fighterAttr.heroStar
    self.awaken = fighterAttr.heroAwaken == 1
    self.skillLevel = fighterAttr.heroSkillLevel
    self.friend = fighterAttr.friend
    if fighterAttr.heroArmor1 ~= nil then
        self.armor1 = fighterAttr.heroArmor1.armorID
        self.armor1Skill = fighterAttr.heroArmor1.skillID
        self.armor1Pro = fighterAttr.heroArmor1.attr
    else
        self.armor1 = 0
        self.armor1Skill = 0
        self.armor1Pro = 0
    end
    if fighterAttr.heroArmor2 ~= nil then
        self.armor2 = fighterAttr.heroArmor2.armorID
        self.armor2Skill = fighterAttr.heroArmor2.skillID
        self.armor2Pro = fighterAttr.heroArmor2.attr
    else
        self.armor2 = 0
        self.armor2Skill = 0
        self.armor2Pro = 0
    end
    self.equipLvArr = {
        [1] = 0,
        [2] = 0,
        [3] = 0
    }
    if fighterAttr.heroEquip ~= nil then
        self.equipLvArr[1] = fighterAttr.heroEquip[1]
        self.equipLvArr[2] = fighterAttr.heroEquip[2]
        self.equipLvArr[3] = fighterAttr.heroEquip[3]
    end
    local lvUp = true
    for i, v in pairs(self.equipLvArr) do
        if v < tonumber(SteamLocalData.tab[105009][2]) then
            lvUp = false
        end
    end
    if lvUp then
        self.ShowSkillLV = self.skillLevel + 1
    else
        self.ShowSkillLV = self.skillLevel
    end
    if fighterAttr.skin ~= 0 and fighterAttr.skin ~= nil then
        self.skin = fighterAttr.skin
    else
        self.skin = self.id
    end
end

---用在好友角色显示
function RoleData:PushSingleFriendHeroData2(fighterAttr)
    self.id = fighterAttr.heroID
    self.level = fighterAttr.heroLevel
    self.star = fighterAttr.heroStar
    self.awaken = fighterAttr.heroAwaken == 1
    self.skillLevel = fighterAttr.heroSkillLevel
    if fighterAttr.heroArmor1 ~= nil then
        self.armor1 = fighterAttr.heroArmor1.armorID
        self.armor1Skill = fighterAttr.heroArmor1.armorSkill
        self.armor1Pro = fighterAttr.heroArmor1.armorProperties
    else
        self.armor1 = 0
        self.armor1Skill = 0
        self.armor1Pro = 0
    end
    if fighterAttr.heroArmor2 ~= nil then
        self.armor2 = fighterAttr.heroArmor2.armorID
        self.armor2Skill = fighterAttr.heroArmor2.armorSkill
        self.armor2Pro = fighterAttr.heroArmor2.armorProperties
    else
        self.armor2 = 0
        self.armor2Skill = 0
        self.armor2Pro = 0
    end
    self.equipLvArr = {
        [1] = 0,
        [2] = 0,
        [3] = 0
    }
    if fighterAttr.equip ~= nil then
        self.equipLvArr[1] = fighterAttr.equip[1]
        self.equipLvArr[2] = fighterAttr.equip[2]
        self.equipLvArr[3] = fighterAttr.equip[3]
    end
    if fighterAttr.skin ~= nil then
        self.skin = fighterAttr.skin
    else
        self.skin = fighterAttr.heroID
    end

end

---更新角色等级
function RoleData:PushHeroLevel(level)
    self.level = level
end
---更新角色经验
function RoleData:PushHeroExp(exp)
    self.exp = exp
end
---更新角色好感
function RoleData:PushHeroFavor(favor)
    self.favor = favor
end
---@return EquipData[] 获取角色共鸣装备
function RoleData:GetHeroVoidEquip()
    ---@type EquipData[]
    local array = {}
    for i = 1, #self.equipArr do
        array[i] = EquipControl.GetSingleEquips(self.equipArr[i])
    end
    return array
end
---判断角色装备是否全解锁并达到条件等级
function RoleData:CheckHeroEquipIsMax()
    local isLevel = true    ---三级装备是否达到条件等级
    local isLock = true     ---三件装备是否全解锁
    ---好友角色属性计算
    if self.userID ~= nil then
        for i = 1, #self.equipLvArr do
            if self.equipLvArr[i] < tonumber(SteamLocalData.tab[105009][2]) then
                isLevel = false
            end
        end
        return isLevel
    end
    ---自己角色属性计算
    if not self.equipArr then
        return
    end
    for i = 1, #self.equipArr do
        local data = EquipControl.GetSingleEquips(self.equipArr[i])
        if not data then
            return
        end
        if data.level < tonumber(SteamLocalData.tab[105009][2]) then
            ---若存在未满级装备置为false
            isLevel = false
        end
        if not data.lockState then
            ---若存在未解锁装备置为false
            isLock = false
        end
    end
    ---判断是否满足三件套满级，满级时技能等级+1
    return isLevel --and isLock
end
---获取角色技能等级
function RoleData:GetHeroSkillLevel()
    if self:CheckHeroEquipIsMax() then
        return self.skillLevel + 1
    end
    return self.skillLevel
end

---获取角色技能等级(前端展示用)(技能显示改回0级)
function RoleData:GetHeroShowSkillLv()
    if self:CheckHeroEquipIsMax() then
        return self.skillLevel + 1
    end
    return self.skillLevel
end
---获取人物属性
function RoleData:GetHeroAttr()
    return ReadData.GetRoleAttr(self.id,self.level,self.star,self:GetHeroSkillLevel(),self.awaken,self.exp,self:CheckHeroEquipIsMax())
end
function RoleData:GetFriendHeroAttr()
    local skillUp = true
    for i ,v in ipairs(self.equipLvArr) do
        if v < tonumber(SteamLocalData.tab[105009][2]) then
            skillUp = false
            break
        end
    end
    return ReadData.CreatRole(self.id,self.skin,self.level,self.star,self.skillLevel,self.awaken,self.favor,true,skillUp)     --好友技能等级传过来时是自身等级，没算装备提升
end
function RoleData:GetHeroAttrWithCoreAndEquip()
    return ReadData.CreatRole(self.id,self.skin,self.level,self.star,self:GetHeroSkillLevel(),self.awaken,self.favor,nil,self:CheckHeroEquipIsMax())
end

---获取人物属性(不要额外技能加成)
function RoleData:GetHeroAttrNoAdditional()
    return ReadData.GetRoleAttr(self.id,self.level,self.star,self.skillLevel,self.awaken,self.exp)
end
---@return CoreData 获取人物核心(槽位1，槽位2)
function RoleData:GetHeroCore(index)
    local id = self["armor"..index]
    if id == nil or id == 0 then
        return nil
    end
    return CoreControl.GetSingleCoreData(id)
end
---@return CoreData 获取单独创建角色核心(槽位1，槽位2)
function RoleData:GetHeroSingleCore(index)
    if self[string.format("core%s",index)] ~= nil then
        return self[string.format("core%s",index)]
    end
    local id = self[string.format("armor%s",index)]
    local properties = self[string.format("armor%sPro",index)]
    local skill = self[string.format("armor%sSkill",index)]
    if id == nil or id == 0 then
        return nil
    end
    if properties == nil or properties == 0 then
        return nil
    end
    self[string.format("core%s",index)] = CoreControl.CreateSingleCore(id,properties,skill)
    return self[string.format("core%s",index)]
end
---@return EquipData 获取人物共鸣装备
function RoleData:GetHeroEquip(index)
    local id = self.equipArr[index]
    if id == nil or id == 0 then
        return nil
    end
    return EquipControl.GetSingleEquips(id)
end
---@return EquipData 获取单独创建人物共鸣装备
function RoleData:GetHeroSingleEquip(index)
    local id = self.equipArr[index]
    local level = self.equipLvArr[index]
    if id == nil or id == 0 then
        return nil
    end
    if level == nil then
        return nil
    end
    return EquipControl.CreateSingleEquip(id,level)
end
---@type FriendSupportInfo SupportInfo
function RoleData:CreateFriendHero(SupportInfo)
    --local friendRoleAttr = ReadData.GetRoleAttr(SupportInfo.heroID,SupportInfo.heroLevel,SupportInfo.heroStar,SupportInfo.heroSkillLevel,SupportInfo.heroAwaken,SupportInfo.heroExp)    --原始角色数据
    --local core1 = CoreControl.GetSingleCoreData(SupportInfo.heroArmor1.ID)  --核心1
    --local core2 = CoreControl.GetSingleCoreData(SupportInfo.heroArmor2.ID)  --核心2
end
function RoleData:ReLoadHeroCore(type, coreId)
    if type == 1 then
        self.armor1 = coreId
    elseif type == 2 then
        self.armor2 = coreId
    end
end

return RoleData