require("LocalData/SkillLocalData")
require("JNBattle/JNStrTool")

---@class JNSkill
JNSkill={}
--外部调用创建新技能 传入 id和等级 等级用来代入数据 ,角色是否已经觉醒
function JNSkill:new(skillId ,realLv,IsAwake,_IsSLv)
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.Id=tonumber(skillId)
    o.RealLV=realLv
    --解析技能属性
    --查找Id
    local tempSkillData = {}
    skillId=skillId
    o.Effects={}
    print( " --解析属性   ----------" ..skillId)
    tempSkillData=SkillLocalData.tab[tonumber(skillId)]
    if tempSkillData == nil then
        print("找不到"..skillId.."这个技能")
    end
    --解析属性
    --解析能否添加技能
    o.Trgger_condition_str=tempSkillData[2]
    --JNSkill.ReadSkillCanUse(tempSkillData[2],o)
    o.Action=tempSkillData[3]


    --特效id,延迟
    --print(skillId .."id" )
    --print(tempSkillData[5])   JNStrTool.SubAtkEffectId(tempSkillData[5])
    o.Delay_str=tempSkillData[4]  --延迟字符串
    o.BeHitTrans_str=tempSkillData[35]
    -- print(tempSkillData[6] )
    o.ShowEffects_str=tempSkillData[5]

    o.ShowEffects=JNStrTool.SubAtkEffectId(tempSkillData[5])  --JNSkill.ReadShowEffect(tempSkillData[5])

    local tempEffect=6
    --说明文本
    o.Explain=JNSkill.ReadSkillExplain(tempSkillData[tempEffect],realLv)
    tempEffect=tempEffect+1 --7

    --cd 所有人攻击一次是一轮 按轮
    o.CdRound=tonumber(tempSkillData[tempEffect])
    o.CdRound_cout=-1* o.CdRound
    tempEffect=tempEffect+1    --8

    --是否觉醒
    if tempSkillData[tempEffect]=="0" then
        o.Awaken=false
    else
        o.Awaken=true
    end
    --觉醒技能要判断自己是否已经觉醒否则上锁
    if IsAwake==false  then
        if o.Awaken then
            o.IsLock=true
        end
    end

    tempEffect=tempEffect+1   --9
    o.Subtitle=tempSkillData[33]
    --0级显示1级效果,加上锁表示不能使用
    if realLv<1 then
        realLv=1
        o.IsLock=true
    end
    o.IsSLv=_IsSLv
    o.Exskill=tonumber(tempSkillData[tempEffect])
    tempEffect=tempEffect+1   --10
    o.Skilltype1=tonumber(tempSkillData[tempEffect])
    tempEffect=tempEffect+1   --11
    o.Skilltype2=tonumber(tempSkillData[tempEffect])
    tempEffect=tempEffect+1   --12
    o.Name=tempSkillData[tempEffect]
    tempEffect=tempEffect+1   --13
    --技能图标
    o.Icon=tempSkillData[tempEffect]
    tempEffect=tempEffect+1     --14
    o.Opportunity=tonumber(tempSkillData[tempEffect])
    tempEffect=tempEffect+1     --15
    o.Object=tonumber(tempSkillData[tempEffect])
    tempEffect=tempEffect+1     --16
    o.Time= JNSkill.ReadSkillTime(tempSkillData[tempEffect],realLv ) --tonumber(tempSkillData[tempEffect])   --持续时间
    tempEffect=tempEffect+1     --17
    o.Exception=tempSkillData[tempEffect]
    JNSkill.ReadException(o)
    tempEffect=tempEffect+1     --18
    local templ=1
    local  tempEffectIndex = tempEffect
    --判断所有技能效果
    for i = 1, 3, 1 do
        -- statements
        --循环判断是否有下一个条件  为0就没有了
        if tempSkillData[tempEffectIndex+3]==nil or tempSkillData[tempEffectIndex+2]=="0" then
            -- print( i.."--循环判断是否有下一个条件  为0就没有了" )
            break
        else
            --解析具体效果 ,第一个效果必有
            local tempEffect= {}
            local   Str=tempSkillData[tempEffectIndex]
            --  tempEffect.Trgger_condition=tempSkillData[tempEffectIndex]
            --解析数据
            tempEffect.Trgger_condition_str=Str
            --先判断是和还是或者
            tempEffect.Trgger_condition={}
            tempEffect.EffectObj=tempSkillData[tempEffectIndex+1]
            --解析分出效果,参数
            --  print(skillId)
            tempEffect=   JNSkill.ReadEffect(tempSkillData[tempEffectIndex+2], realLv, tempEffect,o)
            tempEffect.TrunTimes=tonumber(tempSkillData[tempEffectIndex+3])
            tempEffect.MaxTimes=tempSkillData[tempEffectIndex+4]
            tempEffectIndex=tempEffectIndex+5
            table.insert( o.Effects, tempEffect)
            templ=templ+1
        end
    end--for i = 1, 10
    --  print( "技能效果长度"..templ)
    if tempSkillData[34]=="1" then
        o.display=false
    else
        o.display=true  --默认显示
    end
    o.Evolve = tempSkillData[44]             ---技能进化等级
    o.SkillLvStage = {}      ---技能进阶等级表(强化次数)
    local tempStr = string.split(tempSkillData[45],",")
    for k,v in ipairs(tempStr) do
        table.insert(o.SkillLvStage, tonumber(v))
    end
    return o
