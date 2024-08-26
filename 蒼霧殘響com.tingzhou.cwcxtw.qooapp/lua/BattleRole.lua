require("JNBattle/BattleData")
require("JNBattle/JNSkill")
require("JNBattle/JNStrTool")
require("JNBattle/JNTurnEffectMgr")  --每个回合的特效队列
require("LocalData/RangeLocalData")
require("LocalData/ActorLinesLocalData")
--通过下标计算出要找的目标
---@class BattleRole
BattleRole={}

--头像图标
BattleRole.Icon=nil
BattleRole.Remove=false  --为真时不再添加到攻击列表 表示死亡

--记录造成伤害值和受到的伤害值
BattleRole.AllNumber_Out=0
BattleRole.AllNumber_In=0   --然后是输出治疗和承受治疗
BattleRole.AllHPNumber_Out=0
BattleRole.AllHPNumber_In=0

--角色名
BattleRole.Name=""
BattleRole.IsMonster=false  --是否怪物,如果是怪物则不翻转一些特效

--动画名
BattleRole.AniName=nil

--保存位置坐标,身体中间用来中弹 , 头顶挂眩晕等
BattleRole.DownPos_X=0
BattleRole.DownPos_Y=0
BattleRole.MidPos_X=0
BattleRole.MidPos_Y=0
BattleRole.TopPos_X=0
BattleRole.TopPos_Y=0

--飞行入场数据
BattleRole.FlyIn_X=0
BattleRole.FlyIn_Y=0
BattleRole.FlyIn_Time=0
BattleRole.FlyIn_Line=1

function BattleRole.SubFlyIn(_role, _strdata)  --解析
    if _strdata==nil or _strdata=="0" then
        _role.FlyIn_X=0
        _role.FlyIn_Y=0
        _role.FlyIn_Time=0
        _role.FlyIn_Line=1
    else
        local  tempdata=JNStrTool.strSplit(",",_strdata)
        _role.FlyIn_X=tempdata[1]
        _role.FlyIn_Y=tempdata[2]
        _role.FlyIn_Time=tempdata[3]
        _role.FlyIn_Line=tempdata[4]
    end
end
function  BattleRole.SetFlyIn(_role) --给c#传值
    _role.myAni:Lua_SetFlyInData( tonumber(  _role.FlyIn_X) , tonumber(  _role.FlyIn_Y) ,tonumber(  _role.FlyIn_Time ) ,  tonumber(  _role.FlyIn_Line ) )
end

--看板立绘
BattleRole.Rolepicturespine=nil

--立绘偏移量
BattleRole.Rolepicturespine_X=0
BattleRole.Rolepicturespine_Y=0

--机甲ID1、2
BattleRole.RoleGear1ID="0"
BattleRole.RoleGear2ID="0"

--机甲唯一ID1、2
BattleRole.RoleGear1UID="0"
BattleRole.RoleGear2UID="0"

--机甲总占比1、2
BattleRole.RoleGearRate1="0"
BattleRole.RoleGearRate2="0"

--机甲副属性
BattleRole.RoleGearAddonType1="0"
BattleRole.RoleGearAddonType2="0"

--机甲等级
BattleRole.RoleGearLv1="0"
BattleRole.RoleGearLv2="0"

---相机相关

--Q版战斗动画缩放比例 --可能boss会放大
BattleRole.Qzoom=1
--起始星级
BattleRole.MinStart=1
--最大星级
BattleRole.MaxStart=6
BattleRole.Rank=1  --品阶  1N 2R
--下一级需要的经验公式tempRole
BattleRole.ExpFormula={}
--下一级需要的经验
BattleRole.Experience=1

--攻击方式 ,0 贴脸攻击  ,1 远程 2绕后
BattleRole.Attackmode=1
--是否有施法动画 0没有 ,1 有,辅助和法师会用到,2 没有拉近效果
BattleRole.Casteranimation=1
--招数名字 攻击时显示
BattleRole.AtkName=""
--一句话的角色简介
BattleRole.Attackdescription=""
--角色攻击范围贴图名
BattleRole.AttackRangeTexture = ""
--觉醒状态
BattleRole.IsAwaken=false
--觉醒公式
BattleRole.AwkenFormula={}
-- 职业 1 防御 2 攻击 3 法师 4 支援 5世界boss 不吃职业特攻
BattleRole.Occupation=1
--当前角色攻击帧 ,用于通知对方受击时间 {0.8886,0.99,1.12} 多个受击帧说明结算多次攻击循环
BattleRole.Generalattack={}
--攻击次数
BattleRole.AtkNumber=1
--普攻特效id
BattleRole.m_List_AtkEffectId = {}

--基础帧数和计算方法
BattleRole.m_Generalattack_Base = {}
BattleRole.BulleFlyTime_wait = 0
BattleRole.BulleFlyTime = 0
BattleRole.BulleFlyTime_Camera = 0

function BattleRole.Creat_Generalattack_Base()
    for i = 0,BattleRole.Generalattack.Length do
        BattleRole.m_Generalattack_Base[i] = BattleRole.Generalattack[i]
    end
end
--非多段攻击可以把伤害分多段显示
BattleRole.Show_Delay = {}
BattleRole.Show_Number = {}

-----以下配合动作,当动作播放的时候播放
BattleRole.AttackEffectId = {}
--登场动作特效
BattleRole.DebutEffectId = {}
--死亡特效
BattleRole.DeathEffectId = {}
--眩晕动作特效
BattleRole.VertigoEffectId = {}
--受击动作特效
BattleRole.HitEffectId = {}
--蓄力动作特效
BattleRole.BuildEffectId = {}
--前冲动作1
BattleRole.pd0EffectId = {}
--前冲动作2
BattleRole.pd1EffectId = {}
--后撤动作1
BattleRole.hc0EffectId = {}
--后撤动作2
BattleRole.hc1EffectId = {}
--攻击动作时长
BattleRole.Time_AtkAni = 0
--武器长度
BattleRole.Attackdistance = 0
--子弹飞行速度
BattleRole.Bulletvelocity = 0
--震动
BattleRole.Shake_Delay = {}
BattleRole.Shake_Dur = {}   --震动时间
BattleRole.Shake_Stg = {}   --震动次数
BattleRole.Shake_Random = {}    --随机幅度
BattleRole.Shake_X = {}     --取值范围
BattleRole.Shake_Y = {}
BattleRole.Shake_Z = {}
--0表示【前冲动作>待机动作>攻击动作】
--1表示【前冲动作>攻击动作】
--前冲
BattleRole.ForwardType = 0
--后撤
BattleRole.BackType = 0
--进攻时间参数
BattleRole.TimeNext = 1
--Q版头像
BattleRole.Icon_q=""
--保存c#脚本引用
BattleRole.myAni=nil
--攻击前动作名
BattleRole.NameBefor = 0
--攻击后的动作名
BattleRole.NameAfter = 0
--是左侧还是右侧队伍
BattleRole.IsLeft = true
--当前选中的目标     都是BattleRole
BattleRole.SleRole = nil
--次要目标们
BattleRole.Secondary = {}
--保存当前元素坐标
BattleRole.PosX = 0
BattleRole.PosY = 0
--保存当前元素在攻击队列里的坐标
BattleRole.IndexOrderRank = 1
--当前元素攻击顺序
BattleRole.AtkOrder = 1
--当前元素整体攻击顺序
BattleRole.AllAtkOrder = 1
--当前在第几段
BattleRole.AtkOrderParagraph = 1
--用于排序 ,每次使用先清0
BattleRole.Weight = 0
--正在充能  如果为假,下次直接攻击
BattleRole.IsCharge = true
--是否被禁止攻击 用于跳过回合中的寻敌攻击阶段
BattleRole.IsCannotAtk = false
BattleRole.ThisTurnCrit = false   --本回合是否暴击 回合开始时计算
BattleRole.ThisTurnDoge = false   --是否闪避
BattleRole.ThisTurnPlunder = 0

