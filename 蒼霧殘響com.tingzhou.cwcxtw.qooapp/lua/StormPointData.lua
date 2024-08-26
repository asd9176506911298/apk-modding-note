---关卡数据
---@class StormPointData
---@field towerReward TowerReward[]
StormPointData = Class('StormPointData')
---构造方法
function StormPointData:ctor(id)
    self.id = id                    ---关卡ID
    self.scrollID = nil             ---所属卷ID
    self.scrollType = nil           ---所属卷副本类型
    self.type = nil                 ---配置常规关卡类型
    self.name = ""                  ---关卡名称
    self.teacheID = ""              ---教学ID
    self.idxName = ""               ---关卡索引名
    self.index = {}                 ---关卡索引
    self.fronts = {}                ---前置关卡
    self.o_fronts = {}              ---解锁关卡
    self.plot_f = nil               ---战前剧情
    self.plot_l = nil               ---战后剧情
    self.introduction = ""          ---剧情简介
    self.picture = ""               ---剧情简介图
    self.battleMap = nil            ---战斗地图
    self.star = 0                   ---关卡星级 0为未挑战、1为第一颗星，1<<1为第二颗，1<<3为第三颗 ,多颗则相与 ,战术指导非0时为已挑战
    self.count = 0                  ---关卡挑战次数
    self.unlocks = {}               ---解锁条件(key锁类型，value对应配置ID)
    self.mapX = 0                   ---卷在地图的坐标x
    self.mapY = 0                   ---卷在地图的坐标y
    self.condition = nil            ---星级达成条件
    self.consume = nil              ---消耗物品
    self.reward = nil               ---首通奖励
    self.victory = nil              ---通关奖励
    self.randReward = nil           ---随机奖励
    self.bgm = nil                  ---常规关卡bgm
    self.monsters = { }            ---创建怪物数据
    self.secondMonsters = {}
    self.towerReward = nil          ---挑战奖励条件
    self.towerLevel = 0             ---挑战推荐等级
    self.teach_f = nil              ---战前教学
    self.teach_l = nil              ---战后教学
    self.roles = {}                ---指定角色
    self.drama = nil                ---关卡简介
    self.tips = nil                 ---关卡提示信息
    self.guideIndex = nil           ---战术指导序号
    self.guideName = nil            ---战术指导名
    self.guideIcon = ""             ---战术指导例图
    self.pointType = 0              ---程序定义关卡类型 1-常规关卡 2-红色巨塔 3-战术指导
    self.banSkill=nil
    self.npcType = 0                ---Npc助战类型
    self.banMove = {}               ---禁止操作地板
    self.playerNumber = 9           ---关卡上场玩家数量
    self.recommendLevel = 0
    self.bgpicture = ""             ---剧情回放简介图
    self.reserve = ""               ---连战怪物配置
    self.dangerousEnemy = ""        ---高威胁怪物ID
    self.npcheads = ""              ---npc头像(用于左上角提示框)
    self.promptdialog = ""          ---提示内容
    self.returnFloorId = 0
    self.ContinuousCombatType = 0   ---站位类型
    self.activitypreview2 = nil     ---解锁判断道具
