require("LocalData/JointcrusadeLocalData")
require("LocalData/ActivityLocalData")
require("LocalData/TimeLocalData")
require("LocalData/JcbossLocalData")
---@class BossActivityData 活动数据
BossActivityData = Class("BossActivityData")
-------------构造方法-------------
function BossActivityData:ctor()
    self.id = 0             ---ID
    self.activityID = 0     ---活动ID
    self.activityType = 0   ---活动类型
    self.type = 0           ---魔王类型
    self.name = ""          ---活动名
    self.resource = ""      ---封面
    self.icon = ""          ---活动图标
    self.plot = ""          ---片头剧情
    self.checkpoint = {}    ---关卡ID
    self.ehp = 0            ---Boss血量
    self.kill = ""           ---击杀奖励
    self.shoptype = 0       ---商店类型
    self.bgm = ""           ---BGM
    self.beginTime = ""     ---开始时间
    self.endTime = ""       ---结束时间
    self.battleEndTime = ""   ---战斗关闭时间
    self.BossData = {}      ---Boss活动对应的三个Boss数据
    self.sysLockNum = 1107
end

function BossActivityData:PushData(activityID)
    local config
    for i,v in pairs(JointcrusadeLocalData.tab) do
        if v[2] == activityID then
            config = v
            break
        end
    end
    local activityType = 0
    for i,v in pairs(ActivityLocalData.tab) do
        if v[1] == activityID then
            activityType = v[2]
            break
        end
    end
    if config then
        self.id = config[1]
        self.activityID = config[2]
        self.activityType = activityType
        self.type = config[3]
        self.name = config[4]
        self.resource = config[5]
        self.icon = config[6]
        self.plot = config[7]
        local ids = string.split(config[8],",")
        for i,v in pairs(ids) do
            table.insert(self.checkpoint,v)
        end
        self.ehp = config[9]
        self.kill = config[10]      ---特殊奖励(击杀奖励)
        self.shoptype = config[11]
        self.bgm = config[12]
        ---商店开启时间
        if ActivityLocalData.tab[activityID] then
            local time = ActivityLocalData.tab[activityID][5]
            self.beginTime = TimeLocalData.tab[time][6]
            self.endTime = TimeLocalData.tab[time][7]
        end
        ---战斗开启时间
        for i,v in pairs(ActivityLocalData.tab) do
            if v[2] == 996 then
                self.battleEndTime = TimeLocalData.tab[v[15]][7]
                break
            end
        end

        for i,value in pairs(JcbossLocalData.tab) do
            if value[2] == activityID then
                local bossDta = StormBossData.New()
                bossDta:PushConfig(value)
                table.insert(self.BossData,bossDta)
            end
        end
    end
end

return BossActivityData