end
--解析技能时间
function JNSkill.ReadSkillTime(str,realLv )
    local  temptime = tonumber(str)
    --第一次遇到[开始  把所有的加入临时字符串 ,然后用 & 切割  ]
    local tempIsSubF = false
    local tempChar=""
    local tempStr =""
    local tempTab ={}
    local tempLvStr = "" --等级相关的属性
    --最后一位 ,[  , ]  三种情况都会生成一个字符串
    local stringLen = string.len(str)
    for i = 1, stringLen do
    tempChar=string.sub(str,i,i)
    --已经在isSub的
    if tempIsSubF then
      -- 都加入到 tempLvStr ,直到遇到 ]
        if tempChar=="]" then
        
        tempIsSubF=false
        --切割tempLvTab
        local tempLvArr = JNStrTool.strSplit("&", tempLvStr)
          --找到对应等级的属性
          for k, v in pairs(tempLvArr) do
              if realLv>=k then
                -- 等级大于下标
                tempStr=tempLvArr[k]
                temptime=tempLvArr[k]
              end
          end-- for kv 
          --然后加入到总函数里
          table.insert(tempTab, tempStr)
          tempStr=""
        else
        tempLvStr=tempLvStr..tempChar
        end

    else
        if i==stringLen then
          tempStr=tempStr..tempChar
          if tempStr~="" then
            table.insert(tempTab, tempStr)
          end
          
          tempStr=""
        elseif tempChar=="[" then
          tempIsSubF=true
          if tempStr~="" then
            table.insert(tempTab, tempStr)
          end
          tempStr=""
        else
          tempStr=tempStr..tempChar
        end --i==stringLen 
      end-- if tempIsSubF
    end -- for i = 1,
    --
    temptime=tonumber(temptime)
    return  temptime
end
 --解析技能效果字符串