end
---@class LevelInfo 服务器定义的关卡通信结构
local LevelInfo = {
    levelID = 1,        ---关卡id
    levelStar = 2,      ---关卡星级
    levelCount = 3,     ---已经挑战次数
}
---@class TowerReward 红巨奖励
---@field reward goods 奖励
local TowerReward = {
    taskType = 1,     ---条件类型
    taskCount = 2,    ---条件数量
    taskText = 3,     ---条件说明
    reward = 4,
    isGet = 5,
}
require("LocalData/ChapterLocalData")
---@param config CheckpointLocalData 添加常规配置属性
function StormPointData:PushConfig(config)
    self.id = config.id                 ---关卡ID
    self.scrollID = config.scroll       ---所属卷ID
    self.scrollType = ChapterLocalData.tab[self.scrollID].type  ---所属卷副本类型
    self.type = config.type             ---关卡类型
    self.name = config.cname            ---关卡名称
    self.idxName = config.name          ---关卡索引名
    local idStr = string.split(config.name,"-")
    self.index = #idStr == 2 and tonumber(idStr[2]) or tonumber(idStr[1])  ---关卡索引
    self.banSkill= config.prohibitskill
    ---前置关卡
    local frontStr = string.split(config.front,",")
    for i, v in pairs(frontStr) do
        self.fronts[i] = tonumber(v)
    end
    ---解锁关卡
    self.o_fronts = config.open         ---解锁关卡
    self.plot_f = config.plot_first     ---战前剧情
    self.plot_l = config.plot_last      ---战后剧情
    self.introduction = config.introduction ---剧情简介
    self.picture = config.picture       ---剧情简介图
    self.bgpicture = config.bgpicture   ---剧情回放简介图
    self.battleMap = config.map            ---战斗地图
    self.star = 0                       ---关卡星级 0为未挑战、1为第一颗星，1<<1为第二颗，1<<3为第三颗 ,多颗则相与
    self.count = 0                         ---关卡挑战次数
    self.bgm = config.bgm               ---关卡背景音乐
    self.teacheID = config.teacheid
    ---解锁条件(key锁类型，value对应配置ID)
    local lockStrArr = string.split(config.unlock,",")
    for i, v in pairs(lockStrArr) do
        local lockStr = string.split(v,"_")
        self.unlocks[tonumber(lockStr[1])] = tonumber(lockStr[2])
    end

    local posArr = string.split(config.scrollmappos,",")
    self.mapX = tonumber(posArr[1]) or 0       ---卷在地图的坐标x
    self.mapY = tonumber(posArr[2]) or 0      ---卷在地图的坐标y
    self.condition = config.condition         ---星级达成条件
    self.consume = config.consume             ---消耗物品
    self.reward = config.reward               ---首通奖励
    self.victory = config.victory             ---固定奖励
    self.randReward = config.drop             ---随机奖励
    self.monsters = self:CreateMonsters(config.monster)        ---创建怪物数据
    if config.reserve ~= "0" then
        self.secondMonsters = self:CreateMonsters(config.reserve)
    end
    if self.type == 999 or self.type == 998 then
        self:CreatePlayerRoles(config.player)
    end
    self.towerStar = 0                        ---挑战达成条件
    self.npcType = config.npctype             ---npc使用类型
    for _,index in pairs(string.split(config.npcbanmove,"_")) do
        table.insert(self.banMove,tonumber(index))      ---禁止操作地板
    end
    self.playerNumber = config.playnumber
    ---常规关卡
    self.pointType = 1
    self.recommendLevel = config.recomlevel
    self.dangerousEnemy = config.dangerousenemy
    self.npcheads = config.npcheads
    self.promptdialog = config.promptdialog
    self.returnFloorId = config.returnfloorid
    self.ContinuousCombatType = config.continuouscombattype
    self.activitypreview2 = config.activitypreview2
