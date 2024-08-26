require("JNBattle/JNturnEffect")

require("Mgr/MgrTimer")
require("JNBattle/JNEffect")
require("LocalData/Special_effectLocalData")


--本回合特效表 ,回合结束特效表 因为回合结束的时候,下一个角色已经在攻击了
JNTurnEffectMgr={}

JNTurnEffectMgr.CreatCount = 0
JNTurnEffectMgr.LoadCount = 0
JNTurnEffectMgr.LoadCallBack = nil

--创建本局游戏需要的所有特效 提前计算的情况下不生成特效

function JNTurnEffectMgr.CeratAll(cell)
    if cell then
        JNTurnEffectMgr.LoadCallBack = cell
    else
        JNTurnEffectMgr.LoadCallBack = nil
    end

    CJNEffectShowMgr.CreatEffectPre(JNTurnEffectMgr.LuaCeratAll)
end

function  JNTurnEffectMgr.LuaCeratAll(_intk,_len)
    local tempEffectData={}
    JNTurnEffectMgr.CreatCount = _len
    JNTurnEffectMgr.LoadCount = 0
    for i = 0, _len-1, 1 do
        local value= _intk[i]
        if value==0 then
            -- statements
            JNTurnEffectMgr.LoadCount = JNTurnEffectMgr.LoadCount + 1
            -- print("zqx Creat_Id_Data:", JNTurnEffectMgr.LoadCount)
            if JNTurnEffectMgr.LoadCount == JNTurnEffectMgr.CreatCount then
                -- print("zqx LoadCallBack")
                if JNTurnEffectMgr.LoadCallBack then
                    JNTurnEffectMgr.LoadCallBack()
                end
            end
        else

            local tempId=tonumber(value)
            print(tempId)
            --根据id读取数据
            tempEffectData = Special_effectLocalData.tab[tempId]

            --创建各个数据然后生成
            local id=tonumber(tempEffectData[1])
            local  animated_type=  tonumber(tempEffectData[2])
            local  endtime=  tonumber(tempEffectData[3])
            local  EffectName=  tempEffectData[4]
            local  type=  tempEffectData[5]

            local  subtype= tonumber(tempEffectData[6])
            local  animation= tempEffectData[7]
            local  sound_delay=tonumber( tempEffectData[8])
            local  sound= tempEffectData[9]
            local  delay= tonumber(tempEffectData[10])

            local starting_point= tempEffectData[11]
            local starting_position= tempEffectData[12]
            local  end_object= tonumber(tempEffectData[13])
            local endpoint= tempEffectData[14]
            local end_position= tempEffectData[15]

            local  trajectory= tonumber(tempEffectData[16])
            local  effect_type= tonumber(tempEffectData[17])
            local  Flyingspeed= tonumber(tempEffectData[18])
            local angle= tempEffectData[19]
            local  speed= tonumber(tempEffectData[20])

            local size= tempEffectData[21]
            local exposure= tempEffectData[22]

            --解析所有value值
            CJNEffectShowMgr.Creat_Id_Data( id,  animated_type,  endtime,  EffectName,  type,
                    subtype,  animation,  sound_delay,  sound,  delay,
                    starting_point,  starting_position,  end_object,  endpoint,  end_position,
                    trajectory,  effect_type,  Flyingspeed,  angle,  speed,
                    size,exposure, function (id)
                        JNTurnEffectMgr.LoadCount = JNTurnEffectMgr.LoadCount + 1
                        -- print("zqx Creat_Id_Data:", JNTurnEffectMgr.LoadCount)
                        if JNTurnEffectMgr.LoadCount == JNTurnEffectMgr.CreatCount then
                            -- print("zqx LoadCallBack")
                            if JNTurnEffectMgr.LoadCallBack then
                                JNTurnEffectMgr.LoadCallBack()
                            end

                        end
                    end)
        end
    end
end


--本回合普攻特效
JNTurnEffectMgr.ThisTurnEffectS={}   --{JNturnEffect}
function JNTurnEffectMgr.GetEffects()
    return JNTurnEffectMgr.ThisTurnEffectS
end
--延迟
JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy={}
--本回合特效
JNTurnEffectMgr.EndTurnEffectS={}

--本回合动作表 

--本回合攻前技能特效表
JNTurnEffectMgr.ThisTurnEffectS_BeforAtk={}   --{JNturnEffect}
--本回合攻后技能特效表
JNTurnEffectMgr.JNTurnEffectMgr_AfterAtk={}   --{JNturnEffect}

