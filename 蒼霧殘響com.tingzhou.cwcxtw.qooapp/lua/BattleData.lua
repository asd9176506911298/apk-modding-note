--仅用于存属性
require("LocalData/SteamLocalData")
BattleData = {}
 BattleData.MaxSkillDef=tonumber(SteamLocalData.tab[103012][2])   --技能减伤最大值
 BattleData.MinSkillDef=SteamLocalData.tab[103013][2]

 BattleData.MaxSkillHp=SteamLocalData.tab[103015][2]       --技能带入血上限的最大值
BattleData.AgileDMG=tonumber(SteamLocalData.tab[103010][2])   --闪避减伤
BattleData.AgileDebuff=tonumber(SteamLocalData.tab[103011][2])   --闪避减少debuff持续时间
BattleData.RoundPause = tonumber(SteamLocalData.tab[103017][2])     --回合间间隔时间

BattleData.MaxAtkUp=tonumber(SteamLocalData.tab[103003][2]*10000)  --攻击力上限
BattleData.MinAtkUp=tonumber(SteamLocalData.tab[103004][2]*10000)  --攻击力下限

BattleData.MaxDef=tonumber(SteamLocalData.tab[103008][2])       --装甲上限
BattleData.MinDef=tonumber(SteamLocalData.tab[103009][2])

BattleData.MaxAgi=tonumber(SteamLocalData.tab[103008][2])       --闪避上限
BattleData.MinAgi=tonumber(SteamLocalData.tab[103009][2])

BattleData.MaxCrit=tonumber(SteamLocalData.tab[103005][2] )     --暴击率上限
BattleData.MinCrit=tonumber(SteamLocalData.tab[103006][2] )

BattleData.MinCritDMG=tonumber(SteamLocalData.tab[103007][2])   --暴击伤害下限



BattleData.Camera_Larger_NeedTime=0.2  --运动时间
BattleData.Camera_Larger_WaitTime=0.8 --放大后保持镜头时间时间

BattleData.Camera_Normal_NeedTime=0.5  --运动时间

BattleData.SkillGameIdCout=0

--视频特效用的
--抓取用的时间
BattleData.Videoe_Grab_Time=0.2
BattleData.Videoe_Grab_EaseType=6  --  1-25的曲线类型
--复原时间
BattleData.Videoe_Recovery_Time=0.5
BattleData.Videoe_Recovery_EaseType=6  --  1-25的曲线类型


--每回合时间
BattleData.Battle_TurnTime=1.5
BattleData.Battle_RoundTime=4
--如果当回合角色被跳过,快速下回合的时间
BattleData.Battle_TurnTime_Fast=2
BattleData.Battle_RoundTime_Fast=3

--ex技能震动屏幕
BattleData.Shake_Ex_delaytime=1  --延迟
BattleData.Shake_Ex_time=1       --持续
BattleData.Shake_Ex_strength=10       --强度
BattleData.Shake_Ex_nmuber=20       --次数
BattleData.Shake_Ex_range=50       --范围
--屏幕变红系数和时长
BattleData.Red_Ex_Time=0.5  
BattleData.Red_Ex_Strength=1

--普攻名字震动
BattleData.Shake_Normal_time=1       --持续
BattleData.Shake_Normal_strength=2     --强度
BattleData.Shake_Normal_nmuber=10      --次数
BattleData.Shake_Normal_range=20       --范围

BattleData.Red_Normal_Time=0.2         --时长
BattleData.Red_Normal_Strength=0.4        --强度

function BattleData.GetSkillGameId()
    BattleData.SkillGameIdCout=BattleData.SkillGameIdCout+1  
 return   BattleData.SkillGameIdCout
end


BattleData.Trun={}  --这个表走完说明回合结束 { {skillid ,skillIndex,atkid ,hitid,turnid} ,{skillid ,atkid ,hitid,turnid}} 
--每个元素都是技能id ,技能在施法者哪个表里skillIndex=1攻击前, 2受到攻击前  5回合结束时 6 PermanentSkills  ,施法者,受击者 ,三个组成,如果要插队 则判断turnid 插队完毕后重新给turn赋值


return BattleData