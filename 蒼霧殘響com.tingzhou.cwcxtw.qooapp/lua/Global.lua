require("LocalData/TypeenumerateLocalData")
---通用方法
Global = {}

---@return string 获取千分位数字字符串
function Global.GetPointNumber(number, dep)
    local str1 =""
    local str = tostring(number)
    local strLen = string.len(str)

    if dep == nil then
        dep = ","
    end
    dep = tostring(dep)

    for i=1,strLen do
        str1 = string.char(string.byte(str,strLen+1 - i))..str1
        if  i % 3 == 0 then
            --下一个数 还有
            if strLen - i ~= 0 then
                str1 = ","..str1
            end
        end
    end
    return str1
end
-------------------------时间-----------------------------
---获取当前时间(服务器的)
function Global.GetCurTime()
    return MgrNet.GetServerTime()
end
---获取今天几号
function Global.GetToDay()
    local refreshTime = string.split(SteamLocalData.tab[112000][2],":")
    local totalSec = tonumber(refreshTime[1])*3600 + tonumber(refreshTime[2])*60 + tonumber(refreshTime[3])
    
    local time = MgrNet.GetServerTime()-totalSec
    local toDay = os.date("%d",time)
    return tonumber(toDay)
end

---获取当前属于几月
function Global.GetToMonth()
    local time = MgrNet.GetServerTime()
    local toDay = os.date("%m",time)
    return tonumber(toDay)
end

---获取当前年份
function Global.GetToYear()
    local time = MgrNet.GetServerTime()
    local toDay = os.date("%Y",time)
    return tonumber(toDay)
end

---获取当前月有多少天
function Global.GetTotalDays()
    --获取当前时间戳
    local curTimestamp = Global.GetCurTime()
    --local timeZone = Tool.GetClientTimeZone()   --玩家时区
    --curTimestamp = curTimestamp + timeZone * 3600
    --local nowDate = os.date("!*t", curTimestamp);
    local nowDate = os.date("*t", curTimestamp)
    --for i = 1, 15 do
    --    local dangyuetianshu = tonumber(os.date("%d",os.time({year = nowDate.year,month = i ,day = 0})))
    --    dangyuetianshu = 1
    --end
    return tonumber(os.date("%d",os.time({year = nowDate.year,month = nowDate.month+1 ,day = 0})))
    --return tonumber(os.date("%d",os.time({year=os.date("%Y"),month=os.date("%m") + 1 > 12 and 1 ,day=0})))
end

---获取上月有多少天
function Global.GetLastMonthTotalDays()
    --获取当前时间戳
    local curTimestamp = Global.GetCurTime()
    --local timeZone = Tool.GetClientTimeZone()   --玩家时区
    --curTimestamp = curTimestamp + timeZone * 3600
    --local nowDate = os.date("!*t", curTimestamp);
    local nowDate = os.date("*t", curTimestamp)
    return tonumber(os.date("%d",os.time({year = nowDate.year,month = nowDate.month - 1 < 1 and 12 or nowDate.month - 1,day = 0})))
    --return tonumber(os.date("%d",os.time({year=os.date("%Y"),month=os.date("%m"),day=0})))
end

---获取日期
function Global.GetDate()
    local time = MgrNet.GetServerTime()
    local toDay = os.date("%Y-%m-%d-%H:%M:%S", time)
    return toDay
end

---获取时间拼接
function Global.GetTimeByStr(str, time)
    if time then
        return os.date(str,time)
    else
        return os.date(str,MgrNet.GetServerTime())
    end
end
---时间戳转剩余天数
function Global.TimeToDays(time)
    local days = time / (24*60*60)
    days = math.modf(days) + 1
    return days
end

---时间戳转剩余天数(小于1天返回小时)
function Global.GetRemainTime(remainTime)
    local str = ""
    if remainTime / (3600*24) >= 1 then
        ---剩余天数
        str = MgrLanguageData.GetLanguageByKey("eventraid_ui_surplus")..math.modf(remainTime/(3600*24)).."</color> "..MgrLanguageData.GetLanguageByKey("dailysign_ui_sky")
    else
        ---剩余小时数
        local hour = math.floor(remainTime / 3600) < 1 and 1 or math.floor(remainTime / 3600)
        str = MgrLanguageData.GetLanguageByKey("eventraid_ui_surplus")..hour.."</color> "..MgrLanguageData.GetLanguageByKey("ui_common_hour")
    end
    return str
end