--是否被强控制
BattleRole.Vertigo = false

--初始分数
BattleRole.BossPoint_initial = 0
--当前分数
BattleRole.BossPoint_Now = 0

function BattleRole.CreartData(_role)  --创建C#角色数据 用于计算
    CreatRoleData.CreatLeft(_role.IsMonster,_role.Icon ,_role.Name   ,_role.Rolepicturespine ,_role.Rolepicturespine_X ,
            _role.Rolepicturespine_Y ,1 ,_role.Qzoom ,_role.MinStart ,_role.Rank ,
            _role.Attackmode ,_role.Casteranimation ,_role.AtkName ,_role.Attackdescription ,_role._role ,
            _role.Occupation ,_role.AtkNumber, _role.myAni)
    local str=  tostring( _role.ReadyEffectId_str )
    if str==nil then
        str="0"
    end
    CreatRoleData.SetGeneralattack(_role.Generalattack ,_role.AtkEffectId_str ,_role.DebutEffectId_str ,_role.DeathEffectId_str,_role.VertigoEffectId_str,_role.HitEffectId_str ,str,
    _role.PD0EffectId_str, _role.PD1EffectId_str, _role.HC1EffectId_str, _role.HC2EffectId_str)
    CreatRoleData.SetForwardType( _role.ForwardType, _role.BackType,_role.TimeNext,_role.Icon_q,_role.NameBefor,
            _role.NameAfter,  _role.IsLeft,  _role.PosX,  _role.PosY,
            _role.IndexOrderRank,  _role.ID,  _role.GameID,  _role.LV,  _role.StartLV,
            _role.ShowSkillLV,_role.SkinID == nil and tonumber(_role.ID) or _role.SkinID)
    local m_AtkRange={}
    local m_AtkRange_2={}
    if _role.AtkRange[1]==nil then
        m_AtkRange=nil
        m_AtkRange_2=nil
    else
        for index, value in pairs( _role.AtkRange) do

            m_AtkRange[index]=tonumber (value[1])
            m_AtkRange_2[index]=tonumber(value[2])
        end
    end
    local _bosspoint=_role.BossPoint --世界boss初始分
    if _bosspoint==nil then
        _bosspoint=0
    end
    CreatRoleData.SetAbt( _role.RealDef ,  _role.HP ,  _role.RealAtk ,  _role.RealAgile ,  _role.RealCrit ,
            _role.RealCritDmg ,  _role.RealSuppart ,  _role.Attacktarget ,  m_AtkRange ,  m_AtkRange_2 ,
            _role.HPmax ,_bosspoint)
    CreatRoleData.SetWpen(_role.Attackdistance,_role.Bulletvelocity, _role.Shake,_role.Show_Delay,_role.Show_Number)
    --创建ex技能立绘位置属性
    --[[local m_EXpos_x=0
    --local m_EXpos_y=0
    --local m_EXpos_Size=0
    --local m_EXpos_rx=0
    --local m_EXpos_ry=0
    --local m_EXpos_rz=0
    --if _role.EXpos_x~=nil then
    --    m_EXpos_x=_role.EXpos_x
    --end
    --if _role.EXpos_y~=nil then
    --    m_EXpos_y=_role.EXpos_y
    --end
    --if _role.EXpos_Size~=nil then
    --    m_EXpos_Size=_role.EXpos_Size
    --end
    --if _role.EXpos_rx~=nil then
    --    m_EXpos_rx=_role.EXpos_rx
    --end
    --if _role.EXpos_ry~=nil then
    --    m_EXpos_ry=_role.EXpos_ry
    --end
    --if _role.EXpos_rz~=nil then
    --    m_EXpos_rz=_role.EXpos_rz
    --end]]
    local ffid=0
    if _role.fettersid==nil then
    else
        ffid= _role.fettersid
    end
    --创建技能
    for key_1, value_1 in pairs(_role.Skills) do
        CreatRoleData.CCreatSkill( value_1.IsLock ,  value_1.AtkRoleId , value_1.AtkRoleIsleft , value_1.HitRoleId , value_1.HitRoleIsleft ,
                value_1.ExistTime , value_1.RealLV , value_1.IsSLv , value_1.Id , value_1.RelationSkill ,
                value_1.ShowEffects_str , value_1.Explain , value_1.CdRound , value_1.CdRound_cout , value_1.Exskill ,
                value_1.Awaken , value_1.Skilltype1 , value_1.Skilltype2  , value_1.Name ,
                value_1.Icon , value_1.Opportunity , value_1.Object , value_1.Time , value_1.Exception ,
                value_1.Trgger_condition_str  ,value_1.Subtitle ,value_1.Action ,value_1.Delay_str, value_1.BeHitTrans_str)
        --  创建技能效果 分类  Effects
        for key, value in pairs(value_1.Effects) do

            CreatRoleData.CreatSkillEffect(value.Trgger_condition_str   ,value.EffectObj ,
                    value.EffectType  ,value.TrunTimes  ,value.MaxTimes  )
            for key_fml, value_fml in pairs(value.EffectExactFml) do
                CreatRoleData.CreatSkillEffect_AddFml(value_fml)
            end
        end
    end
    for key_1, value_1 in pairs(_role.Skills_fw) do
        CreatRoleData.CCreatSkill( value_1.IsLock ,  value_1.AtkRoleId , value_1.AtkRoleIsleft , value_1.HitRoleId , value_1.HitRoleIsleft ,
                value_1.ExistTime , value_1.RealLV , value_1.IsSLv , value_1.Id , value_1.RelationSkill ,
                value_1.ShowEffects_str , value_1.Explain , value_1.CdRound , value_1.CdRound_cout , value_1.Exskill ,
                value_1.Awaken , value_1.Skilltype1 , value_1.Skilltype2  , value_1.Name ,
                value_1.Icon , value_1.Opportunity , value_1.Object , value_1.Time , value_1.Exception ,
                value_1.Trgger_condition_str  ,value_1.Subtitle ,value_1.Action ,value_1.Delay_str, value_1.BeHitTrans_str)
        --  创建技能效果 分类  Effects
        for key, value in pairs(value_1.Effects) do
            CreatRoleData.CreatSkillEffect(value.Trgger_condition_str   ,value.EffectObj ,
                    value.EffectType  ,value.TrunTimes  ,value.MaxTimes  )
            for key_fml, value_fml in pairs(value.EffectExactFml) do
                CreatRoleData.CreatSkillEffect_AddFml(value_fml)
            end
        end
    end
    CreatRoleData.Classification()
end

