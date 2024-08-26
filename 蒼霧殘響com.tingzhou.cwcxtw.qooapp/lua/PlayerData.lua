---玩家数据
---@class PlayerData
PlayerData = Class('PlayerData')
---构造方法
function PlayerData:ctor()
    self.UID = 0                ---用户id
    self.nickname = ""          ---昵称
    self.headUrl = 0            ---头像
    self.headFrame = 0          --头像框
    self.allianceId = 0         ---公会id
    self.level = 1              ---等级
    self.exp = 0                ---经验
    self.status = 0             ---状态
    self.title = ""             ---称号
    self.ReNameCount = 0        ---改名次数
    self.weekSign = 0           ---是否已周签到
    self.monthSign = 0          ---是否已月签到
    self.createTime = 0         ---创建时间
    self.lastLoginTime = 0      ---上次登录时间
    self.curLoginTime = 0       ---登录时间
    self.curRoleID = 10000      ---当前人物
    self.newEmailCount = 0      ---未读邮件数量
    self.monthCardRemaining = 0 ---月卡剩余时间
    self.expand = 0             ---核心背包拓展次数
    self.vigor = {}             ---体力
    self.signature = ""         ---签名
    self.tutorial = {}        ---已经完成的教程id
    self.lotterys = {}          ---奖池信息
    self.notify = {}            ---通知
    self.wSignTime = ""          ---上一次七天签到时间
    self.wSignState = false     ---今日七天签到状态
    self.sLoginSign = false     ---是否为登陆后首次检查签到
    self.beforeLv = nil         ---升级前的等级
    self.isLevelUp = false      ---玩家是否升级(用来判断是否弹出升级界面)
    self.birthday = ""          --玩家生日
    self.fundBuyTime = nil      ---基金购买时间
    self.fundVersion = nil      ---基金购买的版本
end
---覆盖玩家数据
function PlayerData:PushData(info)
    self.UID = info.userID          --UID
    self.nickname = info.nike       --昵称
    self.headUrl = info.head        --头像
    self.headFrame = info.headFrame --头像框
    self.allianceId = info.alliance --公会
    self:PushLevel(info.level, false)      --等级
    self:PushExp(info.exp)          --经验
    self.status = info.status       --状态
    self.createTime = info.cTime    --创建时间
    self.lastLoginTime = info.uTime --上次登录时间
    self.ReNameCount = info.reNameNum   --重命名次数
    self.title = info.title         --称号
    self.weekSign = info.wSign      --周签到
    self:PushMonthSignData(info.mSign)  --月签到
    self.curLoginTime = info.nTime  --当前时间
    self.monthCardBuyTime = info.monthCardBuyTime           --月卡购买时间
    self.monthCardRemaining = info.monthCardRemaining       --月卡持续时间
    self.bigMonthCardBuyTime = info.bigMonthCardBuyTime     --大月卡购买时间
    self.bigMonthCardVersion = info.bigMonthCardVersion     --大月卡版本
    self.fundBuyTime = info.fundCardBuyTime         --基金购买时间
    self.fundVersion = info.fundCardVersion         --基金版本
    --主界面人物id
    if info.menuRoleID == 0 then
        if #info.heros == 0 then
            print("推送角色为空")
            local tStr = string.split(SteamLocalData.tab[104005][2],',')
            if #tStr > 0 then
                self.curRoleID = tonumber(tStr[1])
            end
        else
            self.curRoleID = info.heros[1].heroID
        end
    else
        self.curRoleID = info.menuRoleID    
    end
    
    self.newEmailCount = info.newEmailNum   --未读邮件数量
    self:PushVigor(info.vigor)      --体力数值
    self.expand = info.expand       --核心背包拓展次数
    self.lotterys = info.lotterys   --奖池信息
    self.signature =  info.signature    --签名
    self.tutorial = info.tutorial       --已经完成的教程id
    self.wSignTime = info.wSignTime == nil and "" or info.wSignTime    ---上一次七天签到时间
    self.birthday = info.birthday
    self.unGetEmail = info.unGetEmail
    print("当前玩家经验",self.exp)
    ---创建计时器
    MgrNet.CreateLocalTime(info.nTime)
end
---更新经验
function PlayerData:PushExp(exp)
    self.exp = exp
end
---更新等级
function PlayerData:PushLevel(level, checkLvup)
    if checkLvup == nil then
        checkLvup = true
    end
    if checkLvup then
        if level > self.level then
            self.level = level
            MgrSdk.FlyFunRoleUpgrade()
        end
    else
        self.level = level
    end
    PlayerControl.SupportNumMax = PlayerControl.GetMaxSupport(level)
    if MgrUI.GetCurUI().Uid == UID.Login_UI or MgrUI.GetCurUI().Uid == UID.Battle02_UI then
    else
        ---引导中不再触发新引导
        if NoviceViewModel.Noviceing == false then
            NoviceViewModel.ForceGuide(NoviceViewModel.CheckForce())
        end
    end
end

function PlayerData:ChangeLevel(level)
    self.level = level
    if MgrUI.GetCurUI().Uid == UID.Login_UI then
    else

    end
end

---更新签到数据
function PlayerData:PushMonthSignData(mSign)
    self.monthSign = mSign
end

---更新体力
function PlayerData:PushVigor(vigor)
    self.vigor = vigor
    self:Notify()
end
---获取体力
function PlayerData:GetVigor()
    return self.vigor.vigorNum
end

function PlayerData:GetVigorInfo()
    return self.vigor
end

---状态更新
function PlayerData:Notify()
    for _idx,_func in pairs(self.notify) do
        if _func then
            ---存在更新
            _func()
        else
            ---不存在移除
            table.remove(self.notify,_idx)
        end
    end
end
return PlayerData