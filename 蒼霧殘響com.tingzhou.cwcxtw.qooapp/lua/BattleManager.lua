require("JNBattle/BattleRole")
require("Mgr/MgrTimer")
require("ReadData/ReadData")
require("JNBattle/JNSkill")
require("ReadData/BattleRoleData") --传入游戏结束的数据
require("JNBattle/JNStrTool")
require("JNUI/JNPVPData")
require("LocalData/SteamLocalData")
require("LocalData/ActorLinesLocalData")
require("LocalData/RoleattributeLocalData")
require("JNBattle/JNTurnEffectMgr")
require("ReadData/WorldBossData")


--因为引用机制 ,不能在BattleRole中写自己的方法 ,寻找目标等函数全写这里, Role仅仅存贮属性
BattleManager = {}

BattleManager.FloorPos = {
    left = {
        [1] = { -373, -70, 12},
        [2] = { -309, -70, 12},
        [3] = { -245, -70, 12},
        [4] = { -181, -70, 12},
        [5] = { -117, -70, 12},
        [6] = { -53, -70, 12},
        [7] = { -373, -70, -104},
        [8] = { -309, -70, -104},
        [9] = { -245, -70, -104},
        [10] = { -181, -70, -104},
        [11] = { -117, -70, -104},
        [12] = { -53, -70, -104},
        [13] = { -373, -70, -212},
        [14] = { -309, -70, -212},
        [15] = { -245, -70, -212},
        [16] = { -181, -70, -212},
        [17] = { -117, -70, -212},
        [18] = { -53, -70, -212}
    },
    right = {
        [6] = { 377, -70, 12},
        [5] = { 313, -70, 12},
        [4] = { 249, -70, 12},
        [3] = { 185, -70, 12},
        [2] = { 121, -70, 12},
        [1] = { 57, -70, 12},
        [12] = { 377, -70, -104},
        [11] = { 313, -70, -104},
        [10] = { 249, -70, -104},
        [9] = { 185, -70, -104},
        [8] = { 121, -70, -104},
        [7] = { 57, -70, -104},
        [18] = { 377, -70, -212},
        [17] = { 313, -70, -212},
        [16] = { 249, -70, -212},
        [15] = { 185, -70, -212},
        [14] = { 121, -70, -212},
        [13] = { 57, -70, -212}
    }
}--Battle_UI的攻击模式    1.普通战斗 2.PVP 3.boss战 4.模拟boss战 5.红色巨塔 6.战术指导

BattleManager.CurActivityBossPointInfo = nil

BattleManager.BossLevel = {
    Easy = 1,
    Medium = 2,
    Hard = 3
}

BattleManager.CurBossLevel = 1

---站位类型枚举
BattleManager.MonsterStandType =
{
    PVP = nil,
    MONSTER = 0,
    BOSS = 1,
    MONSTER_BOSS_MIX_MONSTER = 2,   ---小怪Boss混搭(小怪)
    MONSTER_BOSS_MIX_BOSS = 3,      ---小怪Boss混搭(Boss)
    MONSTER_MONSTER = 10,           ---小怪-小怪
    MONSTER_BOSS = 11,              ---小怪-Boss
    BOSS_MONSTER = 12,              ---Boss-小怪
    BOSS_BOSS = 13                  ---Boss-Boss
}
---发送给服务器时判断
BattleManager.GameModeType =
{
    Normal = 1,
    PVP = 2,
    WorldBoss = 3,
    AniWorldBoss = 4,
    RedTower = 5,
    Guide = 6,
    Novice = 7,
    ActivityBoss = 8
}
BattleManager.GameMode = BattleManager.GameModeType.Normal
--左边还是右边先攻
BattleManager.IsLeftFirst=true
--按照攻击顺序排列
BattleManager.AtkOrderRank={}
--当前是第几个
BattleManager.AtkOrderRankIndex=1
BattleManager.AtkIndex=1  --当前是第几个攻击 例如50本局第50个攻击者 每次攻击+1
--本轮最大值
BattleManager.AtkOrderRankMax=2
--当前第几轮
BattleManager.AtkRoundCount=1
BattleManager.CanUpdataSkillIcon=false
--GameID计数
BattleManager.GameIdCout=0
--两边的角色
BattleManager.LeftTeam={}
--右边的要读服务器,暂时是单机,右边队伍写死 ,玩家操作左边队伍
BattleManager.RightTeam = {}
BattleManager.FirstRightTeam = {}
BattleManager.GameIdCount=1;  --游戏里的id ,右侧敌人的id+10000
--创建棋盘 每个格子三个属性 ,x,y gameid  通过下标找到对应的角色,再去RightTeam中读取具体属性
BattleManager.ChessboardLeft={ {0,0,0,0,0,0},
                               {0,0,0,0,0,0},
                               {0,0,0,0,0,0}
}
BattleManager.ChessboardRight={ {0,0,0,0,0,0},
                                {0,0,0,0,0,0},
                                {0,0,0,0,0,0}
}
--是否战斗模式 ,已经开始战斗不再显示范围预览0
BattleManager.IsFightStart=false
BattleManager.UI_SleRoleGameID=-1  -- 数字
--点击开始后按照顺序依次加入
BattleManager.LeftAtkOrder={}
BattleManager.RightAtkOrder={}
--{id,role引用}
---@type BattleRole[]
BattleManager.AllRole={}
--临时数据 ,左侧队伍的站位 xy对应棋盘上  但是对应到ChessboardRight中为yx
BattleManager.TempLeftPos={{1,1},{5,2},{3,2},{4,1},{2,2},{2,3},{4,3},{6,3},{6,2} }
BattleManager.TempRightPos={{5,2},{4,3},{3,2},{2,2} ,{5,1},{4,1},{3,1}}
BattleManager.Uiupdata=nil
BattleManager.CjnMgr=nil
BattleManager.FightType = BattleManager.MonsterStandType.MONSTER
BattleManager.bool_IsBossSimulate=true  --判断当前是否在模拟世界BOSS模式(只用于FightType=5情况下)
BattleManager.RoundCout=1
BattleManager.LeftDeadNumber=0
BattleManager.BattleAgain = false
---有二次战斗
BattleManager.hasSecondBattle = false
--创建右侧敌人(数据和spine)
function BattleManager.StartBattle(Uiupdata,BuildNoSpine,standType,BanSkill)  ---BuildNoSpine == 1 时不创建spine
    ---开启摄像机
    CMgrCamera.Instance.FightCamera.gameObject:SetActive(true)
    BattleManager.FightType = standType
    if standType == 1 or standType == 13 then
        BattleManager.BodySize=WorldBossData.Niai_BossSize
    end
    ---设置禁止技能
    CreatRoleData.SetBanSkill(BanSkill)
    BattleManager.RoundCout=1
    BattleManager.IsLeftFirst=true
    ---按照攻击顺序排列
    BattleManager.AtkOrderRank={}
    --当前是第几个
    BattleManager.AtkOrderRankIndex=1
    --当前是第几个攻击 例如50 本局第50个攻击者 每次攻击+1
    BattleManager.AtkIndex=1
    --本轮最大值
    BattleManager.AtkOrderRankMax=2
    --当前第几轮
    BattleManager.AtkRoundCount=1
    --GameID计数
    BattleManager.GameIdCout=0
    --两边的角色
    BattleManager.LeftTeam={}
    --右边的要读服务器,暂时是单机,右边队伍写死 ,玩家操作左边队伍
    BattleManager.RightTeam={}
    BattleManager.GameIdCount=1;  --游戏里的id ,右侧敌人的id+10000
    --创建棋盘 每个格子三个属性 ,x,y gameid  通过下标找到对应的角色,再去RightTeam中读取具体属性
    BattleManager.ChessboardLeft={ {0,0,0,0,0,0},
                                   {0,0,0,0,0,0},
                                   {0,0,0,0,0,0}
    }
    BattleManager.ChessboardRight={ {0,0,0,0,0,0},
                                    {0,0,0,0,0,0},
                                    {0,0,0,0,0,0}
    }
    --是否战斗模式 ,已经开始战斗不再显示范围预览0
    BattleManager.UI_SleRoleGameID=-1  -- 数字
    --点击开始后按照顺序依次加入
    BattleManager.LeftAtkOrder={}
    BattleManager.RightAtkOrder={}
    --{id,role引用}
    BattleManager.AllRole={}
    BattleManager.LeftDeadNumber=0
    BattleManager.CanUpdataSkillIcon=false
    --------------------------------------------上面复原属性
    BattleManager.Uiupdata=Uiupdata
    if BattleManager.bgm~=nil then
        MgrSound.PlayBGM(BattleManager.bgm,0.2)
    end
    BattleManager.CjnMgr=  CJNBattleMgr.Instance
    ---设置战斗状态
    CJNBattleMgr.FightState = 1  ---战斗状态：1布阵、2开场动画、3战斗、4结算
    BattleManager.LeftAtkOrderCout = 1    ---攻击顺序：重置为0
    BattleManager.FihtLoopEnd = false     ---设置为战斗循环未结束
    BattleManager.IsFightStart = false    ---设置为未开启战斗
    if  BattleManager.IsTest == true
    then
    else
        if (BattleManager.FightType == BattleManager.MonsterStandType.MONSTER
                or BattleManager.FightType == BattleManager.MonsterStandType.BOSS
                or BattleManager.FightType == BattleManager.MonsterStandType.MONSTER_MONSTER
                or BattleManager.FightType == BattleManager.MonsterStandType.MONSTER_BOSS
                or BattleManager.FightType == BattleManager.MonsterStandType.BOSS_BOSS) and not CJNBattleMgr.Instance.worldBossBattle   ---由表配置的关卡类型
        then  --普通战斗模式/活动Boss模式
            ---设置常规战斗右侧怪物参数
            BattleManager.IdRight=StormViewModel.CurPointData:GetAllMonsterId()
            BattleManager.SkinIdRight = {}
            BattleManager.Right_Lv=StormViewModel.CurPointData:GetAllMonsterLevel()
            BattleManager.Right_StarLv=StormViewModel.CurPointData:GetAllMonsterStar()
            BattleManager.Right_Awake=StormViewModel.CurPointData:GetAllMonsterAwaken()
            BattleManager.Right_SkillLv=StormViewModel.CurPointData:GetAllMonsterSkillLv()
            BattleManager.Right_Pos=StormViewModel.CurPointData:GetAllMonsterSIndex()
            BattleManager.Right_Qoom=StormViewModel.CurPointData:GetAllMonsterScale()
            BattleManager.Right_IsBoss=StormViewModel.CurPointData:GetAllMonsterIsBoss()
            BattleManager.RightFW1_ID = StormViewModel.CurPointData:GetAllMonsterCore1()
            BattleManager.RightFW1_ZB = StormViewModel.CurPointData:GetAllMonsterCoreProperties1()
            BattleManager.RightFW1_Skill = StormViewModel.CurPointData:GetAllMonsterCoreSkill1()
            BattleManager.RightFW2_ID = StormViewModel.CurPointData:GetAllMonsterCore2()
            BattleManager.RightFW2_ZB = StormViewModel.CurPointData:GetAllMonsterCoreProperties2()
            BattleManager.RightFW2_Skill = StormViewModel.CurPointData:GetAllMonsterCoreSkill2()
            ---若存在二次战斗的怪物数据，分类整理好等待调用
            BattleManager.IdRight2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Id")
            BattleManager.SkinIdRight2 = {}
            BattleManager.Right_Lv2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Level")
            BattleManager.Right_StarLv2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Star")
            BattleManager.Right_Awake2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Awaken")
            BattleManager.Right_SkillLv2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("SkillLv")
            BattleManager.Right_Pos2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("SIndex")
            BattleManager.Right_Qoom2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Scale")
            BattleManager.Right_IsBoss2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("IsBoss")
            BattleManager.RightFW1_ID2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Core1")
            BattleManager.RightFW1_ZB2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("CoreProperties1")
            BattleManager.RightFW1_Skill2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("CoreSkill1")
            BattleManager.RightFW2_ID2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("Core2")
            BattleManager.RightFW2_ZB2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("CoreProperties2")
            BattleManager.RightFW2_Skill2 = StormViewModel.CurPointData:GetSecondBattleAllMonster("CoreSkill2")
        elseif CJNBattleMgr.Instance.worldBossBattle and BattleManager.FightType == BattleManager.MonsterStandType.BOSS     ---联合讨伐
        then
            ---设置联合讨伐右侧怪物参数
            local bossData =EventRaidControl.GetLIANHETAOFAData().BossData[BattleManager.CurBossLevel]
            BattleManager.IdRight={bossData.monsterData.id}
            BattleManager.SkinIdRight = {}
            BattleManager.Right_Lv={bossData.monsterData.level}
            BattleManager.Right_StarLv={bossData.monsterData.star}
            BattleManager.Right_Awake={bossData.monsterData.awaken}
            BattleManager.Right_SkillLv={bossData.monsterData.skillLevel}
            BattleManager.Right_Pos={bossData.monsterData.sIndex}
            BattleManager.Right_Qoom={bossData.monsterData.scale}
            BattleManager.Right_IsBoss={bossData.monsterData.isBoss}
        elseif BattleManager.FightType == BattleManager.MonsterStandType.PVP       ---PVP
        then    --玩家对玩家
            local Left = false
            local right = true
            if PVPViewModel.PlayerIsAtk then
                Left = true
                right = false
            else
                Left = false
                right = true
            end
            ---设置PVP战斗右侧角色参数
            BattleManager.IdRight=PVPViewModel.GetAllRoleId(right)
            BattleManager.SkinIdRight = PVPViewModel.GetAllRoleSkin(right)
            BattleManager.Right_Lv=PVPViewModel.GetAllRoleLevel(right)
            BattleManager.Right_StarLv=PVPViewModel.GetAllRoleStar(right)
            BattleManager.Right_Awake = PVPViewModel.GetAllRoleAwaken(right)
            BattleManager.Right_SkillLv= PVPViewModel.GetAllRoleSkillLv(right)
            BattleManager.Right_Pos=PVPViewModel.GetAllRoleSIndex(right)
            BattleManager.Right_Qoom=PVPViewModel.GetAllRoleScale(right)
            BattleManager.Right_IsBoss=PVPViewModel.GetAllRoleIsBoss(right)
            BattleManager.Right_Favor = PVPViewModel.GetAllRoleFavor(right)
            BattleManager.RightFW1_ID = PVPViewModel.GetAllRoleCoreID1(right)
            BattleManager.RightFW1_ZB = PVPViewModel.GetAllRoleCoreAttr1(right)
            BattleManager.RightFW1_Skill = PVPViewModel.GetAllRoleCoreSkill1(right)
            BattleManager.RightFW2_ID = PVPViewModel.GetAllRoleCoreID2(right)
            BattleManager.RightFW2_ZB = PVPViewModel.GetAllRoleCoreAttr2(right)
            BattleManager.RightFW2_Skill = PVPViewModel.GetAllRoleCoreSkill2(right)
            BattleManager.RightEquipLevel = PVPViewModel.GetAllRoleEquipLevel(right)
            ---设置PVP战斗左侧角色参数
            BattleManager.IdLeft=PVPViewModel.GetAllRoleId(Left)
            BattleManager.SkinIdLeft = PVPViewModel.GetAllRoleSkin(Left)
            BattleManager.Left_Lv=PVPViewModel.GetAllRoleLevel(Left)
            BattleManager.Left_StarLv=PVPViewModel.GetAllRoleStar(Left)
            BattleManager.Left_Awake = PVPViewModel.GetAllRoleAwaken(Left)
            BattleManager.Left_SkillLv= PVPViewModel.GetAllRoleSkillLv(Left)
            BattleManager.Left_Pos=PVPViewModel.GetAllRoleSIndex(Left)
            BattleManager.Left_Qoom=PVPViewModel.GetAllRoleScale(Left)
            BattleManager.Left_IsBoss=PVPViewModel.GetAllRoleIsBoss(Left)
            BattleManager.Left_Favor = PVPViewModel.GetAllRoleFavor(Left)
            BattleManager.LeftFW1_ID = PVPViewModel.GetAllRoleCoreID1(Left)
            BattleManager.LeftFW1_ZB = PVPViewModel.GetAllRoleCoreAttr1(Left)
            BattleManager.LeftFW1_Skill = PVPViewModel.GetAllRoleCoreSkill1(Left)
            BattleManager.LeftFW2_ID = PVPViewModel.GetAllRoleCoreID2(Left)
            BattleManager.LeftFW2_ZB = PVPViewModel.GetAllRoleCoreAttr2(Left)
            BattleManager.LeftFW2_Skill = PVPViewModel.GetAllRoleCoreSkill2(Left)
            BattleManager.LeftEquipLevel = PVPViewModel.GetAllRoleEquipLevel(Left)
        end
    end
    BattleManager.CjnMgr:ClearData()    --清空特效，重新生成地板
    BattleManager.CjnMgr:EndLine()

    if BuildNoSpine ~= 1 then
        BattleManager.initRight()       --初始化右边数据
        BattleManager.initRightSpine()  --初始化右边spine
        if BattleManager.FightType == BattleManager.MonsterStandType.PVP
        then
            BattleManager.initLeft()    --初始化左边队伍数据
            BattleManager.initLeftSpine()   --初始化左边spine
        end
    end

    for i ,v in pairs(BattleManager.RightTeam) do       ---保存为第一场战斗的阵型(由两场战斗时有用)
        BattleManager.FirstRightTeam[i] = clone(v)
    end