function BattleRole.SetGeneralattack(str, tempRole)
    tempRole.Generalattack={}
    local tempStArr=  JNStrTool.strSplit( "," ,str)
    tempRole.AtkNumber=0
    for k, v in pairs(tempStArr) do
        tempRole.AtkNumber=tempRole.AtkNumber+1
        table.insert(tempRole.Generalattack, tonumber(tempStArr[k])/30 )
    end
    -- print(  tempRole.AtkNumber.."g攻击次数"..tempRole.Generalattack[tempRole.AtkNumber])
end



--属性
BattleRole.ID=0  --表里的id
BattleRole.SkinID=nil --皮肤ID
BattleRole.GameID=0  --游戏里的id 因为同一个ID可以生成多个角色,两方队伍也是存这个gameid用来寻找目标
BattleRole.LvMax=100 --最大等级
BattleRole.LV=0  --等级
BattleRole.EXP=0  --当前经验
BattleRole.StartLV=1 --星级
BattleRole.SkillLV=1 --
BattleRole.SkillMaxLV=1 --技能最大等级
BattleRole.SkillLVReality=1  --实际上的技能等级 一个技能可以+9+15但是技能仅仅强化几次
BattleRole.SkillChangeRange={}  ---技能攻击范围改变的等级
BattleRole.SkillTreeName=""     ---技能树名,用于驾驶员技能升级页

BattleRole.HP=100 --当前血量
BattleRole.ShowSkillLV = 1  ---客户端展示等级

BattleRole.Resurrectioned = false   ---本回合复活不受伤害
BattleRole.ExplodeDebuff = false    ---本回合引爆Debuff伤害

--function BattleRole.SetClock_Def( _role, IsLock, _number)
--    _role.Clock_Def_N = _number * 10000;
--    _role.Clock_Def = IsLock;
--    BattleRole.SetDef(_role, _role.Clock_Def_N);
--end
--
--function BattleRole.SetDef(_role,_number)
--    if _role.Clock_Def then
--        _role.RealDef = _role.Clock_Def_N / 10000
--    else
--        _role.RealDef = (_role.Def + _number) / 10000
--        if _role.RealDef > CBattleData.m_MaxDef then
--            _role.RealDef = CBattleData.m_MaxDef
--        elseif _role.RealDef < CBattleData.m_MinDef then
--            _role.RealDef = CBattleData.m_MinDef
--        end
--    end
--end
--function BattleRole.AddDef(_role ,_number)
--    _role.BuffDef= _role.BuffDef + _number * 10000
--    BattleRole.SetDef(_role, _role.BuffAtk)
--end
--血上限公式
BattleRole.HPmaxFormula={}
BattleRole.HPmax=100 --血上限

function BattleRole.SetHPmax(_role,_number)
    _role.HPmax = _number
end

BattleRole.m_BaseHPmax = 100 --基础生命值最大值
BattleRole.m_BuffHPmax = 10000 --buff累加


--[[
function BattleRole.SetHPmax(_role,_number,IsAdd)   --移除时触发的不会加血

    local IntN = _number * 10000
    _role.m_BuffHPmax = _role.m_BuffHPmax + IntN
    --先看是增加还是减少
    if IsAdd then
        local realBuffHPmax = _role.m_BuffHPmax
        if (realBuffHPmax < CBattleData.m_MinSkillHPMax) then
            realBuffHPmax = CBattleData.m_MinSkillHPMax
        end
        _role.m_HPmax = _role.m_BaseHPmax * (realBuffHPmax / 10000)
        --_role.HP += IntN;
    else

        local realBuffHPmax = _role.m_BuffHPmax;
        if (realBuffHPmax < CBattleData.m_MinSkillHPMax) then
            realBuffHPmax = CBattleData.m_MinSkillHPMax;
        end
        _role.m_HPmax = _role.m_BaseHPmax * (realBuffHPmax / 10000)
    end
    if (_role.HP > _role.m_HPmax) then
        _role.HP = _role.m_HPmax
    end
end]]

--攻击力支援力初始化公式
BattleRole.AtkFormula={}

--护盾值 掉血的时候先扣护盾
BattleRole.Shield_Value=0

function BattleRole.AddShield(_role,_number)
    _role.Shield_Value = _number
end

BattleRole.RealAtk=10  --实际攻击力  RealAtk=Atk*(1+BuffAtk)
BattleRole.Atk=10 --攻击力
BattleRole.BuffAtk=0 --buff加减的属性 倍率  最低-0.8 ,最高 2
BattleRole.PermanentAtk=0  --永久buff加的属性
function BattleRole.SetAtk(_role,_number)
    _role.RealAtk = _number
end


--function BattleRole.SetAtk(_role,_number)
--    _number = 10000 + _number
--    if _number > BattleData.MaxAtkUp then
--        _number = BattleData.MaxAtkUp
--    elseif _number < BattleData.MinAtkUp then
--        _number = BattleData.MinAtkUp
--    end
--    _role.RealAtk = _role.Atk * _number / 10000
--end
--function BattleRole.AddAtk(_role ,_number)
--    _number = _number * 10000
--    _role.BuffAtk= _role.BuffAtk + _number
--    BattleRole.SetAtk(_role, _role.BuffAtk)
--end

BattleRole.RealSuppart=0
BattleRole.Suppart=0  --支援力
BattleRole.BuffSuppart=0
BattleRole.PermanentSuppart=0  --永久buff

--function BattleRole.SetSuppart(_role,_number)
--    _number = _role.Suppart + _number
--    if _number < 0 then
--        _number = 0
--    end
--    _role.RealSuppart = _number / 10000
--end
--function BattleRole.AddSuppart(_role ,_number)
--    _number = _number * 10000
--    _role.BuffSuppart = _role.BuffSuppart + _number
--    BattleRole.SetSuppart(_role, _role.BuffAtk)
--end

BattleRole.RealDef=0.5
BattleRole.Def=0.5 --防御力  在创建时赋值
BattleRole.BuffDef=0  --各种Buff
BattleRole.SkillDef=0  --技能减伤 乘算,护甲是加算
BattleRole.SkillDeDef=0    --伤害加深,暂时么有
BattleRole.Clock_Def = false
BattleRole.Clock_Def_N = 0  --万分比

function BattleRole.SetDef(_role,_number)
    _role.RealDef=_number
end

BattleRole.RealAgile=0
BattleRole.Agile=0   --敏捷 闪避率和闪避伤害
BattleRole.BuffAgile=0
BattleRole.PermanentAgile=0
function BattleRole.SetAgile(_role,_number)
    _role.RealAgile = _number
end



BattleRole.RealCrit=0

function BattleRole.SetCrit(_role,_number)
    _role.RealCrit = _number / 10000
end

function BattleRole.SetSCrit(_role,_number,favorData)
    local tFavorCrit = 0
    if favorData then
        tFavorCrit = favorData.crit
    end
    _role.RealCrit = (_number + tFavorCrit)/10000
end
--BattleRole.Crit=0   --暴击
--BattleRole.BuffCrit=0
--BattleRole.PermanentCrit=0
--function BattleRole.SetCrit(_role,_number)
--    _role.RealCrit= _role.Crit+ _number / 10000
--    -- print( _role.RealCrit)
--    -- print( BattleData.MaxCrit.."||"..BattleData.MinCrit)
--    if  _role.RealCrit>BattleData.MaxCrit then
--        _role.RealCrit=BattleData.MaxCrit
--    elseif _role.RealCrit<BattleData.MinCrit then
--        _role.RealCrit=BattleData.MinCrit
--    end
--    -- print( _role.RealCrit)
--end
--function  BattleRole.AddCrit(_role ,_number)
--    -- print(_role.Name.."添加暴击率".._number)
--    _role.BuffCrit= (_role.BuffCrit +_number) * 10000
--    --实际暴击率不能超过100
--    BattleRole.SetCrit(_role, _role.BuffCrit)
--end

