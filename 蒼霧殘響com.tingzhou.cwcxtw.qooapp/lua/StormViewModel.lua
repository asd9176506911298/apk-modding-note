require("LocalData/ActorLinesLocalData")
require("LocalData/WorldbossLocalData")
require("ReadData/WorldBossData")

---战役 VM
StormViewModel = {}
---@type StormScrollData[] 活动卷信息缓存
StormViewModel.CacheEventRaidScrollData = {}
---@type StormPointData[] 活动关卡信息缓存
StormViewModel.CacheEventRaidPointData = {}
---@type StormScrollData[] 剧情卷信息缓存
StormViewModel.CachePlotScrollData = {}
StormViewModel.CacheHardPlotScrollData = {}
---@type StormScrollData[] 资源卷信息缓存
StormViewModel.CacheAssetScrollData = {}
---@type StormPointData[]  常规关卡缓存(挑战战术指导世界boss类不在其中)
StormViewModel.CacheAllPointData = {}
---@type StormScrollData[] 红色巨塔卷信息缓存
StormViewModel.CacheTowerScrollData = {}
---@type StormPointData[]  红色巨塔关卡缓存
StormViewModel.CacheTowerPointData = {}
---@type StormScrollData[] 战术指导卷信息缓存
StormViewModel.CacheGuideScrollData = {}
---@type StormPointData[]  战术指导关卡缓存
StormViewModel.CacheGuidePointData = {}
---@type StormScrollData[] 困难卷信息缓存
StormViewModel.CacheHardScrollData = {}
---@type StormPointData[]  困难关卡缓存
StormViewModel.CacheHardPointData = {}
---@type StormScrollData 当前所在卷
StormViewModel.CurScrollData = nil
---@type StormPointData 当前选择的关卡
StormViewModel.CurPointData = nil
---@type StormPointData 暂时保存当前选择的关卡
StormViewModel.tempCurPointData = nil
---@type StormScrollData 当前所在困难卷
StormViewModel.CurHardScrollData = nil
---当前是否是好友支援阵容
StormViewModel.FriendSupport = false
---当前关卡状态
StormViewModel.CurPointState = 0
---关卡状态类型
StormViewModel.PointState = {
    wait = 0,           ---等待
    firstPlot = 1,      ---战前剧情中
    fight = 2,          ---战斗中
    lastPlot = 3,       ---战后剧情中
    finish = 4,         ---结束
}
---关卡困难度
StormViewModel.LevelType = {
    Normal = 0,
    Hard = 1,
}
---当前世界bossId(activityID)
StormViewModel.CurStormBossId = 0
StormViewModel.CurStormBossId_Monster = 0
---当前模拟世界bossId(activityID)
StormViewModel.CurStormAnaBossId = 0
StormViewModel.CurStormAnaBossId_Monster = 0
---当前联合讨伐是否为模拟战
StormViewModel.IsAnaWorldBoss = false
---是否为剧情模式
StormViewModel.isPlotModel = false
---当前关卡类型
StormViewModel.CurPointType = nil
---当前选中的关卡id
StormViewModel.curChooseId = nil
---当前选中的章节类型
StormViewModel.CurScrollType = nil
---当前的挑战类型
StormViewModel.CurChallenge = nil
---当前选中的资源关章节
StormViewModel.curChooseRes = nil
---当前选择的资源关卡
StormViewModel.CurChooseResPoint = nil
---当前选中的普通关卡
StormViewModel.CurChooseNormal = nil
---当前选中的困难关卡
StormViewModel.CurChooseHard = nil
---当前选中的红色巨塔关卡
StormViewModel.CurChooseTower = nil
---当前选中的战术引导关卡
StormViewModel.CurChooseGuide = nil
---当前选中的剧情活动关卡
StormViewModel.curSelectData = nil

---挑战类型
StormViewModel.ChallengeType = {
    guide = 1,   ---战术指导
    tower = 2,   ---红色巨塔
}

---关卡类型
StormViewModel.PointType = {
    main = 1,   ---主线剧情
    res = 2,    ---资源日常
    tower = 3,  ---挑战爬塔
    guide = 4,  ---战术指导
    activity = 5,   ---活动关卡
    activityBoss = 6    ---活动Boss
}
---章节类型
StormViewModel.ChapterType = {
    MAINEASY = 0,           ---主线简单
    MAINHARD = 1,           ---主线困难
    DAILYRES = 10,          ---日常物资获取
    DAILYCORE = 11,         ---日常核心碎片
    DAILYCHARA = 12,        ---日常突破材料
    ACTIVITYEASY = 100,     ---活动本简单
    ACTIVITYHARD = 101,     ---活动本困难
    ACTIVITYBOSS = 102      ---活动本BOSS
}
---关卡战斗类型
StormViewModel.PointBattleType = {
    NORMAL_BATTLE = 0,   ---普通关卡
    LITTLE_BOSS = 1,     ---小BOSS
    STORY = 2,           ---剧情模式
    PVP = 3,            ---PVP
    PLOTBOSS = 5,        ---worldBoss/剧情boss
    NORMAL_BOSS = 15,    ---关卡BOSS
    ACTIVITY_BOSS = 16,   ---活动本BOSS(已废弃)
    LOGIC_BATTLE = 100,     ---记录位置的战斗类型
    LOGIC_PLOT = 101,       ---记录位置的剧情与其他类型
    LOGIC_BOSS = 102,       ---记录位置的boss战斗
    ACTIVITY_NEWBOSS = 103,         ---活动BOSS
    ACTIVITY_BATTLE = 104,          ---活动战斗关卡
    ACTIVITY_PLOT = 105,            ---活动剧情关卡
    ACTIVITY_BLOODBOSS = 106,       ---活动BOSS记录血量
    ACTIVITY_SEAT = 160,            ---活动类型末尾占位
    NOVICE_BOSS = 998,              ---教学关卡BOSS
    NOVICE_BATTLE = 999             ---新手战斗关卡
}
---当前难度
StormViewModel.CurDifficulty = nil
---活动难度
StormViewModel.ActivityDifficulty = {
    EASY = 1,
    MIDDLE = 2,
    HARD = 3
}
---@type RoleData[] 当前角色数据缓存
StormViewModel.CacheHeroList = {}
---助战Npc阵容固定保存id
StormViewModel.NpcTeamStaticId = 666
---@type FighterBase[] 当前助战Npc阵容
StormViewModel.NpcTeam = {}
StormViewModel.FriendSupportTeam = {}
StormViewModel.localTeam = {}
StormViewModel.IsPlotStarting = false   ---是否剧情正在播放剧情
StormViewModel.CurChoosePlot = 1
---当前关卡困难度 0是普通 1是困难
StormViewModel.CurLevelType = StormViewModel.LevelType.Normal

