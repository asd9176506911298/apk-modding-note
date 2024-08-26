require("Model/Passport/Data/PassportItemData")
require("LocalData/MonthpassLocalData")

---通行证管理器
PassportControl = {}

---月卡奖励数据
---@type PassportItemData[] 通行证奖励数据
local AllPassportReward = {}
---通行证信息 ClientActivityGetNTF
--required int32 userId = 1;
--required int32 activityId = 2;
--required int32 version = 3;
--required int32 score = 4;
--required int64 uTime = 5;
--required string reward = 6;   转成表
local PassportInfo = nil
local PassportVersion = nil   --通行证版本
local PassportBuyTime = nil   --通行证购买时间
local PassBaseData = nil      --通行证总表数据
---推送通行证版本和购买时间
function PassportControl.PushPassport(version,BuyTime)
    PassportVersion = version
    PassportBuyTime = BuyTime
end

function PassportControl.PushPassportData(passes)
    PassportInfo.activityId = passes.activityId
    PassportInfo.Version = passes.Version
    PassportInfo.score = passes.score
    PassportInfo.uTime = passes.uTime
end

---获取通行证版本
function PassportControl.GetVersion()
    return PassportVersion
end
---获取通行证购买时间
function PassportControl.GetBuyTime()
    return PassportBuyTime
end
---是否购买了通行证
function PassportControl.isBought()
    local passport = ActivityControl.GetActivityInfo(ActivityControl.activityTypeEnum.PASSPORT)
    if passport == nil then
        return false
    end
    return passport.version == PassportVersion
end

---读取所有大月卡奖励内容
function PassportControl.GetAllPassportReward(awardId)
    if AllPassportReward ~= nil and #AllPassportReward ~= 0 then
        return AllPassportReward
    end
    for i,v in ipairs(MonthpassawardLocalData.tab) do
        if v[3] == awardId then
            local item = PassportItemData.New(i)
            item:PushData(i)
            table.insert(AllPassportReward,item)
        end
    end
    return AllPassportReward
end
---领取活动奖励ACK
function PassportControl.ActivityRewardSendACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        if tab.errNo == 2003 then
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips1"),2},true)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips2"),2},true)
        end
    end
end
---领取通行证活动奖励NTF
function PassportControl.ActivityRewardSendNTF(buffer, tag)
    ---解析活动奖励
    local tab = assert(pb.decode('PBClient.ClientActivityGetRewardNTF',buffer))
    if tab.goods then
        ---将奖励推送进背包
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
        ---弹出奖励弹窗
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)
    else
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips3"),2},true)
    end
    if tab.reward then
        ---更新已领取的奖励
        PassportControl.RefreshReceivedReward(tab.reward)
    end
    ---刷新背包缓存数据
    BagViewModel.ReloadCacheData()
end
---一键领取所有
function PassportControl.AcceptAll(parentUI)
    local activityRewardReq  =
    {
        activityId = PassportInfo.activityId,
        rewardId = 0,
        rewardType = 1
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientActivityGetRewardREQ',activityRewardReq))
    ItemControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_ACTIVITY_GET_REWARD_REQ,bytes,0,nil,PassportControl.ActivityRewardSendACK,function(...)
        PassportControl.ActivityRewardSendNTF(...)
        ---刷新界面
        parentUI:InitPassport()
    end)
end
---解锁高级通行证
function PassportControl.UnlockSeniorPassport()
    ShopViewModel.FlyFunBuyGoods(110001)
end
---购买等级
function PassportControl.BuyPassportLevel(parentUI,count)
    local buyPassesLevelREQ = {
        count = count
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientBuyPassesLevelREQ',buyPassesLevelREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_BUY_PASSES_LEVEL_REQ,bytes,0,nil,
            function(...) PassportControl.BuyPassportLevelACK(...) end,
            function(...)
                PassportControl.BuyPassportLevelNTF(...)
                parentUI:InitPassport()
            end)
end
function PassportControl.BuyPassportLevelACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientBuyPassesLevelACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        ItemControl.AckError = true
        if tab.errNo == 515 then
            ItemControl.RequireBagItem(function()
                if PassportViewModel.InitPassport then
                    PassportViewModel.InitPassport()
                end
            end)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("passportcontrol_tips4"),2},true)
        end
    end
end
function PassportControl.BuyPassportLevelNTF(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientBuyPassesLevelNTF',buffer))
    ---更新部分活动信息
    ActivityControl.SetActivityInfo(tab.activityId,tab)
    if tab.cost then
        ItemControl.PushGroupItemData(tab.cost,ItemControl.PushEnum.consume)    ---物品消耗
    end
    if tab.goods then
        ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)       ---获得物品
        MgrUI.Pop(UID.ItemAchievePop_UI,{tab.goods},true)       ---弹出奖励窗口
    end
