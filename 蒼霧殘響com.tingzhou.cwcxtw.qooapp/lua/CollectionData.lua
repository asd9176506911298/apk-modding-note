require("JNUI/JNCollection")
require("JNBattle/JNStrTool")
require("JNUI/JNRoleData")
require("JNUI/JNGear")
--require("ReadData/PlayerData")
CollectionData ={}
CollectionData.tab = { 

  RoleCollect={
    --1---2----3---4----5------6-----7------8----9----10------------11-------12--------13-------14---------15----------16-------17---------18-----------19-------20---------21----------22------------23------------24--------25------------26----------27------
    --ID 名字 星级 等级 觉醒 技能等级 职业 立绘名 头像名 装备1等级  装备1信息  装备2等级  装备2信息 装备1唯一ID 装备2唯一ID 是否新获取  品阶  装备1附加属性  装备2附加属性 装备1ID   装备2ID    装备1上限比例  装备2上限比例   角色当前经验  角色唯一ID   角色头像大   角色头像Q
    -- {"10000","露露啦","6","40","1","6","1","lihui_lulula","juese_icon_lulula","-1","0","-1","0","0","0","0","1","0","0","0","0","0","0","5277","1"},
    -- {"10001","朱利乌斯","6","60","1","7","1","lihui_zhuliwusi","juese_icon_zhuliwusi","3","0.521","6","0.325","300000_4","300000_5","0","1","2","0","304213","300301","0.2","0.3","5757"},
    -- {"11000","查理莎","5","20","1","8","2","lihui_chalisha","juese_icon_chalisha","-1","0","-1","0","0","0","0","1","0","0","0","0","0","0","200"},
    -- {"11001","爱丽丝","6","55","1","9","2","lihui_luyisi","juese_icon_luyisi","-1","0","-1","0","0","0","0","1","1","0","0","0","0","0","200"},
    -- {"11002","心纸","6","57","1","9","2","lihui_xinzhi","juese_icon_xinzhi","-1","0","-1","0","0","0","1","1","0","0","0","0","0","0","200"},
    -- {"12000","金库啦","4","5","0","3","3","lihui_jinkula","juese_icon_jinkula","-1","0","-1","0","0","0","0","1","0","0","0","0","0","0","100"},
    -- {"12001","静","4","45","0","5","3","lihui_jingkeleidiya","juese_icon_jing","-1","0","-1","0","0","0","0","3","2","0","0","0","0","0","5"},
    -- {"13000","欧贝啦","3","2","0","4","4","lihui_oubeila","juese_icon_oubeila","-1","0","-1","0","0","0","1","2","2","0","0","0","0","0","50"},
    -- {"13001","弗兰卡","3","3","0","6","4","lihui_fulanka","juese_icon_fulanka","-1","0","-1","0","0","0","0","2","2","0","0","0","0","0","1200"},
    -- {"100001","露露啦","6","40","1","6","1","lihui_lulula","juese_icon_lulula","1","0.023_780","0","90","300000_1","300000_2","0","1","4","0","304220","300000"},
    -- {"10001234","朱利乌斯","6","60","1","7","1","lihui_zhuliwusi","juese_icon_zhuliwusi","3","0.521","6","0.325","300000_4","300000_5","0","1","5","0","304253","300301"},
    -- {"11000322","查理莎","5","20","1","8","2","lihui_chalisha","juese_icon_chalisha","-1","0","-1","0","0","0","0","1","3","0"},
    -- {"10000145","露露啦","6","40","1","6","1","lihui_lulula","juese_icon_lulula","1","0.053","0","90","300000_1","300000_2","0","1","3","0","304311","300000"},
    -- {"100012","朱利乌斯","6","60","1","7","1","lihui_zhuliwusi","juese_icon_zhuliwusi","3","0.521","6","0.325","300000_4","300000_5","0","1","2","0","304253","300301"},
    -- {"110003","查理莎","5","20","1","8","2","lihui_chalisha","juese_icon_chalisha","-1","0","-1","0","0","0","0","1","2","0"},
    -- {"110014","爱丽丝","6","55","1","9","2","lihui_luyisi","juese_icon_luyisi","-1","0","-1","0","0","0","0","1","1","0"},
    -- {"110025","心纸","6","57","1","9","2","lihui_xinzhi","juese_icon_xinzhi","-1","0","-1","0","0","0","1","1","0","0"},
    -- {"120006","金库啦","4","5","0","3","3","lihui_jinkula","juese_icon_jinkula","-1","0","-1","0","0","0","0","1","0","0"},
    -- {"120017","静","4","45","0","5","3","lihui_jing","juese_icon_jing","-1","0","-1","0","0","0","0","3","2","0"},
    -- {"130008","欧贝啦","3","2","0","4","4","lihui_oubeila","juese_icon_oubeila","-1","0","-1","0","0","0","1","2","2","0"},
    -- {"130019","弗兰卡","3","3","0","6","4","lihui_fulanka","juese_icon_fulanka","-1","0","-1","0","0","0","0","2","2","0"},
    -- {"10000110","露露啦","6","40","1","6","1","lihui_lulula","juese_icon_lulula","1","0.453","0","90","300000_1","300000_2","0","1","2","0","304311","300000"},
    -- {"10001211","朱利乌斯","6","60","1","7","1","lihui_zhuliwusi","juese_icon_zhuliwusi","3","0.521","6","0.325","300000_4","300000_5","0","1","1","0","304402","300301"},
    -- {"11000312","查理莎","5","20","1","8","2","lihui_chalisha","juese_icon_chalisha","-1","0","-1","0","0","0","0","1","3","0"},
    -- {"1000013","露露啦","6","40","1","6","1","lihui_lulula","juese_icon_lulula","1","0.293","0","90","300000_1","300000_2","0","1","2","0","304402","300000"},
    -- {"1000114","朱利乌斯","6","60","1","7","1","lihui_zhuliwusi","juese_icon_zhuliwusi","3","0.521","6","0.325","300000_4","300000_5","0","1","2","0","304443","300301"},
    -- {"1100015","查理莎","5","20","1","8","2","lihui_chalisha","juese_icon_chalisha","-1","0","-1","0","0","0","0","1","2","0"},
    -- {"1100116","爱丽丝","6","55","1","9","2","lihui_luyisi","juese_icon_luyisi","-1","0","-1","0","0","0","0","1","1","0"},
    -- {"1100217","心纸","6","57","1","9","2","lihui_xinzhi","juese_icon_xinzhi","-1","0","-1","0","0","0","1","1","0","0"},
    -- {"1200018","金库啦","4","5","0","3","3","lihui_jinkula","juese_icon_jinkula","-1","0","-1","0","0","0","0","1","0","0"},
    -- {"1200119","静","4","45","0","5","3","lihui_jing","juese_icon_jing","-1","0","-1","0","0","0","0","3","2","0"},
    -- {"1300020","欧贝啦","3","2","0","4","4","lihui_oubeila","juese_icon_oubeila","-1","0","-1","0","0","0","1","2","2","0"},
    -- {"1300121","弗兰卡","3","3","0","6","4","lihui_fulanka","juese_icon_fulanka","-1","0","-1","0","0","0","0","2","2","0"},
    -- {"10000122","露露啦","6","40","1","6","1","lihui_lulula","juese_icon_lulula","1","0.025","0","90","300000_1","300000_2","0","1","1","0","305100","300000"},
    -- {"10001223","朱利乌斯","6","60","1","7","1","lihui_zhuliwusi","juese_icon_zhuliwusi","3","0.521","6","0.325","300000_4","300000_5","0","1","1","0","305100","300301"},
    -- {"11000324","查理莎","5","20","1","8","2","lihui_chalisha","juese_icon_chalisha","-1","0","-1","0","0","0","0","1","3","0"},
  }
  ,
  ------------------------------------装甲核心背包-------------------------------------
  ----1---------2---------3-----------------4------5----6-------7-------8--------9-----10------11--------12--------13-------------14----------15---------16------17-------18-----------19--------------20--------
  --核心ID、物品独立ID、初始属性(已经弃用)、当前属性、星级、品阶、强化等级、物品类型、图标名、名字、持有角色UID、人物头像、附加属性类型  属性组合类型   人物Id    装备槽位  总占比   属性具体类型  属性图标组合  属性最大上限范围
  GearBag={
    -- {"300120","300000_1","30","0.0253","3","1","9","1","icon_hx_gjhx_1","攻击核心超频版","10000","juese_icon_lulula"},
    -- {"300000","300000_2","30","90","2","2","5","0","icon_hx_gjhx_0","攻击核心稳定版","10000","juese_icon_lulula"},
    -- {"300201","300000_3","30","50","6","3","4","2","icon_hx_smhx_0","生命核心稳定版","0","juese_icon_lulula"},
    -- {"300330","300000_4","30","0.521","4","4","7","3","icon_hx_smhx_1","生命核心超频版","10001","juese_icon_zhuliwusi"},
    -- {"300500","300000_5","30","0.325","5","1","2","6","icon_hx_bfhx","爆发核心","10001","juese_icon_zhuliwusi"},
    -- {"300500","300000_6","30","0.325","5","1","5","6","icon_hx_bfhx","爆发核心","0","juese_icon_xinzhi"},
    -- {"300500","300000_7","30","0.325","5","1","8","6","icon_hx_bfhx","爆发核心","0","juese_icon_xinzhi"},
    -- {"300500","300000_8","30","0.325","5","1","9","6","icon_hx_bfhx","爆发核心","0","juese_icon_xinzhi"},
  },
  FormationData={
    "10000,1,1_10001,1,2,1_11001,2,2", 
  },
  CombineGroup={
  },
  SaveGroupfomation={
    -- {"1","阵营1","10000,1,1_10001,1,2,1_11001,2,2"},
    -- {"2","阵营2","10000,1,1_10001,1,2,1_11001,2,2"},
    -- {"3","阵营3","10000,1,1_10001,1,2,1_11001,2,2"},
    -- {"4","阵营4","10000,1,1_10001,1,2,1_11001,2,2"},
    -- {"5","阵营5","strforGroup"},
    -- {"6","阵营6","strforGroup"},
    -- {"7","阵营7","strforGroup"},
    -- {"8","阵营8","strforGroup"},
    -- {"9","阵营9","strforGroup"},
    -- {"10","阵营10","strforGroup"},
    -- {"11","阵营11","strforGroup"},
    -- {"12","阵营12","strforGroup"},
    -- {"13","阵营13","strforGroup"},
  }
}
CollectionData.GearId=0
CollectionData.RoleCount=36
CollectionData.DelegateIndex=0
--初始化机娘背包
function CollectionData.InitBag(_JsonData,_JsonCount)
  -- statements
  print("***************开始更新背包**********************")
  CollectionData.tab.RoleCollect={}
  CollectionData.tab.CombineGroup={}
  PlayerData.HaveRole_Id={}
  for i = 0, _JsonCount - 1, 1 do
    -- statements
    local _TempRoleTab ={}
    local RoleId=HttpCore.GetAnalyisDataByKey(_JsonData,"heroId",i)
    local Roleuid=HttpCore.GetAnalyisDataByKey(_JsonData,"heroId",i)
    local RoleLV=HttpCore.GetAnalyisDataByKey(_JsonData,"lv",i)
    local RoleExp=HttpCore.GetAnalyisDataByKey(_JsonData,"exp",i)
    local RoleStar=HttpCore.GetAnalyisDataByKey(_JsonData,"star",i)
    local RoleisAwaken=HttpCore.GetAnalyisDataByKey(_JsonData,"isAwaken",i)
    local RoleskillLv=HttpCore.GetAnalyisDataByKey(_JsonData,"skillLv",i)
    local RolerunesId=HttpCore.GetAnalyisDataByKey(_JsonData,"runesId",i)
    local RolegetTime=HttpCore.GetAnalyisDataByKey(_JsonData,"getTime",i)
    local RoleName=""
    local RoleProType=1
    local RoleRank=1
    local RoleLiHuiName=""
    local RoleIconName=""
    local RoleIconNameBig=""
    local RoleIconNameQ=""
    -- print("***************更新人物等级***"..RoleLV.."*******************")
    for key, value in pairs(GameData.tab.roleattribute) do
      -- statements
      if value[1] == ""..RoleId then
        -- statements
        RoleName=value[2]
        RoleProType=value[5]
        RoleRank=value[6]
        RoleLiHuiName=value[8]
        RoleIconName=value[7]
        RoleIconNameBig=value[60]
        RoleIconNameQ=value[49]
      end
    end
    for key, value in pairs(GameData.tab.fetters) do
      -- statements
      local _TempRoleList=JNStrTool.strSplit(",",value[9])
      for i, n in pairs(_TempRoleList) do
        -- statements
        if n == ""..RoleId then
          -- statements
          local Bool_IsExist =false
          local _TempCombineTab ={}
          for o, r in pairs(CollectionData.tab.CombineGroup) do
            -- statements
            if r[1] == ""..value[1] then
              -- statements
              -- print(""..RoleId.."已存在小队"..value[2])
              Bool_IsExist =true
            end
          end
          if Bool_IsExist == false then
            -- statements
            table.insert(_TempCombineTab,value[1])
            -- print("添加GroupID"..value[1])
            table.insert(_TempCombineTab,value[2])
            -- print("添加Group名字"..value[2])
            table.insert(_TempCombineTab,value[8])
            -- print("添加Group描述"..value[8])
            table.insert(_TempCombineTab,value[9])
            -- print("添加Group成员"..value[9])
            table.insert(_TempCombineTab,value[10])
            -- print("添加Group组合技能类型"..value[4])
            table.insert(_TempCombineTab,value[4])
              -- print("添加Group能量槽数量"..value[5])
            table.insert(_TempCombineTab,value[5])
              -- print("添加Group能量槽溢出伤害加成"..value[6])
            table.insert(_TempCombineTab,value[6])
              -- print("添加Group技能效果"..value[7])
            table.insert(_TempCombineTab,value[7])
              -- print("添加GroupIcon头像"..value[3])
            table.insert(_TempCombineTab,value[3])
            table.insert(CollectionData.tab.CombineGroup,_TempCombineTab)


          end
        end
      end
    end
    table.insert(PlayerData.HaveRole_Id,RoleId)
    table.insert(_TempRoleTab,RoleId)
    table.insert(_TempRoleTab,RoleName)
    table.insert(_TempRoleTab,RoleStar)
    table.insert(_TempRoleTab,RoleLV)
    table.insert(_TempRoleTab,RoleisAwaken)
    table.insert(_TempRoleTab,RoleskillLv)
    table.insert(_TempRoleTab,RoleProType)
    table.insert(_TempRoleTab,RoleLiHuiName)
    table.insert(_TempRoleTab,RoleIconName)
    table.insert(_TempRoleTab,"-1")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"-1")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,RoleRank)
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,"0")
    table.insert(_TempRoleTab,RoleExp)
    table.insert(_TempRoleTab,Roleuid)
    table.insert(_TempRoleTab,RoleIconNameBig)
    table.insert(_TempRoleTab,RoleIconNameQ)
    table.insert(CollectionData.tab.RoleCollect,_TempRoleTab)
    -- print("RoleLV"..RoleLV)
    -- print("RoleExp"..RoleExp)
    -- print("RoleStar"..RoleStar)
    -- print("RoleisAwaken"..RoleisAwaken)
    -- print("RoleskillLv"..RoleskillLv)
    -- print("RoleName"..RoleName)
    -- print("RoleProType"..RoleProType)
    -- print("RoleRank"..RoleRank)
    -- print("AddRole"..RoleId)
  end
