UISysTools={}

-- @field 循环异步创建物体模块
UISysTools.Int_HasCreatCount=0 --已经创建的物体
UISysTools.Int_MaxCreatConut=0 --最大创建数量
UISysTools.Int_PerRoundCreatCount=0 --每轮创建数量
UISysTools.Float_PerRoundDelay=0 --每轮创建延迟
UISysTools.Tab_CreatInfoTab={} --当前用于循环创建的信息表
-- UISysTools.Bool_IsEndCreat=true --是否停止创建flag
UISysTools.Func_CurAsyncCreatFunc=nil
-- @function 终止所有异步创建物体
function UISysTools.StopAllAsyncCreatGo()
    -- statements
    print("取消异步创建")
    UISysTools.Int_HasCreatCount=0
    UISysTools.Int_MaxCreatConut=0
    UISysTools.Int_PerRoundCreatCount=0
    UISysTools.Float_PerRoundDelay=0
    UISysTools.Bool_IsEndCreat=true
    UISysTools.Func_CurAsyncCreatFunc=nil
    UISysTools.Tab_CreatInfoTab={}
    MgrTimer.Cancel("AsyncCreatGo")
end
-- @function 开始循环异步创建物体
function UISysTools.AsyncCreatGo(_CreatFunc,_FuncParaValue,_CreatCountPerRound,_AsyncDelaytime)
    -- statements
    UISysTools.Int_HasCreatCount=0
    UISysTools.Int_MaxCreatConut=0
    UISysTools.Int_PerRoundCreatCount=0
    UISysTools.Float_PerRoundDelay=0
    UISysTools.Tab_CreatInfoTab=_FuncParaValue
    UISysTools.Float_PerRoundDelay =_AsyncDelaytime
    UISysTools.Func_CurAsyncCreatFunc=_CreatFunc
    local tempTabCount = TableToObject.GetTableLength(_FuncParaValue) --当前创建信息表数量
    UISysTools.Int_MaxCreatConut=tempTabCount
    print("UISysTools.Int_MaxCreatConut"..UISysTools.Int_MaxCreatConut)
    if tempTabCount < _CreatCountPerRound then
        -- 判断当前表中是否够一轮创建数量
        UISysTools.Int_PerRoundCreatCount = tempTabCount
    else
        UISysTools.Int_PerRoundCreatCount = _CreatCountPerRound
    end
    UISysTools.Bool_IsEndCreat=false
    MgrTimer.AddDelayNoName(UISysTools.Float_PerRoundDelay,UISysTools.LoopCreatGo,nil)
end

function UISysTools.LoopCreatGo()
    -- 如果终止flag为true则跳出
    if UISysTools.Bool_IsEndCreat == true then
        -- statements
        return
    end
    --当前可创建的物体在信息表中下标上线阈值   已创建数量+本次一轮创建数量
    local curTargetIndex =  UISysTools.Int_HasCreatCount + UISysTools.Int_PerRoundCreatCount
    for key, value in pairs(UISysTools.Tab_CreatInfoTab) do
        --当前生成物体下标是否符合阈值(大于已经创建的下标总数小于最大创建数量)
        if key <=  curTargetIndex and key > UISysTools.Int_HasCreatCount then
            -- statements
            UISysTools.Func_CurAsyncCreatFunc(value)
        end
    end
    UISysTools.Int_HasCreatCount = UISysTools.Int_HasCreatCount+ UISysTools.Int_PerRoundCreatCount
    if UISysTools.Int_MaxCreatConut - UISysTools.Int_HasCreatCount < UISysTools.Int_PerRoundCreatCount then
        -- 如果当前剩余数量已经不足再创建一轮物体，则将每轮创建数量更新至剩余数量
        UISysTools.Int_PerRoundCreatCount =UISysTools.Int_MaxCreatConut - UISysTools.Int_HasCreatCount
    end
    if UISysTools.Int_HasCreatCount >= UISysTools.Int_MaxCreatConut then
        -- statements
        print("UISysTools.Int_HasCreatCount创建了"..UISysTools.Int_HasCreatCount.."总量UISysTools.Int_MaxCreatConut"..UISysTools.Int_MaxCreatConut.."跳出")
        UISysTools.Bool_IsEndCreat=true
    end
    MgrTimer.Cancel("AsyncCreatGo")
    MgrTimer.AddDelay("AsyncCreatGo", UISysTools.Float_PerRoundDelay, UISysTools.LoopCreatGo, nil)
end


