--引用
require("JNBattle/BattleRole")
require("JNBattle/JNStrTool")
require("ReadData/CollectionData")
require("LocalData/RoleattrilevelLocalData")
require("LocalData/MonsterLocalData")
require("LocalData/CharactercoordinatesLocalData")
-- 文件名为 ReadData.lua
-- 定义一个名为 ReadData 的模块
ReadData = {}
ReadData.LVMAX=100  --最大等级
--第一次创建的时候解析经验公式
ReadData.First=true
ReadData.Exp_R1={}  --{ "{lv}^1.95*（{dqstar}-1)+50" ,"{lv}^1.95*（{dqstar}-1)+50"}
ReadData.Exp_R2={}
ReadData.Exp_R3={}
ReadData.Exp_R4={}
--吃经验的时候金币消耗比例
ReadData.ExpCCoin=1
function ReadData.CeratExp()
    if ReadData.First==true then
        ReadData.First=false
        --金币消耗率
        ReadData.ExpCCoin=tonumber(RoleattrilevelLocalData.tab[1][8])  
       
        --仅在第一次解析
        --print("  --仅在第一次解析")
        ReadData.CreatFetters()

        ReadData.Exp_R1[1]=RoleattrilevelLocalData.tab[1][5]
        ReadData.Exp_R1[2]=RoleattrilevelLocalData.tab[2][5]
        ReadData.Exp_R1[3]=RoleattrilevelLocalData.tab[3][5]
        ReadData.Exp_R1[4]=RoleattrilevelLocalData.tab[4][5]
        ReadData.Exp_R1[5]=RoleattrilevelLocalData.tab[5][5]
        ReadData.Exp_R1[6]=RoleattrilevelLocalData.tab[6][5]
      
        ReadData.Exp_R2[1]= RoleattrilevelLocalData.tab[7][5]
        ReadData.Exp_R2[2]= RoleattrilevelLocalData.tab[8][5]
        ReadData.Exp_R2[3]= RoleattrilevelLocalData.tab[9][5]
        ReadData.Exp_R2[4]= RoleattrilevelLocalData.tab[10][5]
        ReadData.Exp_R2[5]= RoleattrilevelLocalData.tab[11][5]
        ReadData.Exp_R2[6]= RoleattrilevelLocalData.tab[12][5]

        ReadData.Exp_R3[1]= RoleattrilevelLocalData.tab[13][5]
        ReadData.Exp_R3[2]= RoleattrilevelLocalData.tab[14][5]
        ReadData.Exp_R3[3]= RoleattrilevelLocalData.tab[15][5]
        ReadData.Exp_R3[4]= RoleattrilevelLocalData.tab[16][5]
        ReadData.Exp_R3[5]= RoleattrilevelLocalData.tab[17][5]
        ReadData.Exp_R3[6]= RoleattrilevelLocalData.tab[18][5]

        ReadData.Exp_R4[1]= RoleattrilevelLocalData.tab[19][5]
        ReadData.Exp_R4[2]= RoleattrilevelLocalData.tab[20][5]
        ReadData.Exp_R4[3]= RoleattrilevelLocalData.tab[21][5]
        ReadData.Exp_R4[4]= RoleattrilevelLocalData.tab[22][5]
        ReadData.Exp_R4[5]= RoleattrilevelLocalData.tab[23][5]
        ReadData.Exp_R4[6]= RoleattrilevelLocalData.tab[24][5]
    end
end
function ReadData.SetExp(tempRole)
    if tempRole.Rank==1 then
        tempRole.LvMax=RoleattrilevelLocalData.tab[tempRole.StartLV][4]
        tempRole.ExpFormula= ReadData.Exp_R1[tonumber(tempRole.StartLV) ]
    elseif tempRole.Rank==2 then
        tempRole.LvMax=RoleattrilevelLocalData.tab[tempRole.StartLV+6][4]
        tempRole.ExpFormula=ReadData.Exp_R2[tonumber(tempRole.StartLV)]
    elseif  tempRole.Rank==3 then
        tempRole.LvMax=RoleattrilevelLocalData.tab[tempRole.StartLV+12][4]
        tempRole.ExpFormula=ReadData.Exp_R3[tonumber(tempRole.StartLV)]
    elseif  tempRole.Rank==4 then
        tempRole.LvMax=RoleattrilevelLocalData.tab[tempRole.StartLV+18][4]
        tempRole.ExpFormula=ReadData.Exp_R4[tonumber(tempRole.StartLV)]
    end
 end
--解析羁绊
function ReadData.CreatFetters()
    -- ReadData.Tab_Tab_fetters={}
    -- for k, v in pairs(GameData.tab.fetters) do
    --     --保存所有的组合
    --     local temptab={}
    --     temptab.id=tonumber(v[1])
    --     temptab.type=tonumber(v[4])
    --     temptab.number=tonumber(v[5])
    --     temptab.overflow=tonumber(v[6])
    --     temptab.skill={}
    --     --解析技能效果
    --     local tempArr=JNStrTool.strSplit(";", v[7])
    --     for key, value in pairs(tempArr) do
    --         if value=="" then
    --         else
    --             --  print(value)
    --             --按照 ,
    --             local tempLvAndValue=JNStrTool.strSplit(",", value)
    --             local tempSkillTab={}
    --             tempSkillTab.lv=tonumber(tempLvAndValue[1])
    --             -- print( tempLvAndValue[2])
    --             local skilltype_value=JNStrTool.strSplit("_",  tempLvAndValue[2])
    --             tempSkillTab.skilltype=tonumber(skilltype_value[1])
    --             tempSkillTab.skillvlaue=tonumber(skilltype_value[2])
    --             --是否还有后续
    --             table.insert(temptab.skill, tempSkillTab)
    --             --  print(  " --是否还有后续")
    --         end
    --     end
    --     --  print(  " --解析所有人的id")
    --     --解析所有人的id
    --     temptab.Zid= JNStrTool.strSplit(",",  v[9])
    --     -- print( v[9].. " --解析所有人的id")
    --     table.insert(ReadData.Tab_Tab_fetters, temptab)
    --end