end
--初始化机甲背包
  ------------------------------------装甲核心背包属性-------------------------------------
  ----1---------2---------3-----------------4------5----6-------7-------8--------9-----10------11--------12--------13--------------14---------15---------16------17-------18-----------19--------------20-----------21------
  --核心ID、物品独立ID、初始属性(已经弃用)、当前属性、星级、品阶、强化等级、物品类型、图标名、名字、持有角色UID、人物头像、附加属性类型  属性组合类型   人物Id    装备槽位  总占比   属性具体类型  属性图标组合  属性最大上限范围  持有者头像
function CollectionData.InitRuneBag(_JsonData,_JsonCount)
  -- statements
  JNPlayerData.GearCoreBag={}
  CollectionData.tab.GearBag={}
  for i = 0, _JsonCount - 1, 1 do
    local GearDataTempTab={}
    local tempTab={}
    local Runeid=HttpCore.GetAnalyisDataByKey(_JsonData,"runeId",i)
    local Runeuid=HttpCore.GetAnalyisDataByKey(_JsonData,"id",i)
    local RuneOriginData=0
    local RuneCurData=0
    local RuneStarLv=0
    local RuneRank=0
    local Runelv=HttpCore.GetAnalyisDataByKey(_JsonData,"lv",i)
    local RuneType=0
    local RuneIconName=""
    local RuneName=""
    local RuneuserHeroId=HttpCore.GetAnalyisDataByKey(_JsonData,"userHeroId",i)
    local RuneUserIconName=""
    -- local RuneDeputyType=HttpCore.GetAnalyisDataByKey(_JsonData,"deputyPropertiesType",i)
    local RuneDeputyType="0"
    local RuneMainType=0
    local RuneCombineMainType=0
    local RuneCombineIconType=0
    -- local RuneOriginRoll=HttpCore.GetAnalyisDataByKey(_JsonData,"initialPropertiesValue",i)
    local RuneCurRoll=HttpCore.GetAnalyisDataByKey(_JsonData,"nowPropertiesValue",i)
    local RuneuseHeroId=0
    local Runeuslot=HttpCore.GetAnalyisDataByKey(_JsonData,"slot",i)
    local RuneRate=RuneCurRoll/1000
    local RuneMaxData=0
    local RuneOwnerRoleIcon=""
    -- print("Runeid"..Runeid.."****************RuneuserHeroId"..RuneuserHeroId)
    for key, value in pairs(GameData.tab.armoredcore) do
      -- statements
      if value[1] == ""..Runeid then
        -- statements
        ------------------------读表数据获取-----------------------------------
        RuneStarLv=tonumber(value[5])
        RuneType=tonumber(value[9])
        RuneMainType=tonumber(value[9])
        RuneCombineMainType=tonumber(value[11])
        RuneRank=tonumber(value[4])
        RuneIconName=value[2]
        RuneName=value[3]
        RuneCombineIconType=value[12]
        RuneMaxData=value[13]
        ------------------------初始属性以及强化属性获取值----------------------------
        if RuneCombineMainType <= 1 then
          local _MaxDatatab=JNStrTool.strSplit("_", value[13])
          local _MaxData=tonumber(_MaxDatatab[2])
          -- statements
          -- --初始随机属性阈值
          -- if tonumber(_MaxData) >= 1 then
          --   -- 非百分比数据
          --   RuneOriginData=math.floor(_MaxData*(tonumber(RuneOriginRoll)/1000))
          -- else
          --   RuneOriginData=CollectionData.GetInfoCorrect(_MaxData*(tonumber(RuneOriginRoll)/1000))
          -- end
          -- RuneOriginData=""..RuneOriginData
          -- print("RuneOriginData************************"..RuneOriginData)
          --强化随机属性阈值
          -- if tonumber(RuneCurRoll) > 0 then
            -- statements
            if tonumber(_MaxData) >= 1 then
              -- 非百分比数据
              RuneCurData=math.floor(_MaxData*(tonumber(RuneCurRoll)/1000))
            else
              RuneCurData=CollectionData.GetInfoCorrect(_MaxData*(tonumber(RuneCurRoll)/1000))
            end
            RuneCurData=""..RuneCurData
          -- else
          --   RuneCurData=RuneOriginData
          -- end
        else
          local _MaxDatatab=JNStrTool.strSplit(";", value[13])
          -- local RuneOriginDataBuffTab={}
          local RuneCurDataBuffTab={}
          for i = 1, 2, 1 do
            --初始随机属性阈值
            local _DataTab=JNStrTool.strSplit("_", _MaxDatatab[i])
            local _MaxData =tonumber(_DataTab[2])
            -- local _TempRuneOriginData=0
            local _TempRuneCurData=0
            -- print("tempTab[1]"..tempTab[1])
            -- if tonumber(_MaxData) >= 1 then
            --   -- 非百分比数据
            --   _TempRuneOriginData=math.floor(_MaxData*(tonumber(RuneOriginRoll)/1000))
            -- else
            --   _TempRuneOriginData=CollectionData.GetInfoCorrect(_MaxData*(tonumber(RuneOriginRoll)/1000))
            -- end
            -- print("_TempRuneOriginData************************".._TempRuneOriginData)
            -- table.insert(RuneOriginDataBuffTab,_TempRuneOriginData)
            --强化随机属性阈值
            -- if tonumber(RuneCurRoll) > 0 then
              -- statements
              if tonumber(_MaxData) >= 1 then
                -- 非百分比数据
                _TempRuneCurData=math.floor(_MaxData*(tonumber(RuneCurRoll)/1000))
              else
                _TempRuneCurData=CollectionData.GetInfoCorrect(_MaxData*(tonumber(RuneCurRoll)/1000))
              end
              -- RuneRate = CollectionData.GetGearRate(_UpMax,_OriginMax,_TempRuneCurData)
              -- print("RuneRate**************"..RuneRate)
              table.insert(RuneCurDataBuffTab,_TempRuneCurData)
            -- else
            --   table.insert(RuneCurDataBuffTab,_TempRuneOriginData)
            -- end
            -- print(RuneCurRoll.."_TempRuneCurData************************".._TempRuneCurData)
          end
          RuneCurData=RuneCurDataBuffTab[1].."_"..RuneCurDataBuffTab[2]
        end
        ------------------------初始属性以及强化属性获取值----------------------------
      end
    end
    for key, value in pairs(CollectionData.tab.RoleCollect) do
      -- statements
      if value[1] ==""..RuneuserHeroId then
        -- statements
        -- print("人物ID"..value[1].."装备了"..Runeid)
        for i, n in pairs(GameData.tab.roleattribute) do
          -- statements
          if n[1] == ""..value[1] then
            -- statements
            RuneUserIconName=n[7]
            RuneOwnerRoleIcon=n[63]
            -- print("Runeid"..Runeid.."RuneUserIconName"..RuneUserIconName)
          end
        end
        if Runeuslot == "0"  then
          -- statements
          value[10]=Runelv
          value[11]=RuneCurData
          value[14]=Runeuid
          value[18]=RuneDeputyType
          value[20]=Runeid
          value[22]=RuneRate
          elseif Runeuslot == "1" then
            -- statements
            value[12]=Runelv
            value[13]=RuneCurData
            value[15]=Runeuid
            value[19]=RuneDeputyType
            value[21]=Runeid
            value[23]=RuneRate
        end
      end
    end
    table.insert(GearDataTempTab,Runeid)
    table.insert(GearDataTempTab,Runeuid)
    table.insert(GearDataTempTab,RuneOriginData)
    table.insert(GearDataTempTab,RuneCurData)
    table.insert(GearDataTempTab,RuneStarLv)
    table.insert(GearDataTempTab,RuneRank)
    table.insert(GearDataTempTab,Runelv)
    table.insert(GearDataTempTab,RuneType)
    table.insert(GearDataTempTab,RuneIconName)
    table.insert(GearDataTempTab,RuneName)
    table.insert(GearDataTempTab,RuneuserHeroId)
    table.insert(GearDataTempTab,RuneUserIconName)
    table.insert(GearDataTempTab,RuneDeputyType)
    table.insert(GearDataTempTab,RuneCombineMainType)
    table.insert(GearDataTempTab,RuneuseHeroId)
    table.insert(GearDataTempTab,Runeuslot)
    table.insert(GearDataTempTab,RuneRate)
    table.insert(GearDataTempTab,RuneMainType)
    table.insert(GearDataTempTab,RuneCombineIconType)
    table.insert(GearDataTempTab,RuneMaxData)
    table.insert(GearDataTempTab,RuneOwnerRoleIcon)
    table.insert(CollectionData.tab.GearBag,GearDataTempTab)
    local _JNGearTemp=JNGear:new(Runeuid,Runelv,RuneStarLv,i,RuneRank,GearDataTempTab)
    table.insert(JNPlayerData.GearCoreBag,_JNGearTemp)
    -- print("AddRuneItem"..Runeid)
    -- print("Runeid"..Runeid)
    -- print("Runeuid"..Runeuid)
    -- print("RuneOriginData"..RuneOriginData)
    -- print("RuneCurData"..RuneCurData)
    -- print("RuneStarLv"..RuneStarLv)
    -- print("RuneRank"..RuneRank)
    -- print("Runelv"..Runelv)
    -- print("RuneType"..RuneType)
    -- print("RuneIconName"..RuneIconName)
    -- print("RuneName"..RuneName)
    -- print("RuneuserHeroId"..RuneuserHeroId)
    -- print("RuneUserIconName"..RuneUserIconName)
    -- print("RuneDeputyType"..RuneDeputyType)
    -- print("RuneMainType"..RuneMainType)
    -- print("RuneOriginRoll"..RuneOriginRoll)
    -- print("RuneCurRoll"..RuneCurRoll)
  end