--@field 其他UI工具类模块
--根据对应的ID播放对应的角色动画以及语音等
function UISysTools.PlayTargetRoleAniVoice(_ActorLineId,_LuaFunc,_SpineObj,_TargetText)
    -- statements
    local _AniName=""  --动画文件名
    local _ActorLineWord=""
    local _AudioPath="RoleVoiceAudio/"
    local _actor =  ActorLinesLocalData.tab[_ActorLineId]
    _AniName=_actor[6]
    _ActorLineWord=_actor[7]
    _AudioPath=_AudioPath.._actor[13]
    if _SpineObj.gameObject ~= nil and _AniName ~= "0" then
        -- statements
        CMgrSpine.Instance:SetSpineAnimation(_SpineObj,_AniName,false)
    end
    _TargetText:GetComponent("Text").text="".._ActorLineWord
    --LuaAudioPlayer.PlaySingleVoiceByAudioClipPath(_AudioPath,_LuaFunc)
end


-- @function 向一个立绘展示框中初始化一个人物立绘信息
function UISysTools.InitRoleSpineToBox(_Root,_RoleId,_PosIndex)
    -- statements
    local _PosInfoTab={}
    local _LihuiName=""
    local _RolePosId=""  --人物的立绘坐标对应表ID
    for key, value in pairs(GameData.tab.roleattribute) do
        -- 获取对应的立绘文件名
        if "".._RoleId == value[1] then
            _LihuiName=value[8]
            _RolePosId=value[9]
        end
    end
    for key, value in pairs(GameData.tab.charactercoordinates) do
        -- statements
        if _RolePosId == value[1] then
            _PosInfoTab=value[_PosIndex]
        end
    end
    local _tempPosTab1 =JNStrTool.strSplit(";", _PosInfoTab)
    local _tempPosTab2=JNStrTool.strSplit(",", _tempPosTab1[1])
    print("Spine _RoleId".._RoleId)
    MgrRes.LoadWatchAuto(_Root,_RoleId,tonumber(_tempPosTab2[1]),tonumber(_tempPosTab2[2]),tonumber(_tempPosTab1[2]))
end


-- @function 获取当前玩家指挥官获得输入经验后的等级以及经验
function UISysTools.GetFinalPlayerLvExp(_CurLv,_CurExp,_InputExp)
    print("_CurLv".._CurLv)
    local _PlayerNextLvNeedExp=(math.pow(tonumber(_CurLv),1.2)*5)+50
    print("_PlayerNextLvNeedExp".._PlayerNextLvNeedExp)
    local _CurSumExp=_CurExp+_InputExp
    if _CurSumExp >= _PlayerNextLvNeedExp then
        -- 经验溢出递归继续算出下个等级是否超出
        -- 等级加一
        local _NextCurLv=_CurLv+1
        -- 减去升级需要的经验
        local _NextInputExp=_CurSumExp-_PlayerNextLvNeedExp
        _CurLv,_CurSumExp = UISysTools.GetFinalPlayerLvExp(_NextCurLv,0,_NextInputExp)
        return _CurLv,_CurSumExp
    else
        return _CurLv,_CurSumExp
    end
end
-- @function 获取当前机娘获得输入经验后的等级以及经验
-- @param _CurLv 当前等级
-- @param _CurExp 当前经验
-- @param _InputExp 输入经验
-- @param _BattleRole 当前机娘数据结构体
function UISysTools.GetFinalRoleLvExp(_CurLv,_CurExp,_InputExp,_BattleRole)
    -- print("_CurLv".._CurLv)
    -- print("_CurExp".._CurExp)
    -- print("_InputExp".._InputExp)
    if tonumber(_CurLv) >= tonumber(_BattleRole.LvMax) then
        --溢出最大等级返回当前等级，经验返回0
        return _CurLv,_InputExp
    end
    local _PlayerNextLvNeedExp=BattleRole.ReturnExp(_BattleRole,_CurLv)
    local _CurSumExp=_CurExp + _InputExp
    if _CurSumExp >= _PlayerNextLvNeedExp then
        -- 经验溢出递归继续算出下个等级是否超出
        -- 等级加一
        local _NextCurLv=_CurLv+1
        -- 减去升级需要的经验
        local _NextInputExp=_CurSumExp-_PlayerNextLvNeedExp
        _CurLv,_CurSumExp = UISysTools.GetFinalRoleLvExp(_NextCurLv,0,_NextInputExp,_BattleRole)
        return _CurLv,_CurSumExp
    else
        return _CurLv,_CurSumExp
    end
