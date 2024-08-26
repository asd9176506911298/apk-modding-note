---抽装备数据
---@class EquipDrawData
EquipDrawData = Class('EquipDrawData')
function EquipDrawData:ctor(id)
    local config = EquipmentsupplyLocalData.tab[id]
    self.id = id
    self.name = config[2]                  ---卡池名字
    self.cardPool = config[3]              ---卡池角色权重
    self.singleDrawGoldPrice = config[4]   ---金币单抽价格
    self.tenDrawGoldPrice = config[5]      ---金币十连抽价格
    self.singleDrawPrice = config[6]       ---共鸣石单抽
    self.tenDrawPrice = config[7]          ---共鸣石十连抽
    self.breakEvenCount = config[8]        ---保底次数
    self.breakEvent = config[9]            ---保底稀有度
    self.timeType = config[10]             ---时间类型 0为永久开发，1为限时开发
    self.timeOpen = config[11]             ---卡池开启时间
    self.timeEnd = config[12]              ---卡池关闭时间
    self.desc = config[13]                 ---卡池说明
    self.show = config[14]                 ---是否显示 0显示 1不显示
    self.limit = config[15]                ---是否限制次数
    self.showRole = config[16]             ---卡池背景图片
    self.sort = config[17]                 ---卡池排序
    self.cardType = config[18]             ---卡池类型 1角色 2装备
    self.enName = config[19]               ---英文名
    self.Icon = config[20]                 ---卡池入口按钮图标
    self.tag = config[21] == "0" and "0" or string.split(config[21],",")              ---卡池标签 [1]标签底图路径[2]多语言
end

---卡池是否开启中
function EquipDrawData:WhetherIsOpen()
    if self.timeType == 0 then
        return true
    end
    --如果角色补给未开放
    if SysLockControl.CheckSysLock(1302) == false then
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

function EquipDrawData:WhetherShow()
    if self.show == 0 then
        return true
    elseif self.show == 1 then
        return false
    else
        return false
    end
end

return EquipDrawData