end
--------------------Tab_fetters id--- {id,id,id}组合成员--- 技能文本
ReadData.Tab_Tab_fetters={}
-- ReadData.Tab_fetters.Zid={}  --组合id{id,id,id}
-- ReadData.Tab_fetters.txt="" --说明文本
-- ReadData.Tab_fetters.skill={}     --1固定攻击 ,2攻击力 3固定血量 4生命值百分比
-- ReadData.Tab_fetters.skill.lv=2
-- ReadData.Tab_fetters.skill.skilltype=2
-- ReadData.Tab_fetters.overflow=0.25
-- ReadData.Tab_fetters.number=0.25    --能量槽数量
-- ReadData.Tab_fetters.type=1     --组合技能类型 1协力攻击 2永久增加属性
--id ,等级,星级,技能等级 ,是否觉醒,额外技能1,额外技能2
---核心和共鸣装备都是自己的数据
function ReadData.CreatRole(GameDataID,skinID,lv,startLV,skillLV,Bool_isAwaken,favor,isPVPRoleOrFriendRole,equipUnlockLV)
    ReadData.CeratExp()
    print("----------------------------------------------------")
    print(GameDataID)
    print(Bool_isAwaken)
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    local tFavorData = HeroControl.GetCurFavorAbility(GameDataID,favor)
    --根据 GameDataID读表
    local TempId = ""..GameDataID
    local RoleRData = RoleattributeLocalData.tab[tonumber(GameDataID)]
    local skinData = RoleuiskinLocalData.tab[(tonumber(skinID) ~= 0 and skinID ~= nil) and tonumber(skinID) or tonumber(GameDataID)]
    --根据id 等级星级 生成角色
    local  tempRole=BattleRole:new()
    tempRole.Remove=false
    if skinID then
        tempRole.SkinID = skinID
    else
        tempRole.SkinID = tonumber(GameDataID)
    end
    tempRole.AtkOrder=0

    --音效
    tempRole.Str_Audio=skinData.interaction
    tempRole.AllNumber_Out=0
    tempRole.AllNumber_In=0
    tempRole.AllHPNumber_Out=0
    tempRole.AllHPNumber_In=0
    tempRole.ID=TempId
    tempRole.IsMonster=false
    --设定  星级等级
    tempRole.StartLV=startLV
    tempRole.LV=lv
    if isPVPRoleOrFriendRole then
        tempRole.SkillLV=tonumber(skillLV)
        if equipUnlockLV == true then
            tempRole.ShowSkillLV=tonumber(skillLV) + 1
        else
            tempRole.ShowSkillLV=tonumber(skillLV)
        end
    else
        if equipUnlockLV == true then
            tempRole.SkillLV=tonumber(skillLV) - 1
        else
            tempRole.SkillLV=tonumber(skillLV)
        end
        tempRole.ShowSkillLV=tonumber(skillLV)
    end
    tempRole.Name = RoleRData[2]
    tempRole.Occupation=tonumber(RoleRData[5])  --转换成数字
    tempRole.Rank=tonumber(RoleRData[6])--品阶
    tempRole.iconBattleFrame = "Quality/RoleRankN_"..RoleRData[6]
    tempRole.iconCareer = "Attribute/ProIcon_"..RoleRData[5]
    tempRole.Icon=RoleRData[7]
    tempRole.Rolepicturespine=RoleRData[8]
    --立绘偏移xy
    local tempTbaXY=JNStrTool.strSplit(",",skinData.coordinate)
    tempRole.Rolepicturespine_X=tonumber(tempTbaXY[1])
    tempRole.Rolepicturespine_Y=tonumber(tempTbaXY[2])
    --Q版动画名称
    --tempRole.AniName=RoleRData[10]
    --普通攻击帧数
    tempRole.SetGeneralattack(RoleRData[11],tempRole)

    tempRole.ZJShake = {}
    tempRole.EXShake = {}
    for i ,v in pairs(SkillLocalData.tab) do
        local str1 = string.split(v[3],";")
        if v[40] == tonumber(GameDataID) and v[3] ~= "0"and str1[2] ~= nil then
            if string.split(str1[1],"_")[1] == "zj" then    --追击动作震动
                local shake = string.split(str1[2],',')
                for j = 1, #shake do
                    tempRole.ZJShake[j] = string.split(shake[j],'_')
                end
            elseif string.split(str1[1],"_")[1] == "0" then --ex动作震动
                local shake = string.split(str1[2],',')
                for j = 1, #shake do
                    tempRole.EXShake[j] = string.split(shake[j],'_')
                end
            end
        end
    end
    --EX角色立绘位置
    tempRole.EXCutInPos = CharactercoordinatesLocalData.tab[tempRole.SkinID].coordinate7
    --身体位置 中间
    local tempBodyPos=JNStrTool.strSplit( ",",skinData.midposition)
    tempRole.MidPos_X=tempBodyPos[1]
    tempRole.MidPos_Y=tempBodyPos[2]
    --身体位置 头顶
    tempBodyPos=JNStrTool.strSplit(",",skinData.topposition)
    tempRole.TopPos_X=tempBodyPos[1]
    tempRole.TopPos_Y=tempBodyPos[2]
    --底部
    tempBodyPos=JNStrTool.strSplit(",",skinData.bottomposition)
    tempRole.DownPos_X=tempBodyPos[1]
    tempRole.DownPos_Y=tempBodyPos[2]

    --普攻特效ID
    tempRole.AtkEffectId_str = skinData.buffplacer
    tempRole.AtkEffectId = JNStrTool.SubAtkEffectId(skinData.buffplacer)
    --登场特效id
    tempRole.DebutEffectId_str = skinData.debut
    tempRole.DebutEffectId=JNStrTool.SubAtkEffectId(skinData.debut)
    --死亡动作特效
    tempRole.DeathEffectId_str = skinData.death
    tempRole.DeathEffectId=JNStrTool.SubAtkEffectId(skinData.death)
    --眩晕
    tempRole.VertigoEffectId_str = skinData.vertigo
    tempRole.VertigoEffectId = JNStrTool.SubAtkEffectId(skinData.vertigo)
    --受击
    tempRole.HitEffectId_str = skinData.hit
    tempRole.HitEffectId = JNStrTool.SubAtkEffectId(skinData.hit)
    --追击特效ID
    tempRole.ZJEffectId_str = skinData.zjeffect
    tempRole.ZJEffectId = JNStrTool.SubAtkEffectId(skinData.zjeffect)
    --跑动
    tempRole.PD0EffectId_str = skinData.pd_1
    tempRole.PD1EffectId_str = skinData.pd_2
    tempRole.HC1EffectId_str = skinData.hc_1
    tempRole.HC2EffectId_str = skinData.hc_2


    tempRole.Qzoom = skinData.qzoom
    tempRole.MinStart = tonumber(RoleRData[21])
    tempRole.MaxStart = tonumber(RoleRData[22])
    -- 飞行入场的数据
    BattleRole.SubFlyIn(tempRole, skinData.admission)
    --攻击方式
    tempRole.Attackmode = tonumber(RoleRData[24])
    tempRole.Casteranimation = tonumber(RoleRData[25])
    --攻击招式
    tempRole.AtkName = skinData.attackname
    --角色简介
    tempRole.Attackdescription = RoleRData[27]
    --觉醒
    tempRole.IsAwaken=Bool_isAwaken
    print(Bool_isAwaken)
    tempRole.StSAwaken(RoleRData[28],tempRole)
    --血量
    tempRole.StSHP(RoleRData[29],tempRole,nil,tFavorData)
    --攻击力

    tempRole.StSAtk(RoleRData[30], tempRole, tFavorData)
    tempRole.StSDef(RoleRData[31], tempRole, tFavorData)
    BattleRole.SetSCrit(tempRole ,tonumber(RoleRData[32]), tFavorData)
    tempRole.StSAgile(RoleRData[33], tempRole, tFavorData)
    BattleRole.SetSCritDMG(tempRole,tonumber(RoleRData[34]), tFavorData)
    tempRole.Attacktarget=tonumber(RoleRData[35])
    tempRole.AtkTargetTips = ReadData.GetAtkTargetTips(RoleRData[35])
    tempRole.StSAtkRange(RoleRData[36],tempRole)  --攻击范围
    --技能
    tempRole.StSSkillLvReal(RoleRData[37],RoleRData[38],RoleRData[39],RoleRData[40],RoleRData[41],tempRole)
    tempRole.SubAwaken(tempRole)
    --清空被赋予的技能
    tempRole.AftTurnAbtChangeSkills={}
    tempRole.AftTurnDotSkills={}
    tempRole.GotBefAtkSkills={}
    tempRole.GotBefHitSkills={}  --受到攻击前
    tempRole.GotAftHitSkills={}  --受到攻击后
    tempRole.GotAftAtkSkills={}  --攻击后
    tempRole.GotOnDeathSkills={}       --自身死亡的时候立即触发,选目标释放技能,然后继续执行技能链
    tempRole.GotOnSupportSkills={}       --支援时
    tempRole.AftTurnBackSkills={}
    --ex技能

    --进攻距离参数
    tempRole.Attackdistance=tonumber(skinData.attackdistance)
    --前冲速度
    tempRole.ForwardType=tonumber(RoleRData[46])
    --后撤速度
    tempRole.BackType=tonumber(RoleRData[47])
    --跳跃高度
    tempRole.TimeNext=tonumber(RoleRData[48])
    --Q版头像
    tempRole.Icon_q=RoleRData[49]
    --攻前动作
    tempRole.NameBefor=tonumber(RoleRData[50])
    tempRole.NameAfter=tonumber(RoleRData[51])
    --EX位置信息
    --local tempstr=RoleRData[55]
    --local tempArr=JNStrTool.strSplit(",",tempstr)
    --tempRole.EXpos_x= tonumber(tempArr[1])
    --tempRole.EXpos_y= tonumber(tempArr[2])
    --tempRole.EXpos_Size= tonumber(tempArr[3])
    --tempRole.EXpos_rx= tonumber(tempArr[4])
    --tempRole.EXpos_ry= tonumber(tempArr[5])
    --tempRole.EXpos_rz= tonumber(tempArr[6])
    ReadData.SetMabt(tempRole)
    --设置自己的核心
    if isPVPRoleOrFriendRole == nil then
        ReadData.SetAllFw_attr(tempRole)
    end
    --子弹飞行速度
    tempRole.Bulletvelocity = skinData.bulletvelocity
    --蓄力特效
    tempRole.ReadyEffectId_str = skinData.ready
    -- 64震动
    tempRole.Shake = skinData.strike

    --命中延迟
    tempRole.Show_Delay={}
    --分段比例
    tempRole.Show_Number={}
    local tempShake=tostring(skinData.delay,"0")
    if tempShake=="0" then
        tempRole.Show_Delay[0]=0
        tempRole.Show_Number[0]=0
    else
        local tempArr=JNStrTool.strSplit(",",tempShake)
        for key_A1, value_A1 in pairs(tempArr) do
            local tempArr_2= JNStrTool.strSplit("_",value_A1)
            tempRole.Show_Delay[key_A1]=tonumber(tempArr_2[1])
            tempRole.Show_Number[key_A1]  =tonumber(tempArr_2[2])
        end
    end
    --经验值 Rank
    ReadData.SetExp(tempRole)
    tempRole.StSExp(tempRole.ExpFormula,tempRole)
    BattleRole.SubExp(tempRole)
    return tempRole