BattleRole.RealCritDmg=0
BattleRole.CritDmg=0  --暴击伤害
BattleRole.BuffCritDmg=0
BattleRole.PermanentCritDmg=0
function BattleRole.SetCritDMG(_role,_number)
    _role.RealCritDmg = _number /10000
end
function BattleRole.SetSCritDMG(_role,_number,favorData)
    local tFavorCritDmg = 0
    if favorData then
        tFavorCritDmg = favorData.criticaldamage
    end
    _role.RealCritDmg = (_number + tFavorCritDmg)/10000
end
--function BattleRole.SetCritDMG(_role,_number)
--    _role.RealCritDmg = _role.CritDmg + _number / 10000
--    if _role.RealCritDmg < BattleData.MinCritDMG then
--        _role.RealCritDmg = BattleData.MinCritDMG
--    end
--end
--function  BattleRole.AddCritDMG(_role ,_number)
--    _role.BuffCritDmg = (_role.BuffCritDmg + _number) * 10000
--    BattleRole.SetCritDMG(_role, _role.BuffCritDmg)
--
--end

--添加Buff(角色,buff id,图片名,回合数,Buff名)
function BattleRole.AddBuff(_role,id,_picName,_Truns,_BuffName)
    return _role.myAni:AddBuff(id,_picName,_Truns,_BuffName)
end
--移除Buff
function BattleRole.RemoveBuff(_role,id,_Truns)
    _role.myAni:RemoveBuff(id,_Truns)
end

function BattleRole.Resurrection(_role,_number)
    _role.myAni:Resurrection(_number)
end

function BattleRole.ThisDead(_role,_number)
    _role.myAni:ThisDead(_number)
end

BattleRole.LastAtkDMG=0   --最近一次普攻造成的伤害
BattleRole.LastBeHit=0
--攻击范围

--选择的方式
BattleRole.Attacktarget=1   --目标类型：1.最前面2.跳过3.最后面4.我方下一个顺序5.随机
--若攻击范围内同时存在多名敌方，则按照【当前攻击目标】>【由前到后、由上到下】
--当同一行没有敌人的时候 上打中  中打下 下打上
BattleRole.AtkTargetTips = ""   --攻击目标描述

--范围表 二维 每一个元素都是 {技能等级 , {0,0},{0,1}} 匹配等级之后 把坐标2的元素{0,0}忽略 ,从3开始赋值给AtkRange
BattleRole.AtkRangeArr={}
--范围 元素为(x,y)的表,不包括原点 0,0 ,没有值说明仅选中一个目标
BattleRole.AtkRange={}

--先解析成技能1234 然后组合成skills ,然后按照技能触发时间分类
BattleRole.Skill_1Fml={}
BattleRole.Skill_2Fml={}
BattleRole.Skill_3Fml={}
BattleRole.Skill_4Fml={}
BattleRole.Skill_5Fml={}

-- {{id,realLv,是否强化等级 } ,{id,realLv ,是否强化等级}  }
BattleRole.Skill_1={}
BattleRole.Skill_2={}
BattleRole.Skill_3={}
BattleRole.Skill_4={}
BattleRole.Skill_5={}

--保存一份引用,按照技能栏分类
BattleRole.Skill_1_example = {}
BattleRole.Skill_2_example = {}
BattleRole.Skill_3_example = {}
BattleRole.Skill_4_example = {}
BattleRole.Skill_5_example = {}  --ex栏
BattleRole.Skills_fw = {} --符文技能,不显示在角色身上
--技能表 存贮自身永远的所有技能,即时是需要赋予给别人的技能
BattleRole.Skills = {}
--献身交换角色Id
BattleRole.XianShenSwitchId = {}
--身上的Buff列表
BattleRole.TabBuffSkill={}
--外部调用创建新角色
function BattleRole:new()
    o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

BattleRole.isCharge = false

function BattleRole.Xulilens(tempRole)
    if tempRole.Vertigo then
        tempRole.myAni.Have_AtkMove = false
        return true
    elseif (tempRole.Occupation ~= 3) then  --不是蓄力型
        return false
    else
        --是不是在蓄力
        if tempRole.isCharge then
            if (CJNBattleLoop.OnlyFightData) then
            else
                tempRole:SetIsChargedFalse(true);
            end
            return true;
        else
            if CJNBattleLoop.OnlyFightData then
            else
                tempRole.myAni:EndStroke();
                tempRole:SetIsChargedTrue();
            end
            return false;
        end
    end
end


--立刻完成蓄力
function BattleRole:SetChargedOver(tempRole)
    BattleRole.SetIsChargedFalse(tempRole,false)
end
--解除蓄力状态
function BattleRole:SetChargedRelieve(tempRole)
    BattleRole.SetIsChargedTrue(tempRole)
end
--蓄力结束
function BattleRole:SetIsChargedFalse(tempRole,ischarged)
    tempRole.IsCharge = false
    tempRole.myAni:InXL(ischarged)
end
--蓄力开始
function BattleRole:SetIsChargedTrue(tempRole)
    tempRole.IsCharge = true
    tempRole.myAni:OutXL()
end
--被攻击
function BattleRole:BeHit(tempRole,isCrit,_canShield,_Dmg,atkNumberType)
    tempRole.myAni:BeHit(isCrit,_canShield,atkNumberType)
end

--动画等表现
--生成实体并加载动画
function BattleRole:RoleAniLoad(tempRole,delay,func)
    --需要得到物体身上的CAnimation实例
    if not func then
        CAnimation.CCreatGo(tempRole.GameID,tempRole.AniName,tempRole.PosX,tempRole.PosY,tempRole.IsLeft,0,tempRole.HP,tempRole.Qzoom,(tempRole.SkinID == nil and tempRole.ID or tempRole.SkinID),tempRole.HPmax, function(myAni)
            tempRole.myAni = myAni
            --解析入场声音
            if tempRole.Str_Audio~=nil and tempRole.Str_Audio~="0" then
                for key, value in pairs(ActorLinesLocalData.tab) do
                    if value[2] == tempRole.Str_Audio and  value[3] == "16" then
                        tempRole.myAni.Audio_Dc=value[13]
                        break
                    end
                end
            end
            BattleRole.SetFlyIn(tempRole)
            BattleRole.CreatEffFollowAni(tempRole)
        end)
    else
        CAnimation.CCreatGo(tempRole.GameID,tempRole.AniName,tempRole.PosX,tempRole.PosY,tempRole.IsLeft,0,tempRole.HP,tempRole.Qzoom,(tempRole.SkinID == nil and tempRole.ID or tempRole.SkinID),tempRole.HPmax, func)
    end
end

function BattleRole.CreatEffFollowAni(tempRole , _NotInSound ,_delay)
    if _delay==nil then
        _delay=0
    end
    --创建所有特效
    for key, value in pairs(tempRole.DebutEffectId) do
        local tempTab=tempRole.DebutEffectId[key]
        JNTurnEffectMgr.CreatEffTo_Action( 0,false,tempRole.GameID,tempRole.GameID,true ,tempTab,1,0,1 ,_NotInSound )
    end