--把第一个 类型为TimerType==3 buff循环的特效引用返回
--外部调用 添加一个特效            通用延迟,如果是多段攻击,把这个延迟累加  用逗号当前缀,所有后续技能都是,    攻击是否近战  特效id  攻击者id 受击者id  是否主要目标  后续特效id  后续特效的下标 上一个特效id
function  JNTurnEffectMgr.AddThisTurn(  _Delay , _prefixIsComma, _AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId ,_NextIndex,_LastId)
    --从表里查找id  

    if _TabNextEffectId==nil or _TabNextEffectId==0 then
        return
    end
    --  print(_TabNextEffectId)
    --   print(_NextIndex)
    --  for key, value in pairs(_TabNextEffectId) do
    --   for a, b in pairs(_TabNextEffectId[key]) do
    --  print(  key..","..a)
    --  print(_TabNextEffectId[key][a])
    -- end

    -- end
    if _TabNextEffectId[_NextIndex]==nil or _TabNextEffectId[_NextIndex][1]==nil or _TabNextEffectId[_NextIndex][1]==0 or _TabNextEffectId[_NextIndex][1]=="0" then
        -- 找不到退出
        return
    end

    local _EffectId=_TabNextEffectId[_NextIndex][1]

    --查找延迟
    local _tempDelay= _TabNextEffectId[_NextIndex][2]
    if _tempDelay==nil then
        _tempDelay=0
    end
    _NextIndex=_NextIndex+1
    _Delay=_Delay+_tempDelay/30
    local tempJNTrunEffect=JNturnEffect:new()
    tempJNTrunEffect.EffectId=_EffectId
    tempJNTrunEffect.AktRoleId=_AktRoleId
    tempJNTrunEffect.HitRoleId=_HitRoleId
    tempJNTrunEffect.IsMianTar=_IsMianTar
    --查询id  
    tempJNTrunEffect.LuaEffect=JNEffect:new(_EffectId,_AktRoleId,_HitRoleId)    --获取Special_effectLocalData表中所有该特效数据
    tempJNTrunEffect.LuaEffect.Delay=tempJNTrunEffect.LuaEffect.Delay+_Delay
    --如果是视频特效类型,跳过自己直接生成下一个
    if  tempJNTrunEffect.LuaEffect.AniType ==2 then
        return  JNTurnEffectMgr.AddThisTurn( _Delay,true ,_AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId , _NextIndex ,_EffectId )
    end

    --自身是否后续特效,后续特效查找上一个特效的延迟时间
    if _prefixIsComma==true then
        --查找同id的延迟记录
        local tempLastTime= JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy[_LastId]
        if tempLastTime~=nil then
            tempJNTrunEffect.LuaEffect.Delay=tempJNTrunEffect.LuaEffect.Delay+tempLastTime
        end
    end
    --如果不是受击特效,判断是否主要目标,否则不发动
    if _IsMianTar==false then
        if   tempJNTrunEffect.LuaEffect.TimerType== 2  then
            --直接下一步
            --   if _IsMianTar then
            --  print(_EffectId.."不加入队列".. tempJNTrunEffect.LuaEffect.FlyType.."真")
            --    else
            --   print(_EffectId.."不加入队列".. tempJNTrunEffect.LuaEffect.FlyType.."假")
            --  end

            --添加到本回合表
            --  table.insert(JNTurnEffectMgr.GetEffects(), tempJNTrunEffect)
            --   调用自己生成,直到下标里不存在特效
            return      JNTurnEffectMgr.AddThisTurn( _Delay,true ,_AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId , _NextIndex ,_EffectId )

        end
    end
    --视频特效也不加入队列
    if tempJNTrunEffect.LuaEffect.StartPosType==2 then
        --   调用自己生成,直到下标里不存在特效
        return JNTurnEffectMgr.AddThisTurn( _Delay,true ,_AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId , _NextIndex ,_EffectId )

    end

    --创建特效文件  
    tempJNTrunEffect.CEffect=CJNEffectShowMgr.CreatEffect()     --(一个空物体，上面挂着CJNEffectShow脚本)

    --传入Lua数据至C#
    -- print("初始化的时候"..tempJNTrunEffect.LuaEffect.Delay)
    tempJNTrunEffect.CEffect:InitCJnEffect(_AktRoleId   ,  _HitRoleId , tempJNTrunEffect.LuaEffect.Endtime ,
            tempJNTrunEffect.LuaEffect.AniType ,  tempJNTrunEffect.LuaEffect.Name  ,  tempJNTrunEffect.LuaEffect.AniName ,
            tempJNTrunEffect.LuaEffect.LocScale_X  ,  tempJNTrunEffect.LuaEffect.LocScale_Y  ,  tempJNTrunEffect.LuaEffect.LocScale_X  ,  tempJNTrunEffect.LuaEffect.StartPos_X  ,
            tempJNTrunEffect.LuaEffect.StartPos_Y  ,  tempJNTrunEffect.LuaEffect.StartPos_Z  ,  tempJNTrunEffect.LuaEffect.Rot_X  ,  tempJNTrunEffect.LuaEffect.Rot_Y  ,  tempJNTrunEffect.LuaEffect.Rot_Z  ,
            tempJNTrunEffect.LuaEffect.TimeScal  ,  tempJNTrunEffect.LuaEffect.Delay  ,  tempJNTrunEffect.LuaEffect.IsLoop  ,  tempJNTrunEffect.LuaEffect.StartPosType  ,  tempJNTrunEffect.LuaEffect.EndPosType  ,  tempJNTrunEffect.LuaEffect.EndPosOffsetType  ,
            tempJNTrunEffect.LuaEffect.EndPos_X  ,  tempJNTrunEffect.LuaEffect.EndPos_Y  ,  tempJNTrunEffect.LuaEffect.EndPos_Z  ,
            tempJNTrunEffect.LuaEffect.FlyType  ,  tempJNTrunEffect.LuaEffect.FlySpeed,  0  ,  0 ,tempJNTrunEffect.LuaEffect.Sound_delay,
            tempJNTrunEffect.LuaEffect.Sound

    )
    --设置自动销毁
    tempJNTrunEffect.CEffect:SetTimeType(tempJNTrunEffect.LuaEffect.TimerType)
    --设置Buff类型
    tempJNTrunEffect.CEffect:SetBuffType(tempJNTrunEffect.LuaEffect.Subtype)
    --创建实例
    tempJNTrunEffect.CEffect:InitEffect()
    local tempDealy= tempJNTrunEffect.CEffect:GetEffectLife()
    --是否有后续,有后续计算时间计算并生成后续特效以及延迟时间
    local NextEffid=_TabNextEffectId[_NextIndex]
    if NextEffid~=nil then
        --计算延迟

        --存id和时间
        JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy[_EffectId]=tempDealy
    else
        -- 接下来如果没有 了,记录延迟

    end
    --添加到本回合表
    table.insert(JNTurnEffectMgr.GetEffects(), tempJNTrunEffect)
    --如果自己TimerType==3 不再生产后续
    if  tempJNTrunEffect.LuaEffect.TimerType==3 then
        --  print(tempJNTrunEffect.LuaEffect.Id .. "--如果自己TimerType==3 不再生产后续".. tempJNTrunEffect.LuaEffect.TimerType)
        --设置特效Buff类型
        return  tempJNTrunEffect.CEffect
    end
    --   调用自己生成,直到下标里不存在特效
    return  JNTurnEffectMgr.AddThisTurn(_Delay,true ,_AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId , _NextIndex ,_EffectId )