end

--解析单个机甲信息
function CollectionData.AnalyisRuneInfo(_Str)
    -- statements
    local _JsonData = "SingleRuneData"
    HttpCore.CreatAnalyisJsonData(_Str,_JsonData)
    local GearDataTempTab={}
    local Runeid=HttpCore.GetAnalyisDataByKey(_JsonData,"runeId",0)
    local Runeuid=HttpCore.GetAnalyisDataByKey(_JsonData,"id",0)
    local RuneOriginData=0
    local RuneCurData=0
    local RuneStarLv=0
    local RuneRank=0
    local Runelv=HttpCore.GetAnalyisDataByKey(_JsonData,"lv",0)
    local RuneType=0
    local RuneIconName=""
    local RuneName=""
    local RuneuserHeroId=HttpCore.GetAnalyisDataByKey(_JsonData,"userHeroId",0)
    local RuneUserIconName=""
    local RuneDeputyType=HttpCore.GetAnalyisDataByKey(_JsonData,"deputyPropertiesType",0)
    local RuneMainType=0
    local RuneCombineMainType=0
    local RuneCombineIconType=0
    -- local RuneOriginRoll=HttpCore.GetAnalyisDataByKey(_JsonData,"initialPropertiesValue",0)
    local RuneCurRoll=HttpCore.GetAnalyisDataByKey(_JsonData,"nowPropertiesValue",0)
    local RuneuseHeroId=0
    local Runeuslot=HttpCore.GetAnalyisDataByKey(_JsonData,"slot",0)
    local RuneRate=RuneCurRoll/1000
    local RuneMaxData=0
    -- print("Runeid"..Runeid.."****************RuneuserHeroId"..RuneuserHeroId)
    for key, value in pairs(GameData.tab.armoredcore) do
      -- statements
      if value[1] == ""..Runeid then
        -- statements
        ------------------------读表数据获取-----------------------------------
        RuneStarLv=tonumber(value[5])
        RuneType=tonumber(value[9])
        RuneMainType=tonumber(value[9])
        RuneCombineMainType=tonumber(value[11])
        RuneRank=tonumber(value[4])
        RuneIconName=value[2]
        RuneName=value[3]
        RuneCombineIconType=value[12]
        RuneMaxData=value[13]
        ------------------------初始属性以及强化属性获取值----------------------------
        if RuneCombineMainType <= 1 then
          local _MaxDatatab=JNStrTool.strSplit("_", value[13])
          local _MaxData=tonumber(_MaxDatatab[2])
            if tonumber(_MaxData) >= 1 then
              -- 非百分比数据
              RuneCurData=math.floor(_MaxData*(tonumber(RuneCurRoll)/1000))
            else
              RuneCurData=CollectionData.GetInfoCorrect(_MaxData*(tonumber(RuneCurRoll)/1000))
            end
            RuneCurData=""..RuneCurData
        else
          local _MaxDatatab=JNStrTool.strSplit(";", value[13])
          local RuneCurDataBuffTab={}
          for i = 1, 2, 1 do
            --初始随机属性阈值
            local _DataTab=JNStrTool.strSplit("_", _MaxDatatab[i])
            local _MaxData =tonumber(_DataTab[2])
            local _TempRuneCurData=0
              if tonumber(_MaxData) >= 1 then
                -- 非百分比数据
                _TempRuneCurData=math.floor(_MaxData*(tonumber(RuneCurRoll)/1000))
              else
                _TempRuneCurData=CollectionData.GetInfoCorrect(_MaxData*(tonumber(RuneCurRoll)/1000))
              end
              table.insert(RuneCurDataBuffTab,_TempRuneCurData)
          end
          RuneCurData=RuneCurDataBuffTab[1].."_"..RuneCurDataBuffTab[2]
        end
        -- print(Runeid.."初始化数据结束RuneOriginData"..RuneOriginData.."RuneCurData"..RuneCurData)
        ------------------------初始属性以及强化属性获取值----------------------------
      end
    end
    for key, value in pairs(CollectionData.tab.RoleCollect) do
      -- statements
      if value[1] ==""..RuneuserHeroId then
        -- statements
        -- print("人物ID"..value[1].."装备了"..Runeid)
        for i, n in pairs(GameData.tab.roleattribute) do
          -- statements
          if n[1] == ""..value[1] then
            -- statements
            RuneUserIconName=n[7]
          end
        end
        if Runeuslot == "0"  then
          -- statements
          value[10]=Runelv
          value[11]=RuneCurData
          value[14]=Runeuid
          value[18]=RuneDeputyType
          value[20]=Runeid
          value[22]=RuneRate
          elseif Runeuslot == "1" then
            -- statements
            value[12]=Runelv
            value[13]=RuneCurData
            value[15]=Runeuid
            value[19]=RuneDeputyType
            value[21]=Runeid
            value[23]=RuneRate
        end
      end
    end
    table.insert(GearDataTempTab,Runeid)
    table.insert(GearDataTempTab,Runeuid)
    table.insert(GearDataTempTab,RuneOriginData)
    table.insert(GearDataTempTab,RuneCurData)
    table.insert(GearDataTempTab,RuneStarLv)
    table.insert(GearDataTempTab,RuneRank)
    table.insert(GearDataTempTab,Runelv)
    table.insert(GearDataTempTab,RuneType)
    table.insert(GearDataTempTab,RuneIconName)
    table.insert(GearDataTempTab,RuneName)
    table.insert(GearDataTempTab,RuneuserHeroId)
    table.insert(GearDataTempTab,RuneUserIconName)
    table.insert(GearDataTempTab,RuneDeputyType)
    table.insert(GearDataTempTab,RuneCombineMainType)
    table.insert(GearDataTempTab,RuneuseHeroId)
    table.insert(GearDataTempTab,Runeuslot)
    table.insert(GearDataTempTab,RuneRate)
    table.insert(GearDataTempTab,RuneMainType)
    table.insert(GearDataTempTab,RuneCombineIconType)
    table.insert(GearDataTempTab,RuneMaxData)
    return GearDataTempTab
