---@class AchievementTaskData
AchievementTaskData = Class("AchievementTaskData")
-------------构造方法-------------
function AchievementTaskData:ctor(id)
    local config = ActiveLocalData.tab[id]
    self.id = id                    ---id
    self.type = config[2]           ---类型  1为战斗 2为搜集 3为消费 4为养成
    self.frontLevel = config[3]         --- 解锁等级  玩家等级满足时开启任务
    self.frontTaskId = config[4]            ---前置任务id
    self.unlockId = config[5]   ---解锁任务id
    self.icon = config[6]      ---任务图标
    self.complete = config[7]  ---完成条件
    self.name = config[8]  ---任务名称
    self.txt = config[9]  ---任务说明
    self.reward =
    {
        [1] = nil,
        [2] = nil,
        [3] = nil
    }   ---奖励
    local rewardStr = string.split(config[10],",")
    for i, v in pairs(rewardStr) do
        local arr = string.split(v,"_")
        local goods =
        {
            goodsID = tonumber(arr[2]),
            goodsType = tonumber(arr[1]),
            goodsNum = tonumber(arr[3]),
        }
        self.reward[i] = goods
    end
    self.isComplete = 0 ---0未完成  1完成 是否完成
    self.isReceive = 0 ---0未完成  1完成 是否完成
    self.medal = config[11]
    self.gotoID = config[12]
    self.UINum = config[13]
    self.taskGroupID = config[15]
    self.activeId = config[16]  ---按系统区分
end

return AchievementTaskData