end
--回合开始的时候清空
function JNTurnEffectMgr.ClearThisTurn()
    JNTurnEffectMgr.ThisTurnEffectS={}
    --延迟
    JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy={}
end

--播放本回合的特效 
function JNTurnEffectMgr.PlayThisTurn()
    local tempCout=0
    for key, value in pairs(JNTurnEffectMgr.GetEffects()) do
        tempCout=tempCout+1
        if   JNTurnEffectMgr.GetEffects()[key].CEffect~=nil then

            JNTurnEffectMgr.GetEffects()[key].CEffect:PlayAni()
        end

        --  JNTrunEffectMgr.Play()
    end
    -- print("  --JNTrunEffectMgr.Play()---     "..tempCout)
end

--替换若干特效                    传入新的id  需要被替换的id
function JNTurnEffectMgr.Replace(_ReEffectId, _BeReEffectId)
    for key, value in pairs(JNTurnEffectMgr.GetEffects()) do
        if JNTurnEffectMgr.GetEffects()[key].EffectId==_BeReEffectId then
            --仅仅替换文件
            --创建新的特效
        end
    end
end
--删除若干特效
function  JNTurnEffectMgr.DleId( _delId)
    local tempCanEnd=true
    for key, value in pairs(JNTurnEffectMgr.GetEffects()) do
        if JNTurnEffectMgr.GetEffects()[key].EffectId==_delId then
            JNTurnEffectMgr.delEff(JNTurnEffectMgr.GetEffects()[key])
            table.remove(JNTurnEffectMgr.GetEffects(),key)
            tempCanEnd=false
            break
        end
    end
    if tempCanEnd then

    else
        JNTurnEffectMgr.DleId( _delId)
    end