end

function BattleManager.StartSecondPhaseBattle(BanSkill)
    BattleManager.hasSecondBattle = true
    BattleManager.GameIdCout = #BattleManager.AllRole
    ---设置禁止技能
    CreatRoleData.SetBanSkill(BanSkill)
    BattleManager.RoundCout=1
    BattleManager.IsLeftFirst=true
    ---按照攻击顺序排列
    BattleManager.AtkOrderRank={}
    --当前是第几个攻击
    BattleManager.AtkIndex=1
    --本轮最大值
    BattleManager.AtkOrderRankMax=2
    --当前第几轮
    BattleManager.AtkRoundCount=1
    --右边的要读服务器,暂时是单机,右边队伍写死 ,玩家操作左边队伍
    BattleManager.RightTeam={}
    BattleManager.ChessboardRight={ {0,0,0,0,0,0},
                                    {0,0,0,0,0,0},
                                    {0,0,0,0,0,0}
    }
    --是否战斗模式 ,已经开始战斗不再显示范围预览0
    BattleManager.UI_SleRoleGameID=-1  -- 数字
    --点击开始后按照顺序依次加入
    BattleManager.LeftAtkOrder={}
    BattleManager.RightAtkOrder={}
    BattleManager.LeftAtkOrderCout = 1
    BattleManager.IdRight = BattleManager.IdRight2
    BattleManager.SkinIdRight = BattleManager.SkinIdRight2
    BattleManager.Right_Lv = BattleManager.Right_Lv2
    BattleManager.Right_StarLv = BattleManager.Right_StarLv2
    BattleManager.Right_Awake = BattleManager.Right_Awake2
    BattleManager.Right_SkillLv = BattleManager.Right_SkillLv2
    BattleManager.Right_Pos = BattleManager.Right_Pos2
    BattleManager.Right_Qoom = BattleManager.Right_Qoom2
    BattleManager.Right_IsBoss = BattleManager.Right_IsBoss2
    BattleManager.RightFW1_ID = BattleManager.RightFW1_ID2
    BattleManager.RightFW1_ZB = BattleManager.RightFW1_ZB2
    BattleManager.RightFW1_Skill = BattleManager.RightFW1_Skill2
    BattleManager.RightFW2_ID = BattleManager.RightFW2_ID2
    BattleManager.RightFW2_ZB = BattleManager.RightFW2_ZB2
    BattleManager.RightFW2_Skill = BattleManager.RightFW2_Skill2

    --if tonumber(StormViewModel.CurPointData.ContinuousCombatType) == BattleManager.MonsterStandType.MONSTER_BOSS then
    --    BattleManager.FightType = BattleManager.MonsterStandType.BOSS
    --elseif tonumber(StormViewModel.CurPointData.ContinuousCombatType) == BattleManager.MonsterStandType.BOSS_MONSTER or tonumber(StormViewModel.CurPointData.ContinuousCombatType) == BattleManager.MonsterStandType.MONSTER_MONSTER then
    --    BattleManager.FightType = BattleManager.MonsterStandType.MONSTER
    --end

    BattleManager.CjnMgr:CleanRightFloor()    --删除地板

    BattleManager.CjnMgr:GenerateRightFloor()
    BattleManager.CjnMgr:EndLine()
    ---清理右边角色
    CJNBattleMgr.Instance:CleanRightRoot()

    BattleManager.AllRole = {}
    BattleManager.initRight()       --初始化右边数据
    BattleManager.initRightSpine()
    for i,v in pairs(BattleManager.RightTeam) do
        if tonumber(v.ID) == 600002 or tonumber(v.ID) == 900002 then
            --隐藏耶梦加得遮挡相机的身体
            v.myAni:HideYMJDBody({4,6})
            --v.myAni:CloseLianyi(4)
        end
    end
    BattleManager.Rank()
    for i,v in pairs(BattleManager.RightTeam) do
        BattleManager.AllRole[v.GameID] = v
    end
    for i,v in pairs(BattleManager.LeftTeam) do
        BattleManager.AllRole[v.GameID] = v
    end
    ---创建新的右边队伍
    for key, value in pairs(BattleManager.RightTeam) do
        if not value.Remove then
            BattleRole.CreartData(value)
        end
    end
    CJNEffectShowMgr.CreatEffectPre(JNTurnEffectMgr.LuaCeratAll)
end

function BattleManager.HideOrder()
    for i,v in pairs(BattleManager.AllRole) do
        v.myAni:HidOrder()
        print("yincang " .. v.GameID)
    end
end

