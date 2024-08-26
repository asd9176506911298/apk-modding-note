-- Code Auto Create Begin
local M = Class('Lock', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.Lock
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[Lock].prefab'
    self.Name = 'Form[Lock]'
    self.Layer = UILayerLv.Lock
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- RaycastEx 列表
        {'imgBg','imgBg',8},
    }
end
-- Code Auto Create End
function M:OnInit()
    self.IsScale = false
    self.NeedLock = false
end

function M:OnShow(pData)
    if pData and pData.Layer then
        self.DataLayer = pData.Layer
    end
end

function M:OnShowFinish()
    -- 保护
    local existLock = false
    for k, v in pairs(MgrUI.LockKeyTab) do
        if v then
            existLock = true
            break
        end
    end
    local ks = { }
    for k, v in pairs(MgrUI.LockKeyTab) do
        table.insert(ks, k)
    end
    self.ObjRoot.name = "LockFor_" .. table.concat(ks, "|")
    if self.DataLayer then
        self:SetLayer(self.DataLayer)
    end
    if not existLock then
        MgrUI.ClosePop(UID.Lock)
    end
end
return M