end
--创建一个没技能的角色
--[[function ReadData.CreatRole_NoSkill(GameDataID,skinID, lv, startLV, skillLV, Bool_isAwaken )
    ReadData.CeratExp()
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    --根据 GameDataID读表
    local TempId = ""..GameDataID
    local RoleRData=RoleattributeLocalData.tab[ tonumber(GameDataID) ]
    local skinData = RoleuiskinLocalData.tab[tonumber(skinID)]

    --根据id 等级星级 生成角色
    local  tempRole=BattleRole:new()
    if skinID then
        tempRole.SkinID = skinID
    else
        tempRole.SkinID = tonumber(GameDataID)
    end
    tempRole.AllNumber_Out=0
    tempRole.AllNumber_In=0
    tempRole.AllHPNumber_Out=0
    tempRole.AllHPNumber_In=0
    tempRole.ID=TempId
    tempRole.IsMonster=false
    tempRole.StartLV=startLV
    tempRole.LV=lv
    tempRole.SkillLV=skillLV
    tempRole.ShowSkillLV=skillLV+1

    local tempIndex=2
    tempRole.Name=RoleRData[2]

    tempIndex=5
    tempRole.Occupation=tonumber(RoleRData[5])  --转换成数字
    tempRole.Rank=tonumber(RoleRData[6])--品阶

    tempIndex=7
    tempRole.Icon=RoleRData[7]
    tempRole.Rolepicturespine=RoleRData[8]
    --立绘偏移xy
    local tempTbaXY=JNStrTool.strSplit(",",RoleRData[9])
    tempRole.Rolepicturespine_X=tonumber(tempTbaXY[1])
    tempRole.Rolepicturespine_Y=tonumber(tempTbaXY[2])

    tempRole.AniName=RoleRData[10]
    tempRole.SetGeneralattack(RoleRData[11],tempRole)

    tempRole.Qzoom=RoleRData[20]
    tempRole.MinStart=tonumber(RoleRData[21])
    tempRole.MaxStart=tonumber(RoleRData[22])
    tempRole.Attackmode=tonumber(RoleRData[24])
    tempRole.Casteranimation=tonumber(RoleRData[25])

    tempRole.AtkName=RoleRData[26]
    --角色简介
    tempRole.Attackdescription=RoleRData[27]
    --觉醒
    tempRole.IsAwaken=Bool_isAwaken
    tempRole.StSAwaken(RoleRData[28],tempRole)
    tempRole.StSHP(RoleRData[29],tempRole)
    tempRole.StSAtk(RoleRData[30], tempRole)
    tempRole.StSDef(RoleRData[31], tempRole)
    BattleRole.SetCrit(tempRole ,tonumber(RoleRData[32]))
    tempRole.StSAgile(RoleRData[33], tempRole)
    BattleRole.SetCritDMG(tempRole,tonumber(RoleRData[34]))
    tempRole.Attacktarget=tonumber(RoleRData[35])
    tempRole.AtkTargetTips = ReadData.GetAtkTargetTips(RoleRData[36])

    tempRole.StSAtkRange(RoleRData[37],tempRole)  --攻击范围
    tempRole.SubAwaken(tempRole)--计算觉醒属性

    tempRole.Attackdistance=tonumber(RoleRData[45])
    tempRole.ForwardType=tonumber(RoleRData[46])
    tempRole.BackType=tonumber(RoleRData[47])
    tempRole.TimeNext=tonumber(RoleRData[48])
    --Q版头像
    tempRole.Icon_q=RoleRData[49]
    --攻前动作
    tempRole.NameBefor=tonumber( RoleRData[50])
    tempRole.NameAfter=tonumber(RoleRData[51])
    ReadData.SetMabt(tempRole)

    --经验值 Rank
    ReadData.SetExp( tempRole )
    tempRole.StSExp(tempRole.ExpFormula,tempRole)
    BattleRole.SubExp(tempRole)
    return tempRole
end]]
--创建怪物 读表不全一样 额外需要一个缩放
function ReadData.CreatMonster(GameDataID,lv,startLV,skillLV,Bool_isAwaken,_qoom,int_atkOrder)
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    --根据 GameDataID读表
    local TempId = ""..GameDataID
    local RoleRData=MonsterLocalData.tab[tonumber(GameDataID)]

    --根据id 等级星级 生成角色
    local  tempRole=BattleRole:new()
    --if Bool_AddSkillLv then
    --    skillLV=skillLV+1
    --    tempRole.Bool_AddSkillLv=true
    --end
    tempRole.Str_Audio=RoleRData[61]
    tempRole.AtkOrder=int_atkOrder
    tempRole.AllNumber_Out=0
    tempRole.AllNumber_In=0
    tempRole.AllHPNumber_Out=0
    tempRole.AllHPNumber_In=0
    tempRole.IsMonster=true
    -- print("当前id--------------------------".. tempRole.ID)
    tempRole.ID=TempId
    --设定  星级等级
    tempRole.StartLV=startLV
    tempRole.LV=lv
    --   print( "dengji"..tempRole.LV)
    tempRole.SkillLV=tonumber(skillLV)

    tempRole.ShowSkillLV=tonumber(skillLV)

    --震动
    tempRole.ZJShake = {}
    tempRole.EXShake = {}
    for i ,v in pairs(SkillLocalData.tab) do
        local str1 = string.split(v[3],";")
        if v[40] == tonumber(GameDataID) and v[3] ~= "0"and str1[2] ~= nil then
            if string.split(str1[1],"_")[1] == "zj" then    --追击动作震动
                local shake = string.split(str1[2],',')
                for j = 1, #shake do
                    tempRole.ZJShake[j] = string.split(shake[j],'_')
                end
            elseif string.split(str1[1],"_")[1] == "0" then --ex动作震动
                local shake = string.split(str1[2],',')
                for j = 1, #shake do
                    tempRole.EXShake[j] = string.split(shake[j],'_')
                end
            end
        end
    end
    --EX角色立绘位置
    if CharactercoordinatesLocalData.tab[tonumber(GameDataID)] then
        tempRole.EXCutInPos = CharactercoordinatesLocalData.tab[tonumber(GameDataID)].coordinate7
    end
    local tempIndex=2
    tempRole.Name=RoleRData[2]
    tempIndex=tempIndex+1

    tempRole.Occupation=tonumber(RoleRData[3])  --转换成数字
    --品阶未读
    tempRole.Icon=RoleRData[4]
    tempRole.Rolepicturespine=RoleRData[5]

    tempRole.iconCareer = "Attribute/ProIcon_"..RoleRData[3]
    tempRole.iconBattleFrame = "Quality/RoleRankN_"..RoleRData[18]
    --立绘偏移xy
    local tempTbaXY=JNStrTool.strSplit(",",RoleRData[6])
    tempRole.Rolepicturespine_X=tonumber(tempTbaXY[1])
    tempRole.Rolepicturespine_Y=tonumber(tempTbaXY[2])
    tempRole.AniName=RoleRData[7]
    tempRole.SetGeneralattack(RoleRData[8],tempRole)
    --身体位置 中间
    local tempBodyPos=JNStrTool.strSplit( ",",RoleRData[9])
    tempRole.MidPos_X=tempBodyPos[1]
    tempRole.MidPos_Y=tempBodyPos[2]
    --身体位置 头顶
    tempBodyPos=JNStrTool.strSplit(",",RoleRData[10])
    tempRole.TopPos_X=tempBodyPos[1]
    tempRole.TopPos_Y=tempBodyPos[2]
    --底部
    tempBodyPos=JNStrTool.strSplit(",",RoleRData[11])
    tempRole.DownPos_X=tempBodyPos[1]
    tempRole.DownPos_Y=tempBodyPos[2]

    --普攻特效ID
    tempRole.AtkEffectId_str=RoleRData[12]
    tempRole.AtkEffectId=JNStrTool.SubAtkEffectId(RoleRData[12])
    --登场特效id
    tempRole.DebutEffectId_str=RoleRData[13]
    tempRole.DebutEffectId=JNStrTool.SubAtkEffectId(RoleRData[13])
    --死亡动作特效
    tempRole.DeathEffectId_str=RoleRData[14]
    tempRole.DeathEffectId=JNStrTool.SubAtkEffectId(RoleRData[14])
    --眩晕
    tempRole.VertigoEffectId_str=RoleRData[15]
    tempRole.VertigoEffectId=JNStrTool.SubAtkEffectId(RoleRData[15])
    --受击
    tempRole.HitEffectId_str=RoleRData[16]
    tempRole.HitEffectId=JNStrTool.SubAtkEffectId(RoleRData[16])
    --跑动
    tempRole.PD0EffectId_str=RoleRData[48]
    tempRole.PD1EffectId_str=RoleRData[49]
    tempRole.HC1EffectId_str=RoleRData[50]
    tempRole.HC2EffectId_str=RoleRData[51]
    --追击特效ID
    tempRole.ZJEffectId_str=RoleRData[62]
    tempRole.ZJEffectId=JNStrTool.SubAtkEffectId(RoleRData[62])

    if _qoom then
        tempRole.Qzoom=RoleRData[17] * _qoom
    else
        tempRole.Qzoom=RoleRData[17]
    end

    tempRole.MinStart=tonumber(RoleRData[18])
    --  tempRole.MaxStart=tonumber(RoleRData[tempIndex])
    -- tempIndex=tempIndex+1
    --计算下一级需要的经验 最大不超过100级

    --  tempRole.StSExp(RoleRData[tempIndex],tempRole)
    --   tempIndex=tempIndex+1
    tempRole.Attackmode=tonumber(RoleRData[19])
    tempRole.Casteranimation=tonumber(RoleRData[20])

    tempRole.AtkName=RoleRData[21]
    --角色简介
    tempRole.Attackdescription=RoleRData[22]
    --觉醒
    tempRole.IsAwaken=Bool_isAwaken

    tempRole.StSAwaken(RoleRData[23],tempRole)
    --血量
    tempRole.StSHP(RoleRData[24],tempRole)
    --攻击力 设置基础攻击力

    tempRole.StSAtk(RoleRData[25], tempRole)
    tempRole.StSDef(RoleRData[26], tempRole)
    --暴击
    BattleRole.SetCrit(tempRole ,tonumber(RoleRData[27]))
    --闪避
    tempRole.StSAgile(RoleRData[28], tempRole)
    --爆伤
    BattleRole.SetCritDMG(tempRole,tonumber(RoleRData[29]))
    tempRole.Attacktarget=tonumber(RoleRData[30])
    tempRole.AtkTargetTips = ReadData.GetAtkTargetTips(RoleRData[30])
    --攻击范围
    tempRole.StSAtkRange(RoleRData[31],tempRole)
    --技能
    tempRole.StSSkillLvReal(RoleRData[32],RoleRData[33],RoleRData[34],RoleRData[35],RoleRData[36],tempRole)
  
    tempRole.SubAwaken(tempRole)
    --清空被赋予的技能
    tempRole.AftTurnAbtChangeSkills={}
    tempRole.AftTurnDotSkills={}
    tempRole.GotBefAtkSkills={}
    tempRole.GotBefHitSkills={}  --受到攻击前
    tempRole.GotAftHitSkills={}  --受到攻击后
    tempRole.GotAftAtkSkills={}  --攻击后
    tempRole.GotOnDeathSkills={}       --自身死亡的时候立即触发,选目标释放技能,然后继续执行技能链
    tempRole.GotOnSupportSkills={}       --支援时
    tempRole.AftTurnBackSkills={}
    --ex技能

    --进攻距离参数
    tempIndex=37
    tempRole.Attackdistance=tonumber(RoleRData[37])
    tempIndex=tempIndex+1
    tempRole.ForwardType=tonumber(RoleRData[38])
    tempIndex=tempIndex+1
    tempRole.BackType=tonumber(RoleRData[39])
    tempIndex=tempIndex+1
    tempRole.TimeNext=tonumber(RoleRData[40])
    tempIndex=tempIndex+1
    --Q版头像
    tempRole.Icon_q=RoleRData[41]
    tempIndex=tempIndex+1
    --额外动作名
    tempRole.NameBefor=RoleRData[42]
    tempIndex=tempIndex+1
    tempRole.NameAfter=RoleRData[43]
    tempIndex=tempIndex+1

    --子弹飞行速度
    tempRole.Bulletvelocity=RoleRData[47]
    --蓄力特效

    tempRole.ReadyEffectId_str=tostring(RoleRData[46])
    -- 64震动

    tempRole.Shake=RoleRData[54]
  
    --命中延迟
    tempRole.Show_Delay={}
    --分段比例
    tempRole.Show_Number={}
    local tempShake=tostring(RoleRData[55],"0")
    if tempShake=="0" then
        tempRole.Show_Delay[0]=0
        tempRole.Show_Number[0]=0

    else
        local tempArr=JNStrTool.strSplit(",",tempShake)
        for key_A1, value_A1 in pairs(tempArr) do
            local tempArr_2= JNStrTool.strSplit("_",value_A1)
            tempRole.Show_Delay[key_A1]=tonumber(tempArr_2[1])
            tempRole.Show_Number[key_A1]  =tonumber(tempArr_2[2])

        end
    end

    --local tempstr=RoleRData[44]
    --local tempArr=JNStrTool.strSplit(",",tempstr)
    --tempRole.EXpos_x= tonumber(tempArr[1])
    --tempRole.EXpos_y= tonumber(tempArr[2])
    --tempRole.EXpos_Size= tonumber(tempArr[3])
    --tempRole.EXpos_rx= tonumber(tempArr[4])
    --tempRole.EXpos_ry= tonumber(tempArr[5])
    --tempRole.EXpos_rz= tonumber(tempArr[6])
    ---添加所有装备属性
    ReadData.SetMabt(tempRole)
    ReadData.SetAllFw_attr(tempRole)
    return tempRole
