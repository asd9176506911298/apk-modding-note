---@class ShopItemData 商品数据
---@field id number 商品id
---@field sortIdx number 商品顺序索引
---@field name string 商品名称
---@field icon string 商品图标路径
---@field ladderItems goods[][] 商品所含物品，key：商品x次前显示0为永久显示，value显示的item[]
---@field ladderIntroduce string[] 商品说明,key：商品x次前显示0为永久显示，value显示的说明
---@field ladderPrice goods [] 购买商品折扣消耗物品,key：商品x次前显示0为永久显示，value消耗的item
---@field ladderOriginal goods [] 购买商品原价消耗物品,key：商品x次前显示0为永久显示，value消耗的item
---@field sellType number 商品出售类型，0：永久出售 1：限时商品
---@field sellSTime number 商品上架时间
---@field sellETime number 商品下架时间
---@field buyCount number 物品当前购买次数
---@field buyMaxCount number 物品在周期内可购买次数
---@field resetBuyType number 物品重置时间————商品表重置周期 0:不重置 1:每日重置 2:每周重置 3:每月重置 4:每年重置 (具体时间通过系统表获取)
---@field lastReTime number 上次刷新时间
---@field isSellGroup boolean 是否可以批量购买
ShopItemData = Class('ShopItemData')
---构造方法
function ShopItemData:ctor()
    self.id = 0
    self.sortIdx = 0
    self.name = MgrLanguageData.GetLanguageByKey("shopdata_tips1")
    self.rank = 0
    self.rankIcon = ""
    self.rankIconB = ""
    self.icon = ""
    self.ladderItems = {}
    self.ladderIntroduce = {}
    self.ladderPrice = {}
    self.ladderOriginal = {}
    self.sellType = 0
    self.sellSTime = 0
    self.sellETime = 0
    self.buyCount = 0
    self.buyMaxCount = 0
    self.resetBuyType = 0
    self.lastReTime = 0
    self.isSellGroup = false
    self.shopType = 0
    self.shopType2 = 0
    self.bgIcon = ""
    self.buyLimit = 0
end
---@param config ShopLocalData 配置商品
function ShopItemData:PushConfig(config)
    self.id = config.id
    self.sortIdx = config.sort
    self.name = config.name
    self.rank = config.rank
    self.rankIcon = string.format("Quality/ShopIcon_%s", config.rank)
    self.rankIconB = string.format("Quality/ShopIconBian_%s", config.rank)
    self.icon = string.format("Item/%s", config.icon)
    self.bgIcon = string.format("Item/%s", config.bgicon)
    if config.type_1 ~= 400000 then
        self.ladderItems = self:SplitLadder_Two(config.content)
        self.ladderIntroduce = self:SplitLadderTips_One(config.introduce)
        self.ladderPrice = self:SplitLadder_One(config.price)
        self.ladderOriginal = self:SplitLadder_One(config.original)
    elseif config.type_1 == 400000 then
        self.ladderPrice = self:SplitRandomLadder(config.price)
    end
    self.sellType = config.type
    self.sellSTime = Global.GetTimeByStr(config.time_open)
    self.sellETime = Global.GetTimeByStr(config.time_end)
    self.buyCount = 0
    self.buyMaxCount = config.frequency
    self.resetBuyType = config.cycle
    self.isSellGroup = config.shoping ~= "1"
    self.lastReTime = MgrNet.GetServerTime()
    self.shopType = config.type_1
    self.shopType2 = config.type_2
    self.buyLimit = config.buylimit
end
---@param info ShopInfo 更新商品购买信息
function ShopItemData:ResetBuyInfo(info)
    self.buyCount = info.shopCount
    self.lastReTime = MgrNet.GetServerTime()
end
---增加商品购买次数
function ShopItemData:AddBuyCount(addNum)
    self.buyCount = addNum == nil and self.buyCount + 1 or self.buyCount + addNum
    self.lastReTime = MgrNet.GetServerTime()
end
---@return goods 获取则扣购买消耗
function ShopItemData:GetPrice()
    if self.ladderPrice[0] ~= nil then
        return self.ladderPrice[0]
    end
    local goods = nil
    for l, g in ipairs(self.ladderPrice) do
        if self.buyCount < g.Limit or l == #self.ladderPrice then
            goods = g
            break
        end
    end
    if goods == nil then
        Log.Error(string.format("当前商品价格未找到id:%s,购买次数：%s", self.id, self.buyCount))
    end
    return goods
end
---@return goods 获取原价购买消耗
function ShopItemData:GetOriginal()
    if self.ladderOriginal[0] ~= nil then
        return self.ladderOriginal[0]
    end
    local goods = nil
    for l, g in pairs(self.ladderOriginal) do
        if self.buyCount < g.Limit or l == #self.ladderOriginal then
            goods = g
            break
        end
    end
    return goods