function BattleManager.ShowSecondWarTeam(teamNumber)
    BattleManager.IsLeftFirst=true
    --两只队伍重新计数
    if teamNumber == 1 then
        BattleManager.GameIdCout = 0
    elseif teamNumber == 2 then
        BattleManager.GameIdCout = #BattleManager.LeftTeam + #BattleManager.RightTeam
    end

    --按照攻击顺序排列
    BattleManager.AtkOrderRank={}
    --点击开始后按照顺序依次加入
    BattleManager.LeftAtkOrder={}
    BattleManager.RightAtkOrder={}
    BattleManager.RightAtkOrderCout = 1
    BattleManager.LeftAtkOrderCout = 1
    --当前是第几个攻击
    BattleManager.AtkIndex=1
    --本轮最大值
    BattleManager.AtkOrderRankMax=2
    --当前第几轮
    BattleManager.AtkRoundCount=1
    --右边的要读服务器,暂时是单机,右边队伍写死 ,玩家操作左边队伍
    BattleManager.RightTeam={}
    BattleManager.ChessboardRight={ {0,0,0,0,0,0},
                                    {0,0,0,0,0,0},
                                    {0,0,0,0,0,0}
    }
    --是否战斗模式 ,已经开始战斗不再显示范围预览0
    BattleManager.UI_SleRoleGameID=-1  -- 数字

    if teamNumber == 1 then
        if BattleManager.IdRight1 ~= nil then
            BattleManager.IdRight = BattleManager.IdRight1
            BattleManager.SkinIdRight = BattleManager.SkinIdRight2
            BattleManager.Right_Lv = BattleManager.Right_Lv1
            BattleManager.Right_StarLv = BattleManager.Right_StarLv1
            BattleManager.Right_Awake = BattleManager.Right_Awake1
            BattleManager.Right_SkillLv = BattleManager.Right_SkillLv1
            BattleManager.Right_Pos = BattleManager.Right_Pos1
            BattleManager.Right_Qoom = BattleManager.Right_Qoom1
            BattleManager.Right_IsBoss = BattleManager.Right_IsBoss1
            BattleManager.RightFW1_ID = BattleManager.RightFW1_ID1
            BattleManager.RightFW1_ZB = BattleManager.RightFW1_ZB1
            BattleManager.RightFW1_Skill = BattleManager.RightFW1_Skill1
            BattleManager.RightFW2_ID = BattleManager.RightFW2_ID1
            BattleManager.RightFW2_ZB = BattleManager.RightFW2_ZB1
            BattleManager.RightFW2_Skill = BattleManager.RightFW2_Skill1
        end
    elseif teamNumber == 2 then
        BattleManager.IdRight1 = BattleManager.IdRight
        BattleManager.SkinIdRight1 = BattleManager.SkinIdRight
        BattleManager.Right_Lv1 = BattleManager.Right_Lv
        BattleManager.Right_StarLv1 = BattleManager.Right_StarLv
        BattleManager.Right_Awake1 = BattleManager.Right_Awake
        BattleManager.Right_SkillLv1 = BattleManager.Right_SkillLv
        BattleManager.Right_Pos1 = BattleManager.Right_Pos
        BattleManager.Right_Qoom1 = BattleManager.Right_Qoom
        BattleManager.Right_IsBoss1 = BattleManager.Right_IsBoss
        BattleManager.RightFW1_ID1 = BattleManager.RightFW1_ID
        BattleManager.RightFW1_ZB1 = BattleManager.RightFW1_ZB
        BattleManager.RightFW1_Skill1 = BattleManager.RightFW1_Skill
        BattleManager.RightFW2_ID1 = BattleManager.RightFW2_ID
        BattleManager.RightFW2_ZB1 = BattleManager.RightFW2_ZB
        BattleManager.RightFW2_Skill1 = BattleManager.RightFW2_Skill

        BattleManager.IdRight = BattleManager.IdRight2
        BattleManager.SkinIdRight = BattleManager.SkinIdRight2
        BattleManager.Right_Lv = BattleManager.Right_Lv2
        BattleManager.Right_StarLv = BattleManager.Right_StarLv2
        BattleManager.Right_Awake = BattleManager.Right_Awake2
        BattleManager.Right_SkillLv = BattleManager.Right_SkillLv2
        BattleManager.Right_Pos = BattleManager.Right_Pos2
        BattleManager.Right_Qoom = BattleManager.Right_Qoom2
        BattleManager.Right_IsBoss = BattleManager.Right_IsBoss2
        BattleManager.RightFW1_ID = BattleManager.RightFW1_ID2
        BattleManager.RightFW1_ZB = BattleManager.RightFW1_ZB2
        BattleManager.RightFW1_Skill = BattleManager.RightFW1_Skill2
        BattleManager.RightFW2_ID = BattleManager.RightFW2_ID2
        BattleManager.RightFW2_ZB = BattleManager.RightFW2_ZB2
        BattleManager.RightFW2_Skill = BattleManager.RightFW2_Skill2
    end
    BattleManager.CjnMgr:CleanRightFloor()
    BattleManager.CjnMgr:GenerateRightFloor()
    BattleManager.CjnMgr:EndLine()
    CJNBattleMgr.Instance:CleanRightRoot()
    --if teamNumber == 2 then
    --    if StormViewModel.CurPointData.ContinuousCombatType == BattleManager.MonsterStandType.MONSTER_BOSS then
    --        BattleManager.FightType = BattleManager.MonsterStandType.BOSS
    --    end
    --elseif teamNumber == 1 then
    --    if StormViewModel.CurPointData.ContinuousCombatType == BattleManager.MonsterStandType.MONSTER_BOSS then
    --        BattleManager.FightType = StormViewModel.CurPointData.ContinuousCombatType
    --    end
    --end
    BattleManager.AllRole = {}
    BattleManager.initRight()       --初始化右边数据
    BattleManager.initRightSpine()
    for i,v in pairs(BattleManager.RightTeam) do
        if tonumber(v.ID) == 600002 or tonumber(v.ID) == 900002 then
            --隐藏耶梦加得遮挡相机的身体
            v.myAni:HideYMJDBody({4,6})
        end
    end
    BattleManager.Rank()
    for i,v in pairs(BattleManager.RightTeam) do
        BattleManager.AllRole[v.GameID] = v
    end
    for i,v in pairs(BattleManager.LeftTeam) do
        BattleManager.AllRole[v.GameID] = v
    end
    ---显示顺序
    for i,v in pairs(BattleManager.AllRole) do
        v.myAni:SetOrder(v.AtkOrder,v.IsLeft)
    end

    CJNBattleMgr.Instance:SetAllFloorHid()
end

