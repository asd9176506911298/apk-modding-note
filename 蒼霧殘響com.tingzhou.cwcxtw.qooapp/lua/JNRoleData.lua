JNRoleData={}

JNRoleData.RoleID=11000
JNRoleData.LV=1
JNRoleData.LvMax=99
JNRoleData.StarLV=3
JNRoleData.SkillLV=1 --技能等级
JNRoleData.IsAwaken=false --是否觉醒
JNRoleData.Rank=3

--是否为怪物
JNRoleData.PreviewRoleType = 1 --1.机娘2.怪物
--怪物Battlerole对象
JNRoleData.MonsterRole=nil
--机娘Battlrrole对象
JNRoleData.BattleRole=nil
JNRoleData.RealDef=0.5  --实际
JNRoleData.Def=0.5 --防御力  在创建时赋值
JNRoleData.BuffDef=0  --各种Buff
JNRoleData.SkillDef=0  --技能减伤 乘算,护甲是加算
JNRoleData.SkillDeDef=0    --伤害加深,暂时么有
JNRoleData.HP=100 --当前血量

--技能预览界面信息
JNRoleData.CurCombineSkillIndex = 1
JNRoleData.CurRoleSkillLV = 1

JNRoleData.NextPanelID= 1 --1.经验预览2.技能预览3.升级界面4.升星界面5.觉醒预览6.技能升级
JNRoleData.RoleUpgradeIndex = 1 --1、技能预览 2、经验预览 3、详情预览界面
return JNRoleData