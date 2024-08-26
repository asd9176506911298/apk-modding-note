require("Model/Player/Data/PlayerData")
require("LocalData/SteamLocalData")
require("LocalData/RoleattributeLocalData") ---看板娘基础配置
require("LocalData/CharactercoordinatesLocalData") ---看板娘坐标配置
require("LocalData/ActorLinesLocalData") ---板娘台词表
require("LocalData/PlayerplLocalData")
---玩家管理器
PlayerControl = {}
---@type PlayerData 玩家数据缓存
local CachePlayerData = PlayerData.New()

---请删掉整合到玩家数据模型里
PlayerControl.BuyNumber = 0
---请删掉整合到玩家数据模型里
PlayerControl.BigPVPBuyNumber = 0
---登录时获取申请我为好友的人数
PlayerControl.ApplyFriendNum = nil

---支援次数
PlayerControl.SupportNum = 0

PlayerControl.SupportNumMax = 0

---与服务器的时间差
PlayerControl.diffTime = 0
---是否第一次获取与服务器的时间差
PlayerControl.getDiffTimeFirst = true

---推送玩家数据
function PlayerControl.PushPlayerData(...)
    CachePlayerData:PushData(...)
    --默认吉雅ID
    if CachePlayerData.curRoleID == 19000 then
        CachePlayerData.curRoleID = 90000
    end
end
---@return PlayerData 获取已完成教程ID
function PlayerControl.GetTutorial()
    return CachePlayerData.tutorial
end

---@return PlayerData 获取玩家数据
function PlayerControl.GetPlayerData()
    return CachePlayerData
end

---检查玩家是否升级
function PlayerControl.CheckLevelUp(lv)
    if lv == nil then
        return
    end
    ---如果升级 推送玩家升级前的数据
    if lv > CachePlayerData.level then
        CachePlayerData.beforeLv = CachePlayerData.level
        PlayerControl.PushLevelUpState(true)
    end
end

---推送升级状态
function PlayerControl.PushLevelUpState(state)
    CachePlayerData.isLevelUp = state
end

---获取玩家当前体力
function PlayerControl.GetVigor()
    return CachePlayerData:GetVigor()
end
---获取玩家最大体力
function PlayerControl.GetMaxVigor()
    local config = PlayerplLocalData.tab[CachePlayerData.level]
    return config[4]
end
---获取玩家最大助战次数
function PlayerControl.GetMaxSupport(level)
    local config
    if level == nil then
        config = PlayerplLocalData.tab[CachePlayerData.level]
    else
        config = PlayerplLocalData.tab[level]
    end
    return config[6]
end
---获取玩家等级
function PlayerControl.GetPlayerLevel()
    return CachePlayerData.level
end
---获取玩家头像
function PlayerControl.GetPlayerIcon()
    ---通过当前角色获取头像
    return RoleattributeLocalData.tab[PlayerControl.GetPlayerData().curRoleID][7]
end
---根据等级获取当前等级最大经验
function PlayerControl.GetMaxExpByLevel(lv)
    local config = PlayerplLocalData.tab[lv]
    return config[3]
end
---注册玩家属性变更通知
function PlayerControl.AddNotify(func)
    table.insert(PlayerControl.GetPlayerData().notify,func)
end
---添加周签到数据
function PlayerControl.PushWeekSignData(day)
    PlayerControl.GetPlayerData().weekSign = day
    PlayerControl.SetWeekSignState(true)
end
---获取周签到数据
function PlayerControl.GetWeekSignData()
    local data = PlayerControl.GetPlayerData().weekSign
    local tIsSignFull = true
    local t = {}
    local i = 1
    for id, value in pairs(SigninLocalData.tab) do
        if value.type == "0" then
            t[i] = i <= data
            if tIsSignFull then
                tIsSignFull = i <= data
            end
            
            i=i+1
        end
    end
    
    return t,tIsSignFull