--左侧的属性 id 等级 觉醒
BattleManager.IdLeft={10000,10000,13000,12000,13000,11000,11000,11000,13000,10000,10000,10000}
BattleManager.LeftGearID1={} --装备1ID表集合表
BattleManager.LeftGearID2={} --装备2ID表集合表
BattleManager.Left_Lv={}
BattleManager.Left_StarLv={}
BattleManager.Left_Awake={}
BattleManager.Left_SkillLv={}
BattleManager.Left_Pos={}
BattleManager.Left_Qoom={}
BattleManager.Left_IsBoss={}
BattleManager.Left_Favor={}
---创建左边队伍   只有PVP用
function BattleManager.initLeft()
    --print("----------创建左边队伍")
    local leftAtkO = 1
    for k, v in pairs(BattleManager.IdLeft) do
        if BattleManager.IdLeft[leftAtkO]==nil  then
            return
        end
        local tempRoleR =nil
        --根据战斗类型判断生成的敌人类型,3为玩家类型用CraetRole
        --记录自己的坐标  右侧的改为用1-18生成
        local tempPos_X =nil
        local tempPos_Y = nil
        --PVP队伍初始化
        if BattleManager.FightType == BattleManager.MonsterStandType.PVP
        then
            if PVPViewModel.PlayerIsAtk then
                ---己方队伍角色
                local lvUp = true
                if BattleManager.LeftEquipLevel[leftAtkO] then
                    for i, v in pairs(BattleManager.LeftEquipLevel[leftAtkO]) do
                        if v < tonumber(SteamLocalData.tab[105009][2]) then
                            lvUp = false
                        end
                    end
                end
                local hero = HeroControl.GetRoleDataByID(BattleManager.IdLeft[leftAtkO])

                tempRoleR= ReadData.CreatRole(BattleManager.IdLeft[leftAtkO],BattleManager.SkinIdLeft[leftAtkO],BattleManager.Left_Lv[leftAtkO],BattleManager.Left_StarLv[leftAtkO],BattleManager.Left_SkillLv[leftAtkO],BattleManager.Left_Awake[leftAtkO],PVPViewModel.IsViewRecord and BattleManager.Left_Favor[leftAtkO] or hero.favor,PVPViewModel.IsViewRecord and true or nil,lvUp)
                if BattleManager.IsTest == nil and PVPViewModel.IsViewRecord then     --如果是回放的时候
                    ReadData.SetMabt(tempRoleR)
                    ---核心属性
                    if BattleManager.LeftFW1_ID[leftAtkO]  ~= 0 and BattleManager.LeftFW1_ID[leftAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.LeftFW1_ID[leftAtkO]  , BattleManager.LeftFW1_ZB[leftAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    if BattleManager.LeftFW2_ID[leftAtkO]  ~= 0 and BattleManager.LeftFW2_ID[leftAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.LeftFW2_ID[leftAtkO]  , BattleManager.LeftFW2_ZB[leftAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    ReadData.AddSkillId(tempRoleR,BattleManager.LeftFW1_Skill[leftAtkO]  ,BattleManager.LeftFW2_Skill[leftAtkO])
                    ---共鸣装备属性
                    local role = HeroControl.GetRoleDataByID(tonumber(tempRoleR.ID))
                    if #BattleManager.LeftEquipLevel[leftAtkO] ~= 0 then
                        ---获取角色共鸣装备1
                        local equip1 = role:GetHeroEquip(1)
                        ---装备等级替换为对方等级
                        local newEquip1 = EquipControl.ReturnSingleEquip(equip1.equipID,BattleManager.LeftEquipLevel[leftAtkO][1])
                        if newEquip1 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip1.attrs,true)
                        end
                        ---获取角色共鸣装备2
                        local equip2 = role:GetHeroEquip(2)
                        local newEquip2 = EquipControl.ReturnSingleEquip(equip2.equipID,BattleManager.LeftEquipLevel[leftAtkO][2])
                        if newEquip2 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip2.attrs,true)
                        end
                        ---获取角色共鸣装备3
                        local equip3 = role:GetHeroEquip(3)
                        local newEquip3 = EquipControl.ReturnSingleEquip(equip3.equipID,BattleManager.LeftEquipLevel[leftAtkO][3])
                        if newEquip3 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip3.attrs,true)
                        end
                    end
                end
            else
                ---对方队伍角色
                local lvUp = true
                if BattleManager.LeftEquipLevel[leftAtkO] then
                    for i, v in pairs(BattleManager.LeftEquipLevel[leftAtkO]) do
                        if v < tonumber(SteamLocalData.tab[105009][2]) then
                            lvUp = false
                        end
                    end
                end
                tempRoleR= ReadData.CreatRole(BattleManager.IdLeft[leftAtkO],BattleManager.SkinIdLeft[leftAtkO],BattleManager.Left_Lv[leftAtkO],BattleManager.Left_StarLv[leftAtkO],BattleManager.Left_SkillLv[leftAtkO],BattleManager.Left_Awake[leftAtkO],BattleManager.Left_Favor[leftAtkO],true,lvUp)
                if BattleManager.IsTest==nil then
                    ReadData.SetMabt(tempRoleR)
                    ---核心属性
                    if BattleManager.LeftFW1_ID[leftAtkO]  ~= 0 and BattleManager.LeftFW1_ID[leftAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.LeftFW1_ID[leftAtkO]  , BattleManager.LeftFW1_ZB[leftAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    if BattleManager.LeftFW2_ID[leftAtkO]  ~= 0 and BattleManager.LeftFW2_ID[leftAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.LeftFW2_ID[leftAtkO]  , BattleManager.LeftFW2_ZB[leftAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    ReadData.AddSkillId(tempRoleR,BattleManager.LeftFW1_Skill[leftAtkO]  ,BattleManager.LeftFW2_Skill[leftAtkO])
                    ---共鸣装备属性
                    local role = HeroControl.GetRoleDataByID(tonumber(tempRoleR.ID))
                    if #BattleManager.LeftEquipLevel[leftAtkO] ~= 0 then
                        ---获取角色共鸣装备1
                        local equip1 = role:GetHeroEquip(1)
                        ---装备等级替换为对方等级
                        local newEquip1 = EquipControl.ReturnSingleEquip(equip1.equipID,BattleManager.LeftEquipLevel[leftAtkO][1])
                        if newEquip1 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip1.attrs,true)
                        end
                        ---获取角色共鸣装备2
                        local equip2 = role:GetHeroEquip(2)
                        local newEquip2 = EquipControl.ReturnSingleEquip(equip2.equipID,BattleManager.LeftEquipLevel[leftAtkO][2])
                        if newEquip2 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip2.attrs,true)
                        end
                        ---获取角色共鸣装备3
                        local equip3 = role:GetHeroEquip(3)
                        local newEquip3 = EquipControl.ReturnSingleEquip(equip3.equipID,BattleManager.LeftEquipLevel[leftAtkO][3])
                        if newEquip3 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip3.attrs,true)
                        end
                    end
                end
                tempRoleR.PVPEnemy = true
            end
            print(tempRoleR.Name.."下标 "..k.." Id "..BattleManager.IdLeft[leftAtkO])
            --if BattleManager.IsTest==nil then
            --    ReadData.SetMabt(tempRoleR)     --设置角色基础属性
            --end
            local tempNum = BattleManager.Left_Pos[leftAtkO]
            ---设置role位置
            tempNum=tempNum-1
            print( tempNum.."  , "..math.floor(tempNum/3))
            tempPos_X =(5- math.floor(tempNum/3))+1
            --tempPos_X = math.floor(tempNum/3)+1
            tempPos_Y =(tempNum%3)+1
            --添加音效
            MgrSound.AddCue("Audio/role/"..BattleManager.IdLeft[leftAtkO]..".acb")
        end
        --id计数器增加
        BattleManager.GameIdCout= BattleManager.GameIdCout+1
        --赋值
        tempRoleR.GameID=BattleManager.GameIdCout
        tempRoleR.IsLeft=true
        tempRoleR.AtkOrder=leftAtkO
        --测试模式直接添加装备
        if BattleManager.IsTest==true then
            ReadData.SetMabt(tempRoleR)
            if BattleManager.LeftFW1_ID[leftAtkO] ~= "0" then
                local AbtArr=  ReadData.GetGearAttr(BattleManager.LeftFW1_ID[leftAtkO]  , BattleManager.LeftFW1_ZB[leftAtkO])
                ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
            end
            if BattleManager.LeftFW2_ID[leftAtkO] ~= "0" then
                local AbtArr=  ReadData.GetGearAttr(BattleManager.LeftFW2_ID[leftAtkO]  , BattleManager.LeftFW2_ZB[leftAtkO])
                ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
            end
            ReadData.AddSkillId(tempRoleR,BattleManager.LeftFW1_Skill[leftAtkO]  ,BattleManager.LeftFW2_Skill[leftAtkO])
        end
        tempRoleR.PosX=tempPos_X
        tempRoleR.PosY=tempPos_Y
        --写入到棋盘
        BattleManager.ChessboardLeft[tempRoleR.PosY][tempRoleR.PosX]=tempRoleR
        BattleManager.AllRole[tempRoleR.GameID]=tempRoleR
        --写入队伍 索引为id
        BattleManager.LeftTeam[tempRoleR.GameID]=tempRoleR
        leftAtkO=leftAtkO + 1
    end
end
--右侧的属性 id 等级 觉醒
BattleManager.IdRight={200000,200000,200001,200001,200002,200002,200003,200003,200004,200005,200005,200000}
BattleManager.RightGearID1={} --装备1ID表集合表
BattleManager.RightGearID2={} --装备2ID表集合表
BattleManager.Right_Lv={}
BattleManager.Right_StarLv={}
BattleManager.Right_Awake={}
BattleManager.Right_SkillLv={}

BattleManager.Right_Pos={}
BattleManager.Right_Qoom={}
BattleManager.Right_IsBoss={}
BattleManager.Right_Favor={}
---初始化右边怪物的队伍  包括血量 位置 攻击顺序 GameID等信息
function BattleManager.initRight()
    if  BattleManager.FightType == BattleManager.MonsterStandType.BOSS or
            BattleManager.FightType == BattleManager.MonsterStandType.BOSS_BOSS or
            CJNBattleMgr.Instance.worldBossBattle then
        CJNBattleLoop.Instance:SetBossstate(2)
    else
        CJNBattleLoop.Instance:SetBossstate(0)
    end
    ---如果是联合讨伐模式，右边只创建一个并且从表中读取怪物配置数据
    if CJNBattleMgr.Instance.worldBossBattle then
        ---@type BattleRole
        local tempRoleR= ReadData.CreatMonster(BattleManager.IdRight[1],BattleManager.Right_Lv[1],BattleManager.Right_StarLv[1],BattleManager.Right_SkillLv[1],BattleManager.Right_Awake[1] ,tonumber(BattleManager.Right_Qoom[1]) )
        if BattleManager.IdRight[1]==900000  then
            BattleManager.BodySize=WorldBossData.Niai_BossSize
        elseif BattleManager.IdRight[1]==900001 then
            BattleManager.BodySize=WorldBossData.Suobeike_BossSize
        elseif BattleManager.IdRight[1]==900002 then
            BattleManager.BodySize=WorldBossData.Yemengjiade_BossSize
        end
        --添加音效
        MgrSound.AddCue("Audio/role/"..BattleManager.IdRight[1]..".acb")
        --id计数器增加
        BattleManager.GameIdCout= BattleManager.GameIdCout + 1
        --赋值
        tempRoleR.GameID = BattleManager.GameIdCout
        --右侧
        tempRoleR.IsLeft = false
        --第一个出手
        tempRoleR.AtkOrder = 1
        tempRoleR.HPmax = EventRaidControl.GetLIANHETAOFAData().BossData[BattleManager.CurBossLevel].maxHp
        tempRoleR.HP = EventRaidControl.GetLIANHETAOFAData().BossData[BattleManager.CurBossLevel].maxHp
        --记录自己的坐标
        local tempNum = BattleManager.Right_Pos[1]
        tempNum = tempNum - 1
        local tempPos_X = math.floor(tempNum/3) + 1
        local tempPos_Y = (tempNum%3) + 1
        tempRoleR.PosX = tempPos_X
        tempRoleR.PosY = tempPos_Y
        BattleManager.ChessboardRight[tempRoleR.PosY][7-tempRoleR.PosX]=tempRoleR --在格子上放右边的角色
        BattleManager.AllRole[tempRoleR.GameID]=tempRoleR
        BattleManager.RightTeam[tempRoleR.GameID]=tempRoleR
        return
    end
    local rightAtkO = 1
    for i = rightAtkO, #BattleManager.IdRight do
        if BattleManager.IdRight[rightAtkO] == nil then
            return
        end
        local tempRoleR =nil
        --根据战斗类型判断生成的敌人类型,3为玩家类型用CraetRole
        --记录自己的坐标  右侧的改为用1-18生成
        local tempPos_X =nil
        local tempPos_Y = nil
        if BattleManager.FightType == BattleManager.MonsterStandType.PVP ---pvp
        then
            if PVPViewModel.PlayerIsAtk ---对方队伍角色
            then
                local lvUp = true
                if BattleManager.RightEquipLevel[rightAtkO] then
                    for i, v in pairs(BattleManager.RightEquipLevel[rightAtkO]) do
                        if v < tonumber(SteamLocalData.tab[105009][2]) then
                            lvUp = false
                        end
                    end
                end
                if BattleManager.IdRight[rightAtkO] == 13009 then
                    local a = 0
                end
                tempRoleR= ReadData.CreatRole(BattleManager.IdRight[rightAtkO],BattleManager.SkinIdRight[rightAtkO],BattleManager.Right_Lv[rightAtkO],BattleManager.Right_StarLv[rightAtkO],BattleManager.Right_SkillLv[rightAtkO],BattleManager.Right_Awake[rightAtkO],BattleManager.Right_Favor[rightAtkO],true,lvUp)
                if BattleManager.IsTest==nil then
                    ReadData.SetMabt(tempRoleR)
                    ---核心属性
                    if BattleManager.RightFW1_ID[rightAtkO]  ~= 0 and BattleManager.RightFW1_ID[rightAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.RightFW1_ID[rightAtkO]  , BattleManager.RightFW1_ZB[rightAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    if BattleManager.RightFW2_ID[rightAtkO]  ~= 0 and BattleManager.RightFW2_ID[rightAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.RightFW2_ID[rightAtkO]  , BattleManager.RightFW2_ZB[rightAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    ReadData.AddSkillId(tempRoleR,BattleManager.RightFW1_Skill[rightAtkO]  ,BattleManager.RightFW2_Skill[rightAtkO])
                    ---共鸣装备属性
                    local role = HeroControl.GetRoleDataByID(tonumber(tempRoleR.ID))
                    if #BattleManager.RightEquipLevel[rightAtkO] ~= 0 then
                        ---获取角色共鸣装备1
                        local equip1 = role:GetHeroEquip(1)
                        ---装备等级替换为对方等级
                        local newEquip1 = EquipControl.ReturnSingleEquip(equip1.equipID,BattleManager.RightEquipLevel[rightAtkO][1])
                        if newEquip1 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip1.attrs,true)
                        end
                        ---获取角色共鸣装备2
                        local equip2 = role:GetHeroEquip(2)
                        local newEquip2 = EquipControl.ReturnSingleEquip(equip2.equipID,BattleManager.RightEquipLevel[rightAtkO][2])
                        if newEquip2 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip2.attrs,true)
                        end
                        ---获取角色共鸣装备3
                        local equip3 = role:GetHeroEquip(3)
                        local newEquip3 = EquipControl.ReturnSingleEquip(equip3.equipID,BattleManager.RightEquipLevel[rightAtkO][3])
                        if newEquip3 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip3.attrs,true)
                        end
                    end
                end
                tempRoleR.PVPEnemy = true
            else    ---自己队伍角色(PVP防御记录用)
                local lvUp = true
                if BattleManager.RightEquipLevel[rightAtkO] then
                    for i, v in pairs(BattleManager.RightEquipLevel[rightAtkO]) do
                        if v < tonumber(SteamLocalData.tab[105009][2]) then
                            lvUp = false
                        end
                    end
                end
                tempRoleR= ReadData.CreatRole(BattleManager.IdRight[rightAtkO],BattleManager.SkinIdRight[rightAtkO],BattleManager.Right_Lv[rightAtkO],BattleManager.Right_StarLv[rightAtkO],BattleManager.Right_SkillLv[rightAtkO],BattleManager.Right_Awake[rightAtkO],BattleManager.Right_Favor[rightAtkO],true,lvUp)
                if BattleManager.IsTest==nil then
                    ReadData.SetMabt(tempRoleR)
                    ---核心属性
                    if BattleManager.RightFW1_ID[rightAtkO]  ~= 0 and BattleManager.RightFW1_ID[rightAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.RightFW1_ID[rightAtkO]  , BattleManager.RightFW1_ZB[rightAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    if BattleManager.RightFW2_ID[rightAtkO]  ~= 0 and BattleManager.RightFW2_ID[rightAtkO] ~= nil then
                        local AbtArr=  ReadData.GetGearAttr(BattleManager.RightFW2_ID[rightAtkO]  , BattleManager.RightFW2_ZB[rightAtkO])
                        ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
                    end
                    ReadData.AddSkillId(tempRoleR,BattleManager.RightFW1_Skill[rightAtkO]  ,BattleManager.RightFW2_Skill[rightAtkO])
                    ---共鸣装备属性
                    local role = HeroControl.GetRoleDataByID(tonumber(tempRoleR.ID))
                    if #BattleManager.RightEquipLevel[rightAtkO] ~= 0 then
                        ---获取角色共鸣装备1
                        local equip1 = role:GetHeroEquip(1)
                        ---装备等级替换为对方等级
                        local newEquip1 = EquipControl.ReturnSingleEquip(equip1.equipID,BattleManager.RightEquipLevel[rightAtkO][1])
                        if newEquip1 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip1.attrs,true)
                        end
                        ---获取角色共鸣装备2
                        local equip2 = role:GetHeroEquip(2)
                        local newEquip2 = EquipControl.ReturnSingleEquip(equip2.equipID,BattleManager.RightEquipLevel[rightAtkO][2])
                        if newEquip2 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip2.attrs,true)
                        end
                        ---获取角色共鸣装备3
                        local equip3 = role:GetHeroEquip(3)
                        local newEquip3 = EquipControl.ReturnSingleEquip(equip3.equipID,BattleManager.RightEquipLevel[rightAtkO][3])
                        if newEquip3 ~= nil then
                            ReadData.InitRoleGear(tempRoleR,newEquip3.attrs,true)
                        end
                    end
                end
            end
            local tempNum = BattleManager.Right_Pos[rightAtkO]
            tempNum=tempNum-1
            tempRoleR.AtkOrder = rightAtkO
            tempPos_X =math.floor(tempNum/3)+1
            tempPos_Y =(tempNum%3)+1
            --添加音效
            MgrSound.AddCue("Audio/role/"..BattleManager.IdRight[rightAtkO]..".acb")
        else    ---非PVP战斗/非联合讨伐
            tempRoleR= ReadData.CreatMonster(BattleManager.IdRight[rightAtkO],BattleManager.Right_Lv[rightAtkO],BattleManager.Right_StarLv[rightAtkO],BattleManager.Right_SkillLv[rightAtkO],BattleManager.Right_Awake[rightAtkO],tonumber(BattleManager.Right_Qoom[rightAtkO]) ,rightAtkO)
            if tempRoleR.Occupation == 5 or tempRoleR.Occupation == 6 then
                if tonumber(tempRoleR.ID) ~= 900002 and tonumber(tempRoleR.ID) ~= 600002 then
                    BattleManager.BodySize=WorldBossData.Niai_BossSize
                else
                    BattleManager.BodySize=WorldBossData.Yemengjiade_BossSize
                end
            end
            local tempNum = BattleManager.Right_Pos[rightAtkO]
            tempNum=tempNum-1
            tempPos_X =math.floor(tempNum/3)+1
            tempPos_Y =(tempNum%3)+1
        end
        --id计数器增加
        BattleManager.GameIdCout = BattleManager.GameIdCout + 1
        --赋值
        tempRoleR.GameID=BattleManager.GameIdCout
        tempRoleR.IsLeft=false
        tempRoleR.PosX=tempPos_X
        tempRoleR.PosY=tempPos_Y
        --测试模式直接添加装备
        if BattleManager.IsTest==true then
            ReadData.SetMabt(tempRoleR)
            if BattleManager.RightFW1_ID[rightAtkO]  ~= "0" then

                local AbtArr=  ReadData.GetGearAttr(BattleManager.RightFW1_ID[rightAtkO]  , BattleManager.RightFW1_ZB[rightAtkO])
                ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
            end
            if BattleManager.RightFW2_ID[rightAtkO]  ~= "0" then
                local AbtArr=  ReadData.GetGearAttr(BattleManager.RightFW2_ID[rightAtkO]  , BattleManager.RightFW2_ZB[rightAtkO])
                ReadData.InitRoleGear( tempRoleR, AbtArr ,true)
            end
            ReadData.AddSkillId(tempRoleR,BattleManager.RightFW1_Skill[rightAtkO]  ,BattleManager.RightFW2_Skill[rightAtkO])
        end
        --写入到棋盘
        BattleManager.ChessboardRight[tempRoleR.PosY][7-tempRoleR.PosX]=tempRoleR
        BattleManager.AllRole[tempRoleR.GameID]=tempRoleR
        -- print(tempRole.Atk)
        ---写入队伍 索引为id
        ---写入队伍 索引为id
        BattleManager.RightTeam[tempRoleR.GameID]=tempRoleR
        rightAtkO=rightAtkO+1
    end
end
function BattleManager.initLeftSpine()
    print("  --创建角色spine ---左侧")

    for k, v in pairs(BattleManager.LeftTeam) do
        local tempRole = BattleManager.LeftTeam[k]
        if tempRole.Remove then
            return
        end
        --创建角色
        BattleManager.AllRole[tempRole.GameID]=tempRole
        tempRole:RoleAniLoad( tempRole,k*0.2)
        print(tempRole.Name.."下标"..k)
        tempRole.myAni:SetPos(tempRole.DownPos_X, tempRole.DownPos_Y,tempRole.MidPos_X ,tempRole.MidPos_Y ,tempRole.TopPos_X, tempRole.TopPos_Y)
        tempRole.myAni:LuaPlayAniName("dj",true,0)
        BattleManager.initAudio(tempRole)
        if tempRole.RealAgile >= 1 then
            tempRole.myAni:SetSingleEffect("Buff_ShanBiMax_v1")
        end
        if tempRole.RealDef >= 1 then
            tempRole.myAni:SetSingleEffect("Buff_HuDunMax_v1")
        end
    end-- for k, v
    --顺便把右边的血条显示
    for k, v in pairs(BattleManager.RightTeam) do
        local tempRole = BattleManager.RightTeam[k]
        BattleManager.initAudio(tempRole)
        tempRole.myAni:ShowHP(true)
    end-- for k, v

end
function  BattleManager.initRightSpine()
    print("创建右侧spine")
    --数量
    for k, v in pairs(BattleManager.RightTeam) do
        local tempRole = BattleManager.RightTeam[k]
        if tempRole.Occupation == 5 or tempRole.Occupation == 6 then
            tempRole.HP = (BattleManager.CurActivityBossHp == 0 or BattleManager.CurActivityBossHp == nil) and tempRole.HP or BattleManager.CurActivityBossHp
        end
        tempRole:RoleAniLoad(tempRole,k*0.2)
        local go = tempRole.myAni.transform:Find("Watch_3D(Clone)")
        if tempRole.Occupation == 5 or tempRole.Occupation == 6
        then
            go.localScale = Vector3(1,1,1)
            if BattleManager.IdRight[1] == 900002 or BattleManager.IdRight[1] == 600002 then
                go.localScale = Vector3(1,1,1)
                ---耶梦加德水花
                MgrTimer.AddDelay("lianyi",0.5,function()
                    tempRole.myAni:YMJDCreateLianyi({{178,-100,-102,3},{-71,-100,102,7},{-368,-100,102,7},{-385,-100,-117,3},{18,-100,-341,5}})
                end,nil)
            end
        end

        --给地板赋值    位置、id和职业
        tempRole.myAni:XYSetPos_Right(tempRole.PosX, tempRole.PosY,tempRole.GameID,tempRole.Occupation)
        --右边先隐藏U
        tempRole.myAni:ShowHP(false)
        if tempRole.Occupation == 5 or tempRole.Occupation == 6
        then
            --这是世界Boss
            tempRole.myAni:ThisIsWorldBoss()
            --替换世界BossUI
            tempRole.myAni:SetBossUI()
            --设置世界Boss盾条
            --tempRole.myAni:SetBossShield(tempRole.shiledNum)
            --记录Boss位置
            tempRole.myAni:RecordBossPosAndRotation()
            --设置显示层级以及UI位置标杆坐标
            tempRole.myAni:SetLaye(BattleManager.BodySize[1],BattleManager.BodySize[2],BattleManager.BodySize[3],BattleManager.BodySize[4])
            if BattleManager.nextNotFlyin then
                BattleManager.nextNotFlyin=nil
                tempRole.myAni:PlayAni(1)
            else
                tempRole.myAni:FlayIn()
            end
            CJNBattleMgr.Instance.hideBossFloor = true
        else
            tempRole.myAni:SetMonster_Size(tonumber(BattleManager.Right_Qoom[tempRole.AtkOrder]))
            tempRole.myAni:ThisIsMonster()
            if 10000 <= tonumber(tempRole.ID) and tonumber(tempRole.ID) < 20000 and (BattleManager.GameMode == BattleManager.GameModeType.RedTower or BattleManager.GameMode == BattleManager.GameModeType.PVP) then    --红色巨塔NPC朝向
                tempRole.myAni:SetNpc_Reverse()
            end
            if BattleManager.pvpF then
                BattleManager.pvpF=nil
                tempRole.myAni:FlayIn()
            else
                tempRole.myAni:PlayAni(1)
            end
            CJNBattleMgr.Instance.hideBossFloor = false
        end
        --赋值顶部坐标
        tempRole.myAni:SetPos(tempRole.DownPos_X, tempRole.DownPos_Y,tempRole.MidPos_X ,tempRole.MidPos_Y ,tempRole.TopPos_X, tempRole.TopPos_Y)

        --百防百闪
        if tempRole.RealAgile >= 1 then
            tempRole.myAni:SetSingleEffect("Buff_ShanBiMax_v1")
        end
        if tempRole.RealDef >= 1 then
            tempRole.myAni:SetSingleEffect("Buff_HuDunMax_v1")
        end
    end
end
--游戏开始时,触发游戏开始的buff
function BattleManager.GameStart(TrueOrFalse,closePanelCallBack)
    CJNBattleLoop.Instance:SetOnlyData(false)
    ---设置管理器为战斗状态
    CJNBattleMgr.FightState = 3

    BattleManager.SetStaticData()          --设置游戏参数
    BattleManager.RankLeftTeam()           --按照攻击顺序排列左边队伍
    BattleManager.Rank()                   --排列整体队伍
    --if BattleManager.FightType ~= 4  then
    --    -- 如果不是PVP对战则需要初始化生成一次左侧Spine
    --    if  BattleManager.IsTest_pve==true  then
    --        print("initLeftSpine175")
    --        BattleManager.initLeftSpine()
    --    end
    --end
    BattleManager.IsFightStart=true

    if closePanelCallBack then
        MgrTimer.AddDelayNoName(0,FightVideoViewModel.SendSign(BattleManager.GameMode,closePanelCallBack))
    else
        BattleManager.GameStart_LuatoC(function ()
            MgrTimer.AddDelayNoName(0,FightVideoViewModel.SendSign(BattleManager.GameMode))
        end)
    end
    Event.Go("UpdateBattleCombineSkillPanel")
end
--设置游戏参数
function BattleManager.SetStaticData()
    CBattleData.HPMax= SteamLocalData.tab[103015][2]--生命值 取值最大值
    CBattleData.m_AgileDMG=SteamLocalData.tab[103010][2]  --闪避减伤
    local temSkilldef_k=tonumber(SteamLocalData.tab[103014][2])
    CBattleData.m_MaxSkillDef=SteamLocalData.tab[103012][2]*10000  --技能减伤最大值
    CBattleData.m_MinSkillDef=SteamLocalData.tab[103013][2]*10000  --技能减伤最小值/伤害加深
    CBattleData.m_AgileDebuff=SteamLocalData.tab[103011][2]
    CBattleData.m_MaxAtkUp=SteamLocalData.tab[103003][2]*10000--攻击力上下限
    CBattleData.m_MinAtkUp=SteamLocalData.tab[103004][2]*10000
    CBattleData.m_MaxDef=SteamLocalData.tab[103001][2]--装甲上下限
    CBattleData.m_MinDef=SteamLocalData.tab[103002][2]
    CBattleData.m_MaxAgi=SteamLocalData.tab[103008][2] --闪避上下限
    CBattleData.m_MinAgi=SteamLocalData.tab[103009][2]
    CBattleData.m_MaxCrit=SteamLocalData.tab[103005][2] --暴击率上下限
    CBattleData.m_MinCrit=SteamLocalData.tab[103006][2]
    CBattleData.m_MinCritDMG=SteamLocalData.tab[103007][2] --最小暴击伤害
    CBattleData.m_MinSkillHPMax=SteamLocalData.tab[103000][2]*10000 --最大生命值最小值
    CBattleData.m_Skilldef_k=temSkilldef_k --技能减伤系数
    print( "--设置游戏参数---------------"..CBattleData.m_Skilldef_k)
end

--给c#传值
function BattleManager.GameStart_LuatoC(callback)
    CreatRoleData.ClearData()           --清理之前角色数据/生成地板
    --创建每个C#角色
    local coutgameid = 0
    for key, value in pairs(BattleManager.AllRole) do
        BattleRole.CreartData(value)
    end
    if  BattleManager.IsTest_pve~=true  then
        for k, v in pairs(BattleManager.AllRole) do
            local tempRole = BattleManager.AllRole[k]
            --创建头像
            if tempRole~=nil then
                tempRole.myAni:HidOrder()
            end
        end
    end
    -------------------------战斗走C#时需要-----------------------------------

    ------------------------------------------------------------
    print("+++++----JNTurnEffectMgr.CeratAll()")
    JNTurnEffectMgr.CeratAll(callback)
   
    --全部创建之后
    --MgrTimer.AddDelayNoName(0.2, JNTurnEffectMgr.CeratAll,nil)
end
require("ReadData/CollectionData")
--重新排列左侧队伍,按照攻击顺序
function BattleManager.RankLeftTeam()
    local temptab = {}
    for key, value in pairs(BattleManager.LeftTeam) do
        --  print( value.GameID..value.Name.."--重新排列左侧队伍,按照攻击顺序"..value.AtkOrder)
        temptab[value.AtkOrder]=value
    end
    BattleManager.LeftTeam=temptab
end
--按照攻击顺序依次加入  排序  剔除标记为 Remove 的角色 如果传入下标 ,下标前的只剔除,后的重新找目标
function BattleManager.Rank()
    BattleManager.AtkOrderRankIndex = 1
    BattleManager.AtkOrderRank={}       --把攻击队列清空
    BattleManager.AtkODLeft={}
    BattleManager.AtkODRight={}
    local LeftLen = 0
    local RightLen = 0
    --先按照攻击顺序排序
    BattleManager.LeftAtkOrder={}
    for k, v in pairs(BattleManager.LeftTeam) do  --把左侧的按照攻击顺序加入
        BattleManager.LeftAtkOrder[BattleManager.LeftTeam[k].AtkOrder]=BattleManager.LeftTeam[k]    --按照队伍内攻击顺序放入左边攻击顺序
        LeftLen = LeftLen + 1
    end
    BattleManager.RightAtkOrder={}
    for k, v in pairs(BattleManager.RightTeam) do
        BattleManager.RightAtkOrder[BattleManager.RightTeam[k].AtkOrder]=BattleManager.RightTeam[k]     --按照队伍内攻击顺序放入右边攻击顺序
        RightLen=RightLen + 1
    end
    local LeftIndex = 1
    local RightIndex = 1
    --左边
    local IsTempSleLeft = true
    local tempRole = nil
    if BattleManager.IsLeftFirst then   --左边先手
        tempRole =  BattleManager.LeftAtkOrder[1]
        IsTempSleLeft = true
        LeftIndex = LeftIndex + 1
    else
        tempRole =  BattleManager.RightAtkOrder[1]
        IsTempSleLeft = false
        RightIndex = RightIndex + 1
    end
    BattleManager.AtkOrderRankMax= LeftLen + RightLen   --最大长度
    local next = function()
        if tempRole==nil or tempRole.Remove==true or tempRole.Occupation==4 or (tempRole.Occupation==3 and tempRole.IsCharged==true)
        then
        if IsTempSleLeft then
            if LeftIndex>LeftLen then
                IsTempSleLeft=false
                tempRole=BattleManager.RightAtkOrder[RightIndex]
                RightIndex=RightIndex+1
            else
                IsTempSleLeft=true
                tempRole=BattleManager.LeftAtkOrder[LeftIndex]
                LeftIndex=LeftIndex+1
            end
        else
            if RightIndex>RightLen then
                IsTempSleLeft=true
                tempRole=BattleManager.LeftAtkOrder[LeftIndex]
                LeftIndex=LeftIndex+1
            else
                IsTempSleLeft=false
                tempRole=BattleManager.RightAtkOrder[RightIndex]
                RightIndex=RightIndex+1
            end
        end
    else
        if IsTempSleLeft then
            if RightIndex>RightLen then
                IsTempSleLeft=true
                tempRole=BattleManager.LeftAtkOrder[LeftIndex]
                LeftIndex=LeftIndex+1
            else
                IsTempSleLeft=false
                tempRole=BattleManager.RightAtkOrder[RightIndex]
                RightIndex=RightIndex+1
            end
        else
            if LeftIndex>LeftLen then
                IsTempSleLeft=false
                tempRole=BattleManager.RightAtkOrder[RightIndex]
                RightIndex=RightIndex+1
            else
                IsTempSleLeft=true
                tempRole=BattleManager.LeftAtkOrder[LeftIndex]
                LeftIndex=LeftIndex+1
            end
        end
    end
    end
    for i = 1,BattleManager.AtkOrderRankMax do
        if tempRole == nil or tempRole.Remove then
            next()
        else
            tempRole.AllAtkOrder = i        --改变角色的总进攻顺序
            table.insert(BattleManager.AtkOrderRank,tempRole)
        end
        next()
    end
end
function BattleManager.SetLeftSpineUI()
    print("  --创建角色spine ---左侧")
    for k, tempRole in pairs(BattleManager.AllRole) do
        if tempRole.IsLeft == true then
            --创建角色
            --BattleManager.AllRole[tempRole.GameID]=tempRole
            --tempRole:RoleAniLoad( tempRole,k*0.2)
            --print(tempRole.Name.."下标"..k)
            tempRole.myAni:SetPos(tempRole.DownPos_X, tempRole.DownPos_Y,tempRole.MidPos_X ,tempRole.MidPos_Y ,tempRole.TopPos_X, tempRole.TopPos_Y)
            tempRole.myAni:LuaPlayAniName("dj",true,0)
            BattleManager.initAudio(tempRole)
        end
    end-- for k, v
    --顺便把右边的血条显示
    for k, tempRole in pairs(BattleManager.AllRole) do
        if tempRole.IsLeft == false then
            BattleManager.initAudio(tempRole)
            tempRole.myAni:ShowHP(true)
        end
    end-- for k, v
end
function BattleManager.initAudio(_temprole)
        --先找对应的名称
        if _temprole.Str_Audio~=nil and _temprole.Str_Audio~="0" then

            for key, value in pairs(ActorLinesLocalData.tab) do

                if value[2] ==tonumber(_temprole.Str_Audio)     then
                    if value[3] == 21 then
                        _temprole.myAni.Audio_Kill=value[13]
                    elseif value[3] == 22 then
                        _temprole.myAni.Audio_Accumulate=value[13]
                    elseif value[3] == 23 then
                        _temprole.myAni.Audio_Atk=value[13]
                    elseif value[3] == 24 then
                        _temprole.myAni.Audio_Pursue=value[13]
                    elseif value[3] == 25 then
                        _temprole.myAni.Audio_EX=value[13]
                    elseif value[3] == 26 then
                        _temprole.myAni.Audio_Dead=value[13]
                    end

                end
            end

        end
        _temprole.myAni:AddAudioClip()
end

--当前活动boss血量
BattleManager.CurActivityBossHp = 0
--给在左侧的人排序
function BattleManager:SortLeft()
    local tempSlrtTab = {}

    for k, v in pairs(BattleManager.LeftTeam) do
        tempSlrtTab[BattleManager.LeftTeam[k].AtkOrder]=BattleManager.LeftTeam[k]
    end
    BattleManager.LeftTeam=tempSlrtTab

end
--替换一个角色 ,攻击顺序不变 ,添加一个 ,排在最后 ,删除一个 ,改变所有大于他的,依次-1
function  BattleManager:DelOrder( _delOrder)
    for k, v in pairs(BattleManager.LeftTeam) do
        if BattleManager.LeftTeam.AtkOrder>_delOrder then
            BattleManager.LeftTeam.AtkOrder= BattleManager.LeftTeam.AtkOrder-1
        end
    end
end

function BattleManager:ExchangeOrder(_LeftId1,_leftId2)

end
--创建一个角色 ,从GameData里读取id ,传入 星级 等级 技能等级 类型：1玩家角色 2Npc
BattleManager.LeftAtkOrderCout=1
function BattleManager.CreartRoleLeft(GameDataID,skinID, LV, StartLV, SkillLV, IsAwken, roleType, userID, friend, favor,equipUnlockLV)
    --读出RoleattributeLocalData表中所有数据
    local tempRoleL= ReadData.CreatRole(GameDataID,skinID,LV,StartLV,SkillLV,IsAwken,favor,nil,equipUnlockLV)
    ---角色类型：1玩家角色 2Npc 3好友支援角色
    if roleType then
        tempRoleL.roleType = roleType
    else
        tempRoleL.roleType = 1
    end
    if userID then
        tempRoleL.userID = userID
        tempRoleL.roleType = 3
    end
    ---是否是好友
    if friend then
        tempRoleL.friend = friend
    end

    -- print("创建的临时"..tempRoleL.Atk)
    --id计数器增加+

    BattleManager.GameIdCout= BattleManager.GameIdCout+1
    print("拖动产生 " .. BattleManager.GameIdCout)
    --赋值
    tempRoleL.GameID=BattleManager.GameIdCout
    tempRoleL.IsLeft=true

    return tempRoleL
end
--拖上去的角色才会被生成攻击顺序    角色  是否+1,如果是替换的顺序不加
function BattleManager.LeftSetOrder(_tempRoleL)
    _tempRoleL.AtkOrder=BattleManager.LeftAtkOrderCout

    BattleManager.LeftAtkOrderCout=BattleManager.LeftAtkOrderCout+1

end
--添加到左侧队伍
function BattleManager.LeftTeamAdd( tempRoleL)
    BattleManager.ChessboardLeft[tempRoleL.PosY][tempRoleL.PosX]=tempRoleL
    BattleManager.AllRole[tempRoleL.GameID]=tempRoleL
    BattleManager.LeftTeam[tempRoleL.AtkOrder]=tempRoleL
end
--添加到左侧暂时
function BattleManager.LeftTeamAdd_Temp( tempRoleL)
    tempRoleL.AtkOrder=BattleManager.LeftAtkOrderCout
    BattleManager.AllRole[tempRoleL.GameID]=tempRoleL
    BattleManager.LeftTeam[tempRoleL.GameID]=tempRoleL

end
function BattleManager.LeftTemaReomve_Temp(tempRoleL)
    BattleManager.AllRole[tempRoleL.GameID]=nil
    BattleManager.LeftTeam[tempRoleL.AtkOrder]=nil
end

function BattleManager.RightTeamRemove(tempRoleL)
    local _removeId=tempRoleL.GameID

    BattleManager.ChessboardRight[tempRoleL.PosY][tempRoleL.PosX]=0

    BattleManager.AllRole[_removeId]=nil
    BattleManager.GameIdCout = BattleManager.GameIdCout - 1
    for i, role in pairs(BattleManager.RightTeam) do
        if role.GameID == _removeId then
            BattleManager.LeftTeam[i] = nil
            break
        end
    end
end

--移除一个
function BattleManager.LeftTemaReomve(tempRoleL)
    local _removeId=tempRoleL.GameID

    BattleManager.ChessboardLeft[tempRoleL.PosY][tempRoleL.PosX]=0

    BattleManager.AllRole[_removeId]=nil
    BattleManager.GameIdCout = BattleManager.GameIdCout - 1
    --local n = 1
    for i, role in pairs(BattleManager.LeftTeam) do
        if role.GameID == _removeId then
            BattleManager.LeftTeam[i] = nil
            break
        end
        --n = n + 1
    end
end
---将大于指定攻击顺序的左侧角色顺序-1
function BattleManager.SetOrderAfter(dragRole)
    BattleManager.GameIdCout = BattleManager.GameIdCout - 1
    BattleManager.LeftAtkOrderCout = BattleManager.LeftAtkOrderCout - 1
    for i, role in pairs(BattleManager.AllRole) do
        if role.AllAtkOrder > dragRole.AllAtkOrder then
            role.AllAtkOrder = role.AllAtkOrder - 1
        end
    end

    for i, role in pairs(BattleManager.LeftTeam) do
        if role.AtkOrder > dragRole.AtkOrder then
            role.AtkOrder = role.AtkOrder - 1
        end
        if role.GameID ~= nil then
            if role.GameID > dragRole.GameID then
                role.GameID = role.GameID - 1
                role.myAni.GameID = role.myAni.GameID - 1
            end
            ---重设地板ID
            role.myAni:XYSetPos2(role.PosX, role.PosY, role.GameID, role.Occupation)
        end
    end
end
--开始战斗的摄像机模式
function BattleManager.SetCanmeraNor()
    ---获取战斗摄像机
    local battleCamera = CMgrCamera.Instance.FightCamera

    ---初始化相机位置
   --Tools.DoCameraUIMove(battleCamera.transform,Vector3(0,-55,-915),1,0,15,false,0,0)
    battleCamera.transform.localPosition=Vector3(0,-55,-915)
    battleCamera.transform.localRotation = Quaternion.Euler(-6, 0, 0)
    battleCamera.fieldOfView = 26;

end
--寻找目标并且显示地板             拖拽角色   拖拽位置横格子 拖拽位置竖格子
function BattleManager.FAndShowRound(_temprole,_posx ,_posy)
    BattleManager.RankLeftTeam()
    local  tempAtkRole=_temprole
    tempAtkRole.SleRole=nil
    --找到角色的目标
    BattleManager.SleTarget(tempAtkRole,tempAtkRole.IsLeft,_posy)
     print("  --显示地板----------".._temprole.Name)
    local temprolex = _temprole.PosX
    local temproley = _temprole.PosY
    if _posx~=nil then
        temprolex=_posx
        temproley=_posy
    end
    ----------判断能否开启
    if tempAtkRole.SleRole==nil or tempAtkRole.SleRole.myAni.gameObject==nil then
        ---设置地板颜色
        BattleManager.CjnMgr:SetFloorStata( _temprole.IsLeft,temprolex,temproley,10+_temprole.Occupation ,-1)
        return
    end
    local IsRed
    CMgrCamera.Instance:CloseStrokeCamera()
    ---描边相机
    if _temprole.Occupation==4 then
        IsRed=false
        CMgrCamera.Instance:StartStrokeCamera(255,230,0)
      else
        IsRed=true
        CMgrCamera.Instance:StartStrokeCamera(255,28,4)    --蓝色 0  17  236  金色  255  230  0
      end
   
    ---判断是否关了重开
    local tempIntX = tempAtkRole.SleRole.PosX
    local tempIntY = tempAtkRole.SleRole.PosY
    local tempIsLeft = tempAtkRole.SleRole.IsLeft

    local tempFstata=1
    if tempAtkRole.Occupation==4 then  --判断是否支援型
        tempFstata=2
    else

    end
    local tabIsleft={}
    local tabPosX={}
    local tabPosY={}
    local tabOcc={}
    --自己角色位置
    table.insert(tabIsleft, _temprole.IsLeft)
    table.insert(tabPosX,temprolex)
    table.insert(tabPosY,temproley)
    table.insert(tabOcc,10+_temprole.Occupation)

    --目标位置
    table.insert(tabIsleft, tempIsLeft)
    table.insert(tabPosX,tempIntX)
    table.insert(tabPosY,tempIntY)
    table.insert(tabOcc,tempFstata)
     --BattleManager.CjnMgr:SetFloorStata( _temprole.IsLeft,temprolex,temproley,10+_temprole.Occupation ,-1)
     --BattleManager.CjnMgr:SetFloorStata( tempIsLeft,tempIntX,tempIntY,tempFstata ,-1)
     --判断是范围攻击
    if tempAtkRole.AtkRange[2]~=nil then
        for k,v in pairs(tempAtkRole.AtkRange) do
            local  tempIntX2
            if _temprole.IsLeft then
                tempIntX2=tempIntX+tempAtkRole.AtkRange[k][1]
            else
                tempIntX2=tempIntX-tempAtkRole.AtkRange[k][1]
            end
            local  tempIntY2=tempIntY+tempAtkRole.AtkRange[k][2]
            --  print("范围攻击 ==========" ..tempIntX2..","..tempIntX..";"..tempIntY2..","..tempIntY )

          -- BattleManager.CjnMgr:SetFloorStata( tempIsLeft,tempIntX2,tempIntY2,tempFstata ,-1)
           table.insert(tabIsleft, tempIsLeft)
           table.insert(tabPosX,tempIntX2)
           table.insert(tabPosY,tempIntY2)
           table.insert(tabOcc,tempFstata)
        end

    end
    --朝目标发射一条线
    BattleManager.CjnMgr:SetFloorSleLine(_temprole.IsLeft,temprolex,temproley,tempAtkRole.SleRole.myAni ,IsRed ,tabIsleft,tabPosX,tabPosY,tabOcc)
      --主要目标脚底生成一个圈 , 所有目标描红
      --tempAtkRole.SleRole.myAni:SetStroke()
      --if tempAtkRole.Secondary[1]~=nil then
          --for key, value in pairs(tempAtkRole.Secondary) do
              --tempAtkRole.Secondary[key].myAni:SetStroke()
          --end
      --end
     -- print("  --显示地板++++++++++++")
end
-------------传递给c#--------------------开始
BattleManager.PvPModelWinOrLose = false
--游戏结束--传值并且弹出界面
function BattleManager.ReturnToMainScene(_win)
    ---若有打开BattlePause_UI，关闭已存在的BattlePause_UI
    MgrUI.ClosePop(UID.BattlePause_UI)
    MgrUI.ClosePop(UID.PVPPause_UI)
    Event.Go("PauseBtnClose")

    BattleManager.PvPModelWinOrLose = _win
    BattleRoleData.Bool_Pass = _win
    MgrTimer.Cancel("BattleUIUpdate")

    if BattleManager.GameMode == BattleManager.GameModeType.RedTower
    then
        ---打开胜利/失败特效
        MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
            Event.Go("PanelFight")
            ---去结算
            --StormViewModel.BattleEndOpen(0)
            ---挑战红巨结算
            if FightVideoViewModel.TowerReward == nil then
                MgrBattle.CloseFight()
            else
                ---更新物品奖励
                --ItemControl.PushGroupItemData(FightVideoViewModel.TowerReward,ItemControl.PushEnum.add)
                ---显示奖励弹窗
                MgrUI.Pop(UID.ItemAchievePop_UI,{FightVideoViewModel.TowerReward,function()
                    ---返回红巨界面
                    MgrBattle.CloseFight()
                end},true)
            end
        end},true)
    elseif BattleManager.GameMode == BattleManager.GameModeType.Guide  ---战术指导
    then
        ---打开胜利/失败特效
        MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
            Event.Go("PanelFight")
            ---战术指导结算
            if FightVideoViewModel.GuideTab == nil or FightVideoViewModel.LeftWin == false then
                MgrBattle.CloseFight()
            else
                ---显示奖励弹窗
                MgrUI.Pop(UID.ItemAchievePop_UI,{FightVideoViewModel.GuideTab.reward,function()
                    ---返回战术指导界面
                    MgrBattle.CloseFight()
                end},true)
            end
        end},true)
    elseif BattleManager.GameMode == BattleManager.GameModeType.Normal or BattleManager.GameMode == BattleManager.GameModeType.Novice or BattleManager.GameMode == BattleManager.GameModeType.ActivityBoss
    then
        ---打开胜利/失败特效
        MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
            Event.Go("PanelFight")
            if NoviceViewModel.NoviceBattleEnd then
                if NoviceViewModel.CurTaskId == 50711 then
                    if BattleRoleData.Bool_Pass then
                        MessageEvent.Go(EID.NoviceCheck,50713)
                    else
                        MessageEvent.Go(EID.NoviceCheck,50712)
                    end
                else
                    MessageEvent.Go(EID.NoviceCheck,nil,nil)
                end
            else
                StormViewModel.BattleEndOpen(0)
            end
        end},true)
    elseif BattleManager.GameMode == BattleManager.GameModeType.PVP
    then
        ---打开胜利/失败特效
        MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
            ---跳过按钮关闭
            Event.Go("JumpOutClose")
            Event.Go("PanelFight")
            ---去回放结算
            if PVPViewModel.IsViewRecord then
                ---打开回放结算界面
                MgrUI.Pop(UID.RecordComplete_UI,nil,true)
            else
                ---打开PVP结算界面
                PVPViewModel.OpenCompleteUI()
            end
        end},true)
    elseif BattleManager.GameMode == BattleManager.GameModeType.WorldBoss or BattleManager.GameMode == BattleManager.GameModeType.AniWorldBoss
    then
        if StormViewModel.IsAnaWorldBoss then
            ---模拟战打开胜利/失败特效后直接返回
            MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
                Event.Go("PanelFight")
                StormViewModel.CloseWorldBossBattle()
            end},true)
        else
            ---非模拟战打开胜利/失败特效和结算弹窗
            MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
                Event.Go("PanelFight")
                ---弹出结算界面
                MgrUI.Pop(UID.WBComplete_UI,{ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId)},true)
            end},true)
        end
    else
        MgrUI.Pop(UID.WinOrFail_UI,{BattleRoleData.Bool_Pass,function()
            MgrBattle.CloseFight()
        end},true)
    end
