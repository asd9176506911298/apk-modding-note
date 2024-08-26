---挑战boss数据
---@class StormBossData
---@field --monsterData MonsterData
---@field monsterData RoleData
---@field rankInfos BossRankInfo[]
StormBossData = Class('StormBossData')
---构造方法
function StormBossData:ctor(id)
    self.id = id                    ---魔王ID
    self.activityid = nil           ---活动ID
    self.monster = nil              ---魔王战斗数据
    self.map = nil                  ---战斗地图
    self.thumbnail_map = nil        ---背景图
    self.thumbnail_drawing = nil    ---模拟战Boss图标
    self.maxHp = 0                  ---魔王最大血量
    self.type = 0                   ---挑战难度
    self.recomlevel = 0             ---推荐等级
    self.integral = 0               ---积分倍率
    self.prohibit = nil             ---UI显示用禁用技能表
end
---添加配置
function StormBossData:PushConfig(config)
    self.id = config[1]                    ---魔王ID
    self.activityid = config[2]           ---活动ID
    local monsterStr = string.split(config[3],"_")
    local id = tonumber(monsterStr[1])
    local star = tonumber(monsterStr[2])
    local level = tonumber(monsterStr[3])
    local isAwaken = tonumber(monsterStr[4])
    local skillLv = tonumber(monsterStr[5])
    local sIndex = tonumber(monsterStr[6])
    local scale = tonumber(monsterStr[7])
    local isBoss = tonumber(monsterStr[8])
    local core1Id = tonumber(monsterStr[9])
    local core1properties = tonumber(monsterStr[10])
    local core1skill = tonumber(monsterStr[11])
    local core2Id = tonumber(monsterStr[12])
    local core2properties = tonumber(monsterStr[13])
    local core2skill = tonumber(monsterStr[14])
    self.monsterData = MonsterControl.CreateSingleMonster(id,star,level,isAwaken,skillLv,sIndex,scale,isBoss,core1Id,core1properties,core1skill,core2Id,core2properties,core2skill,1)
    self.map = config[4]
    self.thumbnail_map = config[5]
    self.thumbnail_drawing = config[6]
    self.maxHp = config[7]
    self.type = config[8]
    self.recomlevel = config[9]
    self.integral = config[10]
    self.prohibit = config[12]
end
---@class BossRankInfo 世界boss排名信息
local rankInfo = {
    score = 0,
    rank = 0,
    nike = "",
    head = 1,
    headFrame = 0,
    level = 0,
    count = 0,
    title = "",
    id = -1,
}
---@class ServerBossData 服务器定义的boss数据结构
---@field goods goods
---@field rankInfo BossRankInfo[]
local bossData = {
    hp = 0,
    subKey = 0,
    nowRank = 0,
    goods = {},
    rewardRank = 0,
    isGetReward = 0,
    rankInfo = {},
    score = 0,
    maxScore = 0,
    count = 0,
}
---@param data ServerBossData 更新当前boss信息
function StormBossData:PushData(data)
    self.hp = data.hp
    self.subKey = data.subKey
    self.nowRank = data.nowRank
    self.reward = data.goods
    self.rewardRank = data.rewardRank
    self.getReward = data.isGetReward
    ---首次获取首页30条排名及玩家当前排名左右30条,以玩家id保存相同id能够直接覆盖当前名次
    self.rankInfos = {}
    if data.rankInfo ~= nil then
        ---保存已知的排名
        for i, v in pairs(data.rankInfo) do
            self.rankInfos[v.rank] = v
        end
        for i, v in ipairs(self.rankInfos) do
            if v == nil then
                ---补全空余的排名为查询中
                ---@type BossRankInfo
                local info = {
                    score = nil,
                    rank = #arr + 1,
                    nike = MgrLanguageData.GetLanguageByKey("stormbossdata_tips1"),
                    head = 1,
                    headFrame = 0,
                    level = nil,
                    count = nil,
                    title = "",
                    id = -1,
                }
                self.rankInfos[i] = info
            end
        end
    end
    self.count = data.count
    ---更新boss今日分数
    self.score = data.score
end
---更新boss历史分数
function StormBossData:PushScore(score)
    self.maxScore = score
end
---更新boss世界历史分数
function StormBossData:PushWorldScore(score)
    self.worldScore = score
end
---@return boolean 魔王关卡是否开启
function StormBossData:CheckUnlock()
    ---时间配置
    local timeConfig = TimeLocalData.tab[self.unlockTime]
    ---判断时间类型
    if timeConfig[2] == 0 then
        ---跨天周计数
        ---获取当前周几
        local wDay = os.date("%w",MgrNet.GetServerTime())
        wDay = wDay == "0" and "7" or wDay
        ---判断开放日配置中是否存在当前天
        if string.find(timeConfig[3],wDay) == nil then
            ---不存在则不开放
            return false
        end
        ---判断当前时间是否在开放日当天限制时间内
        local str = string.split(timeConfig[4],"-")
        local time = os.date("%Y-%m-%d",MgrNet.GetServerTime())
        local timeStr = string.split(time,"-")
        local beginTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
        str = string.split(timeConfig[5],"-")
        local endTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
        ---增加跨一天的时间
        endTime = endTime + 86400
        if not Global.isMiddleTime(beginTime,endTime) then
            ---不在时间内不开放
            return false
        end
    elseif timeConfig[2] == 1 then
        ---不跨天周计数
        ---获取当前周几
        local wDay = os.date("%w",MgrNet.GetServerTime())
        wDay = wDay == "0" and "7" or wDay
        ---判断开放日配置中是否存在当前天
        if string.find(timeConfig[3],wDay) == nil then
            ---不存在则不开放
            return false
        end
        ---判断当前时间是否在开放日跨天限制时间内
        local str = string.split(timeConfig[4],"-")
        local time = os.date("%Y-%m-%d",MgrNet.GetServerTime())
        local timeStr = string.split(time,"-")
        local beginTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
        str = string.split(timeConfig[5],"-")
        local endTime = tonumber(os.time({year=timeStr[1], month = timeStr[2], day = timeStr[3], hour = str[1], min = str[2], sec = str[3]}))
        if not Global.isMiddleTime(beginTime,endTime) then
            ---不在时间内不开放
            return false
        end
    elseif timeConfig[2] == 2 then
        ---具体时间开放
        ---判断当前时间是否在开放日当天限制时间内
        local str = string.split(timeConfig[6],"-")
        local beginTime = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
        str = string.split(timeConfig[7],"-")
        local endTime = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
        if not Global.isMiddleTime(beginTime,endTime) then
            ---不在时间内不开放
            return false
        end
    elseif timeConfig[2] == 999 then
        ---常驻不处理为开放
    end
    return true
end
---清空排行数据
function StormBossData:ClearRanks()
    StormBossData.rankInfos = {}
end
return StormBossData