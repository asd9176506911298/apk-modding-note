MgrLink = {}
MgrLink.IsLink = false
--------跳转管理---------
function MgrLink.LinkStart(_LinkMark)
    if "string" == type(_LinkMark) then
        _LinkMark = string.split(_LinkMark,'_')
    end
    MgrLink.IsLink = true
    if _LinkMark[2] == "zz" then
        ---跳转作战
        ---缓存作战所需数据
        StormViewModel.ReloadStormData()
        if _LinkMark[3] == "zy" then
            if SysLockControl.CheckSysLock(1102) then
                ---资源 需优化
                if _LinkMark[4] == "01" then
                    ActivationTaskViewModel.TurnToTaskPage = true
                    HomeViewModel.OpenChoose()
                else
                    ---跳转对应资源副本
                    MgrLink.TurnToResourcesPointPage(_LinkMark[4], _LinkMark[5])
                end
            else
                MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1102),1},true)
            end
        elseif _LinkMark[3] == "zyjxfb" then --道具详情界面跳转觉醒界面
            MgrLink.TurnToAwake(_LinkMark[4], _LinkMark[5])
        elseif _LinkMark[3] == "lhtf" then
            ---联合讨伐
            HomeViewModel.OpenCrusade(EventRaidControl.GetLIANHETAOFAData().activityType)
        elseif _LinkMark[3] == "0" then
            --打开主线
            StormViewModel.CurScrollType = 1
            HomeViewModel.OpenChoose()
        elseif _LinkMark[3] == "zx" then
            ---跳转副本页面
            MgrLink.TurnToStormPointPage(_LinkMark[4], _LinkMark[5])
        elseif _LinkMark[3] == "knfb" then
            ---打开困难FB
            HomeViewModel.TurnToHardMode()
            --跳转战术指导
        elseif _LinkMark[3] == "zszd" then
            if SysLockControl.CheckSysLock(1109) then
                ---进入战术指导ui
                MgrUI.GoHide(UID.GuidePoint_UI)
            else
                MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1109),1},true)
            end
            --跳转红色巨塔
        elseif _LinkMark[3] == "hsjt" then
            if SysLockControl.CheckSysLock(1105) then
                ---进入红色巨塔ui
                MgrUI.GoHide(UID.StormTower_UI)
            else
                MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1105),1},true)
            end
        end
    elseif _LinkMark[2] == "bj" then
        ---跳转补给
        HomeViewModel.OpenRoleCardDraw(nil,_LinkMark[3])
    elseif _LinkMark[2] == "bb" then
        ---跳转背包
        if _LinkMark[3] == "jj" then
            ---机甲核心
            HomeViewModel.OpenPlayerBag(nil,BagViewModel.BagPageEnum.PageCore)
        elseif _LinkMark[3] == "hxsp" then
            ---核心碎片
            HomeViewModel.OpenPlayerBag(nil,BagViewModel.BagPageEnum.PageCacheCore)
        end
    elseif _LinkMark[2] == "yx" then
        ---跳转演习
        HomeViewModel.OpenExercise()
    elseif _LinkMark[2] == "rw" then
        ---跳转任务
        HomeViewModel.OpenTask()
    elseif _LinkMark[2] == "sc" then
        ---需优化
        if _LinkMark[3] == "lhtf" then
            ---跳转联合讨伐商店
            if SysLockControl.CheckSysLock(1506) then
                --ShopViewModel.WhetherJumpIn = true
                --ShopViewModel.Page = { shopID=114003, ChildShopID=302 }
                --ShopViewModel.OpenShopUI()
                ShopViewModel.OpenLHTFShopUI()
            else
                MgrUI.Pop(UID.PopTip_UI, { SysLockControl.GetSystemLockTips(1506), 1 }, true)
            end
        elseif _LinkMark[3] == "wzbc" then
            ---跳转物资补给商店
            ShopViewModel.WhetherJumpIn = true
            ShopViewModel.Page = { shopID=114002 }
            ShopViewModel.OpenShopUI()
        elseif _LinkMark[3] == "cz" then
            ---钻石充值
            if SysLockControl.CheckSysLock(1501) then
                ShopViewModel.WhetherJumpIn = true
                ShopViewModel.Page = { shopID=114000 }
                local curUI = MgrUI.GetCurUI()
                if curUI.Uid == UID.Shop_UI then
                    ShopViewModel.WhetherJumpIn = false
                    curUI.Tog_ShopHome01().isOn=true
                    curUI.BtnList[ShopViewModel.Page.shopID].transform:GetComponent("Toggle").isOn = true
                    curUI.BtnList[ShopViewModel.Page.shopID].transform:GetComponent("Toggle").isOn = true
                else
                    ShopViewModel.OpenShopUI()
                end
            else
                MgrUI.Pop(UID.PopTip_UI, { SysLockControl.GetSystemLockTips(1506), 1}, true)
            end
        elseif tonumber(_LinkMark[3]) ~= nil then
            ---跳转兑换商店子页签
            local shoptypeCfg = ShoptypeLocalData.tab[tonumber(_LinkMark[4])]
            if shoptypeCfg then
                if SysLockControl.CheckSysLock(shoptypeCfg.systemopen) then
                    ShopViewModel.WhetherJumpIn = true
                    ShopViewModel.Page = { shopID=tonumber(_LinkMark[3]), ChildShopID=tonumber(_LinkMark[4]) }
                    ShopViewModel.OpenShopUI()
                else
                    MgrUI.Pop(UID.PopTip_UI, { SysLockControl.GetSystemLockTips(shoptypeCfg.systemopen), 1 }, true)
                end
            end
        elseif _LinkMark[3] == "mfzs" then
            ---兑换能源晶体
            MgrUI.Pop(UID.ExchangePop_UI,{ tonumber(SteamLocalData.tab[113042][2]), 0, "shop" })
        end
    elseif _LinkMark[2] == "wjxq" then
        if _LinkMark[3] == "zyjs" then
            if SysLockControl.CheckSysLock(2007) == false then
                return
            end
            PlayerAvatarViewModel.GetSupportData(function ()
                MgrUI.GoHide(UID.ChooseSupportRole_UI)
            end)
        end
    elseif _LinkMark[2] == "tlgm" then
        ---体力购买 需优化
        ---直接返回大厅
        MgrUI.GoFirst(UID.Home_UI)
    elseif _LinkMark[2] == "jsy" then
        ---驾驶员升级
        HomeViewModel.OpenCollection()
    elseif _LinkMark[2] == "jy" then
        ---跳转家园
        if _LinkMark[3] == "0" then
            HomeViewModel.OpenArk()
        elseif _LinkMark[3] == "yzts" then
            ---远征
            HomeViewModel.OpenArk("yuanzheng")
        elseif _LinkMark[3] == "cb" then
            ---搓背
            HomeViewModel.OpenBackRub()
        elseif _LinkMark[3] == "hxyf" then
            ---核心强化 需优化
            if _LinkMark[4] == "hs" then
                ArkViewModel.CurType = 3
                MgrUI.GoHide(UID.EnergyFactory_UI)
            else
                ArkViewModel.CurType = 2
                MgrUI.GoHide(UID.EnergyFactory_UI)
            end
        elseif _LinkMark[3] == "djhc" then
            ---道具合成
            HomeViewModel.OpenArk("gongchang")
        end
    elseif _LinkMark[2] == "qd" then
        ---跳转签到
        --MgrUI.Pop(UID.DailySign_UI)
        ActivityControl.OpenHuoDong(ActivityControl.activityTypeEnum.SIGN)
    elseif _LinkMark[2] == "hy" then
        if SysLockControl.CheckSysLock(1700) then
            ---好友
            if _LinkMark[3] == "hytj" then
                ---好友添加
                FriendViewModel.JumpToAddFriends = true
                FriendViewModel.OpenFriendUI()
            elseif _LinkMark[3] == "0" then
                FriendViewModel.OpenFriendUI()
            end
        else
            --MgrUI.Pop(UID.PopTip_UI,{"好友系统未解锁",2},true)
        end
    elseif _LinkMark[2] == "hd" then
        if _LinkMark[3] == "hdgk" then
            --活动关卡/Boss
            StormViewModel.CurPointType = StormViewModel.PointType.activity
            StormViewModel.CurDifficulty = StormViewModel.ActivityDifficulty.EASY
            MgrUI.GoHide(UID.EventLevels_UI)
        elseif _LinkMark[3] == "hdsc" then
            --活动商店
            MgrUI.GoHide(UID.EventShop_UI)
        elseif _LinkMark[3] == "hdzjm" then
            ---活动主界面
            HaiYueControl.OpenUI()
        elseif _LinkMark[3] == "txz" then
            ---通行证
            ---如果未解锁
            if SysLockControl.CheckSysLock(1510) == false then
                MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1510),1},true)
                return
            end
            ---如果在活动时间内
            if PassportControl.GetIsInMiddle() then
                MgrUI.GoHide(UID.Passes_UI)
            else
                MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("home_ui_tips2"), 2 }, true)
            end
        elseif _LinkMark[3] == "0" then
            ---活动主界面
            ActivityControl.OpenHuoDong(tonumber(_LinkMark[4]))
        end
    elseif _LinkMark[2] == "summer" then
        ---夏活
        if _LinkMark[3] == "zjm" then
            ---夏活主界面
            if SysLockControl.CheckSysLock(1106)  then
                SummerControl.OpenSummerHome()
            else
                MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1106),1},true)
            end
        elseif _LinkMark[3] == "tsgk" then
            ---夏活探索界面
            SummerControl.OpenSummerLevel()
        elseif _LinkMark[3] == "boss" then
            ---夏活BOSS界面
            SummerControl.OpenSummerBoss()
        elseif _LinkMark[3] == "sd" then
            ---夏活商店
            SummerControl.OpenSummerShop()
        end
    end
    MgrLink.IsLink = false
