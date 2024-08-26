-- Code Auto Create Begin
local M = Class('Alpha', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.Alpha
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[Alpha].prefab'
    self.Name = 'Form[Alpha]'
    self.Layer = UILayerLv.Lock
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'imgBg','imgBg',2},
    }
end
-- Code Auto Create End
function M:OnArg()
    self.IsScale = false
end

function M:OnShow(pData)
    if pData then
        self.CallBack = pData.Finish
    end
    if pData.Black then
        self.imgBg().color = Color(0,0,0,1)
        return 
    end
    if pData.Mode then
        local dis = pData.Fade or 0.22
        if dis == -1 then
            self.imgBg().color = Color(0,0,0,1)
        else
            Tools.DoImageAlphaCall(self.imgBg(), 0, 1, dis, function()
          
            end)
        end
    else
        local dis = pData.Fade or 0.43
        if dis == -1 then
            self.imgBg().color = Color(0,0,0,1)
        else
            if not self.HasFadeout then
                self.HasFadeout = true
                Tools.DoImageAlphaCall(self.imgBg(), 1, 0, dis, function()
                    MgrUI.ClosePop(UID.Alpha, self.Id)
                end)
            end
        end
    end
end

return M