end
-- @function 根据输入信息初始化界面的一个玩家背包物品Tag
function UISysTools.InitPlayerItemPanel(_Root,_Prefab,_IdList,_M)
    -- statements
    _Prefab:SetActive(false)
    Tools.ClearAllChild(_Root)
    for key, value in pairs(_IdList) do
        -- statements
        local ItemPanelObj = UISysTools.CreatGo(_Prefab,_Root)
        local _ItemIcon=CJNUIMgr.GetSunUseName(ItemPanelObj,"ItemIcon")
        local _ItemCountText=CJNUIMgr.GetSunUseName(ItemPanelObj,"ItemCountText")
        local _Btn_GoShop=CJNUIMgr.GetSunUseName(ItemPanelObj,"+")
        local _IsFoundInBag=false --是否拥有该物品
        local _Count = 0 --默认的数量
        local _pBag = ItemControl.GetNotZeroItems()
        if _pBag[value[1]] then
            _Count = _pBag[value[1]].count
            _IsFoundInBag=true
        end
        _ItemCountText:GetComponent("Text").text=_Count
        local item = ItemLocalData.tab[value[1]]
        MgrRes.LoadSprite(_ItemIcon,"Item/"..item.icon)
        Tools.SetObjRectScale(_ItemIcon,value[2])
        UIEvent.LuaClick(_Btn_GoShop, Handle(_M, function ()
            --LuaAudioPlayer.ResetSingleVoiceAudio()
            MgrUI.ShowBuyGoods(2)
        end))
    end
end
-- @function 根据输入信息初始化界面的一个玩家背包物品Tag
function UISysTools.InitPlayerItemPanel_NoClickEvent(_Root,_Prefab,_IdList,_M)
    -- statements
    _Prefab:SetActive(false)
    Tools.ClearAllChild(_Root)
    for key, value in pairs(_IdList) do
        -- statements
        local ItemPanelObj = UISysTools.CreatGo(_Prefab,_Root)
        local _ItemIcon=CJNUIMgr.GetSunUseName(ItemPanelObj,"ItemIcon")
        local _ItemCountText=CJNUIMgr.GetSunUseName(ItemPanelObj,"ItemCountText")
        local _Count = 0 --默认的数量
        local _IsFoundInBag=false --是否拥有该物品
        for i, n in pairs(JNPlayerData.ItemBag) do
            -- statements
            if n[2] == ""..value[1] then
                _Count=n[3]
                _IsFoundInBag=true
            end
        end
        if _IsFoundInBag == false then
            -- statements
            _Count = 0
        end
        _ItemCountText:GetComponent("Text").text="".._Count
        for i, n in pairs(GameData.tab.goods) do
            -- statements
            if n[1] == ""..value[1] then
                -- statements
                MgrRes.LoadSprite(_ItemIcon,"Item/"..n[4])
            end
        end
        Tools.SetObjRectScale(_ItemIcon,tonumber(value[2]))
    end