end

--道具详情界面跳转对应的觉醒界面
function MgrLink.TurnToAwake(plotIndex, stormIndex)
    if not SysLockControl.CheckSysLock(1102) then
        MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1102),1},true)
        return
    end
    local pData = nil
    for i, v in ipairs(StormViewModel.CacheAssetScrollData) do
        if v.id == tonumber(plotIndex) then
            if  SysLockControl.CheckSysLock(1103) then
                --if StormControl.CheckPointLock(tonumber(stormIndex)) == false then
                if StormControl.CheckScrollLock(tonumber(plotIndex)) == false then
                    --关卡没有解锁
                    MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("bag_ui_text4"), 1 }, true)
                    return
                else
                    --pData = StormViewModel.CacheAssetScrollData[8]      ---周二四六七开攻击觉醒 
                    pData = MgrLink.GetAwakeData(tonumber(plotIndex))
                end
            else
                --觉醒副本没有开启
                MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("bag_ui_text4"), 1 }, true)
                return
            end
        end
    end

    if MgrUI.GetPopUI(UID.NewRoleFormation_UI) ~= nil and plotIndex == "600201" or plotIndex == "600202" or plotIndex == "600203" or plotIndex == "600204" then
        Event.Go("HideNewRoleFormationSelf")
    end

    ---资源ui创建
    StormViewModel.curChooseRes = pData
    --if MgrUI.IsShow(UID.StormPoint_UI)  then
    --    MgrUI.GoBackTo(UID.Home_UI)
    --    MgrTimer.AddDelayNoName(0.4,function()
    --        StormViewModel.OpenStormPointUI(pData, StormViewModel.PointType.res)
    --    end)
    --else
        StormViewModel.OpenStormPointUI(pData, StormViewModel.PointType.res)
    --end
