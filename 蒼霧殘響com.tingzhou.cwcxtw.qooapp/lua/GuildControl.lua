require("LocalData/GuildlevelLocalData")
require("LocalData/GuildheadLocalData")
require("LocalData/GuilddonateLocalData")
require("LocalData/GuildskillLocalData")
require("Model/Guild/Data/GuildLevelData")
require("Model/Guild/Data/GuildHeadData")
require("Model/Guild/Data/GuildDonateData")
require("Model/Guild/Data/GuildSkillData")
---公告管理器
GuildControl = {}
local mGuildLvData = {}             ---公会等级信息
local mGuildHeadData = {}           ---公会头像信息
local mGuildDonateData = {}         ---公会捐献信息
local mGuildSkillData = {}          ---公会技能信息
local mGuildList = nil              ---公会列表
local mGuildInfo = nil              ---个人公会信息
local mGuildSearch = nil             ---搜索公会列表
local mModeList = {}                ---公会加入条件描述
local mOnlineState = {}             ---玩家在线状态描述
local mAppliedList = {}             ---已申请的公会ID列表
local mPlayerSkillData = {}         ---玩家公会科技信息
local mCalmTime = 0                 ---申请工会冷静期(在这个时间之后才能申请工会)
local mDismissTime = 0              ---公会解散时间
local mSelfGuildID = nil            ---自己的公会ID

GuildControl.Job = {
    ---0会员
    member = 0,
    ---1副会长
    deputyLeader = 1,
    ---2会长
    leader = 2
}
GuildControl.OutGuild = -1          ---退出公会

function GuildControl.InitData(_guildID)
    GuildControl.InitGuildLv()
    GuildControl.InitGuildHead()
    GuildControl.InitGuildDonate()
    GuildControl.InitGuildSkill()

    mModeList = {
        ---自由加入
        MgrLanguageData.GetLanguageByKey("ui_guild_text14"),
        ---需要审核
        MgrLanguageData.GetLanguageByKey("ui_guild_text15"),
        ---禁止加入
        MgrLanguageData.GetLanguageByKey("ui_guild_text16"),
    }
    mOnlineState = {
        ---离线
        MgrLanguageData.GetLanguageByKey("ui_guild_text26"),
        ---在线
        MgrLanguageData.GetLanguageByKey("ui_guild_text27"),
    }

    mSelfGuildID = _guildID
end
---初始化公会等级相关信息
function GuildControl.InitGuildLv()
    for i, v in ipairs(GuildlevelLocalData.tab) do
        if mGuildLvData[v.level] == nil then
            mGuildLvData[v.level] = GuildLevelData.New(i)
        end
    end
end
---初始化公会头像相关信息
function GuildControl.InitGuildHead()
    for i, v in ipairs(GuildheadLocalData.tab) do
        if mGuildHeadData[v.id] == nil then
            mGuildHeadData[v.id] = GuildHeadData.New(i)
        end
    end
end
---初始化公会捐献相关信息
function GuildControl.InitGuildDonate()
    for i, v in pairs(GuilddonateLocalData.tab) do
        if mGuildDonateData[v.id] == nil then
            mGuildDonateData[v.id] = GuildDonateData.New(i)
        end
    end
end
---初始化公会技能相关信息
function GuildControl.InitGuildSkill()
    for i, v in pairs(GuildskillLocalData.tab) do
        table.insert(mGuildSkillData,GuildSkillData.New(i))
    end
end
---进入聊天室
function GuildControl.JoinChat()
    if mSelfGuildID > 0 then
        GuildControl.ChatServerConnect()
    end
end
---打开公会系统
function GuildControl.OpenGuildUI(callback)
    if SysLockControl.CheckSysLock(1701) then
        GuildControl.GetGuildData(function(guildInfo, isHaveGuild)
            if isHaveGuild then
                MgrUI.GoHide(UID.Union_UI,function()
                    if callback then
                        callback()
                    end
                end)
            else
                MgrUI.GoHide(UID.UnionJoin_UI,function()
                    if callback then
                        callback()
                    end
                end)
            end
        end)
    else
        MgrUI.Pop(UID.PopTip_UI,{ SysLockControl.GetSystemLockTips(1701),2 },true)
    end
end
---获取公会列表信息
function GuildControl.GetGuildList()
    return mGuildList
end
---获取个人公会信息
function GuildControl.GetGuildInfo()
    return mGuildInfo
end
---获取公会加入条件描述
function GuildControl.GetModeByID(_id)
    if _id >= #mModeList or _id < 0 then
        return ""
    end
    return mModeList[_id+1]