end
--删除一个特效
function  JNTurnEffectMgr.delEff(_eff)

end
--设置攻击者位置
function JNTurnEffectMgr.SetAtkPos(_posx, _posy, _posz)
    for key, value in pairs(JNTurnEffectMgr.GetEffects()) do
        JNTurnEffectMgr.GetEffects()[key].CEffect.SetVideoAtkPos(_posx, _posy, _posz)
    end
end

--设置受击者位置
function JNTurnEffectMgr.SetHitPos(_posx, _posy, _posz)
    for key, value in pairs(JNTurnEffectMgr.GetEffects()) do
        JNTurnEffectMgr.GetEffects()[key].CEffect.SetVideoHitPos(_posx, _posy, _posz)
    end
end

--传入一个基础延迟 和原有延迟叠加
function JNTurnEffectMgr.SetDelay(_delay)
    for key, value in pairs(JNTurnEffectMgr.GetEffects()) do
        JNTurnEffectMgr.GetEffects()[key].CEffect.SetDelay(_delay)
    end
end


JNTurnEffectMgr.ThisTurnIndex=0
function JNTurnEffectMgr.Play()

    JNTurnEffectMgr.ThisTurnIndex=JNTurnEffectMgr.ThisTurnIndex+1
    local _delay=JNTurnEffectMgr.GetEffects()[JNTurnEffectMgr.ThisTurnIndex].DealyTime
    MgrTimer.AddDelayNoName(_delay,JNTurnEffectMgr.TimePlay ,nil)
end

function JNTurnEffectMgr.TimePlay()
    JNTurnEffectMgr.GetEffects()[JNTurnEffectMgr.ThisTurnIndex].CEffect:PlayAni()