end
--取整人物信息
function CollectionData.GetInfoCorrect(_Data)
  -- statements
  local tempInt1 =0
  local tempInt2 =0
  local tempData=0
  tempInt1,tempInt2=math.modf((_Data*1000)/1)
  tempData=tempInt1/1000
  return tempData
end
--获取装备属性占比
function CollectionData.GetGearRate(_UpMax,_OriginMax,_CurData)
  -- statements
  -- print("_UpMax**".._UpMax.."_OriginMax**".._OriginMax.."_CurData***".._CurData)
  return CollectionData.GetInfoCorrect((_CurData/((_UpMax*9)+_OriginMax)))
end

--Http请求获取所有机甲列表
function CollectionData.HttpPostInitRune(_LuaCallBackName)
  -- statements
  HttpCore.GetRuneList("CollectionData.InitRuneList",CollectionData.InitRuneList,_LuaCallBackName)
end
--Http请求获取所有机娘列表
function CollectionData.HttpPostInitRole()
  -- statements
  HttpCore.GetRoleList("CollectionData.ShowList",CollectionData.ShowList,nil)
end
--根据返回的Json解析初始化CollectionData背包
function CollectionData.InitRuneList(_Str,_JsonCount,_LuaCallBackName)
  if _Str ~= nil and _JsonCount>0 then
      -- statements
      HttpCore.CreatAnalyisJsonData(_Str,"RoleRuneData")
      CollectionData.InitRuneBag("RoleRuneData",_JsonCount)
      if _LuaCallBackName ~=nil and _LuaCallBackName ~= "" then
        -- statements
        print("Event go ".._LuaCallBackName)
        Event.Go(_LuaCallBackName)
        -- Event.Clear(_LuaCallBackName)
      end
    else
      if _LuaCallBackName ~=nil and _LuaCallBackName ~= "" then
        -- statements
        print("Event go ".._LuaCallBackName)
        Event.Go(_LuaCallBackName)
        -- Event.Clear(_LuaCallBackName)
      end
  end
  -- print(CollectionData.tab.GearBag[1])