end
function GuildControl.GetAllMode()
    return mModeList
end
---玩家在线状态描述
function GuildControl.GetOnlineState(_id)
    if _id >= #mModeList or _id < 0 then
        return ""
    end
    return mOnlineState[_id+1]
end

function GuildControl.GetLvData(_guildLv)
    return mGuildLvData[_guildLv]
end
---获取已申请的公会ID
function GuildControl.GetAppliedID()
    return mAppliedList
end

function GuildControl.GetGuildData(callback)
    if callback == nil then
        return
    end

    GuildControl.RefreshGuild(nil,function(...)
        callback(...)
    end)
end

function GuildControl.RefreshGuild(_guildid, callback)
    local ClientGetClubInfoREQ = {
        id = _guildid
    }
    local bytes = assert(pb.encode('PBClient.ClientGetClubInfoREQ',ClientGetClubInfoREQ))
    MgrNet.SendReq(MID.CLIENT_GET_CLUB_INFO_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientGetClubInfoACK',buffer))
       
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end,
    function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientGetClubInfoNTF',buffer))
        
        mGuildInfo = tab.club
        GuildControl.PushDonateCount()
        GuildControl.PushPlayerSkillData()
        mGuildList = tab.recommendClub
        if mGuildList then
            mGuildSearch = {}
            for i, v in ipairs(tab.recommendClub) do
                mGuildSearch[v.id] = v
            end
        end
        ---已申请的公会ID列表
        if tab.applyID then
            for i, v in ipairs(tab.applyID) do
                mAppliedList[v] = v
            end
        else
            mAppliedList = {}
        end
        ---公会解散冷静期时间戳
        GuildControl.SetDismissTime(tab.dismissal)
        
        if callback then
            if mGuildInfo then
                if mGuildInfo.dismissal then
                    mDismissTime = mGuildInfo.dismissal
                else
                    mDismissTime = 0
                end
                callback(mGuildInfo,true)
            else
                callback(mGuildList,false)
            end
        end
    end)
end

function GuildControl.SeachGuild(_id, callback)
    GuildControl.RefreshGuild(_id, callback)
end
---创建公会
function GuildControl.CreateGuild(_name)
    local ClientCreateClubInfoREQ = {
        name = _name
    }
    local bytes = assert(pb.encode('PBClient.ClientCreateClubInfoREQ',ClientCreateClubInfoREQ))
    MgrNet.SendReq(MID.CLIENT_CREATE_CLUB_INFO_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientCreateClubInfoACK',buffer))
        
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end, GuildControl.CreateGuildNtf)
end

