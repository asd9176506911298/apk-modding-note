require "Core/MID"
---------------------------------------------------全局函数&变量---------------------------------------------------
MessageEvent = {}
---------------------------------------------------私有函数&变量---------------------------------------------------
local eventDic = {}
---------------------------------------------------公开函数&变量---------------------------------------------------
-- 添加事件监听 mid：消息id（必须的数字）；fun：事件执行方法
function MessageEvent.Add(mid, fun)
    if type(mid) ~= "number" then
        print('注册消息mid必须为number')
        return
    end
    if not fun or type(fun) ~= "function" then
        print('注册消息fun必须为function')
        return
    end
    eventDic[mid] = fun
    --if not eventDic[mid] then
    --    eventDic[mid] = {}
    --end
    --local hasAdd = false
    --for _,v in ipairs(eventDic[mid]) do
    --    if v == fun then
    --        hasAdd = true
    --        break
    --    end
    --end
    --if hasAdd then
    --    print('fun已经被注册过, 请检查注册的消息, mid ： '.. mid)
    --    return
    --end
    --table.insert(eventDic[mid], fun)
end
-- 触发事件 pName：触发事件名称； ...：事件传参
function MessageEvent.Go(mid, ...)
    if not eventDic[mid] then
        print('消息不存在')
        return
    else
        eventDic[mid](...)
    end
    --local endData = {}
    --local funList = eventDic[mid]
    --if not funList then
    --    print('消息不存在')
    --    return
    --end
    --if #funList == 1 then return funList[1](...) end
    --for _,v in ipairs(funList) do
    --    v(...)
    --end
end
-- 移除事件 pName：事件名称（必须字符串）；fun：事件执行方法
function MessageEvent.Remove(mid, fun)
    local funList = eventDic[mid]
    if not funList then
        print('找不到消息委托:'.. mid)
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
function MessageEvent.Clear(mid)
    eventDic[mid] = nil
end
function MessageEvent.CheckClear(mid)
    if (eventDic[mid]) then
        eventDic[mid] = nil
    end
end
-- 移除所有监听
function MessageEvent.ClearAll()
    eventDic = {}
end

return MessageEvent