end
---获取角色属性
function ReadData.GetRoleAttr(RoleId,lv,starLV,skillLV,Bool_isAwaken,exp,equipUnlockLV)
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    ---角色好感等级属性(不算在基础属性中)
    local tFavorData = nil
    ---创建经验算法
    ReadData.CeratExp()
    ---根据RoleId读表
    local RoleRData = RoleattributeLocalData.tab[RoleId]
    ---创建角色
    local tempRole=BattleRole:new()
    ---设定 星级 等级 技能 觉醒
    tempRole.EXP = exp
    tempRole.ID  = RoleId

    tempRole.SkinID = RoleId
    tempRole.IsAwaken=  Bool_isAwaken
    tempRole.StartLV=starLV
    tempRole.MinStart = RoleRData[21]
    tempRole.awakenStar = RoleRData[52]
    tempRole.SkillMaxLV=9
    tempRole.LV=lv
    if equipUnlockLV == true then
        tempRole.SkillLV=tonumber(skillLV) - 1
    else
        tempRole.SkillLV=tonumber(skillLV)
    end
    tempRole.ShowSkillLV=tonumber(skillLV)
    tempRole.Rank=tonumber(RoleRData[6])--品阶
    tempRole.Occupation = RoleRData[5]
    tempRole.SkillTreeName = RoleRData[60]
    ---觉醒后增加属性
    tempRole.StSAwaken(RoleRData[28],tempRole)
    ---血量
    tempRole.StSHP(RoleRData[29],tempRole,nil,tFavorData)
    ---攻击力
    tempRole.StSAtk(RoleRData[30], tempRole,tFavorData)
    ---装甲
    tempRole.StSDef(RoleRData[31], tempRole,tFavorData)
    ---暴击
    BattleRole.SetSCrit(tempRole, tonumber(RoleRData[32]),tFavorData)
    ---闪避
    tempRole.StSAgile(RoleRData[33], tempRole,tFavorData)
    ---暴击伤害
    BattleRole.SetSCritDMG(tempRole,tonumber(RoleRData[34]),tFavorData)
    ---攻击目标
    tempRole.Attacktarget = tonumber(RoleRData[35])
    tempRole.AtkTargetTips = ReadData.GetAtkTargetTips(RoleRData[35])
    ---攻击范围
    tempRole.StSAtkRange(RoleRData[36],tempRole)
    tempRole.AtkName = RoleRData[26]
    ---技能
    tempRole.StSSkillLvReal(RoleRData[37],RoleRData[38],RoleRData[39],RoleRData[40],RoleRData[41],tempRole)
    tempRole.SubAwaken(tempRole)
    ---设置基础属性
    ReadData.SetMabt(tempRole)
    ---经验值 Rank
    ReadData.SetExp( tempRole )
    tempRole.StSExp(tempRole.ExpFormula,tempRole)
    BattleRole.SubExp(tempRole)
    return tempRole
