--require("ReadData/SignItemData")

require("UI/Base/UISysTools")
JNPVPData={}

--判断是否直接跳转至BattleUI的PVPMainform界面
JNPVPData.IsGoTowardsPVPMainForm = false
--默认不是PVP回放
JNPVPData.IsReplayMode = false
-----------------------------------当前本周排行榜信息---------------------------------------
-------------------------------------------------------本周排行榜信息-----------------------------------------------------------------------------------------
--当前第几赛季(周)
JNPVPData.CurSeason=1
--当前浏览赛季
JNPVPData.CurReviewSeason=1
--当前最大排行榜组下标（一组20个）
JNPVPData.TotalRankListIndexMAX = 5
--当前传递的最终LuaCallBack回调函数名
JNPVPData.LuaCallName=""
--临时存储数据用来发送给服务器
--下一次请求的起始下标
JNPVPData.NextFlushTabIndex=1
--本次请求末尾的玩家分数
JNPVPData.CurLastPlayerRank="-1"
--是否首次请求排行榜数据Flag  第一次请求不用剔除首位玩家数据，后续每次请求拿到的数据第一位实则上次请求的最末尾玩家数据
JNPVPData.IsFirstRequestRankList=false
--判断是否已经点击切换赛季Flag 如果置为True则会跳出当前等待回调
JNPVPData.IsSwitchSeason=false
-----1------2-------3-------4------5-------6---------7---------8-----------9--------
--玩家UID--昵称---角色头像---积分---名次--玩家等级---玩家称号---玩家段位ID---玩家段位头像ID
JNPVPData.CurWeekPVPRankListInfoTab={
    -- {"12","INori","lihui_jing2","2888","1","100","行星生物","307001","PVP_large_tiaozhan1"},
    -- {"13","EGOIST","lihui_jinkula2","2650","2","90","赤色の月","307001","PVP_large_tiaozhan1"},
    -- {"14","Aimer","lihui_hanke2","2000","3","95","无名怪物","307001","PVP_large_tiaozhan1"},
    -- {"15","Chelly","lihui_kelimu2","1788","4","90","和谐","307001","PVP_large_tiaozhan1"},
    -- {"16","LiSAOfficial","lihui_zhuliwusi2","1685","5","58","心理测量者","307001","PVP_large_tiaozhan1"},
    -- {"17","YuzurihaINori","lihui_oubeila2","1356","6","50","卡巴内瑞","307001","PVP_large_tiaozhan1"},
    -- {"13","EGOIST","lihui_jinkula2","2650","2","90","赤色の月","307001","PVP_large_tiaozhan1"},
    -- {"14","Aimer","lihui_hanke2","2000","3","95","无名怪物","307001","PVP_large_tiaozhan1"},
    -- {"15","Chelly","lihui_kelimu2","1788","4","90","和谐","307001","PVP_large_tiaozhan1"},
    -- {"16","LiSAOfficial","lihui_zhuliwusi2","1685","5","58","心理测量者","307001","PVP_large_tiaozhan1"},
    -- {"17","YuzurihaINori","lihui_oubeila2","1356","6","50","卡巴内瑞","307001","PVP_large_tiaozhan1"},
}
--初始化PVP排行榜回调事件
function JNPVPData.InitPVPRankListCallBack()
    -- statements
    Event.Clear("RequestFlushHistorySeason")
    Event.Clear("RequestFlushRankCount")
    Event.Clear("RequestFlushRankList")
    Event.Clear("RequestLastSeasonTopPlayerInfo")
    Event.Clear("RequestCurSeason")
    Event.Add("RequestFlushHistorySeason",function (_LuaCallName)
        -- statements
        JNPVPData.RequestFlushHistorySeason(JNPVPData.CurReviewSeason,_LuaCallName)
    end)
    Event.Add("RequestFlushRankCount",function (_LuaCallName)
        -- statements
        JNPVPData.RequestFlushRankCount(_LuaCallName)
    end)
    Event.Add("RequestFlushRankList",function (pvpType,_beginRank,_startScore,_LuaCallName)
        -- statements
        JNPVPData.RequestFlushRankList(pvpType,_beginRank,_startScore,_LuaCallName)
    end)
    Event.Add("RequestLastSeasonTopPlayerInfo",function (_LuaCallName)
        -- statements
        JNPVPData.RequestLastSeasonTopPlayerInfo(_LuaCallName)
    end)
    Event.Add("RequestCurSeason",function (_LuaCallName)
        -- statements
        JNPVPData.RequestCurSeason(_LuaCallName)
    end)
end

--请求更新对应赛季历史排行榜
function JNPVPData.RequestFlushHistorySeason(_season,_LuaCallName)
    HttpCore.GetHistorySeasonInfo(_season,"0","JNPVPData.AnalyisHistorySeasonRankList",JNPVPData.AnalyisHistorySeasonRankList,_LuaCallName)
end
--回调解析对应赛季排行榜数据
function JNPVPData.AnalyisHistorySeasonRankList(_Str,_LuaCallName)
    JNPVPData.CurWeekPVPRankListInfoTab={}
    if _Str == "" then
        -- statements
        return
    end
    HttpCore.CreatAnalyisJsonData(_Str,"CurWeekRankListInfo")
    local _JsonCount=HttpRequestMGR.Instance:GetJsonListCount(_Str)
    local _StartIndex = 0
    if JNPVPData.IsFirstRequestRankList == true then
        -- statements
        _StartIndex = 0
        JNPVPData.IsFirstRequestRankList=false
    else
        _StartIndex = 1
    end

    for i = _StartIndex, _JsonCount - 1, 1 do
        local _TempInfoTab={}
        local _PlayerUID=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","uid",i)
        local _PlayerLv=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","lv",i)
        local _PlayerTitleId=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","title",i)
        local _PlayerScore=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","score",i)
        local _PlayerRankSort=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","rank",i)
        local _PlayerRankId=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","segment",i)
        local _PlayerNickName=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","nickName",i)
        local _PlayerHead=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","head",i)
        local _PlayerRankIcon=""
        for key, value in pairs(GameData.tab.seniorPVP) do
            -- statements
            if value[1] == _PlayerRankId then
                -- statements
                _PlayerRankIcon=value[3]
            end
        end
        table.insert(_TempInfoTab, _PlayerUID)
        table.insert(_TempInfoTab, _PlayerNickName)
        table.insert(_TempInfoTab, "lihui_jing2")
        table.insert(_TempInfoTab, _PlayerScore)
        table.insert(_TempInfoTab, _PlayerRankSort)
        table.insert(_TempInfoTab, _PlayerLv)
        table.insert(_TempInfoTab, _PlayerTitleId)
        table.insert(_TempInfoTab, _PlayerRankId)
        table.insert(_TempInfoTab, _PlayerRankIcon)
        table.insert(JNPVPData.CurWeekPVPRankListInfoTab, _TempInfoTab)
    end
    if _LuaCallName ~=nil and _LuaCallName ~= "" then
        -- statements
        print("Event go ".._LuaCallName)
        Event.Go(_LuaCallName)
    end