---初始化
function StormViewModel.Init(usm, callback)
    StormViewModel.ReloadStormData()    ---加载战役数据缓存
    StormViewModel.OpenStormScrollUI(usm, callback)  ---打开战役卷ui
end
---销毁
function StormViewModel.Close()
    MgrUI.GoBack()
end

---打开战役卷UI
function StormViewModel.OpenStormScrollUI(usm, callback)
    if usm then
        --播放usm
        MgrUI.Pop(UID.UsmPlay,{"EnterBattleChoose3"})
        MgrTimer.AddDelayNoName(0.8,function()
            MgrUI.GoHide(UID.StormScroll_UI, function ()
                if callback then
                    callback()
                end
            end)
            local plotN = MgrNet.CS:GetIsPlot()
            StormViewModel.isPlotModel = plotN == 1
        end,nil)
    else
        MgrUI.GoHide(UID.StormScroll_UI, function ()
            if callback then
                callback()
            end
        end)
        local plotN = MgrNet.CS:GetIsPlot()
        StormViewModel.isPlotModel = plotN == 1
    end
end

---@param data StormScrollData 打开战役关卡UI
function StormViewModel.OpenStormPointUI(data,type)
    StormViewModel.CurHardScrollData = StormViewModel.GetHardScrollByIndex(data.index)
    StormViewModel.CurScrollData = data
    StormViewModel.CurPointType = type
    if MgrUI.IsShow(UID.StormPoint_UI) then
        Event.Go("StormPoint_UI_OnInit")
    else
        MgrUI.GoHide(UID.StormPoint_UI)
    end
end

---打开战役关卡并跳转到某一关
function StormViewModel.TurnStormPointUI(data,type,pointData)
    StormViewModel.CurHardScrollData = StormViewModel.GetHardScrollByIndex(data.index)
    StormViewModel.CurScrollData = data
    StormViewModel.CurPointType = type
    StormViewModel.CurPointData = pointData
    MgrUI.GoHide(UID.StormPoint_UI)
end

--获得当前选择关卡的下一个关卡
function StormViewModel.GetSelectNextCheckPoint(curCheckPoint)
    ---如果不为活动关和活动boss关
    if StormViewModel.CurPointType ~= StormViewModel.PointType.activityBoss and StormViewModel.CurPointType ~= StormViewModel.PointType.activity then
        return
    end
    local index_m = 1
    local PointData = StormControl.GetEventRaidPointData()
    for index, value in ipairs(PointData) do
        if curCheckPoint.id == value.id then
            index_m = index
        end
    end

    if PointData[PointData] == #PointData then
        return PointData[index_m]
    end
    return PointData[index_m + 1]
end

--获得当前选择关卡的上一个关卡
function StormViewModel.GetSelectLastCheckPoint(curCheckPoint)
    ---如果不为活动关和活动boss关
    if StormViewModel.CurPointType ~= StormViewModel.PointType.activityBoss and StormViewModel.CurPointType ~= StormViewModel.PointType.activity then
        return
    end
    if curCheckPoint == nil then
        return StormViewModel.CurPointData
    else
        local index_m = 1
    local PointData = StormControl.GetEventRaidPointData()
    for index, value in ipairs(PointData) do
        if curCheckPoint.id == value.id then
            index_m = index
        end
    end

    if PointData[PointData] == 1 then
        return PointData[index_m]
    end
        return PointData[index_m - 1]
    end
end


---进入剧情关卡
---@param type number StormViewModel.PointType 设置关卡类型,为空不设置
function StormViewModel.OpenStormPlotUI(type)
    StormViewModel.curSelectData = StormViewModel.GetSelectNextCheckPoint(StormViewModel.CurPointData)
    if not StormViewModel.CurPointData then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("stormviewmodel_tips1"),1},true)
        return
    end
    if not StormViewModel.CurPointData:CheckLock() then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrlink_tips3"),1},true)
        return
    end
    if type then
        ---设置模式
        StormViewModel.CurPointType = type
    end
    if StormViewModel.CurPointData.scrollID and StormControl.GetStormScrollById(StormViewModel.CurPointData.scrollID).raidType == 999 then
        ---重打新手引导关
        NoviceControl.ClearNoviceState(StormViewModel.CurPointData.teacheID)
        NoviceViewModel.Check(StormViewModel.CurPointData.teacheID)
    else
        StormViewModel.CurPointState = StormViewModel.PointState.wait
        StormViewModel.CheckPointState()
    end
    if StormViewModel.CurPointData.type == 16 then
        ---当前ID
        EventRaidViewModel.CurIndex = StormViewModel.CurPointData.index
    end
    ---埋点
    local tCurDay = Global.GetCreateRoleDays()
    if tCurDay == 2 or tCurDay == 3 or tCurDay == 7 then
        local tStr = string.format("FirstChallengePoint_%d", PlayerControl.GetPlayerData().UID)
        local tDay = UnityEngine.PlayerPrefs.GetInt(tStr)
        local tKey = {
            [2] = "m66iez",
            [3] = "fz7qcb",
            [7] = "71zdha"
        }
        if tDay ~= tCurDay then
            ---第2 3 7天首次登录游戏关卡
            local tName = string.format("day%d_finsh_challenge_%s",tCurDay,StormViewModel.CurPointData.name)
            MgrSdk.FlyFunTrackEvent(tKey[tCurDay],tName)
            UnityEngine.PlayerPrefs.SetInt(tStr, tCurDay)
        end
    end
