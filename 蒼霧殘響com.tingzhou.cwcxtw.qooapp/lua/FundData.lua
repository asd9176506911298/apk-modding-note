---@class FundData 物品数据
FundData = Class("FundData")
-------------构造方法-------------
function FundData:ctor(id)
    local cfg = FundrebateLocalData.tab[id]
    if cfg == nil then
        return
    end
    self.id = cfg[1]
    self.activityID = cfg[2]                        ---活动ID
    self.awardGroupID = cfg[3]                      ---奖励组
    self.taskID = cfg[4]                            ---成就任务组
    self.pointItem = string.split(cfg[5],'_')   ---积分道具
    self.PointGroup = FundData:PointGroup(self.awardGroupID)        ---积分条件及奖励
end

function FundData:PointGroup(_awardId)
    local cfg = FundawardLocalData.tab
    local tGroup = {}
    for i, v in ipairs(cfg) do
        if v[3] == _awardId then
            local tList = {
                sort = v[2],                                        ---排序
                awardID = v[3],                                     ---奖励组ID
                factor = string.split(v[4],'_'),             ---奖励满足条件
                normalAward = string.split(v[5], '_'),       ---普通奖励
                highAward = string.split(v[6], '_'),         ---高级奖励
                canReceive = 0,                                     ---普通奖励领取状态(0.未完成 1.未领取 2.已领取)
                highCanReceive = 0,                                 ---高级奖励领取状态(0.未完成 1.未领取 2.已领取)
            }
            table.insert(tGroup, tList)
        end
    end
    
    Global.Sort(tGroup, { "sort" },false)
    return tGroup
end

return FundData