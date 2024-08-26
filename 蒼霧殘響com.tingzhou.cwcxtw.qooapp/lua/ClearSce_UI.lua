-- Code Auto Create Begin
local M = Class('ClearSce_UI', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.ClearSce_UI
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[ClearSce_UI].prefab'
    self.Name = 'Form[ClearSce_UI]'
    self.Layer = UILayerLv.Normal
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- RawImage 列表
        {'Lock','Lock',15},
    }
end
-- Code Auto Create End

return M