end
---进入下一个剧情关卡
function StormViewModel.OpenNextPlotUI(_point)
    if _point ~= nil then
        ---查找下一关

        for i, point in pairs(StormViewModel.CacheAllPointData) do
            local str = string.split(_point.o_fronts,"_")
            if tonumber(str[1]) == point.id and tonumber(str[2]) == point.scrollID then
                StormViewModel.CurPointData = point
                StormViewModel.CurScrollData = StormControl.GetStormScrollById(point.scrollID)
                ---开启关卡
                StormViewModel.CheckPointState()
                return
            end
        end
        ---循环结束未找到关卡提示并结束
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("stormviewmodel_tips2"),1},true)
        MgrBattle.CloseFight()
    else
        print("关卡数据为空102")
    end
end
---检查当前关卡状态并执行对应逻辑
function StormViewModel.CheckPointState()
    ---检查战前剧情
    if StormViewModel.CurPointState < StormViewModel.PointState.firstPlot
    then
        StormViewModel.CurPointState = StormViewModel.PointState.firstPlot
        ---跳转到剧情
        if StormViewModel.CurPointData.plot_f ~= nil and StormViewModel.CurPointData.plot_f ~= "0" then
            PlotViewModel.OpenPlotUI(StormViewModel.CurPointData.plot_f,StormViewModel.PlotEndOpen,true,true)
        else
            StormViewModel.CheckPointState()
        end
    elseif StormViewModel.CurPointState < StormViewModel.PointState.fight
    then
        StormViewModel.CurPointState = StormViewModel.PointState.fight
        ---设置关卡状态为未通关
        BattleRoleData.Bool_Pass = false
        ---跳转到战斗
        if StormViewModel.CurPointData.battleMap ~= nil and StormViewModel.CurPointData.battleMap ~= "0" then
            if StormControl.CheckPointLock(StormViewModel.CurPointData.id) then
                MgrBattle.GoFight(MgrBattle.fightType.normal,function()
                    ---获取战斗支援角色
                    FriendViewModel.GetBattleSupport()
                end ,StormViewModel.CurPointData.battleMap)
            else
                MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("stormviewmodel_tips3"),1},true)
                return
            end
        else
            StormViewModel.CheckPointState()
        end
    elseif StormViewModel.CurPointState < StormViewModel.PointState.lastPlot
    then
        StormViewModel.CurPointState = StormViewModel.PointState.lastPlot
        ---跳转到剧情
        if StormViewModel.CurPointData.plot_l ~= nil and StormViewModel.CurPointData.plot_l ~= "0" then
            if MgrUI.GetCurUI().Uid == UID.Battle02_UI then
                if BattleRoleData.Bool_Pass == true then
                    ---通关战斗再播放战后剧情
                    --BattleManager.ClearLuaData()
                    PlotViewModel.OpenPlotUI(StormViewModel.CurPointData.plot_l,StormViewModel.PlotEndOpen,true,true)
                else
                    ---未通关直接进入结算
                    StormViewModel.CheckPointState()
                end
            end
        else
            StormViewModel.CheckPointState()
        end
    elseif StormViewModel.CurPointState < StormViewModel.PointState.finish
    then
        StormViewModel.CurPointState = StormViewModel.PointState.wait
        if StormViewModel.CurPointType == StormViewModel.PointType.tower
        then
            ---挑战红巨结算
            if FightVideoViewModel.TowerReward == nil then
                MgrBattle.CloseFight()
            else
                ---显示奖励弹窗
                MgrUI.Pop(UID.ItemAchievePop_UI,{FightVideoViewModel.TowerReward,function()
                    MgrBattle.CloseFight()
                end},true)
            end
        elseif StormViewModel.CurPointType == StormViewModel.PointType.guide
        then
            ---战术指导结算
            if BattleRoleData.Bool_Pass == true then
                ---战术指导加载教学弹窗
                MgrUI.Pop(UID.NoviceFrame_UI,{StormViewModel.CurPointData.teach_l,nil,function()
                    ---重置当前关卡进度
                    StormViewModel.CurPointState = StormViewModel.PointState.wait
                    if FightVideoViewModel.GuideTab.reward == nil then
                        ---无奖励直接返回
                        MgrTimer.AddDelayNoName(1,function()
                            MgrBattle.CloseFight()
                        end)
                    else
                        ---显示奖励弹窗
                        MgrUI.Pop(UID.ItemAchievePop_UI,{FightVideoViewModel.GuideTab.reward,function()
                            ---无奖励直接返回
                            MgrTimer.AddDelayNoName(1,function()
                                MgrBattle.CloseFight()
                            end)
                        end},true)
                    end
                end},true)
            else
                ---战斗失败直接返回
                MgrTimer.AddDelayNoName(1,function()
                    MgrBattle.CloseFight()
                end)
            end
        elseif StormViewModel.CurPointType == StormViewModel.PointType.activityBoss
        then    --活动Boss结算
            if FightVideoViewModel.NormalRewardTab ~= nil and StormViewModel.CurPointData.battleMap ~= "0" then
                ---显示结算
                local offsetExp = FightVideoViewModel.NormalRewardTab.userExp - FightVideoViewModel.playerExp
                local offsetExpList = {}
                if FightVideoViewModel.NormalRewardTab.heroInfos ~= nil then
                    for i, v in pairs(FightVideoViewModel.NormalRewardTab.heroInfos) do
                        local heroData = HeroControl.GetRoleDataByID(v.heroID)
                        offsetExpList[i] = {}
                        offsetExpList[i].data = heroData
                        offsetExpList[i].offset = v.heroExp - heroData.exp
                    end
                end
                MgrUI.Pop(UID.PVEComplete_UI,{FightVideoViewModel.NormalRewardTab,offsetExp,offsetExpList,true},true)
            else
                MgrUI.Pop(UID.PVEComplete_UI,{FightVideoViewModel.NormalRewardTab,nil,nil,true},true)
            end
        else
            ---纯剧情关卡直接通关
            if StormViewModel.CurPointData.battleMap == "0" then
                if (StormViewModel.CurPointData.type == StormViewModel.PointBattleType.STORY and StormViewModel.CurPointData.star > 0)
                or (StormViewModel.CurPointData.type > StormViewModel.PointBattleType.LOGIC_BATTLE and StormViewModel.CurPointData.star > 0)then
                    ---已经通关
                    MgrBattle.CloseFight()
                    ---检查当前是否是最后一关并且为剧情
                    local data = StormViewModel.CurPointData
                    local frontStr = string.split(data.o_fronts,"_")
                    if data.o_fronts ~= "0" and data.scrollID ~= CheckpointLocalData.tab[tonumber(frontStr[1])].scroll and data.type == 2 and StormViewModel.CurPointData:CheckLock() then
                        ---如果满足条件跳到下一章节
                        local nextData = StormControl.GetStormPointByID(tonumber(frontStr[1]))
                        local nextScrollData = StormControl.GetStormScrollById(tonumber(frontStr[2]))
                        StormViewModel.CurPointData = nextData
                        StormViewModel.CurScrollData = nextScrollData
                    end
                    return
                end
                
                local ClientSetLevelStarREQ = {
                    levelID = StormViewModel.CurPointData.id,
                    teamID = 0,
                    heroID = {},
                }
                ---组装数据
                local bytes = assert(pb.encode('PBClient.ClientSetLevelStarREQ',ClientSetLevelStarREQ))
                print("发送签到"..pb.tohex(bytes))
                local thisACK = function(buffer,tag)
                    print("回放ACK")
                    local tab = assert(pb.decode('PBClient.ClientSetLevelStarACK',buffer))
                    if tab.errNo ~= 0 then
                        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("activityviewmodel_tips1")..tab.errNo, function ()
                            MgrSdk.BackToLogin()
                        end},true)
                    end
                end
                local thisNTF = function(buffer,tag)
                    local tab = assert(pb.decode('PBClient.ClientSetLevelStarNTF',buffer))
                    tab.levelStar = 7
                    ---更新数据统计
                    TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
                    ---获取关卡数据
                    local pointData = StormControl.GetStormPointByID(tab.levelID)
                    ---@type LevelInfo 更新关卡数据
                    local levelInfo = {
                        levelStar = tab.levelStar > pointData.star and tab.levelStar or pointData.star,
                        levelCount = pointData.count + 1,
                    }
                    pointData:PushData(levelInfo)
                    ---获取玩家数据
                    local player = PlayerControl.GetPlayerData()
                    ---检查是否升级
                    PlayerControl.CheckLevelUp(tab.userLevel)
                    ---更新体力
                    player:PushVigor(tab.vigor)
                    ---结算扣除
                    ItemControl.PushGroupItemData(tab.cost,ItemControl.PushEnum.consume)
                    ---更新物品奖励
                    ItemControl.PushGroupItemData(tab.reward,ItemControl.PushEnum.add)
                    ---更新玩家经验
                    player:PushExp(tab.userExp)
                    ---更新玩家等级
                    player:PushLevel(tab.userLevel)
                    if tab.reward ~= nil then
                        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.reward , function()
                            if MgrUI.GetCurUI().Uid ~= UID.Battle02_UI then
                                MgrBattle.CloseFight()
                            end
                        end},true)
                    else
                        MgrBattle.CloseFight()
                    end
                    FightVideoViewModel.NormalRewardTab = nil
                    FightVideoViewModel.NormalRewardTab = tab
                    ---设置地图,玩家所在位置
                    if tab.activityPos then
                        SummerMapControl.SetMapPos(tab.activityPos)
                        SummerMapControl.ChangeLogicState(tab.activityPos,tab.levelStar,tab.levelID)
                    end
                end
                MgrNet.SendReq(MID.CLIENT_SET_LEVEL_STAR_REQ,bytes,0,nil,thisACK,thisNTF)
            end
            if FightVideoViewModel.NormalRewardTab ~= nil and StormViewModel.CurPointData.battleMap ~= "0" then
                ---显示结算
                local offsetExp = FightVideoViewModel.NormalRewardTab.userExp - FightVideoViewModel.playerExp
                local offsetExpList = {}
                if FightVideoViewModel.NormalRewardTab.heroInfos ~= nil then
                    for i, v in pairs(FightVideoViewModel.NormalRewardTab.heroInfos) do
                        local heroData = HeroControl.GetRoleDataByID(v.heroID)
                        offsetExpList[i] = {}
                        offsetExpList[i].data = heroData
                        offsetExpList[i].offset = v.heroExp - heroData.exp
                    end
                end
                if StormViewModel.CurPointData:CheckGuide() then
                    for i, v in pairs(StormViewModel.NPCInfos) do
                        local heroData = v
                        offsetExpList[i] = {}
                        offsetExpList[i].data = heroData
                        offsetExpList[i].offset = 0
                    end
                end
                -----若不在战斗界面返回关卡后结算
                --if MgrUI.GetCurUI().Uid ~= UID.Battle02_UI then
                --    BattleManager.ClearLuaData()
                --    MgrUI.Pop(UID.FullLoading_UI,{0.5,function()
                --        MgrUI.GoClose(UID.StormPoint_UI)
                --    end,nil},true)
                --end
                if StormViewModel.CurPointType == StormViewModel.PointType.activityBoss then
                    MgrUI.Pop(UID.PVEComplete_UI,{FightVideoViewModel.NormalRewardTab,offsetExp,offsetExpList,true},true)
                else
                    if BattleManager.GameMode == BattleManager.GameModeType.ActivityBoss then
                        MgrUI.Pop(UID.PVEComplete_UI,{FightVideoViewModel.NormalRewardTab,offsetExp,offsetExpList,true},true)
                    else
                        local vigorRefund = false
                        if StormViewModel.CurPointData.type == 999 then
                            vigorRefund = true
                        end
                        MgrUI.Pop(UID.PVEComplete_UI,{FightVideoViewModel.NormalRewardTab,offsetExp,offsetExpList,vigorRefund},true)
                    end

                end
            end
        end
    end