end
---获得角色HP(带小数点)
function ReadData.GetRoleHP(RoleId,lv,startLV,skillLV,Bool_isAwaken,exp)
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    ---创建经验算法
    ReadData.CeratExp()
    ---根据RoleId读表
    local RoleRData = RoleattributeLocalData.tab[RoleId]
    ---创建角色
    local tempRole=BattleRole:new()
    ---设定 星级 等级 技能 觉醒
    tempRole.EXP = exp
    tempRole.ID  = RoleId
    tempRole.IsAwaken=  Bool_isAwaken
    tempRole.StartLV=startLV
    tempRole.MinStart = RoleRData[21]
    tempRole.awakenStar = RoleRData[52]
    tempRole.SkillMaxLV=9
    tempRole.LV=lv
    tempRole.SkillLV=tonumber(skillLV)
    tempRole.ShowSkillLV=tonumber(skillLV)+1
    tempRole.Rank=tonumber(RoleRData[6])--品阶
    tempRole.Occupation = RoleRData[5]
    ---血量
    tempRole.StSHP(RoleRData[29],tempRole,true)
    return tempRole.HP
end
--获得怪物属性
function ReadData.GetMonsterAttr(RoleId,startLV,skillLV,Bool_isAwaken,Lv)
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    ---根据RoleId读表
    local RoleRData = MonsterLocalData.tab[RoleId]
    ---创建角色
    local tempRole=BattleRole:new()
    ---设定 星级 等级 技能 觉醒
    tempRole.IsAwaken = Bool_isAwaken

    ---觉醒后增加属性
    tempRole.StSAwaken(RoleRData[23],tempRole)
    ---血量
    tempRole.StSHP(RoleRData[24],tempRole)
    ---攻击力
    tempRole.StSAtk(RoleRData[25], tempRole)
    ---装甲
    tempRole.StSDef(RoleRData[26], tempRole)

    ---暴击
    BattleRole.SetCrit(tempRole ,tonumber(RoleRData[27]))
    ---闪避
    tempRole.StSAgile(RoleRData[28], tempRole)
    ---暴击伤害
    BattleRole.SetCritDMG(tempRole,tonumber(RoleRData[29]))
    ---等级
    tempRole.LV = Lv
    tempRole.StartLV = startLV
    tempRole.SkillMaxLV=9
    tempRole.SkillLV=tonumber(skillLV)
    tempRole.ShowSkillLV=tonumber(skillLV)+1
    tempRole.Occupation = RoleRData[3]
    ---攻击范围
    tempRole.StSAtkRange(RoleRData[31],tempRole)
    tempRole.AtkName = RoleRData[21]
    ---攻击目标
    tempRole.atkTarget = RoleRData[30]
    ---技能
    if RoleRData[36] == 0 then
        RoleRData[36] = "0"
    end
    tempRole.StSSkillLvReal(RoleRData[32],RoleRData[33],RoleRData[34],RoleRData[35],RoleRData[36],tempRole)
    return tempRole