--获得界面显示时间的string
function Global.GetTimeFormat(tBeginTime,tEndTime)
    return tBeginTime[1].."/"..tBeginTime[2].."/"..tBeginTime[3].." "..tBeginTime[4]..":"..tBeginTime[5].."~"..
    tEndTime[1].."/"..tEndTime[2].."/"..tEndTime[3].." "..tEndTime[4]..":"..tEndTime[5]
end

---@param str string "%Y-%m-%d-%H-%M-%S"
---@return number 时间戳转化
function Global.GetTimeByStr(str)
    local time = string.split(str,"-")
    for i = 1, 6 do
        if time[i] == nil then
            time[i] = "0"
        end
    end
    local y = tonumber(time[1])
    --lua底层在安卓端int最大32位，那么能表示的最大值是2147483647，距离1970-01-01 08:00:00这么多秒的时间正是2038-01-19 03:14:07。
    --所以超过这个时间会报错。
    if y > 2037 then
        y = 2037
    end
    local time = tonumber(os.time({ year= y, month= time[2], day= time[3], hour= time[4], min= time[5], sec = time[6]}))
    return time
end
---时间戳差值转化
function Global.GetTimeStamp(timeStr)
    ---服务器时间
    local serverTime = MgrNet.GetServerTime()
    local c_s = os.date("%Y-%m-%d-%H-%M-%S",serverTime)
    local c_st = string.split(c_s,"-")
    ---传入时间
    local st = string.split(timeStr, "-")
    local diff = #c_st - #st
    for i = 1, #st do
        c_st[i+diff] = st[i]
    end
    local time=
    {
        year = c_st[1],
        month = c_st[2],
        day = c_st[3],
        hour = c_st[4],
        minute = c_st[5],
        second = c_st[6],
    }
    return tonumber(os.time(time))
end
---当前时间戳是否在阈值内,参数number时间戳或‘年-月-日-时-分-秒’字符串
function Global.isMiddleTime(beginTime, endTime)
    local _bt = beginTime
    local _et = endTime
    if beginTime == "" or endTime == "" then
        return
    end
    if type(beginTime) == "string" then
        ---转换字符为时间戳
        local str = string.split(beginTime,"-")
        _bt = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
    end
    if type(endTime) == "string" then
        ---转换字符为时间戳
        local str = string.split(endTime,"-")
        _et = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
    end
    ---获取服务器时间
    local time = tonumber(MgrNet.GetServerTime())
    if _bt > time then
        return false
    end
    if _et < time then
        return false
    end
    return true
end
---获取创角天数(按每天早上5点，为零点)
function Global.GetCreateRoleDays(_time)
    ---服务器时间
    local serverTime = MgrNet.GetServerTime()
    if _time then
        serverTime = _time
    end
    local createTime = os.date("%H-%M-%S", PlayerControl.GetPlayerData().createTime)
    local timeStr = string.split(createTime, "-")
    local hms = tonumber(timeStr[1]) * 60 * 60 + tonumber(timeStr[2]) * 60 + tonumber(timeStr[3])
    hms = hms < 18000 and hms + 86400 or hms
    local drt = PlayerControl.GetPlayerData().createTime - hms
    local tday = math.floor((serverTime - drt - 18000) / 86400) + 1
    return tday
end

---传入两个时间戳，检查是否是同一天
function Global.CheckIsSameDay(stamp1,stamp2)
    return os.date("%Y-%m-%d",stamp1) == os.date("%Y-%m-%d",stamp2)
end

---获取时间状态(1.未达到 2.在时间内 3.已超过)
function Global.GetTimeState(beginTime, endTime)
    local _bt = beginTime
    local _et = endTime
    if beginTime == "" or endTime == "" then
        return
    end
    if type(beginTime) == "string" then
        ---转换字符为时间戳
        local str = string.split(beginTime,"-")
        _bt = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
    end
    if type(endTime) == "string" then
        ---转换字符为时间戳
        local str = string.split(endTime,"-")
        _et = tonumber(os.time({year=str[1], month = str[2], day = str[3], hour = str[4], min = str[5], sec = str[6]}))
    end
    ---获取服务器时间
    local time = MgrNet.GetServerTime()
    if _bt > time then
        return 1
    end
    if _et < time then
        return 3
    end
    return 2
end