function JNSkill.ReadEffect(str,realLv ,tempEffect ,_o)
    --   print("切割前-----------"..str)
    --用@切割 得到效果组
    local tempEffArr=JNStrTool.strSplit("@", str)
    tempEffect.EffectType={}
    tempEffect.EffectExactFml={}
    --遍历所有效果
    for a, b in pairs(tempEffArr) do
        --按照 _ 切割
        local tempStrArr= JNStrTool.strSplit("_", tempEffArr[a])
        local _ShowTime=false
        if tonumber(tempStrArr[1])==2  then
            _ShowTime=true
        end
        table.insert( tempEffect.EffectType,tonumber(tempStrArr[1]))  -- tempEffect.EffectType=tonumber(tempStrArr[1])
        tempEffArr[a]=tempStrArr[2]
        --第一次遇到[开始  把所有的加入临时字符串 ,然后用 & 切割  ]
        local tempIsSubF = false
        local tempChar=""
        local tempStr =""
        local tempTab ={}
        local tempLvStr = "" --等级相关的属性

        local name = value

        --最后一位 ,[  , ]  三种情况都会生成一个字符串
        local stringLen = string.len(tempEffArr[a])
        for i = 1, stringLen do
            tempChar=string.sub(tempEffArr[a],i,i)



            --已经在isSub的
            if tempIsSubF then
                -- 都加入到 tempLvStr ,直到遇到 ]
                if tempChar=="]" then

                    tempIsSubF=false
                    --切割tempLvTab
                    local tempLvArr = JNStrTool.strSplit("&", tempLvStr)
                    --找到对应等级的属性
                    for k, v in pairs(tempLvArr) do
                        if realLv>=k then
                            -- 等级大于下标
                            tempStr=tempLvArr[k]
                        end
                    end-- for kv
                    --然后加入到总函数里
                    if _ShowTime  then
                        _o.ShowTime=tonumber(tempStr)
                    end

                    table.insert(tempTab, tempStr)
                    tempStr=""
                else
                    tempLvStr=tempLvStr..tempChar
                end

            else
                if i==stringLen then
                    tempStr=tempStr..tempChar
                    if tempStr~="" then
                        table.insert(tempTab, tempStr)
                    end

                    tempStr=""
                elseif tempChar=="[" then
                    tempLvStr=""
                    tempIsSubF=true
                    if tempStr~="" then
                        table.insert(tempTab, tempStr)
                    end
                    tempStr=""
                else
                    tempStr=tempStr..tempChar
                end --i==stringLen
            end-- if tempIsSubF
        end -- for i = 1,
        --拼接成字符串添加给tempEffect.EffectExactFml
        local returnStr = ""
        for k, v in pairs(tempTab) do
            returnStr=returnStr..tempTab[k]
        end
        --去掉{} 并且形成技能参数
        local tempFormula=  JNStrTool.StrToScript(returnStr)
        -- print( "技能效果公式".. returnStr)
        table.insert(tempEffect.EffectExactFml, tempFormula)
    end--遍历所有效果
    return tempEffect
end

--解析特效字符串 {{特效id,","},{特效id,";"} }
function  JNSkill.ReadShowEffect(Str)
    local tempShowEffectTab= {}
    local stringLen = string.len(Str)
    --遇到 ,或者; 切割成一个  遇到 _切割
    local  tempStr=""  --临时保存特效id
    local tempTabStr={}
    for i=1,stringLen do
        local tempChar=string.sub(Str ,i,i)
        --最后一位
        if i==stringLen then
            tempStr=tempStr..tempChar
            table.insert(tempTabStr ,tempStr)
            table.insert(tempShowEffectTab ,tempTabStr)
            return tempShowEffectTab
        end --最后一位
        if tempChar== "_" then
            -- 添加Id
            if tempStr~="" then
                table.insert(tempTabStr ,tempStr)
                --    print("gongshibufen"..tempStr)
                tempStr=""
                tempTabStr={}
            end
        elseif  tempChar== "," then
            if tempStr~="" then
                table.insert(tempTabStr ,tempStr)
                --    print("gongshibufen"..tempStr)
                tempStr=""

                table.insert(tempTabStr ,",")
                table.insert(tempShowEffectTab ,tempTabStr)
                tempTabStr={}
            end
        elseif  tempChar== ";" then
            if tempStr~="" then
                table.insert(tempTabStr ,tempStr)
                --    print("gongshibufen"..tempStr)
                tempStr=""

                table.insert(tempTabStr ,";")
                table.insert(tempShowEffectTab ,tempTabStr)
                tempTabStr={}
            end
        else --不是分隔符就累加起来
            tempStr=tempStr..tempChar
        end

    end
end
--解析能否被解除,能否叠加 TODO