function GuildControl.CreateGuildNtf(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientCreateClubInfoNTF',buffer))
    ---更新数据统计
    TaskControl.ChangeStatistics(tab.day, tab.week, tab.month, tab.glory)
    
    local tInfo = {
        id = tab.id,
        name = tab.name,
        notice = tab.notice,
        level = tab.level,
        exp = tab.exp,
        money = tab.money,
        user = tab.user,
        skill = tab.skill,
        note = tab.note,
        recruitType = tab.recruitType,
        recruitLevelLimit = tab.recruitLevelLimit,
        Score = tab.Score,
    }
    mGuildInfo = tInfo
    GuildControl.PushDonateCount()
    GuildControl.PushPlayerSkillData()
    ---公会解散冷静期时间戳
    GuildControl.SetDismissTime(0)
    
    MgrUI.GoHide(UID.Union_UI)
end
---申请公会
function GuildControl.GuildApply(_id,callback)
    if _id == nil then
        return
    end
    local ClientJoinClubREQ = {
        id = _id
    }
    local bytes = assert(pb.encode('PBClient.ClientJoinClubREQ',ClientJoinClubREQ))
    MgrNet.SendReq(MID.CLIENT_JOIN_CLUB_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientJoinClubACK',buffer))
        print(tab.errNo)
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end, 
    function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientJoinClubNTF',buffer))

        if tab.club then
            local tInfo = {
                id = tab.club.id,
                name = tab.club.name,
                notice = tab.club.notice,
                level = tab.club.level,
                exp = tab.club.exp,
                money = tab.club.money,
                user = tab.club.user,
                skill = tab.club.skill,
                note = tab.club.note,
                recruitType = tab.club.recruitType,
                recruitLevelLimit = tab.club.recruitLevelLimit,
                Score = tab.club.Score,
            }
            mGuildInfo = tInfo
            GuildControl.PushDonateCount()
            GuildControl.PushPlayerSkillData()
            MgrUI.GoHide(UID.Union_UI)
        else
            ---保存申请过的公会ID
            mAppliedList[tab.clubId] = tab.clubId
            if callback then
                callback()
            end
        end
    end)
end

---发送公会管理设置
function GuildControl.SendGuildManage(_name,_notice,_recruitType,_LevelLimit,callback)
    local tInfo = {
        ---公会名称
        name = _name,
        ---公会公告
        notice = _notice,
        ---公会招募类型选择(0自由加入,1需要审核,2禁止加入)
        recruitType = _recruitType,
        ---工会招募等级限制
        recruitLevelLimit = _LevelLimit
    }
    local ClientModifyClubREQ = {
        info = tInfo
    }
    local bytes = assert(pb.encode('PBClient.ClientModifyClubREQ',ClientModifyClubREQ))
    MgrNet.SendReq(MID.CLIENT_MODIFY_CLUB_REQ,bytes,0,nil, function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientModifyClubACK',buffer))
        
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end,
    function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientModifyClubNTF',buffer))
        if callback then
            callback(tab.info)
        end
    end)
end
---发送成员管理设置
function GuildControl.SendMemberManage(_id,_job,callback)
    local ClientModifyClubREQ = {}
    if _id then
        local tUser = {
            ---用户id(会长不能传自己)
            id = _id,
            ---工会职务 0会员 1副会长 2会长  (除了这三个传其它退出工会)
            job = _job
        }
        ClientModifyClubREQ = {
            user = tUser
        }
    else
        ---专用于会长解散公会和取消解散公会
        ClientModifyClubREQ = {
            dismiss = _job
        }
    end
    
    local bytes = assert(pb.encode('PBClient.ClientModifyClubREQ',ClientModifyClubREQ))
    MgrNet.SendReq(MID.CLIENT_MODIFY_CLUB_REQ,bytes,0,nil, function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientModifyClubACK',buffer))
        
        if tab.errNo~=0 then
            if tab.errNo == 643 then
                ---玩家已退出公会,需重新请求公会数据
                MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_guild_text50"),2},true)
                GuildControl.GetGuildData(function(guildInfo)
                    Event.Go("RefreshGuild", guildInfo)
                end)
            else
                GuildControl.ErrorMsg(tab.errNo)
            end
        end
    end,
    function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientModifyClubNTF',buffer))
        if tab.id == PlayerControl.GetPlayerData().UID then
            GuildControl.SetCalmTime(tab.calmTime)
        end
        ---公会解散冷静期时间戳
        GuildControl.SetDismissTime(tab.dismissTime)
        
        if callback then
            callback(tab.user)
        end
    end)
end
---用户审批
function GuildControl.UserApproval(_applyId,_audit,_guildId)
    local ClientAuditClubREQ = {
        userID = _applyId,
        audit = _audit,
        clubId = _guildId
    }
    local bytes = assert(pb.encode('PBClient.ClientAuditClubREQ',ClientAuditClubREQ))
    MgrNet.SendReq(MID.CLIENT_AUDIT_CLUB_REQ,bytes,0,nil, function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientAuditClubACK',buffer))
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end,
    function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientAuditClubNTF',buffer))
        if tab.result == 0 then
            ---对方已有公会
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_guild_text38"),2},true)
        elseif tab.result == 2 then
            ---公会人数已达上限
            MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("ui_summerevent_text77"), 1 }, true)
        end
        GuildControl.GetGuildData(function(guildInfo)
            Event.Go("RefreshGuild", guildInfo)
        end)
    end)
end
---设置申请公会冷静期时间戳
function GuildControl.SetCalmTime(_calmTime)
    mCalmTime = _calmTime
end
function GuildControl.GetCalmTime()
    return mCalmTime
end
---公会解散冷静期时间戳
function GuildControl.SetDismissTime(_dismissTime)
    mDismissTime = _dismissTime
end
function GuildControl.GetDismissTime()
    return mDismissTime
end
----------------------------------------公会捐献相关---------------------------------------------------------------------
function GuildControl.GetDonateData()
    local arr = {}
    for k,v in pairs(mGuildDonateData) do
        table.insert(arr,v)
    end
    return arr
end

---获取捐献数据长度
function GuildControl.GetDonateDataCount()
    local count = 0
    for k,v in pairs(mGuildDonateData) do
        count = count + 1
    end
    return count
end