end

--请求更新储存的阵型数据
function CollectionData.HttpPostInitGroupData(_LuaCallBackName)
  -- statements
  HttpCore.GetAllGroup("0","CollectionData.InitFomationList",CollectionData.InitFomationList,_LuaCallBackName)
end
function CollectionData.InitGroupData(_JsonData,_JsonCount)
  -- statements
  CollectionData.tab.SaveGroupfomation={}
  for i = 0, _JsonCount - 1, 1 do
    -- statements
    local GroupDataTab={}
    local GroupId=HttpCore.GetAnalyisDataByKey(_JsonData,"formationNum",i)
    local GroupName=HttpCore.GetAnalyisDataByKey(_JsonData,"formationName",i)
    local GroupInfo=HttpCore.GetAnalyisDataByKey(_JsonData,"formationInfo",i)
    table.insert(GroupDataTab,GroupId)
    table.insert(GroupDataTab,GroupName)
    table.insert(GroupDataTab,GroupInfo)
    table.insert(CollectionData.tab.SaveGroupfomation,GroupDataTab)
  end
end
function CollectionData.InitFomationList(_Str,_JsonCount,_LuaCallBackName)
  -- statements
  if _Str ~= nil and _JsonCount>0 then
    -- statements
    HttpCore.CreatAnalyisJsonData(_Str,"RoleFomationData")
    CollectionData.InitGroupData("RoleFomationData",_JsonCount)
    if _LuaCallBackName ~=nil and _LuaCallBackName ~= "" then
      -- statements
      print("Event go ".._LuaCallBackName)
      Event.Go(_LuaCallBackName)
      -- Event.Clear(_LuaCallBackName)
    end
  else
    if _LuaCallBackName ~=nil and _LuaCallBackName ~= "" then
      -- statements
      print("Event go ".._LuaCallBackName)
      Event.Go(_LuaCallBackName)
      -- Event.Clear(_LuaCallBackName)
    end
