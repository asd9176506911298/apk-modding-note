---@class IntegralTaskData
IntegralTaskData = Class("IntegralTaskData")
-------------构造方法-------------
function IntegralTaskData:ctor(id)
    local config = Daytask_rewardLocalData.tab[id]
    self.id = id                    ---id
    self.type = config[2]           ---类型  1为每日 2为每周 3为每月
    self.num = config[3]         --- 积分达成数量
    self.reward =
    {
        [1] = nil,
        [2] = nil,
        [3] = nil
    }   ---奖励
    local rewardStr = JNStrTool.strSplit(",",config[4])
    for i, v in pairs(rewardStr) do
        local arr = JNStrTool.strSplit("_",v)
        local goods =
        {
            goodsID = tonumber(arr[2]),
            goodsType = tonumber(arr[1]),
            goodsNum = tonumber(arr[3]),
        }
        self.reward[i] = goods
    end
    self.isComplete = 0 ---0未完成  1完成 是否完成
    self.isReceive = 0
end

return IntegralTaskData