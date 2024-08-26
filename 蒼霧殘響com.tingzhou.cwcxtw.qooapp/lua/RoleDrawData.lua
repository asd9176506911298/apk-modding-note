---抽角色数据
---@class RoleDrawData
RoleDrawData = Class('RoleDrawData')
function RoleDrawData:ctor(id)
   local config = RolerecruitLocalData.tab[id]
    self.id = id
    self.name = config[2]              ---卡池名字
    self.cardPool = config[3]          ---卡池角色权重
    self.singleDrawPrice = config[6]   ---单抽价格
    self.tenDrawPrice = config[7]      ---十连抽价格
    self.cardNumUp = config[8]         ---概率提升次数
    self.eliteUp = config[10]          ---提升概率
    self.poolUp = config[11]           ---概率提升稀有度
    self.breakEvenCount = config[12]   ---保底次数
    self.breakEven = config[13]        ---保底稀有度
    self.UpRole = config[14]
    self.limit = config[16]            ---次数限制
    self.timeType = config[17]         ---时间类型 0为永久开发，1为限时开发
    self.timeOpen = config[18]         ---卡池开启时间
    self.timeEnd = config[19]          ---卡池结束时间
    self.desc = config[20]             ---卡池说明
    self.cardTitle = config[21]        ---卡池标题
    self.cardDesc = config[22]         ---卡池保底说明
    self.activeStatistic = config[23]  ---是否纳入任务 0不纳入，1纳入
    self.showRole = config[24]         ---卡池显示背景图
    self.sort = config[25]             ---卡池排序
    self.cardType = config[26]         ---卡池类型 1角色 2装备
    self.enName = config[27]           ---卡池英文名
    self.Icon = config[28]             ---卡池入口按钮图
    self.roleatlas = config[29]        ---卡池角色ID
    self.item = config[30]             ---卡池积分道具
    self.shopType = config[31]         ---商店类型
    self.count = 0                     ---卡池总抽取次数
    self.show = config[32]             ---0显示1不显示
    self.tag = config[33] == "0" and "0" or string.split(config[33],",")              ---卡池标签 [1]标签底图路径[2]多语言
end
---卡池是否开启中
function RoleDrawData:WhetherIsOpen()
 if self.timeType == 0 then
  return true
 end
 --如果角色补给未开放
 if SysLockControl.CheckSysLock(1301) == false then
  return false
 end

 local str = string.split(self.timeOpen,"-")
 local endStr = string.split(self.timeEnd,"-")
 local startTime = os.time({
  year = tonumber(str[1]),
  month = tonumber(str[2]),
  day = tonumber(str[3]),
  hour = tonumber(str[4]),
  min = tonumber(str[5]),
  sec = tonumber(str[6])
 })
 local endTime = os.time({
  year = tonumber(endStr[1]),
  month = tonumber(endStr[2]),
  day = tonumber(endStr[3]),
  hour = tonumber(endStr[4]),
  min = tonumber(endStr[5]),
  sec = tonumber(endStr[6])
 })
 local inMiddle = Global.isMiddleTime(startTime, endTime)

 return inMiddle
end

---推送卡池数据
function RoleDrawData:PushData(data)
 self.count = data.lotteryCount
end

---是否到达次数限制
function RoleDrawData:WhetherMaxCount()
 if self.limit == 0 then
  return false
 end
 return self.count >= self.limit
end

function RoleDrawData:WhetherShow()
 if self.show == 0 then
  return true
 elseif self.show == 1 then
  return false
 else
  return false
 end
end

return RoleDrawData