end
--创建配合动作的特效
function JNTurnEffectMgr.CreatEffTo_Action( _Delay , _prefixIsComma, _AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId ,_NextIndex,_LastId,_ActionType,_NotInSound) -- 1登场动作 2--死亡动作 3--眩晕动作 4--受击动作
    --从表里查找id

    if _TabNextEffectId==nil or _TabNextEffectId==0 then
        return
    end

    if _TabNextEffectId[_NextIndex]==nil or _TabNextEffectId[_NextIndex][1]==nil or _TabNextEffectId[_NextIndex][1]==0 or _TabNextEffectId[_NextIndex][1]=="0" then
        -- 找不到退出
        return
    end

    local _EffectId=_TabNextEffectId[_NextIndex][1]

    --查找延迟
    local _tempDelay= _TabNextEffectId[_NextIndex][2]
    if _tempDelay==nil then
        _tempDelay=0
    end
    _NextIndex=_NextIndex+1
    _Delay=_Delay+_tempDelay/30
    local tempJNTrunEffect=JNturnEffect:new()
    --print("创建的id---------" .._EffectId)
    tempJNTrunEffect.EffectId=_EffectId
    tempJNTrunEffect.AktRoleId=_AktRoleId
    tempJNTrunEffect.HitRoleId=_HitRoleId
    tempJNTrunEffect.IsMianTar=_IsMianTar
    --查询id
    tempJNTrunEffect.LuaEffect=JNEffect:new(_EffectId,_AktRoleId,_HitRoleId)
    tempJNTrunEffect.LuaEffect.Delay=tempJNTrunEffect.LuaEffect.Delay+_Delay


    --自身是否后续特效,后续特效查找上一个特效的延迟时间
    if _prefixIsComma==true then
        --查找同id的延迟记录
        local tempLastTime= JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy[_LastId]
        if tempLastTime~=nil then
            tempJNTrunEffect.LuaEffect.Delay=tempJNTrunEffect.LuaEffect.Delay+tempLastTime
        end
    end
    --创建特效文件
    tempJNTrunEffect.CEffect=CJNEffectShowMgr.CreatEffect()
    local sound=  tempJNTrunEffect.LuaEffect.Sound
    local sound_delay=tempJNTrunEffect.LuaEffect.Sound_delay
    if _NotInSound  then
        sound_delay=0
        sound="0"
    end
    -- print("初始化的时候"..tempJNTrunEffect.LuaEffect.Delay)
    tempJNTrunEffect.CEffect:InitCJnEffect(_AktRoleId   ,  _HitRoleId , tempJNTrunEffect.LuaEffect.Endtime ,
            tempJNTrunEffect.LuaEffect.AniType ,  tempJNTrunEffect.LuaEffect.Name  ,  tempJNTrunEffect.LuaEffect.AniName ,
            tempJNTrunEffect.LuaEffect.LocScale_X  ,  tempJNTrunEffect.LuaEffect.LocScale_Y  ,  tempJNTrunEffect.LuaEffect.LocScale_X  ,  tempJNTrunEffect.LuaEffect.StartPos_X  ,
            tempJNTrunEffect.LuaEffect.StartPos_Y  ,  tempJNTrunEffect.LuaEffect.StartPos_Z  ,  tempJNTrunEffect.LuaEffect.Rot_X  ,  tempJNTrunEffect.LuaEffect.Rot_Y  ,  tempJNTrunEffect.LuaEffect.Rot_Z  ,
            tempJNTrunEffect.LuaEffect.TimeScal  ,  tempJNTrunEffect.LuaEffect.Delay  ,  tempJNTrunEffect.LuaEffect.IsLoop  ,  tempJNTrunEffect.LuaEffect.StartPosType  ,  tempJNTrunEffect.LuaEffect.EndPosType  ,  tempJNTrunEffect.LuaEffect.EndPosOffsetType  ,
            tempJNTrunEffect.LuaEffect.EndPos_X  ,  tempJNTrunEffect.LuaEffect.EndPos_Y  ,  tempJNTrunEffect.LuaEffect.EndPos_Z  ,
            tempJNTrunEffect.LuaEffect.FlyType  ,  tempJNTrunEffect.LuaEffect.FlySpeed,  0  ,  0 , tempJNTrunEffect.LuaEffect.StartPosStr,sound_delay,
            sound
    )
    --设置自动销毁
    tempJNTrunEffect.CEffect:SetTimeType(tempJNTrunEffect.LuaEffect.TimerType)
    --设置子类型
    tempJNTrunEffect.CEffect:SetBuffType(tempJNTrunEffect.LuaEffect.Subtype)
    --创建实例
    tempJNTrunEffect.CEffect:InitEffect()
    --赋值给角色
    tempJNTrunEffect.CEffect:SetFollowAni(_ActionType)

    local tempDealy= tempJNTrunEffect.CEffect:GetEffectLife()
    --是否有后续,有后续计算时间计算并生成后续特效以及延迟时间
    local NextEffid=_TabNextEffectId[_NextIndex]
    if NextEffid~=nil then
        --计算延迟
        --存id和时间
        JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy[_EffectId]=tempDealy
    else
        -- 接下来如果没有 了,记录延迟
    end
    --   调用自己生成,直到下标里不存在特效
    return  JNTurnEffectMgr.AddThisTurn(_Delay,true ,_AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId , _NextIndex ,_EffectId )

end