end
--请求更新当前排行榜玩家总数，并初始化最大下标
function JNPVPData.RequestFlushRankCount(_LuaCallName)
    -- statements
    HttpCore.GetTargetRankListCount("0","JNPVPData.InitTotalRankListIndex",JNPVPData.InitTotalRankListIndex,_LuaCallName)
end
--回调更新排行榜最大人数等数据
function JNPVPData.InitTotalRankListIndex(_Str,_LuaCallName)
    -- statements
    local _CurMaxCount=tonumber(_Str)
    local _TempMAXIndex=math.floor(_CurMaxCount/20)
    print(_TempMAXIndex.._TempMAXIndex)
    JNPVPData.TotalRankListIndexMAX=math.floor(_CurMaxCount/20)
    -- JNPVPData.TotalRankListIndexMAX=1
    if _LuaCallName ~=nil and _LuaCallName ~= "" then
        -- statements
        print("Event go ".._LuaCallName)
        Event.Go(_LuaCallName)
    end
end

--请求更新排行榜数据
function JNPVPData.RequestFlushRankList(pvpType,_beginRank,_startScore,_LuaCallName)
    -- statements
    HttpCore.FlushWeekPVPRankList(pvpType,_beginRank,_startScore,"JNPVPData.AnalyisCurWeekRankList",JNPVPData.AnalyisCurWeekRankList,_LuaCallName)
end

--回调解析本周排行榜数据
function JNPVPData.AnalyisCurWeekRankList(_Str,_LuaCallName)
    JNPVPData.CurWeekPVPRankListInfoTab={}
    if _Str == "" then
        -- statements
        return
    end
    HttpCore.CreatAnalyisJsonData(_Str,"CurWeekRankInfo")
    local BeginRank=HttpCore.GetAnalyisDataByKey("CurWeekRankInfo","beginRank")
    local rankInfoList=HttpCore.GetAnalyisDataByKey("CurWeekRankInfo","rankList")
    HttpCore.CreatAnalyisJsonData(rankInfoList,"CurWeekRankListInfo")
    local _JsonCount=HttpRequestMGR.Instance:GetJsonListCount(rankInfoList)
    local _StartIndex = 0
    if JNPVPData.IsFirstRequestRankList == true then
        -- statements
        _StartIndex = 0
        JNPVPData.IsFirstRequestRankList=false
    else
        _StartIndex = 1
    end

    for i = _StartIndex, _JsonCount - 1, 1 do
        local _TempInfoTab={}
        local _PlayerUID=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","uid",i)
        local _PlayerLv=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","lv",i)
        local _PlayerTitleId=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","title",i)
        local _PlayerScore=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","score",i)
        local _PlayerRankSort=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","rank",i)
        local _PlayerRankId=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","segment",i)
        local _PlayerNickName=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","nickName",i)
        local _PlayerHead=HttpCore.GetAnalyisDataByKey("CurWeekRankListInfo","head",i)
        local _PlayerRankIcon=""
        for key, value in pairs(GameData.tab.seniorPVP) do
            -- statements
            if value[1] == _PlayerRankId then
                -- statements
                _PlayerRankIcon=value[3]
            end
        end
        JNPVPData.NextFlushTabIndex=JNPVPData.NextFlushTabIndex+1
        JNPVPData.CurLastPlayerRank=_PlayerScore
        table.insert(_TempInfoTab, _PlayerUID)
        table.insert(_TempInfoTab, _PlayerNickName)
        table.insert(_TempInfoTab, "lihui_jing2")
        table.insert(_TempInfoTab, _PlayerScore)
        table.insert(_TempInfoTab, _PlayerRankSort)
        table.insert(_TempInfoTab, _PlayerLv)
        table.insert(_TempInfoTab, _PlayerTitleId)
        table.insert(_TempInfoTab, _PlayerRankId)
        table.insert(_TempInfoTab, _PlayerRankIcon)
        table.insert(JNPVPData.CurWeekPVPRankListInfoTab, _TempInfoTab)
        if JNPVPData.NextFlushTabIndex >= 500 then
            -- statements
            -- print("已生成500个物体跳出")
            break
        end
    end
    if _LuaCallName ~=nil and _LuaCallName ~= "" then
        -- statements
        print("Event go ".._LuaCallName)
        Event.Go(_LuaCallName)
    end
end
--请求更新上赛季第一名信息
function JNPVPData.RequestLastSeasonTopPlayerInfo(_LuaCallName)
    -- statements
    if tonumber(JNPVPData.CurReviewSeason) > 1 then
        -- statements
        HttpCore.GetLastSeasonTopInfo((JNPVPData.CurReviewSeason - 1),"0","JNPVPData.AnalyisLastSeasonTopPlayerInfo",JNPVPData.AnalyisLastSeasonTopPlayerInfo,_LuaCallName)
    else
        JNPVPData.LastSeasonTopPlayerInfoTab=nil
        if JNPVPData.CurReviewSeason == JNPVPData.CurSeason then
            -- 当前赛季排行榜刷新
            JNPVPData.NextFlushTabIndex=1
            JNPVPData.CurLastPlayerRank="-1"
            JNPVPData.RequestFlushRankCount(_LuaCallName)
        else
            JNPVPData.RequestFlushHistorySeason(JNPVPData.CurReviewSeason,_LuaCallName)
        end
    end
end

--根据返回字符串解析出上个赛季第一名的信息
function JNPVPData.AnalyisLastSeasonTopPlayerInfo(_Str,_LuaCallName)
    -- statements
    JNPVPData.LastSeasonTopPlayerInfoTab={}
    if _Str == "" then
        -- statements
        JNPVPData.LastSeasonTopPlayerInfoTab=nil
        return
    end
    HttpCore.CreatAnalyisJsonData(_Str,"LastSeasonPlayerInfo")
    local _PlayerUID=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","uid")
    local _PlayerLv=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","lv")
    local _PlayerTitleId=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","title")
    local _PlayerScore=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","score")
    local _PlayerRankSort=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","rank")
    local _PlayerRankId=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","segment")
    local _PlayerNickName=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","nickName")
    local _PlayerHead=HttpCore.GetAnalyisDataByKey("LastSeasonPlayerInfo","head")
    local _PlayerRankIcon=""
    for key, value in pairs(GameData.tab.seniorPVP) do
        -- statements
        if value[1] == _PlayerRankId then
            -- statements
            _PlayerRankIcon=value[3]
        end
    end
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerUID)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerNickName)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, "lihui_jing2")
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerScore)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerRankSort)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerLv)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerTitleId)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerRankId)
    table.insert(JNPVPData.LastSeasonTopPlayerInfoTab, _PlayerRankIcon)

    if JNPVPData.CurReviewSeason == JNPVPData.CurSeason then
        -- 当前赛季排行榜刷新
        JNPVPData.NextFlushTabIndex=1
        JNPVPData.CurLastPlayerRank="-1"
        JNPVPData.RequestFlushRankCount(_LuaCallName)
    else
        JNPVPData.RequestFlushHistorySeason(JNPVPData.CurReviewSeason,_LuaCallName)
    end
