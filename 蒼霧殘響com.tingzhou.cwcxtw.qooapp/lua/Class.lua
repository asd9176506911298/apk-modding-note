-- 对象封装
-- 定义一个全局的Class，参数类名，父类元表
function Class(classname, super)
    -- 取父元表的类型
    local superType = type(super)
    -- 声明一个临时的类用来做逻辑
    local cls
    -- 父元表如果类型不是fun和table就说明置空，作用没看懂
    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end
    -- 父元表如果是fun或父元表ctype == 1就进去，没懂
    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}
        --if superType == "table" then
        --     --如果父元表是表,则说明父元表没爹,将父元表所有值赋给cls并继承父元表的构造函数
        --     --copy fields from super
        --    for k,v in pairs(super) do cls[k] = v end
        --    cls.__create = super.__create
        --    cls.super    = super
        --else
        --     --如果父元表不是表,则说明父元表有爹,继承构造
            cls.__create = super
        --end
        -- ctor
        cls.ctor = function() end
        -- 将cls命名为传进来的类名
        cls.__cname = classname
        -- 将cls的type设置为1    父类是function
        cls.__ctype = 1
        -- 给cls提供New构造方法,作用是创建一个类的实例并返回(开始抽象了)
        function cls.New(...)
            -- 创建一个实例
            local instance = cls.__create(...)
            -- copy fields from class to native object 复制cls属性方法给实例
            for k,v in pairs(cls) do
                instance[k] = v
            end
            -- 实例的类为cls
            instance.Class = cls
            -- 实例的构造函数
            instance:ctor(...)
            -- 返回实例
            return instance
        end
    else
        -- inherited from Lua Object 如果父元表不是fun且__ctype不等于1时
        if super then
            -- 如果父元表存在则cls继承父元表
            cls = clone(super)
            cls.super = super
        else
            -- 否则为cls的ctor设置空方法
            cls = {ctor = function() end}
        end
        -- 为cls添加类名
        cls.__cname = classname
        -- ctype == 2意是lua？   父类是table
        cls.__ctype = 2 -- lua
        -- 将_index指向自己,升级为元表（前面的cls还是一个表）
        cls.__index = cls
        -- 创建new方法
        function cls.New(...)
            local instance = setmetatable({}, cls)  --如果cls中存在metatable,setmetatable会失败
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function Copy(pTb)
    local l = {}
    for k,v in pairs(pTb) do
        l[k] = v
    end
    return l
end

function Handle(obj, func)
    if func == nil then Log.Warn("Handle Fun is Nil") end
    if obj == nil then Log.Warn("Handle Obj is Nil") end
    if obj["_AutoFun"..tostring(func)] then return obj["_AutoFun"..tostring(func)] end
    obj["_AutoFun"..tostring(func)] = function(...)
        return func(obj, ...)
    end
    return obj["_AutoFun"..tostring(func)]
end

local _a_func
local _a_args

function FunArgs(fun, args)
    if fun == nil then Log.Warn("FunArgs Fun is Nil") end
    if args == nil then Log.Warn("FunArgs args is Nil") end
    _a_args = args
    _a_func = fun
    return _a_cell
end

function _a_cell(...)
    if _a_args == nil then Log.Warn("_a_args is Nil") end
    if _a_func == nil then Log.Warn("_a_func is Nil") end
    _a_func(...,_a_args)
end

INew = {}
function INew:New(o)
    o = o or {}
    o.super = self
    setmetatable(o,self)
    self.__index = self
    return o
end

local tableDepMax = 10
local tableTap = "    "
local newLine = "\n"
function string.multi(s, n)
    local r = ""
    for i = 1, n do
        r = r..s
    end
    return r
end
function table.val_to_str(v, max, line, dep)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n" )
        if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    else
        return "table" == type(v) and table.tostring(v, max, line, dep + 1) or tostring(v)
    end
end

function table.key_to_str(k, max, line, dep)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "["..table.val_to_str(k, max, line, dep).."]"
    end
end

function table.tostring(tbl, max, line, dep)
    dep = dep or 1
    max = max or tableDepMax
    if dep > max then
        return "..."
    end
    if tbl == nil then return "nil" end
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, table.val_to_str(v, max, line, dep))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            local keyStr = table.key_to_str(k, max, line, dep)
            if keyStr ~= "class" then
                table.insert(result, keyStr.." = "..table.val_to_str(v, max, line, dep))
            end
        end
    end

    local tap = line and ","..newLine..string.multi(tableTap, dep) or ","
    local tv = table.concat(result, tap)
    if tv == nil or #tv == 0 then
        return "{}"
    else
        if line then
            return "{"..newLine..string.multi(tableTap, dep)..tv..newLine..string.multi(tableTap, dep - 1).."}"
        else
            return "{"..tv.."}"
        end
    end
end
function table.print(t,m,l)
    print(table.tostring(t,m,l))
end

function string.trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function math.int45(f)
    return math.floor(f + 0.5)
end

function table.Contains(tb, item)
    for i, v in ipairs(tb) do
        if (v == item) then
            return true
        end
    end
    return false
end