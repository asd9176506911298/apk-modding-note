BattleRoleData ={} 
BattleRoleData.CurBattleNeedInfoTab={"6","150001"}
--是否为上部分的组合预览图标点击
BattleRoleData.Bool_IsCombineSkillIconClick=false

--左边的阵容协力技能图标
BattleRoleData.Tab_CurLeftCombineSkillGroup={}  --{"308000","308001"}  组合技能小队ID_当前能量点数
BattleRoleData.Tab_CurLeft_Number={}            --{2,3} 对应下标的能量点
BattleRoleData.Tab_CurLeftDeadRoleIdList={}     --{"10000","10001"}  死亡角色id
--右边的阵容协力技能图标
BattleRoleData.Tab_CurRightCombineSkillGroup={}
BattleRoleData.Tab_CurRight_Number={}
BattleRoleData.Tab_CurRightDeadRoleIdList={}
--是否通关
BattleRoleData.Bool_Pass=true
--关卡ID
BattleRoleData.Int_BattleID="100003"
--卷名ID
BattleRoleData.Int_ChapterID="90000"
--部署机娘总数
BattleRoleData.Int_RoleSum=1
--怪物部署总数
BattleRoleData.Int_MonsterSum=1
--关卡难度
BattleRoleData.Str_BattleLv=MgrLanguageData.GetLanguageByKey("battleroledata_normal")
--回合数
BattleRoleData.Int_Round=50
--死亡机娘数目
BattleRoleData.Int_DeathCount=4
--结算信息表
BattleRoleData.tab = { 
  RoleData={
    --ID、名字、输出、承伤
  },
  MonsterData={
  },
  BossRealTimePointData={
  },
  BattleRewardData={
    {"150003","20"},
    {"150005","20"},
    {"150012","20"}
  }
}
BattleRoleData.WorldBossTotalDMG=0
BattleRoleData.WorldBossTotalHp=0
BattleRoleData.NextUID=""
BattleRoleData.NextTime=1
BattleRoleData.AutoReadFormStr="" --自动保存的阵容字符串
--本关卡最终获得星数
BattleRoleData.CheckPointStar=3

--自动保存对应类型阵容  1.PVE 2.世界BOSS
function BattleRoleData.AutoSaveFormation(_FormStr,_Type)
  -- statements
  HttpCore.SaveGroup("3",_FormStr,"NULL","0",_Type,"BattleRoleData.AutoSaveFormationCallBack",BattleRoleData.AutoSaveFormationCallBack)
end
--自动读取保存的阵营
function BattleRoleData.AutoReadFormation(_Type,_CallBackName)
  -- statements
  HttpCore.GetGroup("3",_Type,"BattleRoleData.AutoReadFormationCallBack",BattleRoleData.AutoReadFormationCallBack,_CallBackName)
end
--自动读取请求回调
function BattleRoleData.AutoReadFormationCallBack(_Str,_CallBackName)
  -- statements
  HttpCore.CreatAnalyisJsonData(_Str,"AutoReadFormation")
  local _FormStr=HttpCore.GetAnalyisDataByKey("AutoReadFormation","formationInfo")
  print("_FormStr".._FormStr)
  BattleRoleData.AutoReadFormStr=_FormStr
  if _CallBackName ~=nil and _CallBackName ~= "" then
    -- statements
    Event.Go(_CallBackName)
end
end
--自动存储请求回调
function BattleRoleData.AutoSaveFormationCallBack(_Str)
  -- statements
end
--发送PVE结算战报
function BattleRoleData.PostPVEResult()
  -- statements
  local IsWin=0
  BattleRoleData.CheckPointStar=0
  if BattleRoleData.Bool_Pass==true then
    -- statements
    IsWin=1
    BattleRoleData.CheckPointStar=3
  end
  local _chapterId=""
  local _dossierId=""
  for key, value in pairs(GameData.tab.checkpoint) do
    -- statements
    if value[1] == BattleRoleData.Int_BattleID then
      -- statements
      _chapterId=value[16]
      _dossierId=value[15]
    end
  end
  local _HeroIdStr=""
  local _IsFirst=true
  for key, value in pairs(BattleRoleData.tab.RoleData) do
    -- statements
    if _IsFirst==true then
      -- statements
      _HeroIdStr=value[1]
      _IsFirst=false
    else
      _HeroIdStr=_HeroIdStr..","..value[1]
    end
  end
  HttpCore.PostPVEResult(_dossierId, _chapterId, BattleRoleData.Int_BattleID,IsWin,_HeroIdStr,BattleRoleData.Int_MonsterSum,BattleRoleData.Int_DeathCount,BattleRoleData.CheckPointStar,"BattleRoleData.CallBackGoPVEComplete",BattleRoleData.CallBackGoPVEComplete)
