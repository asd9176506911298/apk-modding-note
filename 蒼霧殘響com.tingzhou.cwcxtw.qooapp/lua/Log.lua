---------------------------------------------------全局函数&变量---------------------------------------------------
-- 日志封装器
Log = {}
Log.KEY_SCENE = "SCENE" -- 场景系统模块日志
Log.KEY_UI = "UI" -- 界面系统模块日志
Log.KEY_LUA = "LUA" -- Lua模块日志
Log.Key_NET = "NET" -- Net日志
Log.KEY_BATTLE = "BATTLE" -- 战斗日志
---------------------------------------------------私有函数&变量---------------------------------------------------
local needConsole = false -- 日志是否打印
local needSave = false -- 日志是否保存
local logFilter = {"INFO", "WARN", "ERROR"} -- 日志过滤器，方式白名单内才记录日志
local keyColor = { ["BATTLE"] = "#ff5599", ["NET"] = "green", ["ERROR"] = "red", ["WARN"] = "yellow", ["UI"]= "#4466ff", ["SCENE"] = "#bb7722",}
local dateFormat = "%H:%M:%S"
local _DoContent = function(msg, key) -- 日志处理
    if needConsole then
        local color = keyColor[key]
        if color then
            print(string.format("<color=%s>%s</color>",color, msg))
        else
            print(msg)
        end
    elseif needSave then
        -- [Todo] 日志记录
    end
end
local _CanFilter = function(pFilter) -- 是否可以忽略筛选器
    for i,v in ipairs(logFilter) do
        if pFilter == v then
            return false
        end
    end
    return true
end
---------------------------------------------------公开函数&变量---------------------------------------------------
-- [启动设置] 日志记录类型 pConsole:打印；pSave:保存
function Log.Set(pConsole, pSave)
    needConsole = pConsole
    needSave = pSave
end
-- [启动设置] 设置日志白名单
function Log.SetFilter(pKeyList)
    logFilter = pKeyList
end
-- [启动设置] 添加日志白名单
function Log.AddFilter(pKey)
    table.insert(logFilter, pKey)
end
function Log.RemoveFilter(pKey)
    if pKey == nil or #pKey == 0 then return end
    for i,v in ipairs(logFilter) do
        if v == pKey then
            table.remove(logFilter, i)
            break
        end
    end
end
-- [通用记录] msg：日志信息；key：日志种类（可以根据种类进行白名单过滤）
function Log.Go(msg, key)
    if not (needConsole or needSave) then return end
    if _CanFilter(key) then return end
    local content = string.format("%s[%s]:%s", os.date(dateFormat), key, msg)
    _DoContent(content, key)
end
-- [快捷记录] Info
function Log.Info(msg)
    Log.Go(msg, "INFO")
end
-- [快捷记录] Warn
function Log.Warn(msg)
    Log.Go(msg, "WARN")
end
-- [快捷记录] Net
function Log.Net(msg)
    Log.Go(msg, "NET")
end
function Log.Bat(pMsg)
    if Turn == nil or Turn.IsShowAttack then return end
    Log.Go(pMsg, Log.KEY_BATTLE)
end
-- [快捷记录] Error
function Log.Error(msg)
    if not (needConsole or needSave) then return end
    if _CanFilter("ERROR") then return end
    local debugInfo = debug.getinfo(2, "Sl")
    local content = string.format("%s[%s]:%s(%s:%s)",
        os.date(dateFormat), "ERROR", msg, debugInfo.short_src, debugInfo.currentline)
    _DoContent(content, "ERROR")
end
local GetFileName = function(pPath)
    return string.match(pPath, ".+/(.+)")
end
function Log.Stack()
    local funs = {}
    for i=3,100 do
        local f = debug.getinfo(i)
        if f == nil or f.source == nil then break end
        table.insert(funs, GetFileName(f.source).."."..(f.name or "function").."()")
    end
    print(table.concat(funs, "<<"))
end