end

--请求更新当前第几赛季
function JNPVPData.RequestCurSeason(_LuaCallName)
    -- 原请求赛季类型接口，需替换为tcp协议
    HttpCore.GetCurSeason("0","JNPVPData.AnalyisCurSeason",JNPVPData.AnalyisCurSeason,_LuaCallName)
end
--回调更新当前第几赛季
function JNPVPData.AnalyisCurSeason(_Str,_LuaCallName)
    -- statements
    JNPVPData.CurSeason=tonumber(_Str)
    JNPVPData.CurReviewSeason=JNPVPData.CurSeason
    if _LuaCallName ~=nil and _LuaCallName ~= "" then
        -- statements
        print("Event go ".._LuaCallName)
        Event.Go(_LuaCallName)
    end
end

--首次打开排行榜界面请求数据等待回调跳转
function JNPVPData.AwaitRequestFlushGoPVPRankListForm()
    -- statements
    Event.Clear("AwaitRequestFlushGoPVPRankListForm")
    Event.Add("AwaitRequestFlushGoPVPRankListForm",function ()
        -- statements
        MgrUI.Pop(UID.PVPRankListPanel)
    end)
    JNPVPData.RequestLastSeasonTopPlayerInfo("AwaitRequestFlushGoPVPRankListForm")
end
-------------------------------------------------------本周排行榜信息-----------------------------------------------------------------------------------------
--上个赛季最高位玩家信息表
JNPVPData.LastSeasonTopPlayerInfoTab={"12","INori","lihui_jing2","2888","1","100",MgrLanguageData.GetLanguageByKey("jnpvpdata_tips1"),"307001","PVP_large_tiaozhan1"}
-----------------------------------当前本周排行榜信息---------------------------------------
--当前对战UID
JNPVPData.CurBattleUID=""
--当前对战进攻方信息
--玩家UID
JNPVPData.Battle_AtkPlayer_UID=""
--玩家昵称
JNPVPData.Battle_AtkPlayer_NickName=""
--玩家段位uid
JNPVPData.Battle_AtkPlayer_RankUid=""
--玩家段位分
JNPVPData.Battle_AtkPlayer_RankGoal=""
--玩家段位名次
JNPVPData.Battle_AtkPlayer_Rank=""
--玩家上阵显示角色ID
JNPVPData.Battle_AtkPlayer_RoleId=""
--当前对战防守方信息
--玩家UID
JNPVPData.Battle_DefPlayerUID=""
--玩家昵称
JNPVPData.Battle_DefPlayer_NickName=""
--玩家段位uid
JNPVPData.Battle_DefPlayer_RankUid=""
--玩家段位分
JNPVPData.Battle_DefPlayer_RankGoal=""
--玩家段位名次
JNPVPData.Battle_DefPlayer_Rank=""
--玩家上阵显示角色ID
JNPVPData.Battle_DefPlayer_RoleId=""

--本局是否获胜
JNPVPData.CurPVPBattleIsWin="0"
--本局失败者分数变动
JNPVPData.Battle_DefeatScore=""
--本局获胜者分数变动
JNPVPData.Battle_WinScore=""

--当前玩家战斗信息
--上阵角色ID信息表
--单个信息类型{ID,IconPath}
JNPVPData.Battle_PlayerRoleInfoTab={{"11001","juese_icon_luyisi(q)"}}
--本次战斗掉落奖励信息
JNPVPData.Battle_CurRewardInfoTab={{"150003","200"}}

--当前玩家PVP阵容信息云端存储
JNPVPData.CurBattlePlayerFormationStr=""


--当前玩家PVP阵型信息(简略)
JNPVPData.CurPlayerPvPFormSingleInfo=""

-------------------------------------------------------战斗回放记录信息-----------------------------------------------------------------------------------------

--初始化当前战斗回放记录信息表
function JNPVPData.InitCurBattleDetailInfo(_AtkUid,_AtkNickName,_AtkRankUid,_AtkRankGoal,_AtkRank,_AtkRoleId,_DefUid,_DefNickName,_DefRankUid,_DefRankGoal,_DefRank,_DefRoleId,_PlayerBattleInfo,_EnemyBattleInfo)
    -- statements
    --玩家UID
    JNPVPData.Battle_AtkPlayer_UID=_AtkUid
    --玩家昵称
    JNPVPData.Battle_AtkPlayer_NickName=_AtkNickName
    --玩家段位uid
    JNPVPData.Battle_AtkPlayer_RankUid=_AtkRankUid
    --玩家段位分
    JNPVPData.Battle_AtkPlayer_RankGoal=_AtkRankGoal
    --玩家段位名次
    JNPVPData.Battle_AtkPlayer_Rank=_AtkRank
    --玩家上阵显示角色ID
    JNPVPData.Battle_AtkPlayer_RoleId=_AtkRoleId
    --当前对战防守方信息
    --玩家UID
    JNPVPData.Battle_DefPlayerUID=_DefUid
    --玩家昵称
    JNPVPData.Battle_DefPlayer_NickName=_DefNickName
    --玩家段位uid
    JNPVPData.Battle_DefPlayer_RankUid=_DefRankUid
    --玩家段位分
    JNPVPData.Battle_DefPlayer_RankGoal=_DefRankGoal
    --玩家段位名次
    JNPVPData.Battle_DefPlayer_Rank=_DefRank
    --玩家上阵显示角色ID
    JNPVPData.Battle_DefPlayer_RoleId=_DefRoleId
    --玩家详细战报信息
    JNPVPData.CurBattlePlayerFormInfo=_PlayerBattleInfo
    --敌方详细战报信息
    JNPVPData.CurBattleEnemyFormInfo=_EnemyBattleInfo
end


--当前玩家详细PVP阵型信息(详细战斗记录信息)
JNPVPData.CurBattlePlayerFormInfo=""


--当前对战玩家PVP阵型信息(详细战斗记录信息)
---1----2-----3-----4------5------6------7-----8-----9--------10-------11------12---------13----------14------------15-------------16-----------17------
---ID--星级--等级--觉醒--技能等级--PosX--PosY--Qoom--isBOSS--装备1ID--装备2ID--装备1占比--装备2占比--装备1附加属性--装备2附加属性--装备1强化等级--装备2强化等级
JNPVPData.CurBattleEnemyFormInfo="11003_6_100_1_3_5_2_0_0_0_0_0_0_0_0_0_0"
-------------------------------------------------------战斗回放记录信息-----------------------------------------------------------------------------------------

-------------------------------------------------------战斗站位记录信息-----------------------------------------------------------------------------------------
---1-----2------3-----4--------5-------------6--------------7-----------8-----
---ID---等级---星级---觉醒---攻击顺序---坐标POS(X_Y)----角色站位左右---角色头像名

--当前玩家本局站位PVP信息
JNPVPData.CurBattlePlayerStationInfo=""

--当前敌方玩家本局站位PVP信息
JNPVPData.CurBattleEnemyStationInfo=""