end
---今日周签到状态
function PlayerControl.GetWeekSignState()
    if PlayerControl.GetPlayerData().wSignTime ~= "" then
        local cTime = MgrNet.GetServerTime()
        local tTime = cTime - Global.GetTimeByStr(PlayerControl.GetPlayerData().wSignTime)
        PlayerControl.GetPlayerData().wSignState = PlayerControl.GetPlayerData().wSignState == false and tTime < (86400+5*3600) or PlayerControl.GetPlayerData().wSignState
    end

    return PlayerControl.GetPlayerData().wSignState
end

---周签到次数
function PlayerControl.GetWeekSignCount()
    return PlayerControl.GetPlayerData().weekSign
end

function PlayerControl.SetWeekSignState(_state)
    PlayerControl.GetPlayerData().wSignState = _state
end
---添加月签到数据
function PlayerControl.PushMonthSignData(arr)
    local num = 0
    for i = 1 ,#arr do
        num = num + arr[i]*2^(i-1)
    end
    print(num)
    PlayerControl.GetPlayerData():PushMonthSignData(num)
end
---获取月签到数据
function PlayerControl.GetMonthSignData()
    ---将数据转换为31位的二进制数组
    local data = PlayerControl.GetPlayerData().monthSign
    local t = {}
    for i=30,0,-1 do
        t[i+1] = math.floor(data/2^i)
        data = data % 2^i
    end
    return t
end

---获取购买次数返回
function PlayerControl.BuyNumberACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetBuyNumberACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("playercontrol_tips1"),2},true)
    end
end
function PlayerControl.BuyNumberNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetBuyNumberNTF',buffer))
    print(tab)
    if tab then
        if tab.item then
            for i, v in pairs(tab.item) do
                if v.id == 100001 then
                    PlayerControl.BuyNumber = v.count
                elseif v.id == 100009 then
                    PlayerControl.BigPVPBuyNumber = v.count
                end
            end
        else
            PlayerControl.BuyNumber = 0
            PlayerControl.BigPVPBuyNumber = 0
        end
    else
        PlayerControl.BuyNumber = 0
        PlayerControl.BigPVPBuyNumber = 0
    end
end
---获取购买次数数据
function PlayerControl.SendBuyNumber(_type) --type  0 只获取特殊商店(PVP购买次数、体力购买次数) 1 获取所有商店购买次数
    local BaseREQ  =
    {
        type = _type
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientGetBuyNumberREQ',BaseREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_GET_BUY_NUMBER_REQ,bytes,0,nil, PlayerControl.BuyNumberACK,PlayerControl.BuyNumberNTF)
end

function PlayerControl.PushBuyNumber(data)
    if data then
        if data.buyShops then
            for i, v in pairs(data.buyShops) do
                if v.shopID == 100001 then
                    PlayerControl.BuyNumber = v.shopCount
                elseif v.shopID == 100009 then
                    PlayerControl.BigPVPBuyNumber = v.shopCount
                end
            end
        else
            PlayerControl.BuyNumber = 0
            PlayerControl.BigPVPBuyNumber = 0
        end
    else
        PlayerControl.BuyNumber = 0
        PlayerControl.BigPVPBuyNumber = 0
    end
end

---覆盖拓展核心背包次数
function PlayerControl.PushExpand(number)
    CachePlayerData.expand = number
end

function PlayerControl.PushFriendApplyCount(num)
    PlayerControl.ApplyFriendNum = num
end

function PlayerControl.PushFriendSupport(supportNum)
    PlayerControl.SupportNum = supportNum
    if supportNum == nil then
        PlayerControl.SupportNum = 0
    end
    PlayerControl.SupportNumMax = PlayerControl.GetMaxSupport()
end

function PlayerControl.Clear()
    CachePlayerData = PlayerData.New()
    PlayerControl.BuyNumber = 0
    PlayerControl.BigPVPBuyNumber = 0
end

return PlayerControl
