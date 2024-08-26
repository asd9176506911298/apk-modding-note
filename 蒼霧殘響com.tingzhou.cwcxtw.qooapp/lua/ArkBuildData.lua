---@class ArkBuildData
ArkBuildData = Class('ArkData')
---@param id number 构造方法
function ArkBuildData:ctor(id)
    local config = InfrastructurebuildLocalData.tab[id]
    self.id = id                               ---ID
    self.frontID = config[2]                   ---前置ID
    self.buildType = config[3]                 ---建筑类型
    self.canUp = config[4]                     ---是否可升级 0可以 1 不可以
    self.level = config[5]                     ---建筑当前等级
    self.maxLevel = config[6]                  ---建筑最大等级
    self.playerLevel = config[7]               ---需要玩家等级
    self.name = config[8]                      ---建筑名
    self.desc = config[9]                      ---建筑描述
    self.costTime = config[10]                 ---建造消耗时间
    self.cost = string.split(config[11],"_")       ---建造消耗
    self.yield = string.split(config[18],"_")      ---产量
    self.capacity = config[13]                 ---容量
    self.taskGroup = config[14]                ---远征任务组
    self.expeditionTaskNum = config[15]        ---最大远征任务数量
    self.expeditionNum = config[16]            ---远征队伍数量
    self.unlockID = config[17]                 ---下一级ID
    self.cTime = 0                             ---服务器数据 建筑获取的时间(升级时变动)
    self.uTime = 0                             ---服务器数据 建筑更新时间(升级和收取物资时变动,升级时变成建造完成的时间)
    self.upgrading = false                     ---是否在升级
    self.Upgradeable = false                   ---是否可升级
    self.TimerName = "Ark"..config[3]          ---计时器名字
    self.ReapTime = 0                          ---收获时间
    self.RealYield = string.split(config[12],"_")      ---实际产量
    self.purposeTxt = config[20]               ---建筑用途文本
    self.buildImage = config[21]               ---建筑图片
end

---获取建筑生产了多少物资
function ArkBuildData:GetYieldCount(curTime,uTime)
    if curTime - uTime <= 0 then
        return 0
    end
    if tonumber(self.RealYield[4]) == nil then
        return 0
    end
    ---距离上一次收获的时间/产出时间 = 此建筑距离上一次收获的生产时间
    local sub = (curTime - uTime)/tonumber(self.RealYield[4])
    if sub < 1 then
        return 0
    end
    self.count = math.floor(sub)*tonumber(self.RealYield[3])
    ---如果建筑还在冷却期
    if curTime < self.ReapTime then
        return 0
    end
    return self.count
end

---获取建筑当前状态
function ArkBuildData:GetBuildState()
    local a = Global.GetCurTime()
    if Global.GetCurTime() < self.cTime + self.costTime then
        self.upgrading = true
    else
        self.upgrading = false
    end
    return self.upgrading
end

---获得当前建筑还有多久升级完毕
function ArkBuildData:GetCompletedTime()
    local time = self.cTime - Global.GetCurTime()
    if time <= 0 then
        return "00:00:00"
    end
    local hour = math.floor(time / 3600)
    local min = math.floor((time % 3600) / 60)
    local seconds = math.floor(time % 60)
    if(hour < 10) then hour = "0"..hour end
    if(min < 10) then  min = "0"..min end
    if(seconds < 10) then seconds = "0"..seconds end
    return string.format("%s:%s:%s",hour,min,seconds)
end

---获取建筑当前是否可升级
function ArkBuildData:GetUpgradeState()
    local nextData = ArkControl.GetNextLevelBuildData(self.id)
    if nextData == nil then
        return false
    end
    ---是否可升级
    if nextData.canUp == 1 then
        self.Upgradeable = false
    end
    ---如果建筑满级
    if self.unlockID == 0 then
        self.Upgradeable = false
        return self.Upgradeable
    end
    ---如果当前建筑正在升级
    if Global.GetCurTime() < self.cTime == true then
        return false
    end
    ---货币数量
    local bag = ItemControl.GetAllItems()
    local coin = bag[100005] and bag[100005].count or 0
    ---如果玩家等级大于升级需求并且钱也足够
    if PlayerControl.GetPlayerData().level == nil then
        print(PlayerControl.GetPlayerData().level)
    end
    if self.playerLevel == nil then
        print(self.playerLevel)
    end
    if coin == nil then
        print(coin)
    end
    if self.cost[3] == nil then
        print(self.cost[3])
    end
    if PlayerControl.GetPlayerData().level >= nextData.playerLevel and coin >= tonumber(nextData.cost[3]) then
        self.Upgradeable = true
    else
        self.Upgradeable = false
    end
    return self.Upgradeable
end

---获得建筑每小时的产量
function ArkBuildData:GetProdRate()
    if self.yield[3] == nil then
        return 0
    end
    ---每秒的产量
    local sRate = tonumber(self.yield[3]) / tonumber(self.yield[4])
    local str = math.floor(sRate * 3600) .. "/"..MgrLanguageData.GetLanguageByKey("arkbuilddata_tips1")
    return str
end

---推送建筑收获CD(用于判断是否满足收获条件)
function ArkBuildData:PushReapTime()
    self.ReapTime =  Global.GetCurTime() + 180
end

return ArkBuildData