end
---设置通行证数据
function PassportControl.SetPassportData()
    PassportInfo = ActivityControl.GetActivityInfo(ActivityControl.activityTypeEnum.PASSPORT)
end
---获得通行证数据
function PassportControl.GetPassportData()
    if PassportInfo == nil then
        PassportControl.SetPassportData()
    end
    return PassportInfo
end
function PassportControl.ClearPassportData()
    PassportInfo = nil
end
---获得通行证已领取奖励
function PassportControl.GetReceivedReward()
    if PassportInfo == nil then
        return nil
    end
    local tab = RapidJson.decode(PassportInfo.reward)
    return tab
end
---更新已领取的奖励
function PassportControl.RefreshReceivedReward(reward)
    PassportInfo.reward = reward
end
---增加总积分
function PassportControl.RefreshPassportScore(event)
    if event then
        ---找到对应任务
        for i,v in pairs(event) do
            if v.id == PassportInfo.activityId then
                PassportInfo.score = v.score
            end
        end
    end
end

---获取可领取的奖励
function PassportControl.GetAvailableReward()
    ---已领取的奖励
    local receivedReward = PassportControl.GetReceivedReward()
    local playerRewards = {}
    local Rewards = {}
    local lv = math.modf(PassportControl.GetPassportData().score / 1000)
    if lv > tonumber(SteamLocalData.tab[111008][2]) then
        lv = tonumber(SteamLocalData.tab[111008][2])
    end
    for i,reward in pairs(AllPassportReward) do
        if lv >= i then
            ---加入满足等级条件可领取的奖励
            table.insert(playerRewards,reward)
        end
    end
    ---如果有可领取的奖励
    if next(playerRewards) ~= nil then
        for k,v in pairs(playerRewards) do
            if not PassportViewModel.CheckSeniorLock() then
                ---在可领取的奖励里筛去已领取的奖励
                if PassportControl.Contains(k,receivedReward) == false then
                    ---添加可领取但是未领取的奖励
                    Rewards[#Rewards + 1] = v
                end
            else
                if PassportControl.ContainsSeniorReward(k,receivedReward) == false then
                    ---添加可领取但是未领取的奖励
                    Rewards[#Rewards + 1] = v
                end
            end
        end
        Global.Sort(Rewards,{"id"},false)
        return Rewards
    end
    return nil
end

---获取玩家当前通行证等级
function PassportControl.GetLv()
    if PassportControl.GetPassportData() == nil then
        return 0
    end
    local lv = math.modf(PassportControl.GetPassportData().score / 1000)
    --是否超过最大等级上限
    if lv >= tonumber(SteamLocalData.tab[111008][2]) then
        return tonumber(SteamLocalData.tab[111008][2])
    end
    return lv
end

---是否包含指定元素
function PassportControl.Contains(target,table)
    if table == nil then
        return false
    end
    for k,v in pairs(table) do
        if target == tonumber(k) then
            return true
        end
    end
    return false
end

---是否包含高级奖励
function PassportControl.ContainsSeniorReward(target,receivedReward)
    if receivedReward == nil then
        return false
    end
    for k,v in pairs(receivedReward) do
        if v == 2 and target == tonumber(k) then
            return true
        end
    end
    return false
end

---获取是否在活动时间内
function PassportControl.GetIsInMiddle()
    if PassportControl.GetPassportData() then
        local startTime = TimeLocalData.tab[ActivityLocalData.tab[PassportControl.GetPassportData().activityId][5]][6]
        local endTime = TimeLocalData.tab[ActivityLocalData.tab[PassportControl.GetPassportData().activityId][5]][7]
        local inMiddle = Global.isMiddleTime(startTime, endTime)
        return inMiddle
    end
    return false
end
---通行证总表
function PassportControl.InitPassportBD()
    local temp = PassportControl.GetPassportData()
    for i, v in ipairs(MonthpassLocalData.tab) do
        if v[2] == temp.activityId then
            local t = {
                activityId = v[2],      ---活动ID        
                backImg = v[4],         ---背景图
                awardId = v[6],         ---通行证奖励组
                taskId = v[7],          ---活动成就任务组
                daytaskId = v[8],       ---活动日常任务组
            }
            PassBaseData = t
            break
        end
    end
end

function PassportControl.GetPassportBD()
    if PassBaseData == nil then
        PassportControl.InitPassportBD()
    end
    
    return PassBaseData
end

return PassportControl