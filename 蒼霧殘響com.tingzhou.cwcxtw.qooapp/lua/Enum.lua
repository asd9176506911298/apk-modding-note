---------------------------------------------------全局函数&变量---------------------------------------------------
-- 列表转换到枚举 index：默认第一项枚举初始值
-- Eg:      | Convet to     
-- type = { | type = {
--    A,    |    A = 1,
--    B,    |    B = 2,
--    C,    |    C = 3,
--  }       | }
function EnumFromList(tbl, index)
	local enumtbl = {}
	local enumindex = index or 0
	for i, v in ipairs(tbl) do
	    enumtbl[v] = enumindex + i
	end
	return enumtbl   
end 
-- 字典转换到枚举 index：默认第一项枚举初始值
-- Eg:               | Convet to     
-- table = {         | enum = {     dic = {
--	  A = {id = aa}, |    A = 1,        [1] = {id = aa},
--    B = {id = bb}, |	  B = 2,        [2] = {id = bb},
--    C = {id = cc}, |	  C = 3,        [3] = {id = cc},
--  }                | }
function EnumFromDic(tbl, index)
	local enum = {}
    local dic = {}
	local key = index or 0
	for k, v in pairs(tbl) do
        key = key + 1
	    enum[k] = key
        dic[key] = v
	end
	return enum, dic
end
-- 列表转换到字典 kName：字典名称
-- Eg:          | Convet to     
-- table = {    | dic = {
--	  A,        |    A = {kName = 'A'},
--    B,        |	 B = {kName = 'B'},
--    C,        |	 C = {kName = 'C'},
--  }   
function TableToDic(tbl, kName)
    local dic = {}
    for i,v in ipairs(tbl) do
        dic[v] = {
			[kName] = v,
        }
    end
    return dic
end
-- 字典转换包含key  kName:key vName:value
-- Eg:              | Convet to     
-- dic = {          | dic = {
--	  A = {id = 1}, |    A = {kName = 'A',vName = {id = 1}},
--    B = {id = 2}, |	 B = {kName = 'B',vName = {id = 2}},
--    C = {id = 3}, |	 C = {kName = 'C',vName = {id = 3}},
--  }   
function DicToKey(dic, kName, vName)
    local newDic = {}
    for k,v in pairs(dic) do
        newDic[k] = {
			[kName] = k,
			[vName] = v
        }
    end
    return newDic
end