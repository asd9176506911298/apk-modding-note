Tool = {}
function Tool.LogLoaded()
    local t = {}
    for k,v in pairs(package.loaded) do
        table.insert(t, k)
    end
    local num = string.format('Lua Loaded Num:%s', #t)
    local list = string.format('Lua Loaded List:%s', table.concat(t, '|'))
    local memory = string.format('Lua Memory:%.2fKB',  collectgarbage('count'))
    Log.Go(num, Log.KEY_LUA)
    Log.Go(memory, Log.KEY_LUA)
    --Log.Go(list, Log.KEY_LUA)
end
function Tool.ReLoad(name)
    name = string.gsub(name, "/", ".")
    local oldTb = _G[name]
    package.loaded[name] = nil
    require(name)
    local newTb = _G[name]
    if oldTb then
        setmetatable(oldTb, newTb)
    end
end
function Tool.LogPerform(fun, num, name)
    local t = os.clock()
    for i=1,num do
        fun()
    end
    local msg = string.format('Function %s Run %s Times Cost %s', name, num, (os.clock() - t))
    Log.Go(msg, Log.KEY_LUA)
end

function Tool.CSharpListToLuaTable(CSharpList)
    local list = {}
    if CSharpList then
        local idx = 1
        local iter = CSharpList:GetEnumerator()
        while iter:MoveNext() do
            local v = iter.Current
            list[idx] = v
            idx = idx + 1
        end
    else
        print("No List")
    end
    return list
end

---获得时区
function Tool.GetClientTimeZone()
    local now = os.time()
    local difftime = os.difftime(now,os.time(os.date("!*t",now)))
    return difftime/3600
end

function string.split(s,delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
    local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
          break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

function Tool.RandomList(pList)
    if pList then
        local sum = 0
        local list = {}
        for k,v in pairs(pList) do
            sum = sum + 1
            list[sum] = v
        end
        local idx = math.random(1, sum)
        return list[idx]
    end
    return nil
end
function UnixTickToDate(t)
    return os.date("%Y-%m-%d %H:%M:%S",t / 1000)
end
function GetTimeNow()
    return os.time() + PlayerControl.ServerDiff
end
function GetRemain(t)
    return t - GetTimeNow()
end

local TimeZone = os.time(os.date("!*t")) - os.time(os.date("*t"))

function string2time( timeString )  
    local Y = string.sub(timeString , 1, 4)  
    local M = string.sub(timeString , 6, 7)  
    local D = string.sub(timeString , 9, 10) 
    local hms = string.sub(timeString, 12, 19)
    local arr = string.split(hms, ":")
    local HH = arr[1] 
    local MM = arr[2] 
    local SS = arr[3] 
    local curTime = os.time({year=Y, month=M, day=D, hour=HH, min=MM, sec=SS})
    return curTime
end 

function string.ToRemain(pEndTime)
    local endtime = string2time(pEndTime)
    return os.difftime(endtime , GetTimeNow())
end
function Is_BetweenTime(pStartTime,pEndTime)
    local startTime = string2time(pStartTime)
    local endTime = string2time(pEndTime)
    local currentTime = GetTimeNow()
    if startTime < currentTime and currentTime < endTime then
        return true

    else
        return false
    end
end

local romanNum = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1}
local romanStr = {"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"}
function string.toRoman(pNum)
    local roman = ""
    local i = 1
    while pNum > 0 do
        if pNum >= romanNum[i] then
            pNum = pNum - romanNum[i]
            roman = roman..romanStr[i]
        else
            i = i + 1
        end
    end
    return roman
end
---------------------------------------------------Log Perform Compare List---------------------------------------------------
-- 1 To Compare Table Equal,Use Table is faster than Number In Table. Eg:a = {id = 1} b = {id = 2} 



----------------------------------------------------table操作------------------------------------------------------
-- 删除table中的元素  
function table.RemoveElementByKey(tbl,key)  
    local tmp ={}  
    for i in pairs(tbl) do  
        table.insert(tmp,i)  
    end  
  
    local newTbl = {}  
    local i = 1  
    while i <= #tmp do  
        local val = tmp [i]  
        if val == key then  
            table.remove(tmp,i)  
         else  
            newTbl[val] = tbl[val]  
            i = i + 1  
         end  
     end  
    return newTbl  
end 

-- 深度拷贝table
function table.DeepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- 计算字符串长度
function string.length(inputstr)
    local lenInByte = #inputstr
    local length = 0
    local i = 1
    while (i<=lenInByte)
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                               --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                               --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
        end
        -- local char = string.sub(inputstr, i, i+byteCount-1)                                                    
        i = i + byteCount                                              -- 重置下一字节的索引
        length = length + 1                                             -- 字符的个数（长度）
    end
    return length
end

function table.merge(a, b)
    if b then
        for k,v in pairs(b) do
            if a[k] then
                a[k] = a[k] + v 
            else
                a[k] = v
            end
        end
    end
    return a
end

function table.maxn(tab)
    local idx = nil
    local t = nil
    for i, v in pairs(tab) do
        idx = i
        t = v
    end
    return t,idx
end
function table.minn(tab)
    for i, v in pairs(tab) do
        if v ~= nil then
            return i, v
        end
    end
    return nil,nil
end

-------------------------------------------------------end----------------------------------------------------------