end
--获得怪物属性
function ReadData.GetBossAttr(RoleId,startLV,lv,skillLV,Bool_isAwaken,occupation)
    if Bool_isAwaken==nil or  Bool_isAwaken=="1"or  Bool_isAwaken==1 or  Bool_isAwaken==true  then
        Bool_isAwaken=true
    else
        Bool_isAwaken=false
    end
    ---根据RoleId读表
    local RoleRData = MonsterLocalData.tab[RoleId]
    ---创建角色
    local tempRole=BattleRole:new()
    ---设定 星级 等级 技能 觉醒
    tempRole.IsAwaken = Bool_isAwaken
    tempRole.LV = lv
    tempRole.StartLV = startLV
    tempRole.IsMonster=true
    tempRole.ID = RoleId
    ---觉醒后增加属性
    tempRole.StSAwaken(RoleRData[23],tempRole)
    ---血量
    tempRole.StSHP(RoleRData[24],tempRole)
    ---攻击力
    tempRole.StSAtk(RoleRData[25], tempRole)
    ---装甲
    tempRole.StSDef(RoleRData[26], tempRole)

    ---暴击
    BattleRole.SetCrit(tempRole ,tonumber(RoleRData[27]))
    ---闪避
    tempRole.StSAgile(RoleRData[28], tempRole)
    ---暴击伤害
    BattleRole.SetCritDMG(tempRole,tonumber(RoleRData[29]))

    tempRole.SkillMaxLV=9
    tempRole.SkillLV=tonumber(skillLV)
    tempRole.ShowSkillLV=tonumber(skillLV)+1
    tempRole.Occupation = RoleRData[3]
    ---攻击范围
    tempRole.StSAtkRange(RoleRData[31],tempRole)
    tempRole.AtkName = RoleRData[21]
    ---攻击目标
    tempRole.atkTarget = RoleRData[30]
    ---技能
    if RoleRData[36] == 0 then
        RoleRData[36] = "0"
    end
    tempRole.StSSkillLvReal(RoleRData[32],RoleRData[33],RoleRData[34],RoleRData[35],RoleRData[36],tempRole)

    ---增加觉醒属性
    if tempRole.IsAwaken == true then
        for k, v in pairs(tempRole.AwkenFormula) do
            ---HP
            if v[1] == "1" then
                tempRole.HPmax = tempRole.HPmax + tonumber(v[2])
                tempRole.HP = tempRole.HP + tonumber(v[2])
            end
            if v[1] == "2" and tempRole.Occupation ~= 4 then
                tempRole.Atk = tempRole.Atk + tonumber(v[2])
            end
            if v[1] == "3" and tempRole.Occupation == 4 then
                tempRole.Atk = tempRole.Atk + tonumber(v[2])
            end
        end
    end

    ---添加所有装备属性
    ReadData.SetMabt(tempRole)
    ReadData.SetBossFw_attr(tempRole)
    
    return tempRole
