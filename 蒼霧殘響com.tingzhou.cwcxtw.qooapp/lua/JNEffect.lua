require("LocalData/Special_effectLocalData")
require("JNBattle/JNStrTool")

--根据id 敌人id我方id读取

JNEffect={}
JNEffect.GameId=1  --本回合第几个结算 可以插队
JNEffect.AktRole=nil  --攻击者  id
JNEffect.HitRole=nil  --受击者  id
JNEffect.IsMianTar=false  --是否主要目标,一般只对主要目标生成特效

JNEffect.Id=0
JNEffect.AniType=0 --0.龙骨动画，1.unity 2视频
JNEffect.Endtime=0  --unity特效使用 到时间回收
JNEffect.Name=""    --文件名
JNEffect.TimerType=0  --0.为常规特效：从第1帧计时1.为受击特效：攻击者的攻击帧开始计时  2.攻击特效: 只对主要受击者发动 3.buff循环: 挂在受击者身上,buff移除的时候才消失

JNEffect.AniName=""   -- 特效动画名称/EX用于 后续特效名;旋转摄像机;攻击位置;受击位置 
JNEffect.Sound_delay=0
JNEffect.Sound=""
JNEffect.Delay=0        --单位秒 0.3f
JNEffect.Delay_Initial=0   --初始延迟时间  如果要改变基础延迟  
JNEffect.StartPosType=0  --特效起点类型 0.施法者，1.作用者                              EX视频特效用来填延迟
JNEffect.StartPos_X=0  --格式：X值，Y值，Z轴层级
JNEffect.StartPosStr="0"
JNEffect.StartPos_Y=0 
JNEffect.StartPos_Z=0 
JNEffect.EndPosType=0   --0.施法者，1.作用者                                             Ex用于受击角色出现延迟 
JNEffect.EndPosOffsetType=0  --终点位置偏移0.脚底，1.身体中间，2.头顶                     EX用于受击角色隐藏时间
JNEffect.EndPos_X=0
JNEffect.EndPos_Y=0
JNEffect.EndPos_Z=0
JNEffect.FlyType=0 --0.不飞行 只在起点播放 ，1.旋转且直线飞行，2.抛物线飞行，3.不旋转且直线飞行
JNEffect.IsLoop=0   --0.不循环，1.循环
JNEffect.FlySpeed=0 
JNEffect.Rot_X=0
JNEffect.Rot_Y=0
JNEffect.Rot_Z=0
JNEffect.TimeScal=1   --动画播放速率
JNEffect.LocScale_X=1  --缩放
JNEffect.LocScale_Y=1
JNEffect.exposure=0  -- 1曝光,0不曝光

--外部调用创建新特效
function JNEffect:new(_EffectId ,_AtkId,_HidId)
    o = {}
    setmetatable(o, self)
    self.__index = self
   --
   o.Id=tonumber(_EffectId)

   local tempEffectData={}
   local tempId="".._EffectId

   --o.Effects=tonumber()
   tempEffectData = Special_effectLocalData.tab[tonumber(tempId)]
  

    o.AniType=tonumber(tempEffectData[2])
    o.Endtime=tempEffectData[3]
    o.Name=tempEffectData[4]
    o.TimerType=tonumber(tempEffectData[5])
    o.Subtype=tonumber(tempEffectData[6])
    o.AniName=tempEffectData[7]
    o.Sound_delay=tonumber(tempEffectData[8])
    o.Sound=tempEffectData[9]
    --print("................................................."..tempEffectData[tempIndex])
    o.Delay=tonumber(tempEffectData[10])/30
    o.StartPosType=tonumber(tempEffectData[11])
    --起点坐标偏移
  --  print("id".. o.Id)
  --  print("起点坐标偏移".. o.Id..tempEffectData[tempIndex])
    o.StartPosStr=tempEffectData[12]
    local tempPosArr=JNStrTool.strSplit("," ,tempEffectData[12])
    o.StartPos_X=tonumber(tempPosArr[1])
    o.StartPos_Y=tonumber(tempPosArr[2])
    o.StartPos_Z=tonumber(tempPosArr[3])
    o.EndPosType=tonumber(tempEffectData[13])
    o.EndPosOffsetType=tonumber(tempEffectData[14])
    --终点坐标偏移
    tempPosArr=JNStrTool.strSplit("," ,tempEffectData[15])
    o.EndPos_X=tonumber(tempPosArr[1])
    o.EndPos_Y=tonumber(tempPosArr[2])
    o.EndPos_Z=tonumber(tempPosArr[3])
    o.FlyType=tonumber(tempEffectData[16])
    o.IsLoop=tonumber(tempEffectData[17])
    o.FlySpeed=tonumber(tempEffectData[18])
    --旋转
    tempPosArr=JNStrTool.strSplit("," ,tempEffectData[19])
    o.Rot_X=tonumber(tempPosArr[1])
    o.Rot_Y=tonumber(tempPosArr[2])
    o.Rot_Z=tonumber(tempPosArr[3])

    o.TimeScal=tonumber(tempEffectData[20])
    tempPosArr=JNStrTool.strSplit("," ,tempEffectData[21])
    o.LocScale_X=tonumber(tempPosArr[1])
    o.LocScale_Y=tonumber(tempPosArr[2])

    return o
 end

 --使用特效
 function JNEffect.ShowEffect(_JNEffect)
     
 end

return JNEffect