end

--播放动画 1待机 2 攻击 3 受击 4死亡
function BattleRole:LuaPlayAni(AniId,tempRole)
    tempRole.myAni:PlayAni(AniId)
end
--基础属性生成
--经验
--1 得到公式
function BattleRole.StSExp(Str ,tempRole)
   --print(Str)
    --1 解析出公式
    tempRole.ExpFormula= JNStrTool.StrToScript(Str)
  
    --2 调用计算函数
    BattleRole.SubExp(tempRole)
end
--2 计算公式
function BattleRole.SubExp(tempRole)
    -- 等级上限不计算
    if tempRole.LvMax==tempRole.LV then
        tempRole.Experience=0
        return 0
    else

      --  print(BattleRole.SubFormula(tempRole.ExpFormula,tempRole))
        local f = load(BattleRole.SubFormula(tempRole.ExpFormula,tempRole))()
        tempRole.Experience= f
        tempRole.Experience= math.floor(tempRole.Experience)
       
    end
end
--返回经验值
function BattleRole.ReturnExp(_TempRole,_lv)

    local f = load( BattleRole.SubFormula_2(_TempRole.ExpFormula,_TempRole,_lv))()

    local  returnExp  =f
    returnExp=math.floor(returnExp)
    return  returnExp
end
--血量
--1 得到公式
function BattleRole.StSHP(Str ,tempRole,isExact,favorData)
    if isExact == nil or isExact == false then
        --   print( "血量--------"..Str)
        --1 解析出公式
        tempRole.HPmaxFormula=  JNStrTool.StrToScript(Str)
        --2 调用计算函数
        BattleRole.SubHP(tempRole,favorData)
    else
        --1 解析出公式
        tempRole.HPmaxFormula=  JNStrTool.StrToScript(Str)
        --2 调用计算函数
        BattleRole.SubHP2(tempRole,favorData)
    end
end
--2
function BattleRole.SubHP(tempRole,favorData)
    local tempHpstr = BattleRole.SubFormula(tempRole.HPmaxFormula,tempRole)
    local tFavorHp = 0
    if favorData then
        tFavorHp = favorData.hp
    end
    -- print(tempHpstr)
    -- local t = load( BattleRole.SubFormula(tempRole.HPmaxFormula,tempRole))
    local f = load(tempHpstr)()

    tempRole.HPmax=math.floor(f/10000) + tFavorHp
    tempRole.HP=tempRole.HPmax
    --    print("血量"..tempRole.HP ..tempRole.HPmax )
end
--3
function BattleRole.SubHP2(tempRole,favorData)
    local tempHpstr = BattleRole.SubFormula(tempRole.HPmaxFormula,tempRole)
    local tFavorHp = 0
    if favorData then
        tFavorHp = favorData.hp
    end
    -- print(tempHpstr)
    -- local t = load( BattleRole.SubFormula(tempRole.HPmaxFormula,tempRole))
    local f = load(tempHpstr)() + tFavorHp

    tempRole.HPmax = tonumber(string.format("%.1f", f/10000))
    tempRole.HP=tempRole.HPmax
    --    print("血量"..tempRole.HP ..tempRole.HPmax )
end
--攻击力或支援力
function BattleRole.StSAtk(Str ,tempRole,favorData)
    --1 解析出公式
    tempRole.AtkFormula=  JNStrTool.StrToScript(Str)
    --2 调用计算函数
    BattleRole.SubAtk(tempRole,favorData)
end
function BattleRole.SubAtk(tempRole,favorData)
    local f = load(BattleRole.SubFormula(tempRole.AtkFormula,tempRole))()
    if tempRole.Occupation==4 then
        local tFavorSupport = 0
        if favorData then
            tFavorSupport = favorData.support
        end
        f = f + tFavorSupport
        tempRole.Suppart=f/10000
        tempRole.RealSuppart=tempRole.Suppart
    else
        local tFavorAtk = 0
        if favorData then
            tFavorAtk = favorData.atk
        end
        tempRole.Atk=f/10000
        tempRole.RealAtk = tempRole.Atk + tFavorAtk
        --  print("攻击力".. tempRole.Atk)
    end

end
--防御力
function BattleRole.StSDef( Str,tempRole,favorData)
    local tFavorDef = 0
    if favorData then
        tFavorDef = favorData.defense
    end
    tempRole.Def=(tonumber(Str)+tFavorDef)/10000
    tempRole.RealDef = tempRole.Def
end
--闪避
function BattleRole.StSAgile( Str,tempRole,favorData)
    local tFavorAgile = 0
    if favorData then
        tFavorAgile = favorData.dodge
    end
    tempRole.Agile=(tonumber(Str)+tFavorAgile)/10000
    tempRole.RealAgile= tempRole.Agile
end

--攻击范围
function BattleRole.StSAtkRange(Str ,tempRole)
    --   print("====================攻击范围计算====================")
    --1 解析为表
    --先用;
    --print(  tempRole.AniName ..Str)
    tempRole.SkillChangeRange = {}
    local TempStrRangeLv= JNStrTool.strSplit( ";" ,Str)
    local lvToRangeTab={}
    for key, value in pairs(TempStrRangeLv) do
        -- statements
        local tempDataTab=JNStrTool.strSplit( "," ,value)
        lvToRangeTab[tempDataTab[1]]=tempDataTab[2]

        tempRole.SkillChangeRange[tonumber(tempDataTab[1])] = tempDataTab[2]
    end
    local _CurHighestLv=0 --当前用于匹配的最高等级
    -- print("当前阅览等级为"..tempRole.SkillLV)
    for key, value in pairs(lvToRangeTab) do
        -- statements
        -- print("当前阅览等级为"..tempRole.SkillLV.."对比Key"..key)
        if tonumber(tempRole.ShowSkillLV) >= tonumber(key) then
            -- 只会被更高等级的信息覆盖
            if tonumber(key) >= _CurHighestLv then
                -- statements
                -- print("tempRole.SkillLV"..tempRole.SkillLV.."当前最高等级为_CurHighestLv".._CurHighestLv.."即将要覆盖更高等级"..key.."value"..value)
                _CurHighestLv = tonumber(key)

                for i, n in pairs(RangeLocalData.tab) do
                    -- statements
                    if n[2] == value then
                        -- statements
                        tempRole.AttackRangeTexture=n[3]
                        break
                    end
                end
            end
        end
    end
    local StrArr=JNStrTool.StrArrArr(";",Str,{"[" , "]" , ":" ,"," ,"@"})
    local tempArr={}   --{{ {lv8,0},{1,1} } ,}
    local tempArrindex=1
    tempRole.AtkRange={}
    local temptabRange = {}

    tempRole.AtkRangeArr={} --所有等级的攻击范围
    local  tempIndex = 1
    local  CantAdd =false

    for k,v in pairs(StrArr)  do
        tempArr[k]={}
        temptabRange={}
        --然后添加
        for o,p in pairs(StrArr[k])  do
            local temp = o%2

            if o==1 then
                temp=1
                tempArr[k][o]={StrArr[k][o] , 0}
                StrArr[k][o]={StrArr[k][o] , 0}
                --    print( StrArr[k][o][1].."下标为"..k..o )
                --当前等级大于等于 StrArr[k][o][1] 新建范围表
                tempIndex=tonumber(StrArr[k][o][1])
                --  print(  k..tempRole.SkillLV.."技能等级-------范围"..tonumber(StrArr[k][o][1]) )
                if(tonumber( tempRole.ShowSkillLV ) >= tonumber(StrArr[k][o][1]) ) then
                    --如果小于技能等级,不能添加
                    --  CantAdd=true
                end
            end
            if temp==0 then
                tempArr[k][o]={StrArr[k][o] , StrArr[k][o+1] }
                StrArr[k][o]={StrArr[k][o] , StrArr[k][o+1] }
                table.insert(tempRole.AtkRange,{StrArr[k][o][1],StrArr[k][o][2]}) --添加到实际范围表
                table.insert(temptabRange,{StrArr[k][o][1],StrArr[k][o][2]})
                --  print( StrArr[k][o][1].."下标为"..k..o.."第二个元素".. StrArr[k][o][2])
                tempArr[k][tempArrindex]={StrArr[k][o][1] , StrArr[k][o][2] }
                tempArrindex=tempArrindex+1
            end
        end-- for op
        tempRole.AtkRangeArr[tempIndex]=  temptabRange
    end

    for key, value in pairs( tempRole.AtkRangeArr) do
        if key<tempRole.ShowSkillLV then
            tempRole.AtkRange=value
        elseif key==tempRole.ShowSkillLV then
            tempRole.AtkRangeIsNew=true  -- print("------------范围测试 tempRole.AtkRangeIsNew=true")
            tempRole.AtkRange=value
        end
    end

    -- for q,w in pairs(   tempRole.AtkRangeArr)  do
    --    for e,r in pairs(   tempRole.AtkRangeArr[q])  do
    --      print( q ..","..e..";"..tempRole.AtkRangeArr[q][e][1]..","..tempRole.AtkRangeArr[q][e][2])
    --    end
    -- end

