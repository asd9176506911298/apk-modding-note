require "Core/EID"
---------------------------------------------------全局函数&变量---------------------------------------------------
Event = {}
---------------------------------------------------私有函数&变量---------------------------------------------------
local eventDic = {}
---------------------------------------------------公开函数&变量---------------------------------------------------
-- 添加事件监听 pName：事件名称（必须字符串）；fun：事件执行方法
function Event.Add(pName, fun)
	if type(pName) ~= "string" then
		Log.Error('Event Add Lisnter Name Is Not Typeof string')
        return
	end
	if not fun or type(fun) ~= "function" then
		Log.Error('Event Add Lisnter Function Is Not Typeof function')
        return
	end
	if not eventDic[pName] then
		eventDic[pName] = {}
	end
    local hasAdd = false
    for i,v in ipairs(eventDic[pName]) do
        if v == fun then
            hasAdd = true
            break
        end
    end
    if hasAdd then
		Log.Error('Event Add Error, You Add This Same Function '..pName)
        return
    end
	table.insert(eventDic[pName], fun)
end
-- 触发事件 pName：触发事件名称； ...：事件传参
function Event.Go(pName, ...)
    local endData = {}
    local funList = eventDic[pName]
	if not funList then
		--Log.Error('Event Go Not Find:'..pName)
        return
    end
    if #funList == 1 then return funList[1](...) end
	for i,v in ipairs(funList) do
        v(...)
    end
end
-- 移除事件 pName：事件名称（必须字符串）；fun：事件执行方法
function Event.Remove(pName, fun)
    local funList = eventDic[pName]
	if not funList then
		Log.Error('Event Remove Not Find:'..pName)
        return
	end
    local len = #funList
    for i = len, 1, -1 do
        if funList[i] == fun then
            table.remove(funList, i)
        end
    end
end
-- 移除所有该事件监听 pName：事件名称（必须字符串
function Event.Clear(pName)
    eventDic[pName] = nil
end
function Event.CheckClear(pName)
    if (eventDic[pName]) then
        eventDic[pName] = nil
    end
end
-- 移除所有监听
function Event.ClearAll()
    eventDic = {}
end

return Event