------------------------排序-----------------------------
---通用排序(数组，键组，是否升序)
function Global.Sort(list,keys,isRise)
    table.sort(list,function(a,b)
        for i = 1, #keys do
            if a[keys[i]] ~= b[keys[i]] then
                if type(a[keys[i]]) == "number" then
                    if type(isRise) == "table" then
                        local rise = isRise[i] == nil and false or isRise[i]
                        if rise then
                            return a[keys[i]] > b[keys[i]]
                        else
                            return a[keys[i]] < b[keys[i]]
                        end
                    else
                        if isRise then
                            return a[keys[i]] > b[keys[i]]
                        else
                            return a[keys[i]] < b[keys[i]]
                        end
                    end
                elseif type(a[keys[i]]) == "boolean" then
                    if type(isRise) == "table" then
                        local rise = isRise[i] == nil and false or isRise[i]
                        if rise then
                            return (not a[keys[i]]) and b[keys[i]]
                        else
                            return a[keys[i]] and (not b[keys[i]])
                        end
                    else
                        if isRise then
                            return (not a[keys[i]]) and b[keys[i]]
                        else
                            return a[keys[i]] and (not b[keys[i]])
                        end
                    end
                elseif type(a[keys[i]]) == "string" then
                    Log.Error("字符串类型不允许排序")
                else
                    Log.Error("未知类型不允许排序")
                end
            end
        end
        return false
    end)
end
---------------------Goods---------------------------
---@return ItemLocalData 根据Goods获取本地数据
function Global.GetLocalDataByGoods(info)
    ---转换类型
    local goods = Global.CheckGoodsInStr(info)
    ---获取表名
    local ConfName = TypeenumerateLocalData.tab[goods.goodsType][4]
    ---匹配表名（首字母大写增加LocalData）
    local ConfName = "LocalData/"..string.lower(ConfName):gsub("^%l",string.upper).."LocalData"
    return require(ConfName).tab[goods.goodsID]
end
---@return goods 检查如果有字符串类型转为goods
function Global.CheckGoodsInStr(t)
    local types = {}
    if type(t) == "table" then
        types = t
    elseif type(t) == "number" then
        types.goodsType = t
    elseif type(t) == "string" then
        local s = string.split(t,'_')
        types = {}
        types.goodsType = tonumber(s[1])
        types.goodsID = tonumber(s[2])
        types.goodsNum = tonumber(s[3])
    else
        Log.Error("请勿使用GetLocalDataByGoods解析goods&type之外的类型")
    end
    return types
end
---------------------DoTween--------------------
---X轴移动
function Global.DoMoveX(Obj,x,speed)
    local v3 = Obj.transform.localPosition
    Tools.DoMove(Obj,v3,Vector3(x,v3.y,v3.z),speed,false,nil)
end
---Y轴移动
function Global.DoMoveY(Obj,y,speed)
    local v3 = Obj.transform.localPosition
    Tools.DoMove(Obj,v3,Vector3(v3.x,y,v3.z),speed,false,nil)
end

function Global.DoImageAlphaCall(image,pFrom,pTo, _Duration,pCallBack)
    Tools.DoImageAlphaCall(image, pFrom,  pTo, _Duration,pCallBack)
end

function Global.DoImageAlpha(image,pFrom,pTo, _Duration)
    Tools.DoImageAlpha(image, pFrom,  pTo, _Duration)
end