end
--设置基础属性
function ReadData.SetMabt(_role)
    _role.Skills_fw={}
    _role.basisAtk=_role.RealAtk
    _role.basisDef=_role.RealDef
    _role.basisSuppart=_role.RealSuppart
    _role.basisCrit=_role.RealCrit
    _role.basisCritDmg=_role.RealCritDmg
    _role.basisAgile=_role.RealAgile
    _role.basisHP=_role.HP
    ------固定加成----
    _role.basisAtk_Fixed=0
    _role.basisHP_Fixed=0
    --百分比
    _role.basisAtk_Percent=0
    _role.basisDef_Percent=0
    _role.basisSuppart_Percent=0
    _role.basisCrit_Percent=0
    _role.basisCritDmg_Percent=0
    _role.basisAgile_Percent=0
    _role.basisHP_Percent=0
    _role.basisAgile_Percent=0
    _role.basisSuppart_Percent=0
end
--设置装备属性,并作为基础属性   移除的时候要  传入属性值的负数
function ReadData.SetAdd_Abt(_role ,_str_type,_number)
    if _str_type==0 then  --固定攻击
        _role.basisAtk_Fixed=_role.basisAtk_Fixed+_number
        --实际攻击为  (basisAtk+basisAtk_Fixed)*basisAtk_Percent
        --然后给基础属性赋值
        _role.Atk= (_role.basisAtk+_role.basisAtk_Fixed)*(1+ _role.basisAtk_Percent)
        _role.RealAtk= _role.Atk
        print(_number.."装备属性--固定攻击".. _role.RealAtk)
    elseif _str_type==1 then --百分比攻击力
        -- statements
        _number=_number*0.01
        _role.basisAtk_Percent=_role.basisAtk_Percent+_number
        _role.Atk= (_role.basisAtk+_role.basisAtk_Fixed)*(1+ _role.basisAtk_Percent)
        _role.RealAtk=  _role.Atk
        print(_number.."装备属性--百分比攻击力".. _role.RealAtk)
    elseif _str_type==2 then  --固定生命
        _role.basisHP_Fixed=_role.basisHP_Fixed+_number
        _role.HP= (_role.basisHP+_role.basisHP_Fixed)*(1+ _role.basisHP_Percent)
        _role.HPmax= _role.HP
        print(_number.."装备属性--固定生命".. _role.HPmax)
    elseif _str_type==3 then --百分比生命
        _number=_number*0.01
        _role.basisHP_Percent=_role.basisHP_Percent+_number
        _role.HP= (_role.basisHP+_role.basisHP_Fixed)*(1+ _role.basisHP_Percent)
        _role.HPmax= _role.HP
        print(_number.."装备属性--百分比生命".. _role.HPmax)
    elseif _str_type==4 then  --防御
        _number=_number*0.01
        _role.basisDef_Percent=_role.basisDef_Percent+_number
        _role.Def=_role.basisDef+ _role.basisDef_Percent
        _role.RealDef=_role.Def
        print(_number.."装备属性--防御".. _role.RealDef)
    elseif _str_type==5 then  --暴击
        _number=_number*0.01
        _role.basisCrit_Percent=_role.basisCrit_Percent+_number
        _role.Crit=_role.basisCrit+ _role.basisCrit_Percent
        _role.RealCrit=_role.Crit
        print(_number.."装备属性--暴击".. _role.RealCrit)
    elseif _str_type==6 then  --爆伤
        _number=_number*0.01
        _role.basisCritDmg_Percent=_role.basisCritDmg_Percent+_number
        _role.CritDmg=_role.basisCritDmg+ _role.basisCritDmg_Percent
        _role.RealCritDmg=_role.CritDmg
        print(_number.."装备属性--爆伤".. _role.RealCritDmg)
    elseif _str_type==7 then  --闪避
        _number=_number*0.01
        _role.basisAgile_Percent=_role.basisAgile_Percent+_number
        _role.Agile=_role.basisAgile+ _role.basisAgile_Percent
        _role.RealAgile=_role.Agile
        print(_number.."装备属性--闪避".. _role.RealAgile)
    elseif _str_type==8 then  --支援力
        _number=_number*0.01
        _role.basisSuppart_Percent=_role.basisSuppart_Percent+_number
        _role.Suppart=_role.basisSuppart+ _role.basisSuppart_Percent
        _role.RealSuppart=_role.Suppart
        print(_number.."装备属性--支援力".. _role.RealSuppart)
    end
end
--人物,核心属性,是否装备or卸下 第一次穿装备的时候调用 ReadData.SetMabt(_Role)
---@param attr CoreAttrData[]   
function ReadData.InitRoleGear(_Role,attr,isAdd)
    for i, v in pairs(attr) do
        if isAdd then
            print(v.attrID,"+++++++++++一次")
            ReadData.SetAdd_Abt(_Role ,v.attrID,v.attribute)
        else
            ReadData.SetAdd_Abt(_Role ,v.attrID,-1*v.attribute)
        end
    end
end
require("LocalData/ArmoredcoreLocalData")
---id,占比
function ReadData.GetGearAttr(_Id,properties)
    if _Id == nil or _Id == 0 then
        return
    end
    local armorCoreConfig = ArmoredcoreLocalData.tab[tonumber(_Id)]
    if armorCoreConfig == nil then
        print("没找到对应的核心")
    end
    ---清空已有数值
    local attrs = {}
    ---重新添加核心数据(配置完善后下面两列还原)
    local attrs_str =string.split(armorCoreConfig[11],',')
    local value_str =string.split(armorCoreConfig[12],',')
    for i = 1, #attrs_str do
        local attr_str = string.split(attrs_str[i],'_')
        ---@type CoreAttrData
        local attrData = CoreAttrData.New()
        local attrId = tonumber(attr_str[2])    ---属性配置表id
        local attrEnum = tonumber(attr_str[1])  ---属性类型 0值 1百分比
        local attr = tonumber(value_str[i]) * (properties/10000) ---属性具体数值
        if attrEnum == 1 then
            attr = attr * 0.01
        end
        attrData:PushData(i,attrId,attrEnum,attr)
        attrs[attrData.attrUID] = attrData
    end
    return attrs