--初始化输出PVP站位字符串
function JNPVPData.InitBattleStationInfoStr(_Type,_TabID,_TabLv,_TabStar,_TabAw,_TabOrder,_TabPos,_TabIcon)
    local _ResultStr=""
    local _IsFirst=false --判断是不是首个写入字符
    if  _Type == "1"  then
        JNPVPData.PlayerHeroIDs=""
    end
    for key, value in pairs(_TabID) do
        print("IDLeft Value.."..value)
        --遍历ID表开始拼接站位信息字符串
        if _IsFirst == false then
            -- statements
            _IsFirst=true
        else
            _ResultStr=_ResultStr.."$"
            if  _Type == "1"  then
                -- statements
                JNPVPData.PlayerHeroIDs=JNPVPData.PlayerHeroIDs..","
            end
        end
        if _Type == "1" then
            -- statements
            print("JNPVPData.PlayerHeroIDs+"..value)
            JNPVPData.PlayerHeroIDs=JNPVPData.PlayerHeroIDs..value
        end
        _ResultStr=_ResultStr..value.."#".._TabLv[key].."#".._TabStar[key].."#".._TabAw[key].."#".._TabOrder[key].."#".._TabPos[key].."#".._Type.."#".._TabIcon[key]
    end
    if _Type == "0" then
        -- statements
        JNPVPData.CurBattleEnemyStationInfo=_ResultStr
    else
        JNPVPData.CurBattlePlayerStationInfo=_ResultStr
    end
    JNPVPData.PlayerDeathCount=""..BattleRoleData.Int_DeathCount
end
--根据传入信息字符串返回切割好的信息表
-- @param _Str 存储的我方站位信息字符串
function JNPVPData.AnalyisBattleInfoStr(_Str)
    -- statements
    local mTab={} --存id
    local mLv = {}  --等级
    local mStarLv = {}  --星级
    local mAwake={} --觉醒 1觉醒 0不觉醒
    local mSkillLv = {}  --技能等级
    local mPosX={} --位置x
    local mPosY={} --位置y
    local mQoom={}  --额外缩放
    local mIsBoss  ={}  --是否boss
    local mGear1ID={} --1号槽位装备ID
    local mGear2ID={} --2号槽位装备ID
    local mGear1Rate={}--1号槽位装备UID
    local mGear2Rate={}--2号槽位装备UID
    local mGear1AddonType={}--1号槽位装备UID
    local mGear2AddonType={}--2号槽位装备UID
    local mGear1Lv={}--1号槽位装备UID
    local mGear2Lv={}--2号槽位装备UID
    local temp_data1 = JNStrTool.strSplit(",",_Str)
    for a, b in pairs(temp_data1) do
        local temp_data2=JNStrTool.strSplit("_",temp_data1[a])
        table.insert( mTab, temp_data2[1])
        table.insert( mStarLv, temp_data2[2])
        table.insert( mLv, temp_data2[3])
        table.insert( mAwake, temp_data2[4])
        table.insert( mSkillLv, temp_data2[5])
        table.insert( mPosX, temp_data2[6])
        table.insert( mPosY, temp_data2[7])
        table.insert( mQoom, temp_data2[8])
        table.insert( mIsBoss, temp_data2[9])
        table.insert( mGear1ID, temp_data2[10])
        table.insert( mGear2ID, temp_data2[11])
        table.insert( mGear1Rate, temp_data2[12])
        table.insert( mGear2Rate, temp_data2[13])
        table.insert( mGear1AddonType, temp_data2[14])
        table.insert( mGear2AddonType, temp_data2[15])
        table.insert( mGear1Lv, temp_data2[16])
        table.insert( mGear2Lv, temp_data2[17])
    end
    --返回信息表
    local _ReturnTab={}
    table.insert( _ReturnTab,mTab)
    table.insert( _ReturnTab,mStarLv)
    table.insert( _ReturnTab,mLv)
    table.insert( _ReturnTab,mAwake)
    table.insert( _ReturnTab,mSkillLv)
    table.insert( _ReturnTab,mPosX)
    table.insert( _ReturnTab,mPosY)
    table.insert( _ReturnTab,mQoom)
    table.insert( _ReturnTab,mIsBoss)
    table.insert( _ReturnTab,mGear1ID)
    table.insert( _ReturnTab,mGear2ID)
    table.insert( _ReturnTab,mGear1Rate)
    table.insert( _ReturnTab,mGear2Rate)
    table.insert( _ReturnTab,mGear1AddonType)
    table.insert( _ReturnTab,mGear2AddonType)
    table.insert( _ReturnTab,mGear1Lv)
    table.insert( _ReturnTab,mGear2Lv)

    return _ReturnTab
end
-------------------------------------------------------战斗站位记录信息-----------------------------------------------------------------------------------------

-------------------------------------------------------战斗结算-----------------------------------------------------------------------------------------
--战斗结算请求
function JNPVPData.PostBattleResult()
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~开始POST请求结算信息")
    HttpCore.PVPPostResult(JNPVPData.CurPVPBattleIsWin,JNPVPData.PlayerKillCount,JNPVPData.PlayerDeathCount,JNPVPData.PlayerHeroIDs,JNPVPData.CurBattlePlayerFormInfo,JNPVPData.CurBattleEnemyFormInfo,JNPVPData.CurBattlePlayerStationInfo,JNPVPData.CurBattleEnemyStationInfo,JNPVPData.Battle_DefPlayerUID,0,"JNPVPData.InitPVPCompleteInfo",JNPVPData.InitPVPCompleteInfo,"BattleManangerDelayStartGame_PVP")
end


--初始化当前查阅战斗记录信息表
function JNPVPData.InitPerPVPBattleInfoTab(_IsWin,_ScoreChange,_PlayerName,_PlayerGoal,_PlayerRankID,_EnemyName,_EnemyGoal,_EnemyRankID,_PlayerRankSort,_EnemyRankSort,_TimeStamp,_SingleBattleInfo,_PlayerRankIcon,_EnemyRankIcon,_BattleUID)
    JNPlayerData.CurBattleRecordTab={}
    table.insert(JNPlayerData.CurBattleRecordTab,_IsWin)
    table.insert(JNPlayerData.CurBattleRecordTab,_ScoreChange)
    table.insert(JNPlayerData.CurBattleRecordTab,_PlayerName)
    table.insert(JNPlayerData.CurBattleRecordTab,_PlayerGoal)
    table.insert(JNPlayerData.CurBattleRecordTab,_PlayerRankID)
    table.insert(JNPlayerData.CurBattleRecordTab,_EnemyName)
    table.insert(JNPlayerData.CurBattleRecordTab,_EnemyGoal)
    table.insert(JNPlayerData.CurBattleRecordTab,_EnemyRankID)
    table.insert(JNPlayerData.CurBattleRecordTab,_PlayerRankSort)
    table.insert(JNPlayerData.CurBattleRecordTab,_EnemyRankSort)
    table.insert(JNPlayerData.CurBattleRecordTab,_TimeStamp)
    table.insert(JNPlayerData.CurBattleRecordTab,_SingleBattleInfo)
    table.insert(JNPlayerData.CurBattleRecordTab,_PlayerRankIcon)
    table.insert(JNPlayerData.CurBattleRecordTab,_EnemyRankIcon)
    table.insert(JNPlayerData.CurBattleRecordTab,_BattleUID)
