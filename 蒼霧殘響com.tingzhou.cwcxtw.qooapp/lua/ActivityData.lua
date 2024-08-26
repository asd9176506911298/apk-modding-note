---@class ActivityData 物品数据
ActivityData = Class("ActivityData")
-------------构造方法-------------
function ActivityData:ctor(id)
    local config = ActivityLocalData.tab[id]
    if config == nil then
        print("ActivityLocalData无法找到ID："..id)
        return
    end
    self.activityId = config[1]                         ---ID
    self.activityType = config[2]                       ---活动类型
    self.openLevel = config[3]                          ---开启等级
    self.front = config[4]                              ---前置关卡
    self.unlockTime = config[5]                         ---活动结束时间
    self.battleUnlockEndTime = config[15]               ---活动战斗结束时间
    self.version = config[6]                            ---版本号
    self.sort = config[7]                               ---排序
    self.isShow = config[8]                             ---是否在活动列表中显示(1.显示 0.不显示)
    self.beginTime = "0"                                ---活动开始时间
    self.endTime = "0"                                  ---活动结束时间
    self.battleEndTime = "0"
    self.dayTime = 0                                    ---活动开启天数(特殊时间类型才会判断天数，一般为0)
    self.timeType = TimeLocalData.tab[config[5]][2]     ---时间类型
    if TimeLocalData.tab[config[5]] then
        if self.timeType ~= 999 then
            self.beginTime = TimeLocalData.tab[config[5]][6]
            self.endTime = TimeLocalData.tab[config[5]][7]
            if config[15] ~= 0 then
                self.battleEndTime = TimeLocalData.tab[config[15]][7]               ---战斗结束时间
            end
        else
            self.dayTime = tonumber(TimeLocalData.tab[config[5]][8])
        end
    end
    self.name = config[9]
    self.systemopen = config[10]                        ---系统解锁条件
    self.gotoID = config[11]                            ---跳转

    self.userID = 0                                     ---用户id
    self.score = 0                                      ---活动累计积分
    self.uTime = 0                                      ---更新时间
    self.reward = ""                                    ---活动奖励(k是奖励id，v是奖励类型)
    self.recharge = 0                                   ---累计充值金额
end

function ActivityData:PushData(data)
    self.userID = data.userID
    self.score = data.score
    self.uTime = data.uTime
    self.reward = data.reward
    self.recharge = data.recharge
end

function ActivityData:PushRewardData(reward)
    self.reward = reward
end

---联合讨伐相关数据
function ActivityData:PushBossData(data)
    self.bossID = data.bossID
    self.count = data.count
    self.hp = data.hp
    for i,v in pairs(JointcrusadeLocalData.tab) do
        if v[2] == data.bossID then
            self.maxHp = v[9]
        end
    end
    self.isGetReward = data.isGetReward
    self.nowRank = data.nowRank
    self.rewardRank = data.rewardRank
    self.score = data.score
    self.subKey = data.subKey
    if data.rankInfo ~= nil then
        self.rankInfos = data.rankInfo
        table.sort(self.rankInfos,function(a,b)
            if a.rank < b.rank then
                return true
            else
                return false
            end
        end)
    else
        self.rankInfos = {}
    end

end

function ActivityData:ClearRanks()
    self.rankInfos = {}
end

function ActivityData:CheckUnlock()
    return Global.isMiddleTime(self.beginTime, self.endTime)
end

return ActivityData