end

--4个技能 {skillid ,skilllvreal 实际等级 ,skilltrun 持续回合数 -1表示无限持续, ,opportunity 发动时间点 攻击前后}
--按照时间点加入 回合结束的时候遍历所有技能 ,持续回合数减1
--解析出9个等级 ,根据当前技能等级使用
function BattleRole.StSSkillLvReal(Str1,Str2,Str3,Str4,Str5,tempRole)
    --先用;切割 ,判断当前技能在哪个区间 ,
    tempRole.Skill_1_IsSLv=false
    tempRole.Skill_2_IsSLv=false
    tempRole.Skill_3_IsSLv=false
    tempRole.Skill_4_IsSLv=false
    tempRole.Skill_5_IsSLv=false
    local realStr1=BattleRole.RealSkillStr(Str1, tempRole.ShowSkillLV,tempRole,1)
    local realStr2=BattleRole.RealSkillStr(Str2, tempRole.ShowSkillLV,tempRole,2)
    local realStr3=BattleRole.RealSkillStr(Str3, tempRole.ShowSkillLV,tempRole,3)
    local realStr4=BattleRole.RealSkillStr(Str4, tempRole.ShowSkillLV,tempRole,4)
    local realStr5=BattleRole.RealSkillStr(Str5, tempRole.ShowSkillLV,tempRole,5)

    -- 用 ; { }  , 切割
    tempRole.Skill_1Fml=JNStrTool.StrArrArr("@",realStr1,{"{" , "}" , "," })
    tempRole.Skill_2Fml=JNStrTool.StrArrArr("@",realStr2,{"{" , "}" , "," })
    tempRole.Skill_3Fml=JNStrTool.StrArrArr("@",realStr3,{"{" , "}" , "," })
    tempRole.Skill_4Fml=JNStrTool.StrArrArr("@",realStr4,{"{" , "}" , "," })
    tempRole.Skill_5Fml=JNStrTool.StrArrArr("@",realStr5,{"{" , "}" , "," })
    BattleRole.SubSkillLvReal1(tempRole)
end
function BattleRole.RealSkillStr(_Str,_SkillLv,_tempRole,_index)
    if _Str=="0" then
        return "0"
    end
    --  print("_index".._index)
    local _IsSlv = false
    local tempArr =JNStrTool.strSplit(";",_Str )
    local  tempChar=nil
    local realStr1=""
    --判断使用哪一个  只有第一个才解锁
    local tempIsfist=true
    for key, value in pairs(tempArr) do
        tempChar=  string.sub(tempArr[key] ,8,8)  --20404{0,6,7} 第七个字符是解锁等级  判断第八个是不是逗号,不是也加入
        local  tempChar_2=  string.sub(tempArr[key] ,9,9)
        -- print(tempChar.."技能id" ..tempArr[key] )
        if tempChar_2=="," or tempChar_2=="}"  then
            -- print(tempChar_2.."|||1")
        else
            -- print(tempChar_2.."|||2")
            tempChar=tempChar..tempChar_2
            -- print(tempChar.."|||2")
        end
        tempChar=tonumber(tempChar)
        -- 解锁 判定
        --  print(" --判断使用哪一个-----------|".._SkillLv.."||"..tempChar)
        if _SkillLv==tempChar then
            if tempIsfist then
                if _index==1 then
                    _tempRole.Skill_1_IsSLv=true
                elseif _index==2 then
                    _tempRole.Skill_2_IsSLv=true
                elseif _index==3 then
                    _tempRole.Skill_3_IsSLv=true
                elseif _index==4 then
                    _tempRole.Skill_4_IsSLv=true
                elseif _index==5 then
                    _tempRole.Skill_5_IsSLv=true
                end
            end
            realStr1=tempArr[key]
            -- print("跳出1")
            break
        elseif tempChar> _SkillLv  then
            --技能需求等级大于实际等级停止
            -- print("跳出2")
            break
        end
        tempIsfist=false
        --否则加入到自己等级
        realStr1=tempArr[key]
    end
    if realStr1==nil or realStr1=="" then
        realStr1="0"
    end
    return realStr1
end
--分两步解析技能id
function BattleRole.SubSkillLvReal1(tempRole)
    tempRole.Skill_1=BattleRole.SubSkillLvReal2(tempRole.Skill_1Fml,tempRole.ShowSkillLV)
    tempRole.Skill_2=BattleRole.SubSkillLvReal2(tempRole.Skill_2Fml,tempRole.ShowSkillLV)
    tempRole.Skill_3=BattleRole.SubSkillLvReal2(tempRole.Skill_3Fml,tempRole.ShowSkillLV)
    tempRole.Skill_4=BattleRole.SubSkillLvReal2(tempRole.Skill_4Fml,tempRole.ShowSkillLV)
    tempRole.Skill_5=BattleRole.SubSkillLvReal2(tempRole.Skill_5Fml,tempRole.ShowSkillLV)
    BattleRole.CreatAllSkill( tempRole)
end