end
--PVP战斗结束结算界面信息请求初始化
function JNPVPData.InitPVPCompleteInfo(_Str,_CallBackName)
    -- statements
    JNPVPData.Battle_CurRewardInfoTab={}
    HttpCore.CreatAnalyisJsonData(_Str,"PVPCompleteInfo")
    local _IsWin=JNPVPData.CurPVPBattleIsWin
    local _RewardItemList=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","itemList")
    local _actSegment=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","actSegment")
    local _defScore=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","defScore")
    local _time=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","time")
    local _actRank=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","actRank")
    local _defSegment=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","defSegment")
    local _actScore=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","actScore")
    local _defRank=HttpCore.GetAnalyisDataByKey("PVPCompleteInfo","defRank")

    --更新对战计算信息表
    local _CurBattleScoreChange="0"
    if _IsWin == "1" then
        -- statements
        _CurBattleScoreChange=JNPVPData.Battle_WinScore
    else
        _CurBattleScoreChange=JNPVPData.Battle_DefeatScore
    end
    local _SingleStationInfoStr=JNPVPData.CurBattlePlayerStationInfo.."$"..JNPVPData.CurBattleEnemyStationInfo
    local _PlayerRankIcon=""
    local _EnemyRankIcon=""
    for key, value in pairs(GameData.tab.seniorPVP) do
        -- statements
        if _defSegment == ""..value[1] then
            -- statements
            _EnemyRankIcon=value[3]
        end
        if _actSegment == ""..value[1] then
            -- statements
            _PlayerRankIcon=value[3]
        end
    end

    JNPVPData.InitPerPVPBattleInfoTab(_IsWin,_CurBattleScoreChange,JNPVPData.Battle_AtkPlayer_NickName,_actScore,_actSegment,JNPVPData.Battle_DefPlayer_NickName,_defScore,_defSegment,_actRank,_defRank,_time,_SingleStationInfoStr,_PlayerRankIcon,_EnemyRankIcon,JNPVPData.CurBattleUID)
    print("结算简单站位信息_SingleStationInfoStr".._SingleStationInfoStr)
    --------------------------------初始化掉落物品ItemList-------------------------------
    --根据返回的ItemList字符串切割获得本次战斗掉落物品信息表
    print("***************************_RewardItemList".._RewardItemList)
    local _ItemListCount=HttpRequestMGR.Instance:GetJsonListCount(_RewardItemList)
    HttpCore.CreatAnalyisJsonData(_RewardItemList,"PVPCompleteReward")
    for i = 0, _ItemListCount - 1 , 1 do
        local _RewardID=HttpCore.GetAnalyisDataByKey("PVPCompleteReward","goodsId",i)
        local _RewardCount=HttpCore.GetAnalyisDataByKey("PVPCompleteReward","num",i)
        local _tempInfoTab={}
        table.insert(_tempInfoTab,_RewardID)
        table.insert(_tempInfoTab,_RewardCount)
        table.insert(JNPVPData.Battle_CurRewardInfoTab,_tempInfoTab)
    end
    ----------------------------------ItemList切割完成-----------------------------------
    --执行Lua回调方法
    if _CallBackName ~=nil and _CallBackName ~= "" then
        -- statements
        print("Event go ".._CallBackName)
        Event.Go(_CallBackName)
    end
end
-------------------------------------------------------战斗结算-----------------------------------------------------------------------------------------



-------------------------------------------------------战斗信息-----------------------------------------------------------------------------------------
--玩家总阵亡数
JNPVPData.PlayerDeathCount="0"
--玩家总杀敌数
JNPVPData.PlayerKillCount="0"
--玩家上场机娘ID表
JNPVPData.PlayerHeroIDs=""

-------------------------------------------------------战斗信息-----------------------------------------------------------------------------------------

--获取最新的服务器存储的玩家PVP阵容信息字符串
function JNPVPData.InitCurPlayerFormationStr(_Str)
    -- statements
    HttpCore.CreatAnalyisJsonData(_Str,"InitCurPlayerFormationStr")
    local _GroupInfoPVPStr=HttpCore.GetAnalyisDataByKey("InitCurPlayerFormationStr","formationInfo")
    JNPVPData.CurBattlePlayerFormationStr=_GroupInfoPVPStr
end

--点击等待玩家PVP阵容请求更新开始匹配
function JNPVPData.OnClickPVPMatchAwaitFormFlush()
    -- statements
    JNPVPData.InitCurPlayerPVPForm()
end

--PVP匹配请求
function JNPVPData.StartPVPMatch(_Type)
    -- statements
    HttpCore.PVPMatch(_Type,"JNPVPData.InitPVPPlayersInfo",JNPVPData.InitPVPPlayersInfo)
end

--获取玩家当前PVP阵型信息字符串
function JNPVPData.InitCurPlayerPVPForm()
    HttpCore.GetPVPGroup("0","JNPVPData.LuaCallInitPlayerPVPForm",JNPVPData.LuaCallInitPlayerPVPForm)
end

--回调更新玩家PVP阵容信息字符串
function JNPVPData.LuaCallInitPlayerPVPForm(_str)
    if _str == nil or _str == "" then
        Event.Go("FullLoading_Refresh")
        UISysTools.PopWarn(MgrLanguageData.GetLanguageByKey("jnpvpdata_tips2"))
        return
    end
    HttpCore.CreatAnalyisJsonData(_str,"GroupInfoPVPStr")
    local _GroupInfoPVPStr=HttpCore.GetAnalyisDataByKey("GroupInfoPVPStr","formationInfo")
    if _GroupInfoPVPStr == "" or _GroupInfoPVPStr==nil  then
        -- statements
        Event.Go("FullLoading_Refresh")
        UISysTools.PopWarn(MgrLanguageData.GetLanguageByKey("jnpvpdata_tips2"))
        return
    end
    JNPVPData.CurBattlePlayerFormInfo=_GroupInfoPVPStr
    JNPVPData.StartPVPMatch(0)
end