function JNSkill.ReadSkillCanUse(Str,tempEffect)

    --  tempEffect.Trgger_condition=tempSkillData[tempEffectIndex]
    --解析数据
    --先判断是和还是或者
    tempEffect.Trgger_condition_str=Str
    tempEffect.Trgger_condition={}
    if Str=="0" or Str==nil  then
        tempEffect.Trgger_conditionIsAnd=0
        table.insert(tempEffect.Trgger_condition ,{0})
    else
        local stringLen = string.len(Str)
        tempEffect.Trgger_conditionIsAnd=3
        for i=1,stringLen do

            local tempChar=string.sub(Str ,i,i)
            if tempChar=="#" then
                tempEffect.Trgger_conditionIsAnd=2
                break
            elseif tempChar=="@" then
                tempEffect.Trgger_conditionIsAnd=1
            end
        end
        -- print("条件")
        if   tempEffect.Trgger_conditionIsAnd==3 then
            local  _tab=   JNStrTool.strSplit("_",Str)
            table.insert(tempEffect.Trgger_condition ,_tab)
            -- print(tempEffect.Trgger_condition[1][1])
        elseif tempEffect.Trgger_conditionIsAnd==2 then
            tempEffect.Trgger_condition= JNStrTool.StrArrArr( "#" ,Str  ,{"_"} )
            -- print(tempEffect.Trgger_condition[1][1])
        elseif tempEffect.Trgger_conditionIsAnd==1 then
            tempEffect.Trgger_condition= JNStrTool.StrArrArr( "@" ,Str  ,{"_"} )
            --  print(tempEffect.Trgger_condition[1][1])
        end

    end  --先判断是和还是或者
end
--解析技能说明 然后乘以100

function JNSkill.ReadSkillExplain(str,realLv )

    --第一次遇到[开始  把所有的加入临时字符串 ,然后用 & 切割  ]
    local tempIsSubF = false
    local tempChar=""
    local tempStr =""
    local tempTab ={}
    local tempLvStr = "" --等级相关的属性
    --最后一位 ,[  , ]  三种情况都会生成一个字符串
    local stringLen = string.len(str)
    for i = 1, stringLen do
        tempChar=string.sub(str,i,i)
        --已经在isSub的
        if tempIsSubF then
            -- 都加入到 tempLvStr ,直到遇到 ]
            if tempChar=="]" then

                tempIsSubF=false
                --切割tempLvTab
                local tempLvArr = JNStrTool.strSplit("&", tempLvStr)
                --找到对应等级的属性
                -- tempStr=tempLvStr
                for k, v in pairs(tempLvArr) do
                    if realLv>=k then
                        -- 等级大于下标
                        tempStr=tonumber(tempLvArr[k]) *100
                    end
                end-- for kv
                --然后加入到总函数里
                table.insert(tempTab, tempStr)
                tempStr=""
            else
                tempLvStr=tempLvStr..tempChar
            end

        else
            if i==stringLen then
                tempStr=tempStr..tempChar
                if tempStr~="" then
                    table.insert(tempTab, tempStr)
                end

                tempStr=""
            elseif tempChar=="[" then
                tempLvStr=""
                tempIsSubF=true
                if tempStr~="" then
                    table.insert(tempTab, tempStr)
                end
                tempStr=""
            else
                tempStr=tempStr..tempChar
            end --i==stringLen
        end-- if tempIsSubF
    end -- for i = 1,
    --拼接成字符串添加给tempEffect.EffectExactFml
    local returnStr = ""
    for k, v in pairs(tempTab) do
        returnStr=returnStr..tempTab[k]
    end
    return  returnStr
end

 -------------根据实际情况生成的属性----------------
-- 一对多的技能等于生成多个技能同时生效 -实际上没有生成多个
JNSkill.IsLock=false  -- false 已经解锁 true 被锁了
JNSkill.AtkRoleId=0   --发起者的id
JNSkill.AtkRoleIsleft=true  --发起者是那边的
JNSkill.HitRoleId=0   --被攻击者的id
JNSkill.HitRoleIsleft=true--被攻击者是那边的
JNSkill.ExistTime=0    --技能存在的回合数 实际使用的时候减少这个回合数 ,另一个是表里的数据
--被添加的时候赋值时间 0则结算完毕就消失

JNSkill.RealLV=1 --实际上的等级 ,可能三级角色强化才有一次技能属性提升
JNSkill.IsSLv=false  
------------读表得到的属性和公式--------------------
JNSkill.Id=0  
JNSkill.RelationSkill=0    --普通攻击配置为-1本回合任意伤害击杀为-2 需要技能击杀则配置技能id 仅配置来自什么技能
JNSkill.ShowEffects={}    -- {{特效id,延迟,","},{特效id,";"} }    ","
JNSkill.ShowEffects_str={} --存初始表
JNSkill.Explain=""  --说明
JNSkill.Delay_str=""    --延迟字符串 