end
end
--根据返回的Json解析初始化CollectionData背包
function CollectionData.ShowList(_Str,_JsonCount,_LuaCallBackName)
  -- statements
  Event.Clear("InitGearAfterRole")
  Event.Add("InitGearAfterRole",function ()
    -- statements
    CollectionData.InitGearAfterRole()
  end)
  if _Str ~= nil and _JsonCount>0 then
      -- statements
      HttpCore.CreatAnalyisJsonData(_Str,"RoleCollectData")
      CollectionData.InitBag("RoleCollectData",_JsonCount)
      if _LuaCallBackName ~=nil and _LuaCallBackName ~= "" then
        -- statements
        Event.Go(_LuaCallBackName)
        -- Event.Clear(_LuaCallBackName)
      end
    else
      if _LuaCallBackName ~=nil and _LuaCallBackName ~= "" then
        -- statements
        Event.Go(_LuaCallBackName)
        -- Event.Clear(_LuaCallBackName)
      end
  end
  -- print(_Str)
end
--更新玩家机娘以及机甲装备信息
--当前更新信息后的回调方法名
CollectionData.InitRoleGearCallBackFuncName=""
function CollectionData.InitAllData(_FuncName)
  -- statements
  CollectionData.InitRoleGearCallBackFuncName=_FuncName
  Event.Clear("InitRoleAfterPlayerInfo")
  Event.Add("InitRoleAfterPlayerInfo",CollectionData.InitRoleAfterPlayerInfo)
  --JNPlayerData.HttpPostInitPlayerBag("InitRoleAfterPlayerInfo")
end
--用于等待更新完玩家信息更新机娘信息
function CollectionData.InitRoleAfterPlayerInfo()
  -- statements
  HttpCore.GetRoleList("CollectionData.ShowList",CollectionData.ShowList,"InitGearAfterRole")
end
--用于等待机娘信息更细完成在请求机甲背包
function CollectionData.InitGearAfterRole()
  -- statements
  HttpCore.GetRuneList("CollectionData.InitRuneList",CollectionData.InitRuneList,CollectionData.InitRoleGearCallBackFuncName)
end

--战斗中当前组合小队成员信息表
CollectionData.Tab_CurCombineRoleData = {"10000","12000","13000"}
CollectionData.CurCombineRoleID="308000"

--当前要显示的物品ItemID、以及数量
CollectionData.CurItemDetailId="150005"
CollectionData.CurItemDetailSum=100
return CollectionData