end

---剧情播放结束
function StormViewModel.PlotEndOpen()
    StormViewModel.CheckPointState()
end

---准备阶段退出战斗
function StormViewModel.CloseBattle()
    StormViewModel.CurPointState = StormViewModel.PointState.wait
    MgrBattle.CloseFight()
end
---战斗中退出及战斗结束 type:0战斗结束退出，1战斗中退出返回选关，2战斗中退出返回大厅
function StormViewModel.BattleEndOpen(type)
    if type == 0 then
        StormViewModel.CheckPointState()
    elseif type == 1 then
        StormViewModel.CurPointState = StormViewModel.PointState.wait
        MgrBattle.CloseFight()
    elseif type == 2 then
        ---重置当前关卡进度
        StormViewModel.CurPointState = StormViewModel.PointState.wait
        MgrBattle.CloseFight(true)
    end
end
---前往世界boss战斗
function StormViewModel.OpenWorldBossBattle(isAna)
    StormViewModel.tempCurPointType = StormViewModel.CurPointType
    StormViewModel.CurPointType = nil
    StormViewModel.tempCurPointData = StormViewModel.CurPointData
    StormViewModel.CurPointData = nil
    StormViewModel.IsAnaWorldBoss = isAna
    if not StormViewModel.IsAnaWorldBoss then
        for i,v in pairs(JcbossLocalData.tab) do
            if StormViewModel.CurStormBossId_Monster == v[1] then
                MgrBattle.GoFight(MgrBattle.fightType.boss,nil,v[4])
                break
            end
        end
    else
        for i,v in pairs(JcbossLocalData.tab) do
            if StormViewModel.CurStormAnaBossId_Monster == v[1] then
                MgrBattle.GoFight(MgrBattle.fightType.boss,nil,v[4])
            end
        end
    end