---推送捐献次数数据
function GuildControl.PushDonateCount()
    if mGuildInfo == nil then
        return
    end
    ---如果没有记录
    if mGuildInfo.donate == nil then
        mGuildInfo.donate = {}
        for k,v in pairs(mGuildDonateData) do
            table.insert(mGuildInfo.donate,{id = v.id,count = 0})
        end
    end
    ---记录不全
    if #mGuildInfo.donate ~= GuildControl.GetDonateDataCount() then
        local arr = {}
        for k,v in pairs(mGuildDonateData) do
            table.insert(arr,{id = v.id,count = 0})
        end
        ---覆盖数据
        for i,data in pairs(mGuildInfo.donate) do
            for j,value in pairs(arr) do
                if value.id == data.id then
                    value.count = data.count
                end
            end
        end
        mGuildInfo.donate = arr
    end
end

---推送单个捐献次数数据
function GuildControl.PushSingleDonateCount(_id,_count)
    for k,v in pairs(mGuildInfo.donate) do
        if v.id == _id then
            v.count = _count
        end
    end
end

---传入id获取对应捐献次数
function GuildControl.GetDonateCount(_id)
    if mGuildInfo.donate == nil then
        return 0
    end
    for k,v in pairs(mGuildInfo.donate) do
        --找到匹配的捐献数据
        if v.id == _id then
            return v.count
        end
    end
end

---捐献公会请求
function GuildControl.ClubDonateReq(_id,callback)
    local ClientClubDonateREQ = {
        id = _id
    }
    local bytes = assert(pb.encode('PBClient.ClientClubDonateREQ',ClientClubDonateREQ))
    MgrNet.SendReq(MID.CLIENT_CLUB_DONATE_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientClubDonateACK',buffer))
        
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end, function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientClubDonateNTF',buffer))
        ---更新数据统计
        TaskControl.ChangeStatistics(tab.day, tab.week, tab.month, tab.glory)
        ---消耗道具
        for k,v in pairs(tab.cost) do
            ItemControl.PushSingleItemData(v,ItemControl.PushEnum.consume)
        end
        if tab.goods then
            ---获得道具
            for k,v in pairs(tab.goods) do
                ItemControl.PushSingleItemData(v,ItemControl.PushEnum.add)
            end
            ---弹出奖励窗口
            MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
        end
        ---推送单个捐献次数数据
        GuildControl.PushSingleDonateCount(tab.id,tab.count)
        if callback then
            callback()
        end
    end)
end

---获取今日是否进入捐献界面
function GuildControl.GetDonateState()
    local player = PlayerControl.GetPlayerData()
    local key = player.UID.."_Donate"
    if UnityEngine.PlayerPrefs.HasKey(key) then
        if tonumber(UnityEngine.PlayerPrefs.GetString(key)) == Global.GetCreateRoleDays(Global.GetCurTime()) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function GuildControl.SetDonateState()
    local player = PlayerControl.GetPlayerData()
    local key = player.UID.."_Donate"
    UnityEngine.PlayerPrefs.SetString(key,tostring(Global.GetCreateRoleDays(Global.GetCurTime())))
end

----------------------------------------公会科技相关---------------------------------------------------------------------
function GuildControl.GetPlayerSkillData()
    return mPlayerSkillData
end

---获取单个科技信息
function GuildControl.GetSingleSkillData(_id)
    for k,v in pairs(mGuildSkillData) do
        if v.id == _id then
            return v
        end
    end
end

---获取指定id对应科技下一级科技数据
function GuildControl.GetNextSkillData(id)
    local data = GuildControl.GetSingleSkillData(id)
    local nextLevel = data.level + 1
    if data:WhetherMaxLevel() then
        nextLevel = data.level
    end
    for k,v in pairs(mGuildSkillData) do
        if v.type == data.type and v.level == nextLevel then
            return v
        end
    end
    return nil
end

---推送玩家公会科技数据
function GuildControl.PushPlayerSkillData()
    if mGuildInfo == nil or mGuildInfo.skill == nil then
        return
    end

    ---如果有科技数据
    mPlayerSkillData = {}
    for k,v in pairs(mGuildInfo.skill) do
        table.insert(mPlayerSkillData,GuildControl.GetSingleSkillData(v.id))
    end
end

---推送单个科技数据
function GuildControl.PushSingleSkillData(_id)
    if mGuildInfo.skill == nil then
        return
    end
    for k,v in pairs(mPlayerSkillData) do
        if v.type == GuildControl.GetSingleSkillData(_id).type then
            mPlayerSkillData[k] = GuildControl.GetSingleSkillData(_id)
            break
        end
    end
