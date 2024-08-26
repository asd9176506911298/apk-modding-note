require("JNBattle/JNEffect")
--本回合特效表 ,回合结束特效表 因为回合结束的时候,下一个角色已经在攻击了
JNturnEffect={}
JNturnEffect.EffectId=0  --特效id
JNturnEffect.JnSkill=nil   -- 触发的技能id 同一个技能的飞行时间 普攻是-1                                                                                                                                                                                                                                                                                                                                                                                                            
JNturnEffect.AktRoleId=nil  --攻击者id
JNturnEffect.HitRoleId=nil  --受击者id
JNturnEffect.IsMianTar=false  --是否主要目标
JNturnEffect.NeedTime=0  --播放这个特效需要的时间,包括飞行时间
JNturnEffect.DealyTime=0  --延迟时间
--攻击者是否近战 近战的受击特效根据攻击帧判定  远程根据子弹飞行时间
JNturnEffect.AtkRoleIsCombat=false  
JNturnEffect.LuaEffect=nil  --lua脚本 查询id生成 ,然后传参数给c#
JNturnEffect.CEffect=nil   --c#脚本 ,1计算时间,2开始播放
--每次加入队列的时候判断自己后面是否有带 ";" 需要同步播放的特效组,如果有,加入到这个表

--需要同步播放的特效id  { {同步技能b1,同步技能b1} ,{同步技能c1,同步技能c1} }
JNturnEffect.SynchroEffectId={ }


--外部调用创建新角色
function JNturnEffect:new(_id)
    o = {}
    setmetatable(o, self)
    self._index = self
    o.EffectId=_id
    

    return o
    
 end

return JNturnEffect