end
---准备阶段退出世界boss战斗
function StormViewModel.CloseWorldBossBattle(isGoHome)
    MgrBattle.CloseFight(isGoHome)
end

---@return StormScrollData[] 获取缓存
function StormViewModel.ReloadStormData()
    ---获取常规卷缓存
    StormViewModel.CachePlotScrollData = StormControl.GetStormScrollData(0)
    StormViewModel.CacheHardPlotScrollData = StormControl.GetStormScrollData(2)
    StormViewModel.CacheAssetScrollData = StormControl.GetStormScrollData(1)
    ---获取常规关卡缓存
    StormViewModel.CacheAllPointData = StormControl.GetStormPointData()
    ---获取红巨卷缓存
    StormViewModel.CacheTowerScrollData = StormControl.GetStormTowerScrollData()
    ---获取红巨关卡缓存
    StormViewModel.CacheTowerPointData = StormControl.GetStormTowerPointData()
    ---获取战术指导卷缓存
    StormViewModel.CacheGuideScrollData = StormControl.GetStormGuideScrollData()
    ---获取战术指导关卡缓存
    StormViewModel.CacheGuidePointData = StormControl.GetStormGuidePointData()
    ---获取活动卷缓存
    StormViewModel.CacheEventRaidScrollData = StormControl.GetEventRaidScrollData()
    ---获取活动关卡缓存
    StormViewModel.CacheEventRaidPointData = StormControl.GetEventRaidPointData()
    ---获取困难卷缓存
    StormViewModel.CacheHardScrollData = StormControl.GetStormHardScrollData()
    ---获取困难关卡缓存
    StormViewModel.CacheHardPointData = StormControl.GetStormHardPointData()
end