end
BattleManager.OnlyData=false
BattleManager.BossScoreCell = nil
--boss积分回调 bossHp,atkIndex,atkRoundCount
function BattleManager.ReturnFightData_Eve(...)
    if BattleManager.BossScoreCell ~= nil then
        BattleManager.BossScoreCell(...)
    end
end
-------------传递给c#--------------------结束
--寻找目标              参数1 角色 参数2 左侧还是右侧队伍 参数3角色的位置
function BattleManager.SleTarget(role,IsLeft,_tempRolePosY)
    if _tempRolePosY < 1 then
        return
    end
    --获取到要找目标的角色
    local   tempRole=nil
    tempRole=role

    local tempRolePosY = tempRole.PosY
    if _tempRolePosY~=nil then

        tempRolePosY=_tempRolePosY
        --  print(" --设定要用的Y坐标和x坐标---".. tempRolePosY)
    end
    local   tempTeam=BattleManager.RightTeam
    local  tempChessboard=BattleManager.ChessboardRight
    --类型为普通,攻击最近的目标
    if( tempRole.Attacktarget==1  )
    then
        if (tempRole.IsLeft) then
            tempTeam=BattleManager.RightTeam
            tempChessboard=BattleManager.ChessboardRight
        else
            tempTeam=BattleManager.LeftTeam
            tempChessboard=BattleManager.ChessboardLeft
        end
        --找同一条线的第一个敌人
        --先从棋盘找,然后用对应id找
        local FindTarget = 0 --  1是开始状态 ,2是第二次找目标,3是第三次找目标 -1为找到了
        local TempPosY = tempRolePosY
        --    print(tempRole.PosX..",".. tempRolePosY)
        for f = 3, 1, -1 do
            for i = 6, 1, -1 do
                --有敌人则直接加入并跳出循环,没有换行
                if tempChessboard[TempPosY][i]~=nil and tempChessboard[TempPosY][i]~=0 and tempChessboard[TempPosY][i].Remove~=true then
                    tempRole.SleRole=tempChessboard[TempPosY][i]
                    FindTarget=-1
                    --   print(  "已找到"..TempPosY..","..i.."---------"..  tempRole.SleRole.AniName)
                    break-- for i = 6, 1, -1 do
                end--  if tempChessboard[TempPosY][i]>0 then
            end-- for i = 6, 1, -1 do
            if FindTarget==-1 then
                break
            end -- if FindTarget==0

            FindTarget=FindTarget+1
            --    print("第几次寻找"..f..tempRolePosY..FindTarget.."当前行"..TempPosY)
            --三条线三种换行的方法
            if tempRolePosY==1  then
                if FindTarget==1 then
                    TempPosY=3
                else
                    TempPosY=2
                end
            elseif tempRolePosY==2 then
                if FindTarget==1 then
                    TempPosY=1
                else
                    TempPosY=3
                end
            elseif tempRolePosY==3 then
                if FindTarget==1 then
                    TempPosY=2
                else
                    TempPosY=1
                end
            end

        end--for f=3
        if FindTarget~=-1 then
            --如果没找到目标换行继续找
            for i = 1, 10, 1 do
                -- statements
            end
        end

        --类型为跳过一个 找到目标后,记录为临时目标 ,如果这一行有下一个角色则直接添加,如果没有临时的转正
    elseif( tempRole.Attacktarget==2)
    then
        if (tempRole.IsLeft) then

            tempTeam=BattleManager.RightTeam
            tempChessboard=BattleManager.ChessboardRight
        else
            tempTeam=BattleManager.LeftTeam
            tempChessboard=BattleManager.ChessboardLeft
        end
        --找同一条线的第一个敌人
        --先从棋盘找,然后用对应id找
        local FindTarget = 0 --  1是开始状态 ,2是第二次找目标,3是第三次找目标 -1为找到了
        local TempPosY = tempRolePosY
        for f = 3, 1, -1 do
            local tempIsFind = false --是否已经找到了目标 本行结束的时候如果找到了不再进行下一行 ,本行找到第一个不结束,第二个结束

            for i = 6, 1, -1 do
                --有敌人则直接加入并跳出循环,没有换行

                if tempChessboard[TempPosY][i]~=nil and tempChessboard[TempPosY][i]~=0 and tempChessboard[TempPosY][i].Remove~=true then
                    tempRole.SleRole=tempChessboard[TempPosY][i]

                    FindTarget=-1  --跳出
                    --  print(  "已找到"..TempPosY..","..i.."---------"..  tempRole.SleRole.AniName)
                    if tempIsFind then
                        break-- for i = 6, 1, -1 do
                    else
                        tempIsFind=true
                    end -- if tempIsFind
                end--  if tempChessboard[TempPosY][i]>0 then
            end-- for i = 6, 1, -1 do
            if FindTarget==-1 then
                break
            end -- if FindTarget==0

            FindTarget=FindTarget+1
            --    print("第几次寻找"..f..tempRolePosY..FindTarget.."当前行"..TempPosY)
            --三条线三种换行的方法
            if tempRolePosY==1  then
                if FindTarget==1 then
                    TempPosY=3
                else
                    TempPosY=2
                end
            elseif tempRolePosY==2 then
                if FindTarget==1 then
                    TempPosY=1
                else
                    TempPosY=3
                end
            elseif tempRolePosY==3 then
                if FindTarget==1 then
                    TempPosY=2
                else
                    TempPosY=1
                end
            end

        end--for f=3
        if FindTarget~=-1 then
            --如果没找到目标换行继续找
            for i = 1, 10, 1 do
                -- statements
            end
        end

        --类型为最后面
    elseif( tempRole.Attacktarget==3)
    then
        if (tempRole.IsLeft) then

            tempTeam=BattleManager.RightTeam
            tempChessboard=BattleManager.ChessboardRight
        else
            tempTeam=BattleManager.LeftTeam
            tempChessboard=BattleManager.ChessboardLeft
        end
        --找同一条线的第一个敌人
        --先从棋盘找,然后用对应id找
        local FindTarget = 0 --  1是开始状态 ,2是第二次找目标,3是第三次找目标 -1为找到了
        local TempPosY = tempRolePosY
        --    print(tempRole.PosX..",".. tempRolePosY)
        for f = 3, 1, -1 do
            for i = 6, 1, -1 do
                --有敌人则直接加入并跳出循环,没有换行

                if tempChessboard[TempPosY][i]~=nil and tempChessboard[TempPosY][i]~=0 and tempChessboard[TempPosY][i].Remove~=true then
                    tempRole.SleRole=tempChessboard[TempPosY][i]

                    FindTarget=-1
                    --   print(  "已找到"..TempPosY..","..i.."---------"..  tempRole.SleRole.AniName)
                    --  break-- for i = 6, 1, -1 do
                end--  if tempChessboard[TempPosY][i]>0 then
            end-- for i = 6, 1, -1 do
            if FindTarget==-1 then
                break
            end -- if FindTarget==0

            FindTarget=FindTarget+1
            --    print("第几次寻找"..f..tempRolePosY..FindTarget.."当前行"..TempPosY)
            --三条线三种换行的方法
            if tempRolePosY==1  then
                if FindTarget==1 then
                    TempPosY=3
                else
                    TempPosY=2
                end
            elseif tempRolePosY==2 then
                if FindTarget==1 then
                    TempPosY=1
                else
                    TempPosY=3
                end
            elseif tempRolePosY==3 then
                if FindTarget==1 then
                    TempPosY=2
                else
                    TempPosY=1
                end
            end

        end--for f=3
        if FindTarget~=-1 then
            --如果没找到目标换行继续找
            for i = 1, 10, 1 do
                -- statements
            end
        end

        --类型为我方下一个顺序 支援型

    elseif( tempRole.Attacktarget==4)
    then
        --如果是左侧队伍
        if (tempRole.IsLeft) then
            tempTeam=BattleManager.LeftTeam
            tempChessboard=BattleManager.ChessboardLeft
        else
            tempTeam=BattleManager.RightTeam
            tempChessboard=BattleManager.ChessboardRight
        end
        --遍历寻找下一个攻击顺位
        local tempNextRole=false
        -- print( " --遍历寻找下一个攻击顺位---------------"..tempRole.AtkOrder)
        local tempNextOrder=tempRole.AtkOrder+1
        --  print("--遍历寻找下一个攻击顺位"..tempNextOrder)
        --  print("下一个-------------|".. tempTeam[tempNextOrder].AtkOrder )
        --  排序
        local  tempLen = 0
        local tempSortArr = {}
        for key, value in pairs(tempTeam) do
            if value~=nil then
                tempLen=tempLen+1
                tempSortArr[tempLen]=value
            end

        end
        local tempExcRole=nil  --用来交换的角色
        for k = 1, tempLen-2, 1 do
            for i = 1, tempLen-1, 1 do
                if tempSortArr[i].AtkOrder> tempSortArr[i+1].AtkOrder  then
                    tempExcRole= tempSortArr[i]
                    tempSortArr[i]=tempSortArr[i+1]
                    tempSortArr[i+1]=tempExcRole
                end
            end
        end-- for k = 1


        for i = 1, tempLen, 1 do
            -- print("下一个-------------|"  .. tempSortArr[i].AtkOrder)
            --找出下一个
            if tempSortArr[i].AtkOrder>=tempNextOrder then
                if  tempSortArr[i].Remove or tempNextRole==true then
                    --移除死亡的角色
                else
                    tempRole.SleRole=tempSortArr[i]
                    -- print("已经找到的-------------|"..  tempRole.SleRole.AtkOrder)
                    tempNextRole=true
                    break
                end
            end


        end

        --寻找第一个
        if tempNextRole==false then
            for i = 1, tempLen, 1 do
                --找出下一个
                if  tempSortArr[i].Remove then

                else
                    tempRole.SleRole=tempSortArr[i]
                    tempNextRole=true
                    break
                end
            end
        end

    elseif( tempRole.Attacktarget==7)   --自身为目标
    then
        tempRole.SleRole = tempRole
    elseif( tempRole.Attacktarget==8)
    then
        --如果是左侧队伍
        if (tempRole.IsLeft) then
            tempTeam=BattleManager.RightTeam
            tempChessboard=BattleManager.ChessboardRight
        else
            tempTeam=BattleManager.LeftTeam
            tempChessboard=BattleManager.ChessboardLeft
        end
        --遍历寻找下一个攻击顺位
        local tempNextRole=false
        local tempNextOrder=tempRole.AtkOrder+1
        --  排序
        local  tempLen = 0
        local tempSortArr = {}
        for key, value in pairs(tempTeam) do
            if value~=nil then
                tempLen=tempLen+1
                tempSortArr[tempLen]=value
            end

        end
        local tempExcRole=nil  --用来交换的角色
        for k = 1, tempLen-2, 1 do
            for i = 1, tempLen-1, 1 do
                if tempSortArr[i].AtkOrder> tempSortArr[i+1].AtkOrder  then
                    tempExcRole= tempSortArr[i]
                    tempSortArr[i]=tempSortArr[i+1]
                    tempSortArr[i+1]=tempExcRole
                end
            end
        end
        for i = 1, tempLen, 1 do
            -- print("下一个-------------|"  .. tempSortArr[i].AtkOrder)
            --找出下一个
            if tempSortArr[i].AtkOrder>=tempNextOrder then
                if  tempSortArr[i].Remove or tempNextRole==true then
                    --移除死亡的角色
                else
                    tempRole.SleRole=tempSortArr[i]
                    -- print("已经找到的-------------|"..  tempRole.SleRole.AtkOrder)
                    tempNextRole=true
                    break
                end
            end
        end
        --寻找第一个
        if tempNextRole==false then
            for i = 1, tempLen, 1 do
                --找出下一个
                if  tempSortArr[i].Remove then

                else
                    tempRole.SleRole=tempSortArr[i]
                    tempNextRole=true
                    break
                end
            end
        end
    end
    -- 找到目标后,如果是范围攻击则依次添加其他目标到次要目标 Secondary 里
    if tempRole.SleRole==nil then
        return --主目标找不到返回空
    end
    tempRole.Secondary={}
    local tempfirst = true  --第一个目标是自己,不再添加
    if (tempRole.AtkRange[2] ~= nil) then
        for m, n in pairs(tempRole.AtkRange) do
            if tempfirst then
                tempfirst=false
            else --if tempfirst
                -- print(tempRole.AtkRange[m][2].."目标"..tempRole.AtkRange[m][1]..","..m)
                --在对应棋盘中查找下标
                --如果越界了也不行
                if  tempRole.SleRole.PosY-tempRole.AtkRange[m][2]>=1 and  tempRole.SleRole.PosY-tempRole.AtkRange[m][2]<=3 then
                    local tempSecondRole =  tempChessboard[ tempRole.SleRole.PosY-tempRole.AtkRange[m][2]][tempRole.SleRole.PosX-tempRole.AtkRange[m][1]]
                    --   print("...其他目标的id"..tempRoleID)
                    if tempSecondRole~=nil and tempSecondRole~=0 then
                        --id不为空则加入到次要目标表
                        --  print( "次要目标为"..tempSecondRole.AniName )
                        table.insert( tempRole.Secondary, tempSecondRole)
                    end--if tempRoleID>0
                end--如果越界了也不行
            end--if tempfirst
        end--  for m, n
    end