end

--根据觉醒关卡ID获得关卡数据
function MgrLink.GetAwakeData(id)
    local data = nil
    for index, value in ipairs(StormViewModel.CacheAssetScrollData) do
        if id == value.id then
            data = StormViewModel.CacheAssetScrollData[index]
        end
    end
    return data
end

---跳转对应资源界面
function MgrLink.TurnToResourcesPointPage(plotIndex, stormIndex)
    if not SysLockControl.CheckSysLock(1102) then
        MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1102),1},true)
        return
    end

    StormViewModel.ReloadStormData()
    if plotIndex == "600001" then
        StormViewModel.curChooseRes = StormViewModel.CacheAssetScrollData[10]
        StormViewModel.OpenStormPointUI(StormViewModel.CacheAssetScrollData[10],StormViewModel.PointType.res)
        return
    end

    --参数：章节,关卡
    local pData = nil
   -- StormViewModel.ReloadStormData()
    for i, v in ipairs(StormViewModel.CacheAssetScrollData) do
        if v.id == tonumber(plotIndex) then
            if stormIndex == "610000" and SysLockControl.CheckSysLock(1006) then
                if not SysLockControl.CheckSysLock(1104) then
                    MgrUI.Pop(UID.PopTip_UI,{SysLockControl.GetSystemLockTips(1104),1},true)
                    return
                end
                if StormControl.CheckPointLock(tonumber(stormIndex)) == false then
                    pData = StormViewModel.CacheAssetScrollData[9]      ---周二三五七开攻击核心
                elseif StormControl.CheckPointLock(tonumber(stormIndex + 1)) == false then
                    pData = StormViewModel.CacheAssetScrollData[i]      ---周一三四六开生命核心
                end
            elseif stormIndex == "620100" and SysLockControl.CheckSysLock(1004) then
                if StormControl.CheckPointLock(tonumber(stormIndex)) == false then
                    pData = StormViewModel.CacheAssetScrollData[8]      ---周二四六七开攻击觉醒
                elseif StormControl.CheckPointLock(tonumber(stormIndex + 1)) == false then
                    pData = StormViewModel.CacheAssetScrollData[12]     ---周一三五七开防卫觉醒
                end
            else
                if StormControl.CheckPointLock(tonumber(stormIndex)) then
                    pData = StormViewModel.CacheAssetScrollData[i]      ---开对应副本
                end
            end
        end
    end
    if not pData then
        MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("mgrlink_tips2"), 1 }, true)
        return
    end
    ---资源ui创建
    StormViewModel.curChooseRes = pData
    StormViewModel.OpenStormPointUI(pData, StormViewModel.PointType.res)
end

---跳转副本界面
function MgrLink.TurnToStormPointPage(plotIndex, stormIndex)
    --参数：章节,关卡
    local pData = StormControl.GetStormScrollById(tonumber(plotIndex))
    local isLock = StormControl.CheckScrollLock(tonumber(plotIndex))
    local pointData = StormControl.GetStormPointByID(tonumber(stormIndex))
    StormViewModel.ReloadStormData()
    if isLock then
        StormViewModel.TurnStormPointUI(pData, StormViewModel.PointType.main, pointData)
    else
        MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("mgrlink_tips3"), 1 }, true)
    end
end

---跳转到指定剧情
function MgrLink.TurnToPlot(type,chapterId)
    ---剧情未解锁
    if ArtAtlasControl.CheckUnlock(type,chapterId) == false then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_summerevent_text35")},true)
        return
    end
    ArtAtlasControl.OpenPlotAtlasUI(type,chapterId)
end

return MgrLink