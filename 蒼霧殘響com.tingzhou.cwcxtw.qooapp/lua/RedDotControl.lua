require("Model/RedDot/Data/RedDotData")

RedDotControl = {}
---根节点
local RootDot = nil
---@type RedDotData[]
local RedDotDataMap = {}

----注册根节点
function RedDotControl.RegisterBaseDot(name)
    if  RedDotDataMap[name] == nil then
        local DotData = RedDotData.New(name)
        if RootDot == nil then
            RootDot = DotData
        end
        RedDotDataMap[name] = DotData
    end
end
----注册子节点
function RedDotControl.RegisterChildDot(name,parentName)
    if  RedDotDataMap[name] == nil then
        local parentData = RedDotDataMap[parentName]
        if parentData == nil then
            print("没有找到父节点")
            return
        else
            local childDotData = RedDotData.New(name)
            parentData:AddChildDot(name,childDotData)
            RedDotDataMap[name] = childDotData
        end
    end
end

--获取红点数据
function RedDotControl.GetDotData(name)
    return RedDotDataMap[name]
end

--显示红点
function RedDotControl.CheckRedDotUI(dotName,func)
    local data = RedDotControl.GetDotData(dotName)
    data.NoticeFunc = func
    data.NoticeFunc()
end

---UI红点闪烁
function RedDotControl.RedDotFlash(dots)
    for i = 1,#dots,1 do
        if dots[i].gameObject.activeSelf then
            RedDotControl.Flash(dots[i])
        end
    end
end

function RedDotControl.Flash(dot)
    MgrTimer.AddRepeat(dot.name,1,function()
        if dot.color.a >= 1 then

        end
        if dot.color.a <= 0 then

        end
    end,-1,nil)
end

function RedDotControl.ClearFunc(dotName)
    local data = RedDotControl.GetDotData(dotName)
    if data then
        data.NoticeFunc = nil
    end
end

return RedDotControl