---请求世界boss数据
--[[function StormViewModel.SendStormBossData(callback)
    ---序列化请求
    local bytes = assert(pb.encode('PBClient.ClientBossDataREQ',{rev=""}))
    ---发送请求
    MgrNet.SendReq(MID.CLIENT_BOSS_DATA_REQ,bytes,0,nil,StormViewModel.ReqBossDataAck,function(...)
        StormViewModel.ReqBossDataNtf(...)
        if callback then
            callback()
        end
    end)
end

function StormViewModel.ReqBossDataAck(buffer)
    local tab = assert(pb.decode('PBClient.ClientBossDataACK',buffer))
    if tab.errNo ~= 0 then
        local errorStr = MgrLanguageData.GetLanguageByKey("fightvideoviewmodel_tips2")..tab.errNo
        MgrUI.Pop(UID.PopTip_UI,{errorStr,1},true)
    end
end
---接收并更新世界boss数据
function StormViewModel.ReqBossDataNtf(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientBossDataNTF',buffer))
    ---更新单个boss数据
    local data = StormControl.GetStormBoss(tab.bossID)
    if data ~= nil then
        data:PushData(tab)
        StormViewModel.CurStormBossId = tab.bossID
    else
        print("未找到boss,id:"..tab.bossID)
    end
    ---检查是否存在奖励
    if tab.goods ~= nil and tab.goods ~= {} then
        ---检查是否未领取
        if tab.isGetReward == 0 then
            ---将奖励添加到背包并弹窗显示奖励
            ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
            MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
        end
    end

    ---更新所有boss历史分数
    if tab.maxScores ~= nil then
        for i, v in pairs(tab.maxScores) do
            local bd = StormControl.GetStormBoss(v.bossID)
            if bd ~= nil then
                bd:PushScore(v.maxScore)
            end
        end
    end
    ---更新所有boss世界历史分数
    if tab.worldScores ~= nil then
        for i, v in pairs(tab.worldScores) do
            local bd = StormControl.GetStormBoss(v.bossID)
            if bd ~= nil then
                bd:PushWorldScore(v.maxScore)
            end
        end
    end
end]]

---新请求Boss数据
function StormViewModel.SendStormBossData2(callback)
    local tData = EventRaidControl.GetLIANHETAOFAData()
    ---判断是不是在活动时间内
    if tData then
        if not Global.isMiddleTime(tData.beginTime,tData.endTime) then
            print("活动未开启")
            return
        end
    end
    ---序列化请求
    local bytes = assert(pb.encode('PBClient.ClientEventBossDataREQ',
            {
                bossID = tData.activityID
            }))
    ---发送请求
    MgrNet.SendReq(MID.CLIENT_BOSS_DATA_E_REQ,bytes,0,nil,StormViewModel.ReqBossDataAck2,function(...)
        StormViewModel.ReqBossDataNtf2(...)
        if callback then
            callback()
        end
    end)
end

function StormViewModel.ReqBossDataAck2(buffer)
    local tab = assert(pb.decode('PBClient.ClientBossDataACK',buffer))
    if tab.errNo ~= 0 then
        if tab.errNo == 626 then
            local errorStr = MgrLanguageData.GetLanguageByKey("ui_qita_text115")--..tab.errNo
            MgrUI.Pop(UID.PopTip_UI,{errorStr,1},true)
            return
        end
        local errorStr = MgrLanguageData.GetLanguageByKey("fightvideoviewmodel_tips2")..tab.errNo
        MgrUI.Pop(UID.PopTip_UI,{errorStr,1},true)
    end
end
---接收并更新世界boss数据
function StormViewModel.ReqBossDataNtf2(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientBossDataNTF',buffer))
    ---更新单个boss数据
    local data = ActivityControl.GetCurActivityByID(tab.bossID)
    if data ~= nil then
        data:PushBossData(tab)
        StormViewModel.CurStormBossId = tab.bossID
    else
        print("未找到boss,activityID:"..tab.bossID)
    end
    ---检查是否存在奖励
    if tab.goods ~= nil and tab.goods ~= {} then
        ---检查是否未领取
        --if tab.isGetReward == 0 then
        FightVideoViewModel.LHTFReward = tab.goods
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
        ---将奖励添加到背包并弹窗显示奖励
        --Event.Add("LHTFReward",Handle(StormViewModel,StormViewModel.LHTFRewardFunc))
        --ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
        --MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
        --end
    end
    ---更新所有boss历史分数
    if tab.maxScores ~= nil then
        for i, v in pairs(tab.maxScores) do
            local bd = ActivityControl.GetCurActivityByID(tab.bossID)
            if bd ~= nil then
                bd:PushScore(v.maxScore)
            end
        end
    end
    ---更新所有boss世界历史分数
    if tab.worldScores ~= nil then
        for i, v in pairs(tab.worldScores) do
            local bd = ActivityControl.GetCurActivityByID(tab.bossID)
            if bd ~= nil then
                bd:PushWorldScore(v.maxScore)
            end
        end
    end
end

function StormViewModel.LHTFRewardFunc()
    ---将奖励添加到背包并弹窗显示奖励
    Log.Error("执行联合讨伐奖励弹窗")
    if FightVideoViewModel.LHTFReward ~= nil and #FightVideoViewModel.LHTFReward ~= 0 then
        MgrUI.Pop(UID.ItemAchievePop_UI,{FightVideoViewModel.LHTFReward},true)
    end
end

---@param bossID number 根据id获取世界boss,若未传id则根据当前模式获取世界boss
---@return StormBossData 获取世界boss数据
function StormViewModel.GetWorldBossData(bossID)
    if bossID ~= nil then
        return StormControl.GetStormBoss(bossID)
    end
    if StormViewModel.IsAnaWorldBoss then
        ---模拟战
        return StormControl.GetStormBoss(StormViewModel.CurStormAnaBossId)
    else
        ---世界boss正式挑战
        return StormControl.GetStormBoss(StormViewModel.CurStormBossId)
    end
end

---获取完整英雄数据
function StormViewModel.GetHeroData()
    if StormViewModel.CurPointType ~=nil and StormViewModel.CurPointType == StormViewModel.PointType.guide then
        ---战术指导获取关卡指定角色
        StormViewModel.CacheHeroList = StormViewModel.CurPointData:GetRoles()
    else
        if StormViewModel.CurPointData ~= nil then
            ---非战术指导通过类型确认上场类型
            if StormViewModel.CurPointData.npcType == 0 then
                ---使用默认角色
                StormViewModel.CacheHeroList = HeroControl.GetHaveHero()
            elseif StormViewModel.CurPointData.npcType == 1 or StormViewModel.CurPointData.npcType == 2 then
                ---使用指定Npc
                StormViewModel.CacheHeroList = StormViewModel.CurPointData:GetRoles()
            elseif StormViewModel.CurPointData.npcType == 3 or StormViewModel.CurPointData.npcType == 4 then
                ---使用玩家角色+指定Npc
                StormViewModel.CacheHeroList = HeroControl.GetHaveHero()
                for _, role in pairs(StormViewModel.CurPointData:GetRoles()) do
                    table.insert(StormViewModel.CacheHeroList,role)
                end
            else
                print("未指定的类型，请检查！！！！！！！！")
            end
        else
            ---无当前关卡但是有世界BossId
            --if StormViewModel.CurStormBossId ~= nil then
                ---使用默认角色
                StormViewModel.CacheHeroList = HeroControl.GetHaveHero()
            --end

        end
    end
end

---@return RoleData[] 获取筛选排序后的英雄数据
function StormViewModel.GetSortAndFilterHeroArr(filters,sort,rise,isSupport)
    local array = {}
    if isSupport == nil or isSupport == false then
        array = StormViewModel.CacheHeroList
    else
        array = FriendViewModel.FriendSupportData
    end

    ---有类型时筛选
    if filters and not filters[0] then
        ---筛选
        local filterGroup = {}
        for i = 1, #filters do
            if filters[i] then
                table.insert(filterGroup,i)
            end
        end
        array = StormViewModel.RoleFilter(array, "career", filterGroup)
    end
    ---排序(1等级，2星级，3稀有度，4好感度,5取得时间)
    local sortGroupArr = {
        [1] = {"level","star","rank","awaken","id"},
        [2] = {"star","level","rank","awaken","id"},
        [3] = {"rank","star","level","id"},
        [4] = {"favor","rank","level","id"},
        [5] = {"cTime","id"},
    }
    Global.Sort(array,sortGroupArr[sort],rise)
    return array
end

---为缓存池添加英雄数据
function StormViewModel.AddHeroData(heroId)
    if StormViewModel.CurPointType == StormViewModel.PointType.guide or(StormViewModel.CurPointData ~= nil and StormViewModel.CurPointData.type == 999)  then
        local data = StormViewModel.CurPointData:GetRoleById(heroId)
        ---战术指导添加关卡指定角色
        table.insert(StormViewModel.CacheHeroList,data)
    else
        local data = HeroControl.GetRoleDataByID(heroId)
        ---非战术指导则添加玩家角色
        table.insert(StormViewModel.CacheHeroList,data)
    end
end
---添加缓冲池好友英雄数据
function StormViewModel.AddFriendHeroData(heroId)
    table.insert(FriendViewModel.FriendSupportData,HeroControl.CreateSingleFriendHeroData(FriendViewModel.SupportData[tonumber(heroId)]))
end

---移除缓存池英雄数据`
function StormViewModel.RemoveHeroData(heroId)
    for i, data in pairs(StormViewModel.CacheHeroList) do
        if data.id == heroId then
            table.remove(StormViewModel.CacheHeroList,i)
            break
        end
    end
end
---移除缓冲池好友英雄数据
function StormViewModel.RemoveFriendHeroData(heroId,userId)
    for i, data in pairs(FriendViewModel.FriendSupportData) do
        if data.id == heroId and data.userID == userId then
            table.remove(FriendViewModel.FriendSupportData,i)
            break
        end
    end
end

---获取自动排序攻击顺序id
function StormViewModel.GetAutoAtkOrderByList(idList)
    ---@type RoleData[]
    local dataList = {}
    for _, id in pairs(idList) do
        dataList[#dataList + 1] = HeroControl.GetRoleDataByID(id)
    end
    Global.Sort(dataList,{"career","level","awaken","rank","star","cTime","favor","id"},true)
    local list = {}
    for i, v in ipairs(dataList) do
        list[i] = v.id
    end
    return list
end

---@return StormScrollData[] 根据类型获取对应卷数据
function StormViewModel.GetStormScrollData(uiType)
    if uiType == 1  ---主线剧情(前面添加一条空数据以做居中显示)
    then
        local arr = {}
        arr[#arr + 1] = {}
        for i, v in pairs(StormViewModel.CachePlotScrollData) do
            if v.index == 0 then
                arr[#arr + 1] = v
            end
        end
        for i, v in pairs(StormViewModel.CachePlotScrollData) do
            if v.index ~= 0 then
                arr[#arr + 1] = v
            end
        end
        arr[#arr + 1] = {}
        return arr
    elseif uiType == 2 ---资源日常
    then
        local asArr = {}
        for i = 1, #StormViewModel.CacheAssetScrollData do
            local data = StormViewModel.CacheAssetScrollData[i]
            if asArr[data.type2] == nil then
                asArr[data.type2] = data
            elseif StormControl.CheckScrollLock(data.id) then
                asArr[data.type2] = data
            end
        end
        local arr = {}
        for i, v in pairs(asArr) do
            arr[#arr + 1] = v
        end
        Global.Sort(arr,{"type2"},false)
        return arr
    elseif uiType == 3 ---战术指导及挑战
    then
        local arr = {}
        arr[#arr + 1] = {}
        arr[#arr + 1] = {}
        for i, v in pairs(StormViewModel.CacheGuideScrollData) do
            arr[#arr + 1] = v
        end
        for i, v in pairs(StormViewModel.CacheTowerScrollData) do
            arr[#arr + 1] = v
        end
        arr[#arr + 1] = {}
        arr[#arr + 1] = {}
        return arr
    elseif uiType == 4 ---活动
    then
        local actArr = {}
        actArr[#actArr + 1] = {}
        actArr[#actArr + 1] = {}
        for i,v in pairs(StormViewModel.CacheEventRaidScrollData) do
            if v.raidType == StormControl.raidType.RAID_EASY then
                actArr[#actArr + 1] = v
            end
        end
        actArr[#actArr + 1] = {}
        actArr[#actArr + 1] = {}
        return actArr
    end
end

---根据类型2获取对应资源卷
function StormViewModel.GetResScrollData(type2)
    local arr = {}
    for i, v in pairs(StormViewModel.CacheAssetScrollData) do
        if v.type2 == type2 then
            arr[v.index] = v
        end
    end
    return arr
end

---请求排行数据
---@param page number 页数0~N 若超过最大页则返回末页
---@param callback function ui逻辑回调
function StormViewModel.SendBossRank(page,callback)
    ---序列化
    local buffer = assert(pb.encode('PBClient.ClientBossRankEventREQ',{ bossID = StormViewModel.CurStormBossId,pack = page }))
    MgrNet.SendReq(MID.CLIENT_BOSS_RANK_E_REQ,buffer,0,nil,StormViewModel.ClientBossRankAck,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientBossRankNTF',buffer))
        ---@type BossRankInfo[]
        local rInfo = tab.rankInfo
        if rInfo then
            for i, v in pairs(rInfo) do
                ---若当前id已存在，则将已存在的id设置为查询中
                for rank, info in pairs(ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos) do
                    if info.id == v.id then
                        ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos[rank] = {
                            score = nil,
                            rank = rank,
                            nike = MgrLanguageData.GetLanguageByKey("stormbossdata_tips1"),
                            head = 1,
                            headFrame = 0,
                            level = nil,
                            count = nil,
                            title = "",
                            id = -1,
                        }
                    end
                end
                ---将数据写入排名
                ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos[v.rank + 1] = v
            end
        end
        ---通知更新ui
        if callback ~= nil then
            callback()
        end
    end)
end

function StormViewModel.ClientBossRankAck(buffer)
    local tab = assert(pb.decode('PBClient.ClientBossRankACK',buffer))
    if tab.errNo ~= 0 then
        local errorStr = MgrLanguageData.GetLanguageByKey("fightvideoviewmodel_tips2")..tab.errNo
        print(errorStr)
    end
end

---@return number 获取当前排名数量
function StormViewModel.CheckRankCount()
    local count = 0
    if #ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos == 0 then
        return 0
    else
        for i, v in pairs(ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos) do
            count = count + 1
        end
        return count
    end

end

---@return boolean 检查目标页30条是否完整
function StormViewModel.CheckRankPage(page)
    local starIdx = page * 30 + 1
    local endIdx = starIdx + 29
    for i = starIdx, endIdx do
        if ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos[i] == nil or ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos[i].id == -1 then
            return false
        end
    end
    return true
end

---@param type number 类型1所有排名，类型2无榜首的所有排名，类型3只获取榜首
---@return BossRankInfo[] 获取世界boss无排名第一的玩家排名
function StormViewModel.GetWorldBossRank(type)
    local arr = {}
    if type == 1 then
        if ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos ~= nil then
            return ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos
        end
    elseif type == 2 then
        if ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos ~= nil then
            for rank, rInfo in pairs(ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos) do
                if rInfo.rank ~= 0 then
                    arr[rInfo.rank] = rInfo
                end
            end
        end
    elseif type == 3 then
        if ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos ~= nil then
            for rank, rInfo in pairs(ActivityControl.GetCurActivityByID(StormViewModel.CurStormBossId).rankInfos) do
                if rInfo.rank == 0 then
                    arr[1] = rInfo
                    break
                end
            end
        end
    end
    return arr
end

---@return StormPointData[] 根据当前卷获取对应关卡数据
function StormViewModel.GetStormPointData()
    if not StormViewModel.CurScrollData then
        print("当前卷为空,请检查卷数据")
        return
    end
    local array = {}
    for i, pointId in pairs(StormViewModel.CurScrollData.points) do
        array[StormViewModel.CacheAllPointData[pointId].index] = StormViewModel.CacheAllPointData[pointId]
    end
    ---添加假数据
    for i = 1,3 do
        array[#array + 1] = {}
    end
    return array
end

---@return StormPointData[] 获取挑战红巨层数据
function StormViewModel.GetStormTowerPointData()
    local arr = {}
    for i, v in pairs(StormViewModel.CacheTowerPointData) do
        arr[#arr + 1] = v
    end
    ---上方添加2条空数据做居中效果
    for i = 1, 2 do
        arr[#arr + 1] = {
            id = 10000000,
            isEmpty = true
        }
    end
    ---下方添加三条空数据做居中效果
    for i = 1, 3 do
        arr[#arr + 1] = {
            id = -1,
            isEmpty = true
        }
    end
    Global.Sort(arr,{"id"},true)
    return arr
end

---@return number 获取红巨数量
function StormViewModel.GetStormTowerCount()
    local count = 0
    for i, v in pairs(StormViewModel.CacheTowerPointData) do
        count = count + 1
    end
    return count
end

---@return StormPointData[] 获取战术指导关卡数据
function StormViewModel.GetStormGuidePointData()
    local arr = {}
    for i, v in pairs(StormViewModel.CacheGuidePointData) do
        arr[#arr + 1] = v
    end
    Global.Sort(arr,{"star","id"},false)
    return arr
end

---角色筛选
function StormViewModel.RoleFilter(list, key, values)
    local t = {}
    for _, data in pairs(list) do
        for _, v in pairs(values) do
            if data[key] == v then
                ---任一类型相同时添加
                table.insert(t,data)
                break
            end
        end
    end
    return t
end

---检测日常卷是否解锁
function StormViewModel.CheckAssetsScroll(type2)
    for i, data in pairs(StormViewModel.CacheAssetScrollData) do
        if data.type2 == type2 then
            ---卷下有任一子卷解锁则解锁
            if StormControl.CheckScrollLock(data.id) == true then
                return true
            end
        end
    end
    return false
end

function StormViewModel.HideRoleUI()
    local LeftUI = GameObject.Find("JNMgr/LeftRoot")
    local RightUI = GameObject.Find("JNMgr/RightRoot")
    if LeftUI and RightUI then
        LeftUI.gameObject:SetActive(false)
        RightUI.gameObject:SetActive(false)
    end
end

---通过索引获取困难卷
function StormViewModel.GetHardScrollByIndex(index)
    for i,data in pairs(StormViewModel.CacheHardScrollData) do
        if data.index == index then
            return data
        end
    end
    return nil
end

---@return StormPointData[] 根据当前卷获取对应关卡数据
function StormViewModel.GetStormHardPointData()
    if not StormViewModel.CurHardScrollData then
        print("当前卷为空,请检查卷数据")
        return
    end
    local array = {}
    for i, pointId in pairs(StormViewModel.CurHardScrollData.points) do
        array[StormViewModel.CacheAllPointData[pointId].index] = StormViewModel.CacheAllPointData[pointId]
    end
    ---添加假数据
    for i = 1,3 do
        array[#array + 1] = {}
    end
    return array
end

function StormViewModel.GetPlotByScroll(id)
    local list = {}
    local scroll = StormControl.GetStormScrollById(id)
    for key, value in pairs(scroll.points) do
        local point = StormControl.GetStormPointByID(value)
        if point.plot_f ~= nil and point.plot_f ~= "0" then
            list[point.plot_f] = 0
        end
        if point.plot_l ~= nil and point.plot_l ~= "0" then
            list[point.plot_l] = 0
        end
    end
    return list
end

function StormViewModel.PlayerLevelUp_Pop(info)
    MgrUI.Pop(UID.PlayerLevelUp_UI,info,true)
end

---清理数据，在关闭UI直接返回主界面时调用
function StormViewModel.ClearData()
    StormViewModel.CurPointData = nil    --当前关卡数据
end

function StormViewModel.Clear()
    StormViewModel.CacheEventRaidScrollData = {}
    StormViewModel.CacheEventRaidPointData = {}
    StormViewModel.CachePlotScrollData = {}
    StormViewModel.CacheAssetScrollData = {}
    StormViewModel.CacheAllPointData = {}
    StormViewModel.CacheTowerScrollData = {}
    StormViewModel.CacheTowerPointData = {}
    StormViewModel.CacheGuideScrollData = {}
    StormViewModel.CacheGuidePointData = {}
    StormViewModel.CacheHardScrollData = {}
    StormViewModel.CacheHardPointData = {}
    StormViewModel.CurScrollData = nil
    StormViewModel.CurPointData = nil
    StormViewModel.tempCurPointData = nil
    StormViewModel.CurLevelType = 0
    StormViewModel.CurHardScrollData = nil
    StormViewModel.FriendSupport = false
    StormViewModel.CurPointState = 0
    StormViewModel.CurStormBossId = 0
    StormViewModel.CurStormAnaBossId = 0
    StormViewModel.IsAnaWorldBoss = false
    StormViewModel.isPlotModel = false
    StormViewModel.CurPointType = nil
    StormViewModel.tempCurPointType = nil
    StormViewModel.CurDifficulty = nil
    StormViewModel.CacheHeroList = {}
    StormViewModel.NpcTeamStaticId = 666
    StormViewModel.NpcTeam = {}
    StormViewModel.FriendSupportTeam = {}
    StormViewModel.localTeam = {}
    StormViewModel.IsPlotStarting = false
    StormViewModel.curChooseRes = nil
    StormViewModel.CurScrollType = nil
    StormViewModel.CurChallenge = nil
    StormViewModel.CurChooseResPoint = nil
    StormViewModel.CurChooseNormal = nil
    StormViewModel.CurChooseHard = nil
    StormViewModel.CurChooseTower = nil
    StormViewModel.CurChooseGuide = nil
end

return StormViewModel