end---公会科技升级请求
function GuildControl.ClubSkillReq(_id,callback)
    local ClientClubSkillREQ = {
        id = _id
    }
    local bytes = assert(pb.encode('PBClient.ClientClubSkillREQ',ClientClubSkillREQ))
    MgrNet.SendReq(MID.CLIENT_CLUB_SKILL_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientClubSkillACK',buffer))
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end, function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientClubSkillNTF',buffer))
        ---更新数据统计
        TaskControl.ChangeStatistics(tab.day, tab.week, tab.month, tab.glory)
        ---消耗道具
        for k,v in pairs(tab.cost) do
            ItemControl.PushSingleItemData(v,ItemControl.PushEnum.consume)
        end
        ---推送单个数据
        GuildControl.PushSingleSkillData(tab.id)
        if  callback then
            callback()
        end
    end)
end
---公会聊天
function GuildControl.SendChat(_msg,callback)
    local ClientClubChatREQ = {
        text = _msg
    }
    local bytes = assert(pb.encode('PBClient.ClientClubChatREQ',ClientClubChatREQ))
    MgrNet.SendReq(MID.CLIENT_CLUB_CHAT_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientClubChatACK',buffer))
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        end
    end,nil)
end

function GuildControl.ChatServerConnect()
    MgrChatNet.ConnectServer(function(err,msgId)
        ---网络异常处理
        MgrUI.Pop(UID.PopTip_UI,{string.format(MgrLanguageData.GetLanguageByKey("mgrnet_tips1"),err),1},true)
    end,function(buffer,tag)
        local info = assert(pb.decode('PBClient.ClientJoinChatACK',buffer))
        if info.errNo ~= 0 then
            ---失败
            Log.Error(ServerError[info.errNo])
            if info.errNo >= 20000 then
                MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips29"),1},true)
            else
                MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"),1},true)
            end
        end
    end,function(buffer,tag)
        local info = assert(pb.decode('PBClient.ClientJoinChatNTF',buffer))
        if info.channel ~= nil then
            print("进入聊天室")
            MgrChatNet.RegisterNTF(MID.CLIENT_CLUB_CHAT_NTF,function(buffer,tag)
                local tab = assert(pb.decode('PBClient.ClientClubChatNTF',buffer))

                if mGuildInfo.note == nil then
                    mGuildInfo.note = {}
                end
                table.insert(mGuildInfo.note,tab)
                Event.Go("GuildChatMsg", tab)
            end)
        end
    end)
end

function GuildControl.JoinClubChat(callback)
    local ClientJoinClubChatREQ = {
        --rev = ""
    }
    local bytes = assert(pb.encode('PBClient.ClientJoinClubChatREQ',ClientJoinClubChatREQ))
    MgrChatNet.SendReq(MID.CLIENT_JOIN_CLUB_CHAT_REQ,bytes,0,nil,function(buffer, tag)
        local tab = assert(pb.decode('PBClient.ClientJoinClubChatACK',buffer))
        if tab.errNo~=0 then
            GuildControl.ErrorMsg(tab.errNo)
        else
            if callback then
                callback()
            end
        end
    end, nil)
end

function GuildControl.ErrorMsg(_errorNo)
    if _errorNo == 5 then
        ---名字中包含敏感词，请修改
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_guild_text76"),2},true)
    elseif _errorNo == 6 then
        ---已申请
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("addfriendpop_ui_tips3"),2},true)
    elseif _errorNo == 638 then
        ---没有找到您要的公会
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_guild_text60"),2},true)
        GuildControl.OpenGuildUI()
    elseif _errorNo == 640 then
        GuildControl.OpenGuildUI()
    elseif _errorNo == 642 then
        ---公会人数已满
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_guild_text24"),2},true)
    elseif _errorNo == 643 then
        ---权限不足
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_guild_text34"),2},true)
    elseif _errorNo == 648 then
        ---已申请
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("addfriendpop_ui_tips3"),2},true)
    else
        print("errorNo: ".._errorNo)
    end
end

function GuildControl.Clear()
    mGuildLvData = {}
    mGuildHeadData = {}
    mGuildDonateData = {}
    mGuildSkillData = {}
    mGuildList = nil
    mGuildInfo = nil
    mGuildSearch = nil
    mModeList = {}
    mOnlineState = {}
    mAppliedList = {}
    mPlayerSkillData = {}
    mCalmTime = 0
    mDismissTime = 0
end

return GuildControl