--创建特效并且播放
function JNTurnEffectMgr.CreatEffTo_Action_Show( _Delay , _prefixIsComma, _AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId ,_NextIndex,_LastId,_ActionType,_NotInSound) -- 1登场动作 2--死亡动作 3--眩晕动作 4--受击动作
    if _TabNextEffectId==nil or _TabNextEffectId==0 then
        return
    end
    --从表里查找id
    if _TabNextEffectId[_NextIndex]==nil or _TabNextEffectId[_NextIndex][1]==nil or _TabNextEffectId[_NextIndex][1]==0 or _TabNextEffectId[_NextIndex][1]=="0" then
        return
    end
    --特效ID
    local _EffectId=_TabNextEffectId[_NextIndex][1]
    --查找延迟
    local _tempDelay= _TabNextEffectId[_NextIndex][2]
    if _tempDelay==nil then
        _tempDelay=0
    end
    _NextIndex=_NextIndex+1
    _Delay=_Delay+_tempDelay/30
    local tempJNTrunEffect=JNturnEffect:new()
    --print("创建的id---------" .._EffectId)
    tempJNTrunEffect.EffectId=_EffectId
    tempJNTrunEffect.AktRoleId=_AktRoleId
    tempJNTrunEffect.HitRoleId=_HitRoleId
    tempJNTrunEffect.IsMianTar=_IsMianTar
    --查询id，读表获取Lua特效数据
    tempJNTrunEffect.LuaEffect=JNEffect:new(_EffectId,_AktRoleId,_HitRoleId)
    tempJNTrunEffect.LuaEffect.Delay=tempJNTrunEffect.LuaEffect.Delay+_Delay
    --自身是否后续特效,后续特效查找上一个特效的延迟时间
    if _prefixIsComma==true then
        --查找同id的延迟记录
        local tempLastTime= JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy[_LastId]
        if tempLastTime~=nil then
            tempJNTrunEffect.LuaEffect.Delay=tempJNTrunEffect.LuaEffect.Delay+tempLastTime
        end
    end
    --创建特效文件
    tempJNTrunEffect.CEffect=CJNEffectShowMgr.CreatEffect() --CJNEffectShow C#
    local sound=  tempJNTrunEffect.LuaEffect.Sound
    local sound_delay=tempJNTrunEffect.LuaEffect.Sound_delay
    if _NotInSound  then
        sound_delay=0
        sound="0"
    end
    --传数据给C#
    tempJNTrunEffect.CEffect:InitCJnEffect_gaming(_AktRoleId   ,  _HitRoleId , tempJNTrunEffect.LuaEffect.Endtime ,
            tempJNTrunEffect.LuaEffect.AniType ,  tempJNTrunEffect.LuaEffect.Name  ,  tempJNTrunEffect.LuaEffect.AniName ,
            tempJNTrunEffect.LuaEffect.LocScale_X  ,  tempJNTrunEffect.LuaEffect.LocScale_Y  ,  tempJNTrunEffect.LuaEffect.LocScale_X  ,  tempJNTrunEffect.LuaEffect.StartPos_X  ,
            tempJNTrunEffect.LuaEffect.StartPos_Y  ,  tempJNTrunEffect.LuaEffect.StartPos_Z  ,  tempJNTrunEffect.LuaEffect.Rot_X  ,  tempJNTrunEffect.LuaEffect.Rot_Y  ,  tempJNTrunEffect.LuaEffect.Rot_Z  ,
            tempJNTrunEffect.LuaEffect.TimeScal  ,  tempJNTrunEffect.LuaEffect.Delay  ,  tempJNTrunEffect.LuaEffect.IsLoop  ,  tempJNTrunEffect.LuaEffect.StartPosType  ,  tempJNTrunEffect.LuaEffect.EndPosType  ,  tempJNTrunEffect.LuaEffect.EndPosOffsetType  ,
            tempJNTrunEffect.LuaEffect.EndPos_X  ,  tempJNTrunEffect.LuaEffect.EndPos_Y  ,  tempJNTrunEffect.LuaEffect.EndPos_Z  ,
            tempJNTrunEffect.LuaEffect.FlyType  ,  tempJNTrunEffect.LuaEffect.FlySpeed,  0  ,  0 , tempJNTrunEffect.LuaEffect.StartPosStr,sound_delay,
            sound
    )
    --设置自动销毁
    tempJNTrunEffect.CEffect:SetTimeType(tempJNTrunEffect.LuaEffect.TimerType)
    --设置子类型
    tempJNTrunEffect.CEffect:SetBuffType(tempJNTrunEffect.LuaEffect.Subtype)
    --创建实例  用上面传的数据
    tempJNTrunEffect.CEffect:InitEffect()
    --赋值给角色
    tempJNTrunEffect.CEffect:SetFollowAni(_ActionType)

    tempJNTrunEffect.CEffect:PlayAni()

    local tempDealy= tempJNTrunEffect.CEffect:GetEffectLife()
    --是否有后续,有后续计算时间计算并生成后续特效以及延迟时间
    local NextEffid=_TabNextEffectId[_NextIndex]
    if NextEffid~=nil then
        --计算延迟
        --存id和时间
        JNTurnEffectMgr.ThisTurnEffectS_IdAndDealy[_EffectId]=tempDealy
    else
        -- 接下来如果没有 了,记录延迟
    end
    --   调用自己生成,直到下标里不存在特效
    return  JNTurnEffectMgr.AddThisTurn(_Delay,true ,_AktRoleId, _HitRoleId,_IsMianTar, _TabNextEffectId , _NextIndex ,_EffectId )

end

return JNTurnEffectMgr