end
---@return goods 获取道具描述
function ShopItemData:GetIntroduce()
    if self.ladderIntroduce[0] ~= nil then
        return self.ladderIntroduce[0]
    end
    local goods = nil
    for l, g in pairs(self.ladderIntroduce) do
        if self.buyCount < g.goodsLimit or l == #self.ladderIntroduce then
            goods = g
            break
        end
    end
    return goods
end
---@return goods 获取购买道具的所有数据
function ShopItemData:GetBuyItem()
    if self.ladderItems[0] ~= nil then
        return self.ladderItems[0]
    end
    local cl = -1
    local goods = {}
    for l, g in pairs(self.ladderItems) do
        if self.buyCount < l and cl < l then
            cl = l
            for i, v in ipairs(g) do
                goods[#goods+1] = v
            end
            break
        end
    end
    return goods
end

---@return goods[] 拆分梯次限制一维
function ShopItemData:SplitLadder_One(str)
    if str == nil or str == "" or str == "0" then
        return {}
    end
    local arr = {}
    local infos = string.split(str, ";")
    for idx, info in pairs(infos) do
        local _info = string.split(info, ",")
        local _limit = tonumber(_info[1])
        _limit = _limit < 0 and 0 or _limit
        local gs = string.split(_info[2], "_")
        ---@type goods
        local goods = {}
        goods.goodsType = tonumber(gs[1])
        goods.goodsID = tonumber(gs[2])
        goods.goodsNum = tonumber(gs[3])
        goods.Limit = _limit
        if _limit == 0 then
            arr[_limit] = goods
        else
            arr[#arr+1] = goods
        end
    end
    return arr
end
---@return goods[][] 拆分梯次限制二维
function ShopItemData:SplitLadder_Two(str)
    if str == nil or str == "" or str == "0" then
        return {}
    end
    local arr = {}
    local infos = string.split(str, ";")
    for idx, info in pairs(infos) do
        local _info = string.split(info, ",")
        local _limit = tonumber(_info[1])
        _limit = _limit < 0 and 0 or _limit
        local tArr = {}
        for i = 2, #_info do
            local gs = string.split(_info[i], "_")
            ---@type goods
            local goods = {}
            goods.goodsType = tonumber(gs[1])
            goods.goodsID = tonumber(gs[2])
            goods.goodsNum = tonumber(gs[3])
            tArr[#tArr + 1] = goods
        end
        arr[_limit] = tArr
    end
    return arr
end
---@return goods[] 随机商店字符串拆分
function ShopItemData:SplitRandomLadder(str)
    if str == nil or str == "" or str == "0" then
        return {}
    end
    local arr = {}
    local gs = string.split(str, "_")
    ---@type goods
    local goods = {}
    goods.goodsType = tonumber(gs[1])
    goods.goodsID = tonumber(gs[2])
    goods.goodsNum = tonumber(gs[3])
    arr[0] = goods

    return arr
end
---@return goods[] 拆分梯次限制一维(道具描述)
function ShopItemData:SplitLadderTips_One(str)
    if str == nil or str == "" or str == "0" then
        return {}
    end
    local arr = {}
    local infos = string.split(str, ";")
    for idx, info in pairs(infos) do
        local _info = string.split(info, ",")
        local _limit = tonumber(_info[1])
        _limit = _limit < 0 and 0 or _limit
        ---@type goods
        local goods = {}
        goods.goodsLimit = _limit
        goods.goodsTips = _info[2]
        if _limit == 0 then
            arr[_limit] = goods
        else
            arr[#arr+1] = goods
        end
    end
    return arr
end

---@return number 获取购买次数重置时间,若小于0重置购买次数，为空不重置
function ShopItemData:GetResetBuyTime(time)
    local resetTime = 0
    --是否刷新
    local reset = false
    --当前时间
    local curTime = os.date("*t",time)
    ---1、每日重置 2、每周重置 3、每月重置 4、每年重置 其他不重置
    if self.resetBuyType == 1 then
        --日刷新时间配置
        local conf = string.split(SteamLocalData.tab[112001][2],":")
        --如果当天刷新，当天刷新时间戳
        local rTime = os.time({year = curTime.year, month = curTime.month, day = curTime.day, hour = tonumber(conf[1]) , min = tonumber(conf[2]), sec = tonumber(conf[3])})
        --下次刷新时间
        local nextTime = rTime + 86400
        --如果当前大于刷新时间
        if time >= rTime then
            resetTime = nextTime - time
        else
            resetTime = rTime - time
        end
        --如果上次刷新时间小于当天刷新时间且当前时间大于当前刷新时间
        if self.lastReTime < rTime and time >= rTime then
            reset = true
        end
    elseif self.resetBuyType == 2 then
        --周刷新时间配置
        local conf = string.split(SteamLocalData.tab[112002][2],",")
        --周几刷新
        local weekNum = tonumber(conf[1])
        --刷新时间
        local timeStr = string.split(conf[2],":")
        --如果当天刷新，当天刷新时间戳
        local rTime = os.time({year = curTime.year, month = curTime.month, day = curTime.day, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        --本周第几天
        local day = tonumber(os.date("%w",time)) == 0 and 7 or tonumber(os.date("%w",time))
        --本周刷新日
        local targetTime = os.date("*t",rTime - ((day - weekNum) * 86400) + 604800)
        --下次刷新时间
        local nextTime = os.time({year = targetTime.year, month = targetTime.month, day = targetTime.day, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        --判断当天是否刷新日
        if day == weekNum then
            --如果当天刷新且当前时间已过刷新时间
            if time >= rTime then
                resetTime = nextTime - time
            else
                --当前时间还未到刷新时间
                resetTime = rTime - time
            end
            --如果上次刷新时间小于当天刷新时间且当前时间大于当前刷新时间
            if self.lastReTime < rTime and time >= rTime then
                reset = true
            end
        else
            resetTime = nextTime - time
        end
    elseif self.resetBuyType == 3 then
        --月刷新时间配置
        local conf = string.split(SteamLocalData.tab[112003][2],",")
        --几号刷新
        local dayAmount = tonumber(conf[1])
        --刷新时间
        local timeStr = string.split(conf[2],":")
        --如果当天刷新，当天刷新时间戳
        local rTime = os.time({year = curTime.year, month = curTime.month, day = curTime.day, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        --当前月份数
        local monthNum = tonumber(os.date("%m",time))
        --当前年份数
        local yearNum = tonumber(os.date("%Y",time))
        --本月第几天
        local dayNum = tonumber(os.date("%d",time))
        --下次刷新时间
        local nextTime = 0
        if monthNum == 12 then
            --如果当前12月，次月刷新时间就是下一年的1月份
            nextTime = os.time({year = yearNum + 1, month = 1, day = dayAmount, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        else
            --正常月份+1
            nextTime = os.time({year = yearNum, month = monthNum + 1, day = dayAmount, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        end
        --当前要刷新
        if dayNum == dayAmount then
            --如果当天刷新且当前时间已过刷新时间
            if time >= rTime then
                resetTime = nextTime - time
            else
                --当前时间还未到刷新时间
                resetTime = rTime - time
            end
            --如果上次刷新时间小于当天刷新时间且当前时间大于当前刷新时间
            if self.lastReTime < rTime and time >= rTime then
                reset = true
            end
        else
            resetTime = nextTime - time
        end

    elseif self.resetBuyType == 4 then
        --年刷新配置
        local conf = string.split(SteamLocalData.tab[112005][2],",")
        --几月刷新
        local monthAmount = tonumber(conf[1])
        --刷新时间
        local timeStr = string.split(conf[2],":")
        --如果当天刷新，当天刷新时间戳
        local rTime = os.time({year = curTime.year, month = curTime.month, day = curTime.day, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        --当前年份数
        local yearNum = tonumber(os.date("%Y",time))
        --当前月份数
        local monthNum = tonumber(os.date("%m",time))
        --本月第几天
        local dayNum = tonumber(os.date("%d",time))
        --下一年刷新时间
        local nextTime = os.time({year = curTime.year + 1, month = monthAmount, day = 1, hour = tonumber(timeStr[1]) , min = tonumber(timeStr[2]), sec = tonumber(timeStr[3])})
        --当天是刷新日
        if monthNum == monthAmount and dayNum == 1 then
            --如果当天刷新且当前时间已过刷新时间
            if time >= rTime then
                resetTime = nextTime - time
            else
                --当前时间还未到刷新时间
                resetTime = rTime - time
            end
            --如果上次刷新时间小于当天刷新时间且当前时间大于当前刷新时间
            if self.lastReTime < rTime and time >= rTime then
                reset = true
            end
        else
            resetTime = nextTime - time
        end
    else
        return nil
    end
    if reset then
        ---@type ShopInfo 重置购买次数
        local info = {}
        info.shopID = self.id
        info.shopCount = 0
        self:ResetBuyInfo(info)
        return 0
    end
    return resetTime
end
---更新随机商店道具数据
function ShopItemData:SetRandomShopItemData(info)
    local config = RoleequipmentLocalData.tab[info.goodsID]
    if info.goodsType == 1 then
        config = ItemLocalData.tab[info.goodsID]
    elseif info.goodsType == 2 then
        config = CorechipLocalData.tab[info.goodsID]
    elseif info.goodsType == 4 then
        config = HideLocalData.tab[info.goodsID]
    end
    if config == nil then
        Log.Error(string.format("未找到物品配置类型,Id:%s, Type:%s",goods.goodsID,goods.goodsType))
        return
    end
    if info.goodsType == 5 then
        self.name = config[2]
        self.icon = string.format("Equip/%s", config[4])
    else
        self.name = config.name
        self.icon = string.format("Item/%s", config.icon)
    end

    local tArr = {}
    local goods = {}
    goods.goodsType = info.goodsType
    goods.goodsID = info.goodsID
    goods.goodsNum = info.goodsNum
    tArr[1] = goods
    self.ladderItems[0] = tArr
    
    self.verificationTime = info.time
    self.buyCount = info.count
    self.buyMaxCount = tonumber(RandomshopLocalData.tab[info.id].frequency)
end

return ShopItemData