end  --寻找目标结束
--找到目标后对所有目标施加技能,然后开始结算队列
--所有技能结算完毕,回合结束
function BattleManager.ClearLuaData()

    print("清理战斗数据  BattleManager.ClearLuaData()")
    if CJNBattleMgr.Instance then
        CJNBattleMgr.Instance:CelarRoot()
    end
    --GameID计数
    BattleManager.GameIdCout=0
    --两边的角色
    BattleManager.LeftTeam={}
    --右边的要读服务器,暂时是单机,右边队伍写死 ,玩家操作左边队伍
    BattleManager.RightTeam={}
    BattleManager.FirstRightTeam = {}
    BattleManager.hasSecondBattle = false
    BattleManager.GameIdCount=1;  --游戏里的id ,右侧敌人的id+10000
    --创建棋盘 每个格子三个属性 ,x,y gameid  通过下标找到对应的角色,再去RightTeam中读取具体属性
    BattleManager.ChessboardLeft={ {0,0,0,0,0,0},
                                   {0,0,0,0,0,0},
                                   {0,0,0,0,0,0}
    }
    BattleManager.ChessboardRight={ {0,0,0,0,0,0},
                                    {0,0,0,0,0,0},
                                    {0,0,0,0,0,0}
    }
    --是否战斗模式 ,已经开始战斗不再显示范围预览0
    BattleManager.IsFightStart=false
    BattleManager.UI_SleRoleGameID=-1  -- 数字
    --点击开始后按照顺序依次加入
    BattleManager.LeftAtkOrder={}
    BattleManager.RightAtkOrder={}
    --{id,role引用}
    BattleManager.AllRole={}
    MgrTimer.Cancel("lianyi")
end
return BattleManager