JNSkill.CdRound=0--技能冷却时间 轮 round 所有人攻击一次
JNSkill.CdRound_cout=0    -- 技能冷却计时器上次触发的轮次 
JNSkill.Exskill=0  --是否ex技能 0 不是 1是
JNSkill.Awaken=false  --是否觉醒技能
JNSkill.Skilltype1=0  --1.增益技能，2.减益技能，3.额外伤害
JNSkill.Skilltype2=0  --技能二级类型

--分类：0.不读，1.免疫类，2.重置类，3.反射反击类，4.吸收类，5.复活类，6.恢复类，7.持续伤害类，
--8.挑衅类，9.攻击妨碍类，10.标志，11.标识，12.无视，13.禁止，14.能力弱化，15.能力强化，
--16.复制，17.解除，18.护盾，19.赋予能力，20.防护罩（免伤），21.集中，22.特别  
--有持续时间的技能挂在目标身上

JNSkill.Name=""
JNSkill.Icon=""
JNSkill.Action=""         --附带的动作
JNSkill.Opportunity=nil  --触发时间点 攻击前还是后 等
JNSkill.Object=0   --作用对象：1.自己,2.我军,3.敌人,4.场上全体敌人,5.场上全体友军
JNSkill.Time=0    --持续时间   1表示持续到回合结束  0结算完毕移除
JNSkill.Exception=0  --例外事项 ----------- 0.不读,1.不可解除,2.不可叠加,3.不可免疫,4.不可禁止,5.不可暴击,6.可叠加,7.禁止复活,8.战斗中不受生命属性变更影响,9.战斗中不受装甲属性变更影响,10.战斗中不受攻击属性变更影响,11.战斗中不受暴击属性变更影响,12.战斗中不受暴击伤害属性变更影响,13.战斗中不受闪避属性变更影响,14.受免疫减益类技能影响,15.无法复制持续时间为负数的技能[永久]
--解析例外事项     
function JNSkill.ReadException(_tempSkill)
  local  _str=_tempSkill.Exception   -- 用@
  local tempArr = JNStrTool.strSplit("@", _str)
  for key, value in pairs(tempArr) do
    if value=="1" then
      JNSkill.ContRemove=false  --不可解除
    elseif value=="2" then
      -- statements
    elseif value=="3" then
      JNSkill.ContImmune=true   --无视免疫
    elseif value=="4" then
      JNSkill.ContBan=true     --不可禁止
    elseif value=="5" then
      JNSkill.ContCirt=true   --不能暴击
    elseif value=="6" then
      JNSkill.CanSuperposition=true  --叠加  一般都不可叠加
    elseif value=="7" then
      JNSkill.ContResurrection=true  --禁止复活  
    elseif value=="7" then
      JNSkill.ContResurrection=true  --禁止复活  一般都不可叠加
    elseif value=="7" then
      JNSkill.ContResurrection=true  --禁止复活  一般都不可叠加
    end
  end

end
JNSkill.ContRemove=false        --不可解除
JNSkill.CanSuperposition=false  --叠加  一般都不可叠加
JNSkill.ContImmune=false        --无视免疫使用
JNSkill.ContBan=false           --不可被禁止
JNSkill.ContCirt=false           --不可暴击
JNSkill.ContResurrection=false  --不可复活
JNSkill.Effects={  }  --


--技能效果存SkillEffect数组
JNSkill.Trgger_conditionIsAnd=0  
JNSkill.Trgger_condition={}  -- {{条件,符号,值} ,{} }
--技能跳字
JNSkill.Subtitle=""

SkillEffect={}

SkillEffect.Trgger_conditionIsAnd=0   --0没有条件 1 所有条件都要满足 2满足一个 3只有一个条件
SkillEffect.Trgger_condition={} --触发条件=等于>大于》大于等于<小于《小于等于
-- {{条件,符号,值} ,{} }


SkillEffect.EffectObj=0        --生效的物体 
SkillEffect.EffectType={}    --技能效果类型 和下面对应
SkillEffect.EffectExactFml={}   --属性公式 {公式1 ,公式2 }
SkillEffect.TrunTimes=0  --每回合触发的次数, 现在只有0和1 ,0表示只有第一回合触发1表示每回合都触发
SkillEffect.MaxTimes="0"  --




return JNSkill