end
---@param config table 添加挑战红巨配置属性
function StormPointData:PushTowerConfig(config)
    ---关卡ID
    self.id = config[1]
    ---关卡类型
    self.type = 1
    ---关卡名称
    self.name = config[2]
    ---解锁条件(key锁类型，value对应配置ID)
    local lockStrArr = string.split(config[3],",")
    for i, v in pairs(lockStrArr) do
        local lockStr = string.split(v,"_")
        self.unlocks[tonumber(lockStr[1])] = tonumber(lockStr[2])
    end
    ---前置关卡
    local frontStr = string.split(config[4],",")
    for i, v in pairs(frontStr) do
        self.fronts[i] = tonumber(v)
    end
    ---创建怪物数据
    self.monsters = self:CreateMonsters(config[6])
    ---战斗地图
    self.battleMap = config[9]
    ---背景音乐
    self.bgm = config[10]
    ---挑战奖励
    self.towerReward = {}
    local task = string.split(config[7],";")
    for i, v in ipairs(task) do
        self.towerReward[i] = {}
        local str = string.split(v,",")
        local str_1 = string.split(str[1],"_")
        self.towerReward[i].taskType = tonumber(str_1[1])
        self.towerReward[i].taskCount = tonumber(str_1[2])
        self.towerReward[i].taskText = TermdescLocalData.tab[tonumber(str_1[3])][2]
        self.towerReward[i].reward = str[2]
        self.towerReward[i].isGet = false
    end
    ---推荐等级
    self.towerLevel = config[8]
    ---红色巨塔
    self.pointType = 2
    self.playerNumber = 9
end
---@param config table 添加挑战战术指导配置属性
function StormPointData:PushGuideConfig(config)
    ---关卡ID
    self.id = config[1]
    ---关卡类型
    self.type = 1
    ---关卡索引名
    self.idxName = config[2]
    ---关卡名称
    self.name = config[3]
    ---战前教学
    self.teach_f = tonumber(config[4])
    ---战后教学
    self.teach_l = tonumber(config[5])
    ---解锁条件(key锁类型，value对应配置ID)
    local lockStrArr = string.split(config[6],",")
    for i, v in pairs(lockStrArr) do
        local lockStr = string.split(v,"_")
        self.unlocks[tonumber(lockStr[1])] = tonumber(lockStr[2])
    end
    ---前置关卡
    local frontStr = string.split(config[7],",")
    for i, v in pairs(frontStr) do
        self.fronts[i] = tonumber(v)
    end
    ---创建角色数据
    local roleCof = config[9]
    if roleCof ~= nil or roleCof ~= "0" then
        ---@type FighterAttr2[]
        local fighterAttrs = {}
        local fighterStr = string.split(roleCof,";")
        for i, v in pairs(fighterStr) do
            if v ~= nil and v ~= "" then
                local f_str = string.split(v,"_")
                fighterAttrs[i] = {}
                fighterAttrs[i].base = {}
                fighterAttrs[i].base.roleID = tonumber(f_str[1])
                fighterAttrs[i].base.index = tonumber(f_str[6])
                fighterAttrs[i].star = tonumber(f_str[2])
                fighterAttrs[i].level = tonumber(f_str[3])
                fighterAttrs[i].awaken = tonumber(f_str[4])
                fighterAttrs[i].skill = tonumber(f_str[5])
                fighterAttrs[i].body = tonumber(f_str[7])
                fighterAttrs[i].boss = tonumber(f_str[8])
                fighterAttrs[i].armorID1 = tonumber(f_str[9])
                fighterAttrs[i].armorRatio1 = tonumber(f_str[10])
                fighterAttrs[i].armorSkill1 = tonumber(f_str[11])
                fighterAttrs[i].armorID2 = tonumber(f_str[12])
                fighterAttrs[i].armorRatio2 = tonumber(f_str[13])
                fighterAttrs[i].armorSkill2 = tonumber(f_str[14])
                fighterAttrs[i].equipLevel = {
                    0,0,0
                }
            end
        end
        self.roles = self:CreateRoles(fighterAttrs)
    end
    ---创建怪物数据
    self.monsters = self:CreateMonsters(config[10])
    ---创建首通奖励
    self.reward = config[11]
    ---战斗地图
    self.battleMap = config[12]
    ---背景音乐
    self.bgm = config[13]
    ---关卡简介
    self.drama = config[14]
    ---提示信息
    self.tips = config[15]
    ---右上方关卡序号
    self.guideIndex = config[16]
    ---右上方关卡名
    self.guideName = config[17]
    ---右侧例图
    self.guideIcon = string.format("Preview/%s",config[18])
    ---战术指导
    self.pointType = 3
    self.playerNumber = 9