--玩家匹配信息请求解析初始化
function JNPVPData.InitPVPPlayersInfo(_Str)
    HttpCore.CreatAnalyisJsonData(_Str,"PVPPlayersInfo")
    local EnemyUID=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","uid")
    local EnemyNickName=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","nickName")
    local EnemyRank=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","defRank")
    local EnemySegment=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","defSegment")
    local EnemyScore=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","defScore")
    local EnemyFormation=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","formation")
    local EnemyHeroVOS=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","heroVOS")
    local PlayerRank=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","actRank")
    local PlayerSegment=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","actSegment")
    local PlayerScore=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","actScore")
    local ChangeScore=HttpCore.GetAnalyisDataByKey("PVPPlayersInfo","changeScore")
    --根据返回信息更新PVPData
    JNPVPData.Battle_DefPlayerUID=EnemyUID
    JNPVPData.Battle_DefPlayer_RankUid=EnemySegment
    JNPVPData.Battle_DefPlayer_RankGoal=EnemyScore
    JNPVPData.Battle_DefPlayer_Rank=EnemyRank
    JNPVPData.Battle_DefPlayer_NickName=EnemyNickName
    JNPVPData.Battle_AtkPlayer_RankUid=PlayerSegment
    JNPVPData.Battle_AtkPlayer_RankGoal=PlayerScore
    JNPVPData.Battle_AtkPlayer_Rank=PlayerRank
    JNPVPData.Battle_AtkPlayer_NickName=JNPlayerData.nickname
    JNPVPData.Battle_AtkPlayer_UID=JNPlayerData.UID
    local ScoreChangeTab=JNStrTool.strSplit("_",ChangeScore)
    JNPVPData.Battle_DefeatScore=""..ScoreChangeTab[3]
    JNPVPData.Battle_WinScore=""..ScoreChangeTab[2]
    local _AnalyisFormInfo=JNPVPData.AnalyisRoleRealBattleInfoStr(EnemyFormation,EnemyHeroVOS)
    JNPVPData.CurBattleEnemyFormInfo=_AnalyisFormInfo
    JNPVPData.GetPlayerRoleIconInfoStr(JNPVPData.CurBattlePlayerFormInfo)
    JNPVPData.GetCurPlayerPVPFormationStr()
    MgrUI.ClosePop(UID.PvPMainForm)
    --MgrUI.ClosePop(UID.Battle_AbtNew)
    MgrUI.GoFirst(UID.LockLoadPanel)
    MgrUI.Pop(UID.PvPStartPop)
end

--根据当前获得的服务器请求返回最新玩家PVP阵容信息字符串，通过玩家机娘背包、符文等数据解析重新生成最新的PVP阵容信息字符串
function JNPVPData.GetCurPlayerPVPFormationStr()
    local _OriginInfoStr=JNPVPData.CurBattlePlayerFormationStr
    Event.Clear("InitCurPlayerFormAfterFlushRoleList")
    --回调方法等待玩家机娘以及机甲背包更新数据后开始解析
    Event.Add("InitCurPlayerFormAfterFlushRoleList",function ()
        --这里面写具体解析以及重新拼接字符串方法
        local _PerRoleInfoStrTab=JNStrTool.strSplit(",",_OriginInfoStr)
        --所有储存角色信息记录表
        local _RoleInfoTab={}
        for key, value in pairs(_PerRoleInfoStrTab) do
            -- statements
            local _TempRoleInfoTab=JNStrTool.strSplit("_",value)
            for i, n in pairs(CollectionData.tab.RoleCollect) do
                -- statements
                if n[1] == _TempRoleInfoTab[1] then
                    -- 匹配机娘ID
                    --星级
                    _TempRoleInfoTab[2]=n[3]
                    --等级
                    _TempRoleInfoTab[3]=n[4]
                    --觉醒
                    _TempRoleInfoTab[4]=n[5]
                    --技能等级
                    _TempRoleInfoTab[5]=n[6]
                    --装备1ID
                    _TempRoleInfoTab[10]=n[20]
                    --装备2ID
                    _TempRoleInfoTab[11]=n[21]
                    --装备1占比
                    _TempRoleInfoTab[12]=n[22]
                    --装备2占比
                    _TempRoleInfoTab[13]=n[23]
                    --装备1附加属性
                    _TempRoleInfoTab[14]=n[18]
                    --装备2附加属性
                    _TempRoleInfoTab[15]=n[19]
                    --装备1强化等级
                    _TempRoleInfoTab[16]=n[10]
                    --装备2强化等级
                    _TempRoleInfoTab[17]=n[12]

                end
            end

            table.insert(_RoleInfoTab,_TempRoleInfoTab)
        end
        local _IsFirst=false --是否为第一个信息
        local _ReturnStr="" --返回信息
        --开始拼接字符串补完计划
        for key, value in pairs(_RoleInfoTab) do
            -- statements
            if _IsFirst==false then
                -- statements
                _IsFirst=true
            else
                _ReturnStr=_ReturnStr..","
            end
            for i, n in pairs(value) do
                -- statements
                _ReturnStr=_ReturnStr.."_"..n
            end
        end
        JNPVPData.CurBattlePlayerFormationStr=_ReturnStr
    end)
    --调用背包更新方法，传入需要执行的回调方法名(在更新结束后更新字符串)
    CollectionData.InitAllData("InitCurPlayerFormAfterFlushRoleList")
end

--根据详细战斗记录信息字符串切割得到简略头像字符串
function JNPVPData.GetPlayerRoleIconInfoStr(_Str)
    -- statements
    local _PerRoleInfoStrTaB=JNStrTool.strSplit(",",_Str)
    JNPVPData.Battle_PlayerRoleInfoTab={}
    for key, value in pairs(_PerRoleInfoStrTaB) do
        -- 切割单个机娘信息字符串拿到机娘ID
        local _RoleInfoTab=JNStrTool.strSplit("_",value)
        for i, n in pairs(GameData.tab.roleattribute) do
            -- statements
            if n[1] == _RoleInfoTab[1] then
                -- statements
                local _tempTab1={}
                table.insert(_tempTab1,n[1])
                table.insert(_tempTab1,n[49])
                table.insert(JNPVPData.Battle_PlayerRoleInfoTab,_tempTab1)
            end
        end
    end