end
-- @function 初始化一个物品预制体
function UISysTools.InitItemPrefab(_Item,_Id,_Sum,_Scale)
    -- statements
    print("_Id".._Id.."_Sum".._Sum)
    local _RewardRankImg=CJNUIMgr.GetSunUseName(_Item,"RewardRankImg")
    local _RewardIconImg=CJNUIMgr.GetSunUseName(_Item,"RewardIconImg")
    local _ItemCountText=CJNUIMgr.GetSunUseName(_Item,"ItemCountText")
    local _ItemStarPrefab=CJNUIMgr.GetSunUseName(_Item,"ItemStarPrefab")
    local _ItemStarRoot=CJNUIMgr.GetSunUseName(_Item,"ItemStarRoot")
    local _StarPanel=CJNUIMgr.GetSunUseName(_Item,"StarPanel")
    local _VFXPanel=CJNUIMgr.GetSunUseName(_Item,"VFXPanel")
    local _Rank_2_Vfx=CJNUIMgr.GetSunUseName(_VFXPanel,"lanse_vfx")
    local _Rank_3_Vfx=CJNUIMgr.GetSunUseName(_VFXPanel,"zise_vfx")
    local _Rank_4_Vfx=CJNUIMgr.GetSunUseName(_VFXPanel,"jinse_vfx")
    local _Img_ItemCountPivot=CJNUIMgr.GetSunUseName(_Item,"Img_ItemCountPivot")
    local _Img_ItemCountBg=CJNUIMgr.GetSunUseName(_Item,"Img_ItemCountBg")
    _ItemStarPrefab:SetActive(false)
    for key, value in pairs(ItemLocalData.tab) do
        -- 匹配商品信息
        if value[1] == "".._Id then
            -- statements
            if tonumber(value[15]) <= 0 then
                -- 没有星级隐藏星级panel
                print("隐藏该物品"..value[1].."星级为"..value[15])
                _StarPanel:SetActive(false)
                _ItemStarRoot:SetActive(false)
            else
                print("显示该物品"..value[1].."星级为"..value[15])
                _StarPanel:SetActive(true)
                _ItemStarRoot:SetActive(true)
                UISysTools.InitStarPanel(tonumber(value[15]),_ItemStarRoot,_ItemStarPrefab)
            end
            MgrRes.LoadSprite(_RewardIconImg,"Item/"..value[4])
            MgrRes.LoadSprite(_RewardRankImg,"Item/Rank/ItemRank_"..value[5])
            --根据品阶显示特效
            if value[5] == "2" then
                _Rank_2_Vfx:SetActive(true)
                _Rank_3_Vfx:SetActive(false)
                _Rank_4_Vfx:SetActive(false)
            elseif value[5] == "3" then
                -- statements
                _Rank_2_Vfx:SetActive(false)
                _Rank_3_Vfx:SetActive(true)
                _Rank_4_Vfx:SetActive(false)
            elseif value[5] == "4" then
                -- statements
                _Rank_2_Vfx:SetActive(false)
                _Rank_3_Vfx:SetActive(false)
                _Rank_4_Vfx:SetActive(true)
            else
                _Rank_2_Vfx:SetActive(true)
                _Rank_3_Vfx:SetActive(false)
                _Rank_4_Vfx:SetActive(false)
            end
        end
    end
    if tonumber(_Sum) >= 10000 then
        --_Sum = math.floor(tonumber(_Sum)/1000)
        _ItemCountText:GetComponent("Text").text=JNStrTool.numberAbbr(_Sum) --"".._Sum.."K"
    else
        _ItemCountText:GetComponent("Text").text=JNStrTool.numberAbbr(_Sum) 
    end
    Tools.ForceRebuildLayout(_ItemCountText)
    Tools.ForceRebuildLayout(_Img_ItemCountBg)
    Tools.ForceRebuildLayout(_Img_ItemCountPivot)
    Tools.SetObjRectScale(_Item,_Scale)
end
-- @function 初始化一个物品预制体不带特效
function UISysTools.InitItemPrefabWithOutVfx(_Item,_Id,_Sum,_Scale)
    -- statements
    -- print("_Id".._Id.."_Sum".._Sum)
    local _RewardRankImg=CJNUIMgr.GetSunUseName(_Item,"RewardRankImg")
    local _RewardIconImg=CJNUIMgr.GetSunUseName(_Item,"RewardIconImg")
    local _ItemCountText=CJNUIMgr.GetSunUseName(_Item,"ItemCountText")
    local _ItemStarPrefab=CJNUIMgr.GetSunUseName(_Item,"ItemStarPrefab")
    local _ItemStarRoot=CJNUIMgr.GetSunUseName(_Item,"ItemStarRoot")
    local _StarPanel=CJNUIMgr.GetSunUseName(_Item,"StarPanel")
    local _Img_ItemCountPivot=CJNUIMgr.GetSunUseName(_Item,"Img_ItemCountPivot")
    local _Img_ItemCountBg=CJNUIMgr.GetSunUseName(_Item,"Img_ItemCountBg")
    _ItemStarPrefab:SetActive(false)
    for key, value in pairs(GameData.tab.goods) do
        -- 匹配商品信息
        if value[1] == "".._Id then
            -- statements
            if tonumber(value[15]) <= 0 then
                -- 没有星级隐藏星级panel
                -- print("隐藏该物品"..value[1].."星级为"..value[15])
                _StarPanel:SetActive(false)
                _ItemStarRoot:SetActive(false)
            else
                -- print("显示该物品"..value[1].."星级为"..value[15])
                _StarPanel:SetActive(true)
                _ItemStarRoot:SetActive(true)
                UISysTools.InitStarPanel(tonumber(value[15]),_ItemStarRoot,_ItemStarPrefab)
            end
            MgrRes.LoadSprite(_RewardIconImg,"Item/"..value[4])
            MgrRes.LoadSprite(_RewardRankImg,"Item/Rank/ItemRank_"..value[5])
        end
    end
    if tonumber(_Sum) >= 10000 then
        --_Sum = math.floor(tonumber(_Sum)/1000)
        _ItemCountText:GetComponent("Text").text=JNStrTool.numberAbbr(_Sum)-- "".._Sum.."K"
    else
        _ItemCountText:GetComponent("Text").text=JNStrTool.numberAbbr(_Sum)
    end
    Tools.ForceRebuildLayout(_ItemCountText)
    Tools.ForceRebuildLayout(_Img_ItemCountBg)
    Tools.ForceRebuildLayout(_Img_ItemCountPivot)
    Tools.SetObjRectScale(_Item,_Scale)