function math.pow(num,n)
    return num^n
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end
---获取好感等级
---@param _favor "经验值"
function Global.CheckFavorLv(_favor)
    ---根据杂项表判定每级的经验
    local tFavorData = string.split(SteamLocalData.tab[105002][2], ',')
    local tMaxV = string.split(tFavorData[#tFavorData], '_')    ---最高等级的参数
    for i = 1, #tFavorData - 1 do
        local tValue = string.split(tFavorData[i], '_')     ---当前等级的值
        local tNextValue = string.split(tFavorData[i + 1], '_')     ---下一等级的值

        if _favor >= tonumber(tValue[2]) and _favor < tonumber(tNextValue[2]) then
            local tExpRatio = (_favor - tonumber(tValue[2])) / (tonumber(tNextValue[2]) - tonumber(tValue[2]))
            ---当前等级,当前经验百分比,最大等级,当前等级经验,当前等级经验上限
            return tonumber(tValue[1]), tExpRatio, tonumber(tMaxV[1]), (_favor - tonumber(tValue[2])), (tonumber(tNextValue[2]) - tonumber(tValue[2]))
        elseif i+1 == #tFavorData then
            local tExpRatio = (_favor - tonumber(tValue[2])) / (tonumber(tNextValue[2]) - tonumber(tValue[2]))
            ---当前等级,当前经验百分比,最大等级,当前等级经验,当前等级经验上限
            return tonumber(tNextValue[1]), tExpRatio, tonumber(tMaxV[1]), (tonumber(tNextValue[2]) - tonumber(tValue[2])), (tonumber(tNextValue[2]) - tonumber(tValue[2]))
        end
    end
end

function Global.MaxFavorLv()
    ---根据杂项表判定每级的经验
    local tFavorData = string.split(SteamLocalData.tab[105002][2], ',')
    return tonumber(string.split(tFavorData[#tFavorData],'_')[2])
end

---获得缩进的数量(数量超过五位数就按K显示，例:50000 —— 50k)
function Global.GetConciseCount(num)
    if num >= 10000 and num < 10000000 then
        return math.floor(num/1000)..MgrLanguageData.GetLanguageByKey("ui_suojin_k")
    elseif num >= 10000000 and num < 1000000000 then
        return math.floor(num/10000)..MgrLanguageData.GetLanguageByKey("ui_suojin_w")
    elseif num >= 1000000000 then
        return math.floor(num/100000000)..MgrLanguageData.GetLanguageByKey("ui_suojin_e")
    else
        return num
    end
end

function Global.CopyTable(tab)
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        end
        local new_table = {}
        for k,v in pairs(obj) do
            new_table[_copy(k)] = _copy(v)
        end
        return setmetatable(new_table,getmetatable(obj))
    end
    return _copy(tab)
end

function Global.IsNil(uobj)
    return uobj:Equals(nil)
end


function Global.Contains(list,value)
    for k,v in pairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

---是否在时间内
function Global.CheckOnTime(timeData)
    local curData = os.date("*t",Global.GetCurTime())
    local weekNum = tonumber(os.date("%w", Global.GetCurTime()))  --当前星期几
    local str = string.split(timeData[4],"-")
    local endStr = string.split(timeData[5],"-")
    ---开启时间时间戳
    local openTime = os.time({year = curData.year, month = curData.month, day = curData.day, hour = tonumber(str[1]) , min = tonumber(str[2]), sec = tonumber(str[3])})
    local stamp =  os.time({year = curData.year, month = curData.month, day = curData.day, hour = 0 , min = 0, sec = 0 }) + 86400
    local tomorrowData = os.date("*t",stamp)
    ---结束时间时间戳
    local endTime = os.time({year = tomorrowData.year, month = tomorrowData.month, day = tomorrowData.day, hour = tonumber(endStr[1]) , min = tonumber(endStr[2]), sec = tonumber(endStr[3])})
    local openSec =  tonumber(str[1]) * 3600 + tonumber(str[2]) * 60 + tonumber(str[3])
    local endSec = tonumber(endStr[1]) * 3600 + tonumber(endStr[2]) * 60 + tonumber(endStr[3])
    local curSec = curData.hour * 3600 + curData.min * 60 + curData.sec
    ---判断时间类型
    if timeData[2] == 0 or timeData[2] == 1 then
        if timeData[2] == 0 then
            if weekNum == 0 then
                weekNum = 7
            end
            ---如果当前总秒数 < 开启时间秒数 表示还没到开启时间
            if curSec < openSec then
                if curSec < endSec then
                    return Global.Contains(string.split(timeData[3],","),tostring(weekNum - 1 < 0 and 0 or weekNum -1))
                else
                    return false
                end
            else
                if Global.GetCurTime() > openTime and Global.GetCurTime() < endTime then  --到新的一天
                    return Global.Contains(string.split(timeData[3],","),tostring(weekNum))
                else
                    return false
                end
            end
        elseif timeData[2] == 1 then
            ---判断当天是否满足开启条件
            local isCurDay = Global.Contains(string.split(timeData[3],","),tostring(weekNum))   --当天是否解锁
            if isCurDay then
                if curSec > openSec and curSec < endSec then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    else
        ---判断具体的时间
        if timeData[2] == 999 then
            return true
        elseif timeData[2] == 2 then
            local _str = string.split(timeData[6],"-")
            local _endStr = string.split(timeData[7],"-")
            local startStamp = os.time({year = tonumber(_str[1]), month = tonumber(_str[2]), day = tonumber(_str[3]), hour = tonumber(_str[4]) , min = tonumber(_str[5]), sec = tonumber(_str[6]) })
            local endStamp = os.time({year = tonumber(_endStr[1]), month = tonumber(_endStr[2]), day = tonumber(_endStr[3]), hour = tonumber(_endStr[4]) , min = tonumber(_endStr[5]), sec = tonumber(_endStr[6]) })
            if Global.GetCurTime() > startStamp and Global.GetCurTime() < endStamp then
                return true
            else
                return false
            end
        end
    end
    return false
end

---@param num1 number 拥有的数量
---@param num1 number 消耗的数量
---@return string 根据策划表的富文本配置，返回两个数字比较后的文本
function Global.GetCompareText(num1,num2)
    if num1 == nil or num2 == nil then
        return
    end
    local x = tonumber(num1)
    local y = tonumber(num2)
    --大于被比较的数字
    if x >= y then
        return string.format(MgrLanguageData.GetLanguageByKey("ui_guild_text39"),JNStrTool.numberAbbr(x),y)
    else
        --小于被比较的数字
        return string.format(MgrLanguageData.GetLanguageByKey("ui_guild_text40"),JNStrTool.numberAbbr(x),y)
    end
end

---@param num1 number 拥有的数量
---@param num1 number 消耗的数量
---@param key string y的富文本格式
---@param isNumAbbr boolean 是否需要缩进数字
---@return string 根据策划表的富文本配置，比较xy大小最后返回x的text
function Global.GetSingleComparedText(num1,num2,key,isNumAbbr)
    if num1 == nil or num2 == nil then
        return
    end
    local x = tonumber(num1)
    local y = tonumber(num2)
    local costNum = isNumAbbr and JNStrTool.numberAbbr(y) or y
    --大于被比较的数字 满足条件
    if x >= y then
        if key then
            return string.format(MgrLanguageData.GetLanguageByKey(key),costNum)
        else
            --部分情况满足条件文本不需要变色
            return costNum
        end
    else
        return string.format(MgrLanguageData.GetLanguageByKey("ui_tongyong_text235"),costNum)
    end
end

---RGB颜色转十六进制
function Global.converColor2Hex(color)
    return Global.converRGB2Hex(color.r, color.g, color.b)
end
function Global.converRGB2Hex(r, g, b)
    local str = ""
    --十进制转到十六进制
    if string.len(string.sub(string.format("%#x",r),3)) == 1 then
        str = str .. "0" .. string.sub(string.format("%#x",r),3)
    elseif string.len(string.sub(string.format("%#x",r),3)) == 0 then
        str = str .. "00"
    else
        str = str .. string.sub(string.format("%#x",r),3)
    end

    if string.len(string.sub(string.format("%#x",g),3)) == 1 then
        str = str .. "0" .. string.sub(string.format("%#x",g),3)
    elseif string.len(string.sub(string.format("%#x",g),3)) == 0 then
        str = str .. "00"
    else
        str = str .. string.sub(string.format("%#x",g),3)
    end

    if string.len(string.sub(string.format("%#x",b),3)) == 1 then
        str = str .. "0" .. string.sub(string.format("%#x",b),3)
    elseif string.len(string.sub(string.format("%#x",b),3)) == 0 then
        str = str .. "00"
    else
        str = str .. string.sub(string.format("%#x",b),3)
    end
    return str
end

---体力校准
function Global.TiliCalibration()
    ---刷新体力
    local vigorInfo = PlayerControl.GetPlayerData():GetVigorInfo()
    if vigorInfo.vigorNum >= PlayerplLocalData.tab[PlayerControl.GetPlayerData().level][4] then --已经超出不校准
        return
    end
    ---上次恢复体力时间和当前时间插值
    local diffTime = Global.GetCurTime() - vigorInfo.vigorTime
    ---要恢复的体力次数
    local times = math.floor(diffTime / tonumber(SteamLocalData.tab[104004][2]))
    PlayerControl.GetPlayerData().vigor.vigorNum = PlayerControl.GetPlayerData().vigor.vigorNum + times
    PlayerControl.GetPlayerData().vigor.vigorTime = PlayerControl.GetPlayerData().vigor.vigorTime + tonumber(SteamLocalData.tab[104004][2]) * times
    if PlayerControl.GetPlayerData().vigor.vigorNum >= PlayerplLocalData.tab[PlayerControl.GetPlayerData().level][4] then   --加完之后超出，回调
        local Surplus = PlayerControl.GetPlayerData().vigor.vigorNum - PlayerplLocalData.tab[PlayerControl.GetPlayerData().level][4]
        PlayerControl.GetPlayerData().vigor.vigorNum = PlayerplLocalData.tab[PlayerControl.GetPlayerData().level][4]
        PlayerControl.GetPlayerData().vigor.vigorTime = PlayerControl.GetPlayerData().vigor.vigorTime - Surplus * tonumber(SteamLocalData.tab[104004][2])
    end

end

return Global