end
---@param level LevelInfo 覆盖常规关卡数据
function StormPointData:PushData(level)
    self.star = level.levelStar         ---关卡星级
    self.count = level.levelCount       ---关卡挑战次数
end
---@return boolean,boolean,boolean 检查当前星达成
function StormPointData:CheckStar()
    if self.towerReward ~= nil then
        return self.towerReward[1].isGet,self.towerReward[2].isGet,self.towerReward[3].isGet
    else
        if self.star == 0 then
            return false,false,false
        elseif self.star == 1 then
            return true,false,false
        elseif self.star == 2 then
            return false,true,false
        elseif self.star == 3 then
            return true,true,false
        elseif self.star == 4 then
            return false,false,true
        elseif self.star == 5 then
            return true,false,true
        elseif self.star == 6 then
            return false,true,true
        elseif self.star == 7 then
            return true,true,true
        end
    end
end

---@return boolean[] 检查当前红巨达成
function StormPointData:CheckTowerTask()
    local arr = {}
    for i, v in ipairs(self.towerReward) do
        arr[#arr + 1] = v.isGet
    end
    return arr
end

---@return boolean 检查当前战术指导达成
function StormPointData:CheckGuideLock()
    return self.star > 0
end

---@return boolean 检查是否存在剧情关卡
function StormPointData:CheckIsPlot()
    if self.plot_f ~= nil and self.plot_f ~= "" and self.plot_f ~= "0" then
        return true
    end
    if self.plot_l ~= nil and self.plot_l ~= "" and self.plot_l ~= "0" then
        return true
    end
    return false
end
---@return boolean 检查是否存在战斗
function StormPointData:CheckIsBattle()
    if self.battleMap ~= nil and self.battleMap ~= "" and self.battleMap ~= "0" then
        return true
    end
    return false
end
---@param fighterAttrs FighterAttr2[] 创建关卡指定用的角色数据
---@return RoleData[]
function StormPointData:CreateRoles(fighterAttrs)
    local arr = {}
    for i, fighterAttr in pairs(fighterAttrs) do
        local role = HeroControl.CreateSingleHero(fighterAttr)
        ---角色类型修改为Npc
        role.type = 2
        arr[#arr + 1] = role
    end
    return arr
end
---@return RoleData[] 获取关卡指定角色数据
function StormPointData:GetRoles()
    if self.roles == nil then
        Log.Error("关卡角色数据为空2")
        return nil
    end
    local arr = {}
    for i, v in pairs(self.roles) do
        arr[#arr + 1] = v
    end
    return arr
end
---@return RoleData 获取关卡指定角色数据
function StormPointData:GetRoleById(id)
    if self.roles == nil then
        Log.Error("关卡角色数据为空2")
        return nil
    end
    for i, v in pairs(self.roles) do
        if v.id == id then
            return v
        end
    end
    return nil
end
---@return --MonsterData[] 创建关卡怪物数据
---@return RoleData[] 创建关卡怪物数据
function StormPointData:CreateMonsters(str)
    if str == "0" then
        ---为空不创建
        return nil
    end
    local mList = {}
    local list = string.split(str,";")
    for i, v in ipairs(list) do
        if v ~= "" then
            local data = string.split(v,"_")
            local id = tonumber(data[1])
            local star = tonumber(data[2])
            local level = tonumber(data[3])
            local isAwaken = tonumber(data[4])
            local skillLv = tonumber(data[5])
            local sIndex = tonumber(data[6])
            local scale = tonumber(data[7])
            local isBoss = tonumber(data[8])
            local core1Id = tonumber(data[9])
            local core1properties = tonumber(data[10])
            local core1skill = tonumber(data[11])
            local core2Id = tonumber(data[12])
            local core2properties = tonumber(data[13])
            local core2skill = tonumber(data[14])
            local atkOrder = i
            mList[#mList + 1] = MonsterControl.CreateSingleMonster(id,star,level,isAwaken,skillLv,sIndex,scale,isBoss,core1Id,core1properties,core1skill,core2Id,core2properties,core2skill,atkOrder)
        end
    end
    return mList
end
---@return RoleData[] 创建关卡玩家配置数据
function StormPointData:CreatePlayerRoles(data)
    ---创建角色数据
    local roleCof = data
    if roleCof == nil then
        return
    end
    if roleCof ~= nil or roleCof ~= "0" then
        ---@type FighterAttr2[]
        local fighterAttrs = {}
        local fighterStr = string.split(roleCof,";")
        for i, v in pairs(fighterStr) do
            local f_str = string.split(v,"_")
            fighterAttrs[i] = {}
            fighterAttrs[i].base = {}
            fighterAttrs[i].base.roleID = tonumber(f_str[1])
            fighterAttrs[i].base.index = tonumber(f_str[6])
            fighterAttrs[i].star = tonumber(f_str[2])
            fighterAttrs[i].level = tonumber(f_str[3])
            fighterAttrs[i].awaken = tonumber(f_str[4])
            fighterAttrs[i].skill = tonumber(f_str[5])
            fighterAttrs[i].body = tonumber(f_str[7])
            fighterAttrs[i].boss = tonumber(f_str[8])
            fighterAttrs[i].armorID1 = tonumber(f_str[9])
            fighterAttrs[i].armorRatio1 = tonumber(f_str[10])
            fighterAttrs[i].armorSkill1 = tonumber(f_str[11])
            fighterAttrs[i].armorID2 = tonumber(f_str[12])
            fighterAttrs[i].armorRatio2 = tonumber(f_str[13])
            fighterAttrs[i].armorSkill2 = tonumber(f_str[14])
            fighterAttrs[i].equipLevel = {
                0,0,0
            }
        end
        self.roles = self:CreateRoles(fighterAttrs)
    end
end
---@return number[] 获取所有怪物Id
function StormPointData:GetAllMonsterId()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.id
    end
    return arr
end
---@return number[] 获取二次战斗怪物属性
function StormPointData:GetSecondBattleAllMonster(str)
    local arr = {}
    if self.secondMonsters == nil or #self.secondMonsters == 0 then
        Log.Error("关卡二次战斗怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.secondMonsters) do
        if str == "Id" then
            arr[i] = v.id
        elseif str == "Level" then
            arr[i] = v.level
        elseif str == "Star" then
            arr[i] = v.star
        elseif str == "Awaken" then
            arr[i] = v.awaken
        elseif str == "SkillLv" then
            arr[i] = v.skillLevel
        elseif str == "SIndex" then
            arr[i] = v.sIndex
        elseif str == "Scale" then
            arr[i] = v.scale
        elseif str == "IsBoss" then
            arr[i] = v.isBoss
        elseif str == "Core1" then
            arr[i] = v.armor1
        elseif str == "CoreProperties1" then
            arr[i] = v.armor1Pro
        elseif str == "CoreSkill1" then
            arr[i] = v.armor1Skill
        elseif str == "Core2" then
            arr[i] = v.armor2
        elseif str == "CoreProperties2" then
            arr[i] = v.armor2Pro
        elseif str == "CoreSkill2" then
            arr[i] = v.armor2Skill
        end
    end
    return arr
end
---@return number[] 获取所有怪物等级
function StormPointData:GetAllMonsterLevel()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.level
    end
    return arr
end
---@return number[] 获取所有怪物星级
function StormPointData:GetAllMonsterStar()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.star
    end
    return arr
end
---@return number[] 获取所有怪物觉醒状态
function StormPointData:GetAllMonsterAwaken()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.awaken
    end
    return arr
end
---@return number[] 获取所有怪物技能等级
function StormPointData:GetAllMonsterSkillLv()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.skillLevel
    end
    return arr
end
---@return number[] 获取所有怪物位置索引
function StormPointData:GetAllMonsterSIndex()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.sIndex
    end
    return arr
end
---@return number[] 获取所有怪物缩放
function StormPointData:GetAllMonsterScale()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.scale
    end
    return arr
end
---@return number[] 获取所有怪物是否为Boss
function StormPointData:GetAllMonsterIsBoss()
    local arr = {}
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.isBoss
    end
    return arr
end
---@return number[] 获取所有怪物核心1
function StormPointData:GetAllMonsterCore1()
    local arr = {}
    if self.monsters == nil then
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.armor1
    end
    return arr
end
---@return number[] 获取所有怪物核心1属性
function StormPointData:GetAllMonsterCoreProperties1()
    local arr = {}
    if self.monsters == nil then
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.armor1Pro
    end
    return arr
end
---@return number[] 获取所有怪物核心1技能
function StormPointData:GetAllMonsterCoreSkill1()
    local arr = {}
    if self.monsters == nil then
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.armor1Skill
    end
    return arr
end
---@return number[] 获取所有怪物核心2
function StormPointData:GetAllMonsterCore2()
    local arr = {}
    if self.monsters == nil then
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.armor2
    end
    return arr
end
---@return number[] 获取所有怪物核心2属性
function StormPointData:GetAllMonsterCoreProperties2()
    local arr = {}
    if self.monsters == nil then
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.armor2Pro
    end
    return arr
end
---@return number[] 获取所有怪物核心2技能
function StormPointData:GetAllMonsterCoreSkill2()
    local arr = {}
    if self.monsters == nil then
        return arr
    end
    for i, v in ipairs(self.monsters) do
        arr[i] = v.armor2Skill
    end
    return arr
end
---@return --MonsterData 获取关卡中的怪物数据
---@return RoleData 获取关卡中的怪物数据
function StormPointData:GetMonsterById(id,atkOrder)
    if self.monsters == nil then
        Log.Error("关卡怪物需要配置,ID:"..self.id)
        return nil
    end
    for i, v in ipairs(self.monsters) do
        if v.id == id then
            if atkOrder == nil or atkOrder == v.atkOrder then
                return v
            end
        end
    end
    for i, v in ipairs(self.secondMonsters) do
        if v.id == id then
            if atkOrder == nil or atkOrder == v.atkOrder then
                return v
            end
        end
    end
end
---获取奖励物品
function StormPointData:GetRewards()
    local arr = {}
    if self.reward ~= "0" and self.reward ~= nil then
        ---首通奖励
        local t = JNStrTool.strSplit(",",self.reward)
        for i, v in pairs(t) do
            local config = Global.GetLocalDataByGoods(v)
            local data = {}
            data.type = string.split(v,"_")[1]
            data.id = config.id
            data.config = config
            data.quality = config.quality
            data.isOnceAdopt = true
            data.count = tonumber(string.split(v,"_")[3])
            data.isRec = self.star >= 7
            data.idx = #arr + 1
            --if self.star == 0 then
            --    arr[#arr + 1] = data
            --end
            arr[#arr + 1] = data
        end
    end
    if self.randReward ~= "0" and self.randReward ~= nil then
        ---随机奖励
        local t = string.split(self.randReward,",")
        for i1, v1 in ipairs(t) do
            if v1 ~= nil and v1 ~= "0" and v1 ~= "" then
                local t1 = string.split(v1,"_")
                if t1[1] ~= nil and t1[1] ~= "0" and t1[1] ~= "" then
                    local rRs = DropLocalData.tab[tonumber(t1[1])][4]
                    if rRs ~= nil and rRs ~= "0" and rRs ~= "" then
                        local t3 = JNStrTool.strSplit(",",rRs)
                        --Log.Error(string.format("关卡奖励配置不正确，请检查,关卡id:%s",self.id))
                        for i2, v2 in pairs(t3) do
                            local config = Global.GetLocalDataByGoods(v2)
                            local v2Self = string.split(v2,"_")
                            local isGet = false
                            for i3, v3 in pairs(arr) do
                                if v3.type == v2Self[1] and v3.config.id == config.id and v3.isOnceAdopt == false then
                                    arr[i3].count = arr[i3].count + tonumber(v2Self[3])
                                    isGet = true
                                    break
                                end
                            end
                            if isGet ~= true then
                                local data = {}
                                data.type = v2Self[1]
                                data.id = config.id
                                data.config = config
                                data.quality = config.quality
                                data.isOnceAdopt = false
                                data.count = tonumber(v2Self[3])
                                data.isRec = false
                                data.idx = #arr + 1
                                arr[#arr + 1] = data
                            end
                        end
                    end
                end
            end
        end
    end
    if self.victory ~= "0" and self.victory ~= nil then
        ---固定奖励
        local t = JNStrTool.strSplit(",",self.victory)
        for i, v in pairs(t) do
            local config = Global.GetLocalDataByGoods(v)
            local vSelf = string.split(v,"_")
            local isGet = false
            for i3, v3 in pairs(arr) do
                if v3.type == vSelf[1] and v3.config.id == config.id and v3.isOnceAdopt == false then
                    arr[i3].count = arr[i3].count + tonumber(vSelf[3])
                    isGet = true
                    break
                end
            end
            if isGet ~= true then
                local data = {}
                data.type = vSelf[1]
                data.config = config
                data.id = config.id
                data.quality = config.quality
                data.isOnceAdopt = false
                data.count = tonumber(vSelf[3])
                data.isRec = false
                data.idx = #arr + 1
                arr[#arr + 1] = data
            end
        end
    end
    if self.towerReward ~= nil then
        ---爬塔奖励
        for i, v in pairs(self.towerReward) do
            local config = Global.GetLocalDataByGoods(v.reward)
            local data = {}
            data.type = string.split(v.reward,"_")[1]
            data.config = config
            data.quality = config.quality
            data.isOnceAdopt = false
            data.count = tonumber(string.split(v.reward,"_")[3])
            data.id = tonumber(string.split(v.reward,"_")[2])
            data.isRec = false
            data.isTake = v.isGet
            data.isTower = true
            data.idx = -i
            data.towerIdx = i
            arr[#arr + 1] = data
        end
    end
    Global.Sort(arr,{"isOnceAdopt","idx"},{false,false})
    return arr
end
---@class StormPointLockEnum 关卡开启条件类型
local StormPointLockEnum = {
    PlayerLevel = 0,    ---玩家等级
    TimeConfig  = 1,    ---时间配置表
}
---@return boolean 检查当前关卡是否解锁
function StormPointData:CheckLock()
    -----检查前置关卡星级，为零时未通关
    if StormViewModel.isPlotModel == true then
        return true
    end
    if self.pointType == 1
    then
        ---新手引导关
        if StormControl.GetStormScrollById(self.scrollID).raidType == 999 then
            if self.fronts[1] == 0 then
                return true
            else
                local groupId = NoviceControl.GetNoviceDataByID(StormControl.GetStormPointByID(self.fronts[1]).teacheID).group
                ---如果当前引导上一关已完成
                if NoviceControl.GroupsIsDone(groupId) == true then
                    return true
                else
                    return false
                end
            end
        end
        ---常规关卡
        for idx, frontID in pairs(self.fronts) do
            if frontID ~= 0 then
                local frontData = StormControl.GetStormPointByID(frontID)
                if frontData then
                    local s1,s2,s3 = frontData:CheckStar()
                    if not s1 and not s2 and not s3 then
                        return false
                    end
                end
            end
        end
    elseif self.pointType == 2
    then
        ---红色巨塔
        for idx, frontID in pairs(self.fronts) do
            if tonumber(frontID) ~= 0 then
                local frontData = StormControl.GetStormTowerPointData()[frontID]
                for i, v in ipairs(frontData:CheckTowerTask()) do
                    if v then
                        return true
                    end
                end
                return false
            end
        end
    elseif self.pointType == 3
    then
        ---战术指导
        for idx, frontID in pairs(self.fronts) do
            if frontID ~= 0 then
                local frontData = StormControl.GetStormGuidePointData()[frontID]
                return frontData:CheckGuideLock()
            end
        end
    end
    ---检查开启条件
    for type, v in pairs(self.unlocks) do
        if type == StormPointLockEnum.PlayerLevel
        then
            ---检查玩家等级
            local pLevel = PlayerControl.GetPlayerLevel()
            if pLevel < v then
                return false
            end
        elseif type == StormPointLockEnum.TimeConfig
        then
            ---检查时间配置
            local timeConfig = TimeLocalData.tab[v]
            ---判断时间类型
            if timeConfig[2] == 0 then
                ---跨天周计数
                ---获取当前周几
                local wDay = os.date("%w",MgrNet.GetServerTime())
                wDay = wDay == "0" and "7" or wDay
                local h = os.date("%H",MgrNet.GetServerTime())
                h = tonumber(h)
                wDay = h < 5 and wDay - 1 or wDay
                wDay = (wDay == 0) and "7" or wDay
                wDay = math.floor(wDay)
                ---判断开放日配置中是否存在当前天
                if string.find(timeConfig[3],wDay) == nil then
                    ---不存在则不开放
                    return false
                end
                ---判断当前时间是否在开放日当天限制时间内
                local str = string.split(timeConfig[4],"-")
                local time = os.date("%Y-%m-%d",MgrNet.GetServerTime())
                local timeStr = string.split(time,"-")
                local beginTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
                str = string.split(timeConfig[5],"-")
                local endTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
                ---增加跨一天的时间
                endTime = endTime + 86400
                ---减5小时临时用
                beginTime = beginTime - 18000

                endTime = endTime - 18000
                if not Global.isMiddleTime(beginTime,endTime) then
                    ---不在时间内不开放
                    print(self.name.."未开放,原因：")
                    return false
                end
            elseif timeConfig[2] == 1 then
                ---不跨天周计数
                ---获取当前周几
                local wDay = os.date("%w",MgrNet.GetServerTime())
                wDay = wDay == "0" and "7" or wDay
                ---判断开放日配置中是否存在当前天
                if string.find(timeConfig[3],wDay) == nil then
                    ---不存在则不开放
                    return false
                end
                ---判断当前时间是否在开放日跨天限制时间内
                local str = string.split(timeConfig[4],"-")
                local time = os.date("%Y-%m-%d",MgrNet.GetServerTime())
                local timeStr = string.split(time,"-")
                local beginTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
                str = string.split(timeConfig[5],"-")
                local endTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
                if not Global.isMiddleTime(beginTime,endTime) then
                    ---不在时间内不开放
                    return false
                end
            elseif timeConfig[2] == 2
            then
                ---具体时间开放
                ---判断当前时间是否在开放日当天限制时间内
                local str = string.split(timeConfig[6],"-")
                local beginTime = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
                str = string.split(timeConfig[7],"-")
                local endTime = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
                if not Global.isMiddleTime(beginTime,endTime) then
                    ---不在时间内不开放
                    return false
                end
            elseif timeConfig[2] == 999 then
                ---常驻不处理为开放
            end
        end
    end
    return true
end
---@return boolean 检查当前PVE关卡是否是教学关卡
function StormPointData:CheckGuide()
    if self.type == 999 or self.type == 998 then
        return true
    end
    return false
end
---@return boolean 检查当前关卡是否是新手关卡
function StormPointData:CheckNovice()
    local scroll = StormControl.GetStormScrollById(self.scrollID)
    if scroll.raidType == 999 and scroll.type == 0 then
        return true
    end
    return false
end

return StormPointData