end
--添加所有的装备属性
function ReadData.SetAllFw_attr(_Role)
    if BattleManager.IsTest_pve~=nil then
        return
    else
           
    end
    print("--添加所有的装备属性".._Role.ID)
    --ReadData.SetMabt(_Role)
    ---@type RoleData 获取角色属性
    local data = nil
    if _Role.IsMonster then
        ---怪物
        if BattleManager.FightType ~= nil and not CJNBattleMgr.Instance.worldBossBattle then
            ---常规战斗
            data = StormViewModel.CurPointData:GetMonsterById(tonumber(_Role.ID),_Role.AtkOrder)
        elseif CJNBattleMgr.Instance.worldBossBattle then
            ---世界boss
            data = EventRaidControl.GetLIANHETAOFAData().BossData[1].monsterData
        end
    else
        ---人物
        data = HeroControl.GetRoleDataByID(tonumber(_Role.ID))
    end
    if data == nil then
        print("--跳出1")
        return
    end
    ---获取角色核心1
    local core1 = data:GetHeroCore(1)
    if core1 ~= nil then
        ---添加核心技能
        if core1.skill ~= nil and core1.skill ~= 0 and core1.skill ~= "0" then
            _Role.AddFwSkill(core1.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core1.attrs,true)
    end
    ---获取怪物核心1
    core1 = data:GetMonsterCore(1)
    if core1 ~= nil then
        ---添加核心技能
        if core1.skill ~= nil and core1.skill ~= 0 and core1.skill ~= "0" then
            _Role.AddFwSkill(core1.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core1.attrs,true)
    end
    ---获取角色核心2
    --local core2 = data:GetCore(2)
    local core2 = data:GetHeroCore(2)
    if core2 ~= nil then
        ---添加核心技能
        if core2.skill ~= nil and core2.skill ~= 0 and core2.skill ~= "0" then
            _Role.AddFwSkill(core2.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core2.attrs,true)
    end
    ---获取怪物核心2
    core2 = data:GetMonsterCore(2)
    if core2 ~= nil then
        ---添加核心技能
        if core2.skill ~= nil and core2.skill ~= 0 and core2.skill ~= "0" then
            _Role.AddFwSkill(core2.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core2.attrs,true)
    end
    if not _Role.IsMonster then
        ---获取角色共鸣装备1
        local equip1 = data:GetHeroEquip(1)
        if equip1 ~= nil then
            ReadData.InitRoleGear(_Role,equip1.attrs,true)
        end
        ---获取角色共鸣装备2
        local equip2 = data:GetHeroEquip(2)
        if equip2 ~= nil then
            ReadData.InitRoleGear(_Role,equip2.attrs,true)
        end
        ---获取角色共鸣装备3
        local equip3 = data:GetHeroEquip(3)
        if equip3 ~= nil then
            ReadData.InitRoleGear(_Role,equip3.attrs,true)
        end
    end
end
function ReadData.AddSkillId(_Role, IntSkillId1,IntSkillId2)
   
    if IntSkillId1~=nil and  IntSkillId1~=0  and  IntSkillId1~="0" then
        _Role.AddFwSkill(IntSkillId1,_Role)
    end
   
        if IntSkillId2~=nil and  IntSkillId2~=0 and  IntSkillId2~="0" then
            _Role.AddFwSkill(IntSkillId2,_Role)
        end
end

function ReadData.GetInfoCorrect(_Data)
    -- statements
    local tempInt1 =0
    local tempInt2 =0
    local tempData=0
    tempInt1,tempInt2=math.modf((_Data*1000)/1)
    tempData=tempInt1/1000
    return tempData
end

function ReadData.GetAtkTargetTips(_idx)
    if _idx == 1 then
        return MgrLanguageData.GetLanguageByKey("fightdragview_front")
    elseif _idx == 2 then
        return MgrLanguageData.GetLanguageByKey("fightdragview_passover")
    elseif _idx == 3 then
        return MgrLanguageData.GetLanguageByKey("fightdragview_end")
    elseif _idx == 4 then
        return MgrLanguageData.GetLanguageByKey("fightdragview_next")
    elseif _idx == 5 then
        return MgrLanguageData.GetLanguageByKey("fightdragview_random")
    end
end
--添加BOSS所有的装备属性
function ReadData.SetBossFw_attr(_Role)
    if BattleManager.IsTest_pve~=nil then
        return
    else

    end
    print("--添加所有的装备属性".._Role.ID)
    --ReadData.SetMabt(_Role)
    ---@type RoleData 获取角色属性
    local data = nil
    if _Role.IsMonster then
        ---怪物
        if BattleManager.FightType ~= nil then
            ---常规战斗
            data = StormViewModel.CurPointData:GetMonsterById(tonumber(_Role.ID),_Role.AtkOrder)
        end
    end
    if data == nil then
        print("--跳出1")
        return
    end
    ---获取角色核心1
    local core1 = data:GetHeroCore(1)
    if core1 ~= nil then
        ---添加核心技能
        if core1.skill ~= nil and core1.skill ~= 0 and core1.skill ~= "0" then
            _Role.AddFwSkill(core1.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core1.attrs,true)
    end
    ---获取怪物核心1
    core1 = data:GetMonsterCore(1)
    if core1 ~= nil then
        ---添加核心技能
        if core1.skill ~= nil and core1.skill ~= 0 and core1.skill ~= "0" then
            _Role.AddFwSkill(core1.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core1.attrs,true)
    end
    ---获取角色核心2
    --local core2 = data:GetCore(2)
    local core2 = data:GetHeroCore(2)
    if core2 ~= nil then
        ---添加核心技能
        if core2.skill ~= nil and core2.skill ~= 0 and core2.skill ~= "0" then
            _Role.AddFwSkill(core2.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core2.attrs,true)
    end
    ---获取怪物核心2
    core2 = data:GetMonsterCore(2)
    if core2 ~= nil then
        ---添加核心技能
        if core2.skill ~= nil and core2.skill ~= 0 and core2.skill ~= "0" then
            _Role.AddFwSkill(core2.skill,_Role)
        end
        ---添加核心属性
        ReadData.InitRoleGear(_Role,core2.attrs,true)
    end
    if not _Role.IsMonster then
        ---获取角色共鸣装备1
        local equip1 = data:GetHeroEquip(1)
        if equip1 ~= nil then
            ReadData.InitRoleGear(_Role,equip1.attrs,true)
        end
        ---获取角色共鸣装备2
        local equip2 = data:GetHeroEquip(2)
        if equip2 ~= nil then
            ReadData.InitRoleGear(_Role,equip2.attrs,true)
        end
        ---获取角色共鸣装备3
        local equip3 = data:GetHeroEquip(3)
        if equip3 ~= nil then
            ReadData.InitRoleGear(_Role,equip3.attrs,true)
        end
    end
end
return ReadData