end
-- @function 创建一个机娘头像框
function UISysTools.CreatRoleIconPrefab(_RoleData,_Root)
    -- 根据传入的机娘信息刷新机娘头像UI
    MgrRes.GetPrefab('ABOriginal/Effect/Prefab_RoleIcon.prefab',function(_tempIcon)
        _tempIcon.transform:SetParent(_Root.transform)
        _tempIcon.transform.localScale = Vector3(1,1,1)
        _tempIcon.transform.localPosition = Vector3.zero
        local _Img_RoleIcon=CJNUIMgr.GetSunUseName(_tempIcon,"Img_RoleIcon")
        local _Img_RankKuang=CJNUIMgr.GetSunUseName(_tempIcon,"Img_RankKuang")
        local _Img_ProIcon=CJNUIMgr.GetSunUseName(_tempIcon,"Img_ProIcon")
        local _Text_Rank=CJNUIMgr.GetSunUseName(_tempIcon,"Text_Rank")
        local _Text_Lv=CJNUIMgr.GetSunUseName(_tempIcon,"Text_Lv")
        local _Panel_Star_HighLight=CJNUIMgr.GetSunUseName(_tempIcon,"Panel_Star_HighLight")
        local _Img_StarJueXingPrefab=CJNUIMgr.GetSunUseName(_tempIcon,"Img_StarJueXingPrefab")
        local _Img_StarPrefab=CJNUIMgr.GetSunUseName(_tempIcon,"Img_StarPrefab")
        _Img_StarJueXingPrefab:SetActive(false)
        _Img_StarPrefab:SetActive(false)
        MgrRes.LoadLongIcon(_Img_RoleIcon,_RoleData.ID)
        if _RoleData.IsAwaken == true then
            -- 觉醒星
            UISysTools.InitStarPanel(tonumber(_RoleData.StartLV),_Panel_Star_HighLight,_Img_StarJueXingPrefab)
        else
            UISysTools.InitStarPanel(tonumber(_RoleData.StartLV),_Panel_Star_HighLight,_Img_StarPrefab)
        end
        _Text_Rank:GetComponent("Text").text="+".._RoleData.SkillLV
        _Text_Lv:GetComponent("Text").text="".._RoleData.LV
        MgrRes.LoadSprite(_Img_ProIcon,"Attribute/ProIcon_".._RoleData.Occupation)
        MgrRes.LoadSprite(_Img_RankKuang,"Quality/RoleRankN_".._RoleData.Rank)
    end)
    return nil
end
--创建一个物体
function UISysTools.CreatGo(_Prefab,_Root)
    -- statements
    local tempObj=CJNUIMgr.CreatGo(_Prefab,_Root)
    tempObj.transform.localPosition = Vector3.zero
    return tempObj
end
--创建星星
function UISysTools.CreatStar(_Root,_Prefab)
    -- statements
    local UnJuxingStar=CJNUIMgr.CreatGo(_Prefab,_Root)
    UnJuxingStar.transform.localPosition = Vector3(UnJuxingStar.transform.localPosition.x,UnJuxingStar.transform.localPosition.y,0)
end
--根据星级对对应根节点初始化星星
function UISysTools.InitStarPanel(_StarLV,_Root,_Prefab)
    -- statements
    Tools.ClearAllChild(_Root)
    for i = 1, _StarLV, 1 do
        -- statements
        UISysTools.CreatStar(_Root,_Prefab)
    end
end

function UISysTools.GetCorrectRate(_InputValue1,_InputValue2)
    -- statements
    local _ReturnRate=0
    if _InputValue1 ~= 0 and _InputValue2 ~= 0 then
        local _InputRate=_InputValue1/_InputValue2
        _ReturnRate=(math.floor(_InputRate*1000))/1000
    end
    return _ReturnRate
end
--根据日期获取星期几
function UISysTools.GetWeekNum()
    local weekNum = os.date("*t",os.time()).wday  -1
    if weekNum == 0 then
        weekNum = 7
    end
    return weekNum
end

-----------------------开启警告弹窗--------------

function UISysTools.PopWarn(_WarnText)
    -- statements
    JNGearData.WarnText=_WarnText
    MgrUI.Pop(UID.WarnningPanel)
    MgrTimer.AddDelayNoName(2,UISysTools.ClosePop,nil)
end
function UISysTools.ClosePop()
    -- statements
    MgrUI.ClosePop(UID.WarnningPanel)
end
-----------------------开启警告弹窗结束---------------------
return UISysTools