end
--根据服务器返回具体机娘信息字符串解析补全PVP战斗阵容字符串
function JNPVPData.AnalyisRoleRealBattleInfoStr(_TargetStr,_InfoStr)
    --如果敌方不携带HEROVOS信息则视为机器人直接返回阵容字符串
    if _InfoStr == "" or _InfoStr == "[]" then
        return _TargetStr
    end
    print("~~~~~~~~~~~_InfoStr".._InfoStr)
    -- 在匹配到敌人后根据接口返回的当前敌方机娘实时数据表(Key["heroVOS"])更新普通信息字符串(Key["formation"])  详情见接口文档
    local _ReturnStrInfoTab={}
    local _TargetStrInfoTab=JNStrTool.strSplit(",", _TargetStr)
    for key, value in pairs(_TargetStrInfoTab) do
        -- statements
        local _TargetStrInfoTab2=JNStrTool.strSplit("_", value)
        table.insert(_ReturnStrInfoTab,_TargetStrInfoTab2)
    end
    HttpCore.CreatAnalyisJsonData(_InfoStr,"PVPRoleInfoAnalyis")
    local RoleListCount = HttpRequestMGR.Instance:GetJsonListCount(_InfoStr)
    for i = 0, RoleListCount - 1, 1 do
        local RoleID=HttpCore.GetAnalyisDataByKey("PVPRoleInfoAnalyis","heroId",i)
        local Rolelv=HttpCore.GetAnalyisDataByKey("PVPRoleInfoAnalyis","lv",i)
        local Rolestar=HttpCore.GetAnalyisDataByKey("PVPRoleInfoAnalyis","star",i)
        local RoleisAwaken=HttpCore.GetAnalyisDataByKey("PVPRoleInfoAnalyis","isAwaken",i)
        local RoleskillLv=HttpCore.GetAnalyisDataByKey("PVPRoleInfoAnalyis","skillLv",i)
        local RoleruneVOS=HttpCore.GetAnalyisDataByKey("PVPRoleInfoAnalyis","runeVOS",i)
        HttpCore.CreatAnalyisJsonData(RoleruneVOS,"PVPRoleRuneInfoAnalyis"..i)
        local RuneListCount = HttpRequestMGR.Instance:GetJsonListCount(RoleruneVOS)
        local RoleGear1ID ="0"
        local RoleGear2ID ="0"
        local RoleGearRate1 ="0"
        local RoleGearRate2 ="0"
        local RoleGearAddonType1 ="0"
        local RoleGearAddonType2 ="0"
        local RoleGearLv1 ="0"
        local RoleGearLv2 ="0"
        if RuneListCount > 0 then
            --如果解析出来机甲装备数量大于0
            for j = 0, RuneListCount - 1, 1 do
                local RuneID=HttpCore.GetAnalyisDataByKey("PVPRoleRuneInfoAnalyis","runeId",j)
                local RuneRate=HttpCore.GetAnalyisDataByKey("PVPRoleRuneInfoAnalyis","nowPropertiesValue",j)
                local RuneDeputy=HttpCore.GetAnalyisDataByKey("PVPRoleRuneInfoAnalyis","deputyPropertiesType",j)
                local RuneLv=HttpCore.GetAnalyisDataByKey("PVPRoleRuneInfoAnalyis","lv",j)
                local RuneSlot=HttpCore.GetAnalyisDataByKey("PVPRoleRuneInfoAnalyis","slot",j)

                if RuneSlot == "0" then
                    -- 第一个槽位
                    RoleGear1ID=RuneID
                    RoleGearRate1=RuneRate
                    RoleGearAddonType1=RuneDeputy
                    RoleGearLv1=RuneLv
                elseif RuneSlot == "1" then
                    --第二个槽位
                    RoleGear2ID=RuneID
                    RoleGearRate2=RuneRate
                    RoleGearAddonType2=RuneDeputy
                    RoleGearLv2=RuneLv
                end
            end
        end
        for key, value in pairs(_ReturnStrInfoTab) do
            -- 匹配到了字符串中保存的机娘ID，更新最新信息到字符串信息表中
            if value[1] == ""..RoleID then
                value[2]=Rolestar
                value[3]=Rolelv
                value[4]=RoleisAwaken
                value[5]=RoleskillLv
                value[10]=RoleGear1ID
                value[11]=RoleGear2ID
                value[12]=RoleGearRate1
                value[13]=RoleGearRate2
                value[14]=RoleGearAddonType1
                value[15]=RoleGearAddonType2
                value[16]=RoleGearLv1
                value[17]=RoleGearLv2
            end
        end
    end
    local _ReturnStr=""
    local _IsFirst=false

    --开始拼接字符串补完计划
    for key, value in pairs(_ReturnStrInfoTab) do
        -- statements
        if _IsFirst==false then
            -- statements
            _IsFirst=true
        else
            _ReturnStr=_ReturnStr..","
        end
        local _IsFirst2=false
        for i, n in pairs(value) do
            -- statements
            if _IsFirst2==false  then
                -- statements
                _IsFirst2 =true
            else
                _ReturnStr=_ReturnStr.."_"
            end
            _ReturnStr=_ReturnStr..n
        end
    end
    print("******************************PVP字符串补完即完成输出字符串为".._ReturnStr)
    return _ReturnStr
end
-- --获取玩家PVP界面信息
-- function JNPVPData.InitPlayerPVPData(_Str)
--     HttpCore.CreatAnalyisJsonData(_Str,"PVPPlayerData")
-- end

function JNPVPData.InitAllBattleRecord(_LuaCallName)
    -- 初始化所有信息
    JNPVPData.FlushAllPVPBattleRecord(1,"AwaitAtkRecordFlush")
    Event.Clear("AwaitAtkRecordFlush")
    Event.Add("AwaitAtkRecordFlush",function ()
        JNPVPData.FlushAllPVPBattleRecord(0,_LuaCallName)
    end)
end

--获取更新最新的玩家战斗记录信息
function JNPVPData.FlushAllPVPBattleRecord(_Type,_LuaCallName)
    if _Type == 0 then
        --刷新防守方排行榜数据
        HttpCore.GetAllPVPRecord("0","0","JNPVPData.FlushBattleRecordTab",JNPVPData.FlushBattleRecordTab,_LuaCallName)
    else
        --刷新攻击方排行榜数据
        HttpCore.GetAllPVPRecord("0","1","JNPVPData.FlushBattleRecordTab",JNPVPData.FlushBattleRecordTab,_LuaCallName)
    end