end

function BattleRoleData.CallBackGoPVEComplete(_Str)
  HttpCore.CreatAnalyisJsonData(_Str,"PVEResultRewardList")
  local ItemListCount= HttpRequestMGR.Instance:GetJsonListCount(_Str)
  BattleRoleData.tab.BattleRewardData={}
  if ItemListCount > 0 then
    -- statements
    for i = 0, ItemListCount - 1, 1 do
      -- statements
      local ItemInfoTab={}
      local _ItemId=HttpCore.GetAnalyisDataByKey("PVEResultRewardList","goodsId",i)
      local _ItemType=HttpCore.GetAnalyisDataByKey("PVEResultRewardList","type",i)
      local _ItemNum=HttpCore.GetAnalyisDataByKey("PVEResultRewardList","num",i)
      if _ItemType ~= "0" then
        table.insert(ItemInfoTab,_ItemId)
        table.insert(ItemInfoTab,_ItemNum)
        local _Bool_IsAdd = false --当前是否已经存储在 Flag
        for key, value in pairs(BattleRoleData.tab.BattleRewardData) do
          if value[1] == _ItemId then
            -- statements
            value[2]=""..(tonumber(value[2]) + tonumber(_ItemNum))
            _Bool_IsAdd=true
            break
          end
        end
        if not _Bool_IsAdd then
          table.insert(BattleRoleData.tab.BattleRewardData,ItemInfoTab)
        end
      end
    end
  end
  Event.Clear("FlushPlayerDataInitPveComplete")
  Event.Add("FlushPlayerDataInitPveComplete",function ()
    -- statements
    Event.Go("FullLoading_Refresh")
    MgrUI.GoFirst(UID.PVEComplete)
  end)
  JNPlayerData.HttpPostInitPlayerBag("FlushPlayerDataInitPveComplete")
end

--根据传入的左侧队伍初始化当前生效的组合技能buff
function BattleRoleData.InitLeftCombineSkillInfoTab(_TempTeam,_IsLeft)
  -- statements
  if _IsLeft == true then
    --左侧队伍
    BattleRoleData.Tab_CurLeftCombineSkillGroup={}
  else
    BattleRoleData.Tab_CurRightCombineSkillGroup={}
  end
  local _tempRoleCountTab = {} --临时用于计数当前各个组合技能的上场人数
  --遍历当前所有组合技能类型的成员ID与场上队员Id匹配，匹配到的小队则用小队id作为Key，当前小队上场人数作为value给_tempRoleCountTab赋值
  for key, value in pairs(CollectionData.tab.CombineGroup) do
    -- statements
    local _RoleIdList=JNStrTool.strSplit(",",value[4])
    for i, n in pairs(_TempTeam) do
      -- 遍历左侧上场队员信息
      for o, r in pairs(_RoleIdList) do
        -- 遍历当前组合小队成员idlist
        if ""..n.ID == r  then
          -- 匹配到对应队员ID
          if _tempRoleCountTab[value[1]] ~= nil then
            -- statements
            _tempRoleCountTab[value[1]] = _tempRoleCountTab[value[1]] + 1
          else
            _tempRoleCountTab[value[1]] = 1
          end
        end
      end
    end
  end
  for key, value in pairs(_tempRoleCountTab) do
    -- statements
    if value >= 2 then
      -- 当前小队的组合上场人数大于等于2个
      if _IsLeft == true then
        -- 右侧队伍
        table.insert(BattleRoleData.Tab_CurLeftCombineSkillGroup,key)
        table.insert(BattleRoleData.Tab_CurLeft_Number,0)
      else
        table.insert(BattleRoleData.Tab_CurRightCombineSkillGroup,key)
        table.insert(BattleRoleData.Tab_CurRight_Number,0)
      end
    end
  end
end

return BattleRoleData