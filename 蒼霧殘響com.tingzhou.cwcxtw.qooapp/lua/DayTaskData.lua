---@class DayTaskData
DayTaskData = Class("DayTaskData")
-------------构造方法-------------
function DayTaskData:ctor(id)
    local config = DaytaskLocalData.tab[id]
    self.id = id                    ---id
    self.type = config[2]           ---类型  1为每日 2为每周 3为每月
    self.frontLevel = config[3]         --- 解锁等级  玩家等级满足时开启任务
    self.frontTaskId = config[4]        ---前置任务id
    self.unlockId = config[5]   ---解锁任务id
    self.complete = config[6]   ---完成条件
    self.reward =
    {
        [1] = nil,
        [2] = nil,
        [3] = nil
    }   ---奖励
    local rewardStr = string.split(config[7],",")
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

    self.txt = config[8]  ---任务说明
    self.gotoID = config[9] ---跳转ID
    self.dayTaskID = config[10] ---任务组ID
    self.isComplete = 0 ---0未完成  1完成 是否完成
    self.isReceive = 0 ---0不能领取 1可领取
    self.openCopy = config[11]  ---通关了此关卡则显示，不填默认显示
    self.openTime = config[12]   ---开启时间 0无条件 n时间表id
end

return DayTaskData