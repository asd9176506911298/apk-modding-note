TableToObject={}



-- @param _mTab 目标筛选表(一个存储着设置了元表的表集合表)  _Table
-- @param _Var 目标筛选属性名(需要筛选的目标元表键值)  _String
-- @param _EqualVarTab 目标筛选对比参数表(用于比对对应元表键值的value)  _Table
-- @param _IsInvert 是否反选(筛选出与条件表中值不符的结果)  _Bool

-- @example TableToObject.FillterMTabByVar(_mtab,Rank,4,true)
-- @example 得到_mtab的所有value表中，包含Rank属性的且Rank属性value值等于4的元素
function TableToObject.FillterMTabByVar(_mTab,_Var,_EqualVarTab,_IsInvert)
    -- statements
    local _ReturnTab={}
    if _mTab == nil  then
        -- print("空表筛选弹出")
        return _ReturnTab
    end
    -- print("当前筛选表总长度"..TableToObject.GetTableLength(_mTab))
    for key, value in pairs(_mTab) do
        -- statements
        for i, n in pairs(value) do
            -- statements
            if i == _Var then
                -- 筛选出对应键值的信息
                if _EqualVarTab ~= nil and (TableToObject.GetTableLength(_EqualVarTab)) > 0 then
                    -- 筛选表不为空进入键值kv比对
                    if _IsInvert == true then
                        -- 反选
                        local _IsDif=false
                        for o, r in pairs(_EqualVarTab) do
                            -- print("********当前对比Key为"..i.."Value为"..n.."对比对象为"..r)
                            if n ~= r then
                                --循环判断是否与每个条件表中的值都不同更新Flag
                                _IsDif=true
                            else
                                --匹配到与反选表中相同元素键值，跳出将Flag置为flase
                                _IsDif=false
                                break
                            end
                        end
                        if _IsDif == true then
                            -- 根据最终Flag的值判断是否为与反选条件表中的值都不匹配，加入筛选结果表
                            table.insert(_ReturnTab, value)
                        end
                    else
                        -- 正选
                        for o, r in pairs(_EqualVarTab) do
                            -- print("********当前对比Key为"..i.."Value为"..n.."对比对象为"..r)
                            -- 遍历条件变量表中每个值符合的加入筛选结果表
                            if n == r then
                                -- 对应键值的value与条件变量表中的值匹配，加入筛选结果表
                                table.insert(_ReturnTab, value)
                            end
                        end
                    end
                else
                    -- print("对比EqualTab空")
                    -- 如果传入空条件变量表则默认将该键值所有表插入筛选结果表
                    table.insert(_ReturnTab, value)
                end
            end
        end
    end
    return _ReturnTab
end

-- @param _mTab 目标筛选表(一个存储着设置了元表的表集合表)
-- @param _Var 目标排序筛选的属性名(需要筛选的目标元表键值)
-- @param _IsInvert 是否倒序
-- @function 筛选出目标表中对应属性最大值的元素表
function TableToObject.MaxN(_mTab,_Var,_IsInvert)
    local _ReturnTab=nil
    if _mTab == nil  then
        return nil
    end
    local _TempValue=nil
    local _IsFirst=false
    for key, value in pairs(_mTab) do
        -- statements
        for i, n in pairs(value) do
            -- statements
            if i == _Var then
                -- 筛选出对应键值的信息
                -- print("找到匹配的键值"..i)
                if _IsFirst ==  false then
                    -- 首次排序默认将当前存储的最大值设置为第一个值
                    if tonumber(n) == nil then
                        -- 需要排序筛选的属性键值不是number类型无法排序最大值
                        -- print("tonumber失败")
                        return nil
                    end
                    _TempValue=tonumber(n)
                    -- print("当前_TempValue".._TempValue)
                    _ReturnTab=value
                    _IsFirst = true
                else
                    if _IsInvert == true then
                        -- 倒序
                        -- print("上一个最小值".._TempValue.."本次对比"..tonumber(n))
                        if tonumber(n) <= _TempValue then
                            -- 判断当前键值的属性value是否小于存储的最小值键值
                            -- 是则更新最小值键值
                            -- print("上一个最小值".._TempValue.."本次更新"..tonumber(n))
                            _TempValue=tonumber(n)
                            _ReturnTab=value
                        end
                    else
                        if tonumber(n) >= _TempValue then
                            -- 判断当前键值的属性value是否大于存储的最大值键值
                            -- 是则更新最大值键值
                            _TempValue=tonumber(n)
                            _ReturnTab=value
                        end
                    end
                end
            end
        end
    end
    return _ReturnTab
end

-- @function 向表中添加不重复的数据
function TableToObject.AddUnContainedValue(_mTab,_Value)
    local _IsContain =false
    for key, value in pairs(_mTab) do
        -- statements
        if _Value == value then
            -- 检测到包含该元素
            _IsContain=true
            break
        end
    end
    if _IsContain == false then
        -- statements
        table.insert(_mTab,_Value)
    end
end
-- @function 获取当前表长度(包括不连续表)
function TableToObject.GetTableLength(_mTab)
    local leng=0
    for k, v in pairs(_mTab) do
        if v ~= nil then
            -- statements
            leng=leng+1
        end
    end
    return leng;
end

-- @function 根据传入条件表判断当前权重是否符合，符合则返回权重否则返回false
function TableToObject.GetTargetWeight(_VarTab,_InputValue)
    local _Isqualified=false --是否合格
    local _EqualValue=tonumber(_VarTab[3])
    if _VarTab[2] == "=" then
        -- 等于目标值
        if _InputValue == _EqualValue then
            -- statements
            _Isqualified=true
        end
        elseif _VarTab[2] == ">"  then
            -- 大于于目标值
            if _InputValue > _EqualValue then
                -- statements
                _Isqualified=true
            end
        elseif _VarTab[2] == "<"  then
            -- 小于目标值
            if _InputValue < _EqualValue then
                -- statements
                _Isqualified=true
            end
        elseif _VarTab[2] == "》"  then
            -- 大于等于目标值
            -- print("对比大于等于_InputValue".._InputValue.."_EqualValue".._EqualValue)
            if _InputValue >= _EqualValue then
                -- statements
                _Isqualified=true
            end
        elseif _VarTab[2] == "《"  then
            -- 小于等于目标值
            if _InputValue <= _EqualValue then
                -- statements
                _Isqualified=true
            end
        
    end
    if _Isqualified == true then
        -- statements
        -- print("符合返回true _VarTab[4]".._VarTab[4])
        return _VarTab[4]
    else
        return false
    end
end

function TableToObject.GetCorrectRate(_InputValue1,_InputValue2)
    -- statements
    print("_InputValue1".._InputValue1.."_InputValue2".._InputValue2)
    local _ReturnRate=0
    if _InputValue1 ~= 0 and _InputValue2 ~= 0 then
        local _InputRate=_InputValue1/_InputValue2
        _ReturnRate=(math.floor(_InputRate*1000))/1000
    end
    if _InputValue1 > 0 and _ReturnRate == 0 then
        --当前输入值占比太小被约去，则设置为0.01（最小占比）
        _ReturnRate = 0.01
    end
    return _ReturnRate
end
--拷贝表的数据不保留引用关系
function TableToObject.CopyTab(_TargetTab,_CurTab)
    -- statements
    _CurTab ={}
    for key, value in pairs(_TargetTab) do
        -- statements
        table.insert(_CurTab,value)
    end
    return _CurTab
end

return TableToObject