--传入二维数组{{id,lv1,lv2,lv3}{id,lv1,lv2} } ,返回技能{ {id,realLv },{id,realLv },{id,realLv } }的二维数组
function BattleRole.SubSkillLvReal2(StrArr,SkillLV)
    if StrArr[1][2]==nil  then
        return {{0,0,false}}
    end

    SkillLV= tonumber(SkillLV)
    local tempArrArr = {}
    local tempArr = {}  --只有两个元素 id和lv  新增一个参数 是否强化等级

    local tempIsSLv = false


    for k,v in pairs(StrArr)  do
        local tempLv = 0
        tempArr={}
        tempIsSLv=false
        for o,p in pairs(StrArr[k])  do
            --如果是第一个元素则记为技能id 然后判断当前技能强化等级 决定技能的真实等级
            -- print(StrArr[k][o])
            if o==1 then
                table.insert(tempArr, StrArr[k][o])--1
                -- print("StrArr[k][o]"..StrArr[k][o])
            else
                --不是第一个元素判断当前技能强化等级,每超过一个
                local tempN = tonumber( StrArr[k][o])

                --  print("StrArr[k][o]"..StrArr[k][o])
                -- print("SkillLV"..SkillLV.."||"..tempN)
                if SkillLV >=tempN then  --直到技能等级小于的时候跳出
                    if SkillLV==tempN then
                        tempIsSLv=true
                    else
                        tempIsSLv=false
                    end
                    tempLv=tempLv+1
                else
                    break
                end
            end
        end --for op
        table.insert(tempArr, tempLv) --2
        table.insert(tempArr, tempIsSLv)--3
        --print("i=0----id".. tempArr[1].."lv"..tempArr[2])
        table.insert(tempArrArr,tempArr)

    end --for k v  StrArr
    return tempArrArr
end

--创建一个角色的所有技能 ,然后根据使用结点分类
function BattleRole.CreatAllSkill(tempRole)
 
    --清空角色拥有的所有技能列表
    tempRole.Skills={}

    --按照栏位分四个  新增ex栏位
    tempRole.Skill_1_example={}
    tempRole.Skill_2_example={}
    tempRole.Skill_3_example={}
    tempRole.Skill_4_example={}
    tempRole.Skill_5_example={}

    if tempRole.Skill_1~=nil then
        BattleRole:SwithSkill(tempRole.Skill_1,tempRole,1)
    end-- if tempRole.Skill_1~=nil

    if tempRole.Skill_2~=nil then
        BattleRole:SwithSkill(tempRole.Skill_2,tempRole,2)
    end-- if tempRole.Skill_1~=nil
    if tempRole.Skill_3~=nil then
        BattleRole:SwithSkill(tempRole.Skill_3,tempRole,3)
    end-- if tempRole.Skill_1~=nil
    if tempRole.Skill_4~=nil then
        BattleRole:SwithSkill(tempRole.Skill_4,tempRole,4)
    end-- if tempRole.Skill_1~=nil
    if tempRole.Skill_5~=nil then
        BattleRole:SwithSkill(tempRole.Skill_5,tempRole,5)
    end-- if tempRole.Skill_1~=nil
end
--子方法用于分类
function BattleRole:SwithSkill(Skill_n,tempRole, _ExampleIndex)


    if Skill_n[1][1]==0 then
        return
    end


    for k, v in pairs(Skill_n) do
        local tempSkill =   BattleRole.CreatSkill( Skill_n[k][1],Skill_n[k][2],tempRole.IsAwaken,Skill_n[k][3])
        -- print("添加技能".. tempSkill.Opportunity)
        --每个技能都会加到 Skills
        if _ExampleIndex==4 then
            if tempRole.IsAwaken==true  then
                table.insert(tempRole.Skills,tempSkill)
            end
        else
            table.insert(tempRole.Skills,tempSkill)
        end

        if tempSkill.display then
            --按照第几个技能分类
            if _ExampleIndex==1 then
                table.insert(tempRole.Skill_1_example,tempSkill)
            elseif _ExampleIndex==2 then
                table.insert(tempRole.Skill_2_example,tempSkill)
            elseif _ExampleIndex==3 then
                table.insert(tempRole.Skill_3_example,tempSkill)
            elseif _ExampleIndex==4 then
                table.insert(tempRole.Skill_4_example,tempSkill)
            elseif _ExampleIndex==5 then
                table.insert(tempRole.Skill_5_example,tempSkill)
           
            end
        end


    end --for k v
end
--添加符文技能
function BattleRole.AddFwSkill(IntId ,tempRole)
    local tempSkill = BattleRole.CreatSkill(IntId,1,tempRole.IsAwaken,false)
    
    table.insert(tempRole.Skills_fw,tempSkill)
end

--生成技能  生成技能后加入到 OwnBefAtkSkills 自身技能组 ,每次到时机的时候 添加使用者和被使用者 ,然后调用公式计算属性
function BattleRole.CreatSkill(id,realLv,IsAwaken,_IsSLv)

    local tempSkill = JNSkill:new(id, realLv,IsAwaken,_IsSLv)
    -- print( "生成技能"..tempSkill.RealLV ..tempSkill.Id)
    return tempSkill
end

--切割出觉醒属性  传入字符串
function BattleRole.StSAwaken(Str ,tempRole)

    --用 ,切割然后加入临时表 ,再依次切割临时表生成
    local  StrArr =JNStrTool.strSplit(",", Str)
    for k, v in pairs(StrArr) do
        --在用 _ 切割
        StrArr[k]=JNStrTool.strSplit("_",StrArr[k])
    end
    tempRole.AwkenFormula=StrArr

end

--计算觉醒属性 传入角色
function BattleRole.SubAwaken(tempRole)

    --没有觉醒直接返回
    if tempRole.IsAwaken==false  then
        return
    end
    --   print(tempRole.HPmax.."------------------计算觉醒属性------------")
    for k,v in pairs(tempRole.AwkenFormula) do
        --每一个元素都是 { 1-3属性类型, 属性变化率}
        if  tempRole.AwkenFormula[k][1]=="1" then
            tempRole.HPmax=tempRole.HP+tempRole.AwkenFormula[k][2]
            tempRole.HP=tempRole.HPmax
        elseif  tempRole.AwkenFormula[k][1]=="2" then
            tempRole.Atk=tempRole.RealAtk+tempRole.AwkenFormula[k][2]
            tempRole.RealAtk= tempRole.Atk
        elseif  tempRole.AwkenFormula[k][1]=="3" then
            tempRole.Suppart=tempRole.RealSuppart+tempRole.AwkenFormula[k][2]/10000
            tempRole.RealSuppart=tempRole.Suppart
        end
    end--for
    -- print("------------------计算觉醒属性------------"..tempRole.HPmax)
end
function BattleRole.SubFormula_2(formulaStr ,tempRole,_lv)
    --如果没有一个分割符则不需要
    local tempReturnStr="return "
    local tempStr = {}
    --遍历所有的变量型字符
    local tempVariable=""
    for k, v in pairs(formulaStr) do
        tempVariable=  formulaStr[k]
        --  print(formulaStr[k] .. "--重新组成字符串" .. tempVariable)
        if tempVariable=="lv" then
            tempReturnStr= tempReturnStr.._lv
            -- 替换对应的参数
            --  formulaStr[k]=tempRole.LV
        elseif tempVariable=="dqstar" then
            tempReturnStr= tempReturnStr..tempRole.StartLV
            -- 当前星级
            --  formulaStr[k] =tempRole.StartLV
        else
            tempReturnStr= tempReturnStr..formulaStr[k]
        end
        --  BattleManager.LeftTeam[k].SleTarget(BattleManager)
    end
    --重新组成字符串
    --  tempReturnStr = "return "
    --   for k, v in pairs(formulaStr) do

    --  tempReturnStr=tempReturnStr..formulaStr[k]
    --  BattleManager.LeftTeam[k].SleTarget(BattleManager)
    --    end
  --  print(tempReturnStr)
    return tempReturnStr
