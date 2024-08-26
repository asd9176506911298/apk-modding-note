require("LocalData/StoryactivityLocalData")
require("LocalData/ActivityLocalData")
require("LocalData/TimeLocalData")
---@class EventRaidData 活动数据
EventRaidData = Class("EventRaidData")
-------------构造方法-------------
function EventRaidData:ctor()
    self.id = 0             ---ID
    self.activityID = 0     ---活动ID
    self.name = ""          ---活动名
    self.resource = ""      ---封面
    self.icon = ""          ---活动图标
    self.plot = ""          ---片头剧情
    self.chapterId = {}     ---卷ID
    self.shopType = 0       ---商店类型
    self.taskId = 0         ---活动成就任务组
    self.dayTaskId = 0      ---活动日常任务组
    self.beginTime = ""     ---开始时间
    self.endTime = ""       ---结束时间
    self.battleEndTime = "0"
    self.music = ""         ---活动主界面bgm
    self.gallary = nil      ---剧情回放跳转
    self.group = nil        ---引导id
end

function EventRaidData:PushData(activityID)
    local config
    for i,v in pairs(StoryactivityLocalData.tab) do
        if v[2] == activityID then
            config = v
        end
    end
    if config then
        self.id = config[1]
        self.activityID = config[2]
        self.name = config[3]
        self.resource = config[4]
        self.icon = config[5]
        self.plot = config[6]
        local ids = string.split(config[7],",")
        for i,v in pairs(ids) do
            table.insert(self.chapterId, tonumber(v))
        end
        self.shopType = {}
        local tlist = string.split(config[8],',')
        for i,v in pairs(tlist) do
            table.insert(self.shopType, tonumber(v))
        end
        self.taskId = config[9]
        self.dayTaskId = config[10]
        local activeCfg = ActivityLocalData.tab[activityID]
        if activeCfg then
            local time = activeCfg[5]
            self.beginTime = TimeLocalData.tab[time][6]
            self.endTime = TimeLocalData.tab[time][7]
            if activeCfg[15] ~= 0 then
                self.battleEndTime = TimeLocalData.tab[activeCfg[15]][7]               ---战斗结束时间
            end
        end
        self.music = config[11]
        if config[13] ~= "0" then
            self.gallary = string.split(config[13],',')
        end
        self.group = config[12]
    end
end

return EventRaidData