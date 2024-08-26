
---@class RedDotData
RedDotData = Class('RedDotData')
---@param name string 构造方法
function RedDotData:ctor(name)
    ---节点名称
    self.name = name
    ---父节点
    self.parent = nil
    ---节点回调
    self.NoticeFunc = nil
    ---节点状态
    self.State = false
    ---@type RedDotData[] 子节点
    self.childNodeData = {}
end

---@param data RedDotData 添加子节点
function RedDotData:AddChildDot(name,data)
    self.childNodeData[name] = data
    data.parent = self.name
end

function RedDotData:GetCurDotState()
    local childState = false
    if next(self.childNodeData) ~= nil then
        for i, v in pairs(self.childNodeData) do
            if v:GetCurDotState() then
                childState = true
                break
            end
        end
    else
        return self.State
    end
    return childState
end

--设置红点状态
function RedDotData:SetState(value)
    self.State = value
    if self.parent then
        if value then
            RedDotControl.GetDotData(self.parent):SetState(value)   
        else
            RedDotControl.GetDotData(self.parent).State = RedDotControl.GetDotData(self.parent):GetCurDotState()
        end
        if RedDotControl.GetDotData(self.parent).NoticeFunc then
            RedDotControl.GetDotData(self.parent).NoticeFunc()
        end
    end
end

return RedDotData