end
--回调执行解析数据以及更新对应战斗记录表
function JNPVPData.FlushBattleRecordTab(_Str,_Count,_Type,_LuaCallName)
    local _JsonDataKey=""
    if _Type == "0" then
        --防守方
        JNPlayerData.PlayerPvPWeekRecord_Def={}
        _JsonDataKey="PlayerDefBattleRecord"
    else
        --进攻方
        JNPlayerData.PlayerPvPWeekRecord_Atk={}
        _JsonDataKey="PlayerAtkBattleRecord"
    end
    HttpCore.CreatAnalyisJsonData(_Str,_JsonDataKey)
    if tonumber(_Count) > 0 then
        -- statements
        for i = 0, _Count - 1, 1 do
            -- statements
            local _TempBattleRecordInfo={}
            local _GoalChange=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"getScore",i)
            local _IsWin=0
            if _GoalChange ~= nil and _GoalChange ~= "" then
                -- statements
                if tonumber(_GoalChange) > 0 then
                    _IsWin = "1"
                else
                    _IsWin = "0"
                end
            end
            local _BattleUid=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"id",i)
            local _AtkPlayerName=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"attackerNickName",i)
            local _AtkPlayerGoal=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"attackerScore",i)
            local _AtkPlayerRankId=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"attackerSegment",i)
            local _AtkPlayerRankSort=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"attackerRank",i)
            local _DefPlayerName=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"defenderNickName",i)
            local _DefPlayerGoal=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"defenderScore",i)
            local _DefPlayerRankId=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"defenderSegment",i)
            local _DefPlayerRankSort=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"defenderRank",i)
            local _TimeStamp=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"creatTime",i)
            --对局简略详情（应为在界面列表中不显示这个数据只有点开才有所以在此处数据列表中不请求，后面单独请求）
            local _SingleBattleInfo=""
            --进攻方头像的表中的键值ID
            local _AtkIconID=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"attackerHead",i)
            --进攻方头像名
            local _AtkIcon=""
            --防守方头像的表中的键值ID
            local _DefIconID=HttpCore.GetAnalyisDataByKey(_JsonDataKey,"defenderHead",i)
            --防守方头像名
            local _DefIcon=""
            --进攻方段位头像名
            local _AtkRankIcon=""
            --防守方段位头像名
            local _DefRankIcon=""
            for key, value in pairs(GameData.tab.seniorPVP) do
                -- statements
                if value[1] == _AtkPlayerRankId then
                    -- statements
                    _AtkRankIcon=value[3]
                end
                if value[1] == _DefPlayerRankId then
                    -- statements
                    _DefRankIcon=value[3]
                end
            end
            if _Type == "0" then
                -- 防守方  应为玩家为防守方所以对应插入信息对调保证表的统一
                table.insert(_TempBattleRecordInfo, _IsWin)
                table.insert(_TempBattleRecordInfo, _GoalChange)
                table.insert(_TempBattleRecordInfo, _DefPlayerName)
                table.insert(_TempBattleRecordInfo, _DefPlayerGoal)
                table.insert(_TempBattleRecordInfo, _DefPlayerRankId)
                table.insert(_TempBattleRecordInfo, _AtkPlayerName)
                table.insert(_TempBattleRecordInfo, _AtkPlayerGoal)
                table.insert(_TempBattleRecordInfo, _AtkPlayerRankId)
                table.insert(_TempBattleRecordInfo, _DefPlayerRankSort)
                table.insert(_TempBattleRecordInfo, _AtkPlayerRankSort)
                table.insert(_TempBattleRecordInfo, _TimeStamp)
                table.insert(_TempBattleRecordInfo, _SingleBattleInfo)
                table.insert(_TempBattleRecordInfo, _DefRankIcon)
                table.insert(_TempBattleRecordInfo, _AtkRankIcon)
                table.insert(_TempBattleRecordInfo, _BattleUid)
                table.insert(JNPlayerData.PlayerPvPWeekRecord_Def, _TempBattleRecordInfo)
            else
                -- 进攻方
                table.insert(_TempBattleRecordInfo, _IsWin)
                table.insert(_TempBattleRecordInfo, _GoalChange)
                table.insert(_TempBattleRecordInfo, _AtkPlayerName)
                table.insert(_TempBattleRecordInfo, _AtkPlayerGoal)
                table.insert(_TempBattleRecordInfo, _AtkPlayerRankId)
                table.insert(_TempBattleRecordInfo, _DefPlayerName)
                table.insert(_TempBattleRecordInfo, _DefPlayerGoal)
                table.insert(_TempBattleRecordInfo, _DefPlayerRankId)
                table.insert(_TempBattleRecordInfo, _AtkPlayerRankSort)
                table.insert(_TempBattleRecordInfo, _DefPlayerRankSort)
                table.insert(_TempBattleRecordInfo, _TimeStamp)
                table.insert(_TempBattleRecordInfo, _SingleBattleInfo)
                table.insert(_TempBattleRecordInfo, _AtkRankIcon)
                table.insert(_TempBattleRecordInfo, _DefRankIcon)
                table.insert(_TempBattleRecordInfo, _BattleUid)
                table.insert(JNPlayerData.PlayerPvPWeekRecord_Atk, _TempBattleRecordInfo)
            end

        end
    end
    print("JNPVPData_LuaCallName".._LuaCallName)
    if _LuaCallName ~=nil and _LuaCallName ~= "" then
        -- statements
        print("Event go ".._LuaCallName)
        Event.Go(_LuaCallName)
        -- Event.Clear(_LuaCallName)
    end
end
--请求更新主界面所有信息(包括战报)后跳转至主界面
function JNPVPData.RequestAllPVPDataGoMainForm()
    -- statements
    Event.Clear("AwaitPVPMainFormInfoFlush")
    Event.Add("AwaitPVPMainFormInfoFlush",function ()
        -- statements
        JNPVPData.AwaitRecordFlushToPVPMain()
    end)
    JNPVPData.RequestFlushPVPMainFormInfo("AwaitPVPMainFormInfoFlush")
end
--请求更新战报界面信息后跳转到PVP主界面方法
function JNPVPData.AwaitRecordFlushToPVPMain()
    -- statements
    Event.Clear("AwaitRecordFlushToPVPMain")
    Event.Add("AwaitRecordFlushToPVPMain",function ()
        --回调更新数据跳转到主界面
        JNPVPData.IsGoTowardsPVPMainForm = false
        -- MgrUI.ClosePop(UID.PopLoad)
        Event.Go("FullLoading_Refresh")
        MgrUI.Pop(UID.PvPMainForm)
        Event.Go("ClickGoPVPMainForm")
    end)
    JNPVPData.InitAllBattleRecord("AwaitRecordFlushToPVPMain")
end


--点击请求更新PVP主界面信息
function JNPVPData.RequestFlushPVPMainFormInfo(_LuaCallName)
    -- statements
    HttpCore.GetPVPMainFormInfo("0","JNPVPData.CallBackFlushPVPMainForm",JNPVPData.CallBackFlushPVPMainForm,_LuaCallName)
end

function JNPVPData.CallBackFlushPVPMainForm(_Str,_LuaCallName)
    --开始解析字符串
    if _Str == "" or _Str == nil then
        -- statements
        return
    end
    HttpCore.CreatAnalyisJsonData(_Str,"PVPMainFormInfo")
    local _PlayerRankId=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","segment")
    local _PlayerRankGoal=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","score")
    local _PlayerRankSort=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","rank")
    local _PlayerAtkSum=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","atcBattleNum")
    local _PlayerAtkWinSum=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","atcVictoryNum")
    local _PlayerDefSum=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","defBattleNum")
    local _PlayerDefWinSum=HttpCore.GetAnalyisDataByKey("PVPMainFormInfo","defVictoryNum")
    --更新普通信息
    JNPlayerData.PlayerMainRankID=_PlayerRankId
    JNPlayerData.PlayerCurRank=_PlayerRankSort
    JNPlayerData.PlayerCurRankGoal=_PlayerRankGoal
    --计算进攻防守记录胜率场次信息
    JNPlayerData.PlayerPvpWeekWinCount_Atk=tonumber(_PlayerAtkWinSum)
    JNPlayerData.PlayerPvpWeekDefeatCount_Atk=tonumber(_PlayerAtkSum)-JNPlayerData.PlayerPvpWeekWinCount_Atk
    JNPlayerData.PlayerPvpWeekWinRate_Atk=TableToObject.GetCorrectRate(tonumber(_PlayerAtkWinSum),tonumber(_PlayerAtkSum))
    JNPlayerData.PlayerPvpWeekWinCount_Def=tonumber(_PlayerDefWinSum)
    JNPlayerData.PlayerPvpWeekDefeatCount_Def=tonumber(_PlayerDefSum)-JNPlayerData.PlayerPvpWeekWinCount_Def
    JNPlayerData.PlayerPvpWeekWinRate_Def=TableToObject.GetCorrectRate(tonumber(_PlayerDefWinSum),tonumber(_PlayerDefSum))

    if _LuaCallName ~=nil and _LuaCallName ~= "" then
        -- statements
        print("Event go ".._LuaCallName)
        Event.Go(_LuaCallName)
        -- Event.Clear(_LuaCallName)
    end
end

return JNPVPData