end

--解析公式  formulaStr 公式 ,要改变属性的角色 仅仅用于角色基础属性 ,技能属性使用另一个
function BattleRole.SubFormula(formulaStr ,tempRole)
    --如果没有一个分割符则不需要
    local tempReturnStr="return "


    --遍历所有的变量型字符
    local tempVariable=""

    for k, v in pairs(formulaStr) do
        tempVariable=  formulaStr[k]
        --    print(formulaStr[k] .. "--重新组成字符串" .. tempVariable)
        if tempVariable=="lv" then
            tempReturnStr= tempReturnStr..tempRole.LV
            -- 替换对应的参数
            --  formulaStr[k]=tempRole.LV
        elseif tempVariable=="dqstar" then
            tempReturnStr= tempReturnStr..tempRole.StartLV
            -- 当前星级
            --  formulaStr[k] =tempRole.StartLV
        else
            tempReturnStr= tempReturnStr..formulaStr[k]
        end
        --  BattleManager.LeftTeam[k].SleTarget(BattleManager)
    end
    --重新组成字符串
    --  tempReturnStr = "return "
    --      for k, v in pairs(formulaStr) do

    --  tempReturnStr=tempReturnStr..formulaStr[k]
    --  BattleManager.LeftTeam[k].SleTarget(BattleManager)
    --    end
    tempReturnStr = tempReturnStr
    return tempReturnStr
end

--解析技能公式 技能使用者,受击者 ,技能公式
function BattleRole.SubSkillFormula( _atkRole,_hitROle,formulaStr)
    local tempReturnStr="return "

    local tempChar="0"

    --遍历所有的变量型字符
    local tempVariable=""
    for k, v in pairs(formulaStr) do
        tempChar=formulaStr[k]
        tempVariable=  formulaStr[k]
        --     print(formulaStr[k] .. "--重新组成字符串" .. tempVariable)
        if tempVariable=="wfmaxhp" then

            -- 替换对应的参数
            tempChar=tonumber(_atkRole.HPmax)
        elseif tempVariable=="wfdqhp" then --当前血量

            tempChar =_atkRole.HP
        elseif tempVariable=="wfsshp" then --损失血量
            tempChar =_atkRole.HPmax- _atkRole.HP
        elseif tempVariable=="wfzybuff" then --增益Buff数目
            tempChar =BattleRole.UpBuffNumber(_atkRole)
        elseif tempVariable=="wfjybuff" then   --减益buff数目
            tempChar =BattleRole.DeBuffNumber(_atkRole)
        elseif tempVariable=="wfzyl" then   --支援力
            tempChar =_atkRole.RealSuppart
        elseif tempVariable=="mwfzyl" then   --基础支援力
            tempChar =_atkRole.Suppart
        elseif tempVariable=="wffy"   then   --防御力
            tempChar =_atkRole.RealDef
        elseif tempVariable=="mwffy" then   --基础防御力
            tempChar =_atkRole.Def
        elseif tempVariable=="wfgj" then   --攻击力
            tempChar =_atkRole.RealAtk
        elseif tempVariable=="mwfgj" then   --基础攻击力
            tempChar =_atkRole.Atk
            --   print(  "带入攻击"..formulaStr[k] )
        elseif tempVariable=="wfbj" then   --暴击率
            tempChar =_atkRole.RealCrit
        elseif tempVariable=="mwfbj" then   --基础暴击率
            tempChar =_atkRole.Crit
            --  print(_atkRole.Name.."带入爆击"..formulaStr[k] )
        elseif tempVariable=="wfbs" then   --暴击伤害
            tempChar =1+ _atkRole.RealCritDmg
        elseif tempVariable=="mwfbs" then   --基础暴击伤害
            tempChar =1+ _atkRole.CritDmg
        elseif tempVariable=="wfsb"  then   --闪避
            tempChar =_atkRole.RealAgile
        elseif  tempVariable=="mwfsb" then
            tempChar =_atkRole.Agile
        elseif tempVariable=="wfpgsh" then   --上次普攻造成的伤害
            tempChar=_atkRole.LastAtkDMG
        elseif tempVariable=="wfgjsh" then   --这次攻击造成的所有伤害  TODO
            tempChar=_atkRole.LastAtkDMG

            --敌方的属性
        elseif tempVariable=="dfmaxhp" then
            -- 替换对应的参数
            tempChar=_hitROle.HPmax
        elseif tempVariable=="dfdqhp" then --当前血量

            tempChar =_hitROle.HP
            if tempChar<0 then
                tempChar=0
            end
        elseif tempVariable=="dfsshp" then --损失血量
            tempChar =_hitROle.HPmax- _hitROle.HP
        elseif tempVariable=="dfzybuff" then --增益Buff数目
            tempChar =BattleRole.UpBuffNumber(_hitROle)
        elseif tempVariable=="dfjybuff" then   --减益buff数目
            tempChar =BattleRole.DeBuffNumber(_hitROle)
        elseif tempVariable=="dfzyl" then   --支援力
            tempChar =_hitROle.RealSuppart
        elseif tempVariable=="mdfzyl" then   --基础支援力
            tempChar =_hitROle.Suppart
        elseif tempVariable=="dffy" then   --防御力
            tempChar=_hitROle.RealDef
        elseif tempVariable=="mdffy" then   --基础防御力
            tempChar=_hitROle.Def
        elseif tempVariable=="dfgj" then   --攻击力
            tempChar=_hitROle.RealAtk
        elseif tempVariable=="mdfgj" then   --基础攻击力
            tempChar=_hitROle.Atk
        elseif tempVariable=="dfbj" then   --暴击率
            tempChar =_hitROle.RealCrit
        elseif tempVariable=="mdfbj" then   --基础暴击率
            tempChar =_hitROle.Crit
        elseif tempVariable=="dfbs" then   --暴击伤害
            tempChar=_hitROle.RealCritDmg
        elseif tempVariable=="mdfbs" then   --基础暴击伤害
            tempChar=_hitROle.CritDmg
        elseif tempVariable=="dfsb" then   --闪避
            tempChar =_hitROle.RealAgile
        elseif tempVariable=="mdfsb" then   --基础闪避
            tempChar =_hitROle.Agile
        elseif tempVariable=="dfpgsh" then   --上次普攻造成的伤害
            tempChar =_hitROle.LastAtkDMG
        elseif tempVariable=="dfgjsh" then   --这次攻击造成的所有伤害
            tempChar =_atkRole.LastBeHit
            --print(   _atkRole.LastAtkDMG.."|2|".._hitROle.LastAtkDMG.."这次攻击造成的所有伤害".._hitROle.Name.._atkRole.Name.." , ".._hitROle.LastBeHit.." , ".._atkRole.LastBeHit)
        end
        --  BattleManager.LeftTeam[k].SleTarget(BattleManager)
        tempReturnStr=tempReturnStr..tempChar   --重新组成字符串


    end
    --如果前俩都是-号返回0


    return tempReturnStr
end



-----------外部调用---  如果返回真就可以生成特效




return BattleRole