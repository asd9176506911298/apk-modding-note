-- Code Auto Create Begin
local M = Class('PartLoading_UI', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.PartLoading_UI
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[PartLoading_UI].prefab'
    self.Name = 'Form[PartLoading_UI]'
    self.Layer = UILayerLv.Lock
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'heidi','heidi',2},{'loadingtiao(xiao)2','heidi/loadingtiao(xiao)2',2},{'SliderMap','heidi/SliderMap',2},{'Mask','Mask',2},
        -- TextMeshProUGUI 列表
        {'PointText','heidi/PointText',20},
    }
end
-- Code Auto Create End
-- 打开手动关闭
-- MgrUI.Pop(UID.PartLoading_UI)
-- Event.Go("PartLoading_Close")

-- 打开自动关闭
-- MgrUI.Pop(UID.PartLoading_UI, 延迟关闭时间number)

function M:OnInit()
    self.heidi().gameObject:SetActive(false)
    -- 加载条
    M.SliderMap=self.SliderMap().gameObject
    -- 进度文本
    M.PointText = self.PointText().gameObject

    Event.Add("PartLoading_Close",function()
        print("手动执行了关闭")
        M.OnBack()
    end)
end

function M:OnShow(_stayTime)
    MgrTimer.AddDelay("DelayPartLoading",2,function()
        self.heidi().gameObject:SetActive(true)
    end,nil)
    -- 文本动画
    local pointStr = ""
    MgrTimer.Cancel("PartLoading_Point")
    MgrTimer.AddRepeat("PartLoading_Point", 0.3, function()
        pointStr = pointStr.."."
        if string.len(pointStr) > 3 then
            pointStr = ""
        end
        if M.PointText.gameObject ~= nil then
            -- statements
            M.PointText:GetComponent("TextMeshProUGUI").text = MgrLanguageData.GetLanguageByKey("ui_loading_text")..pointStr
        end
    end, nil, nil)

    -- 滑块动画
    local dir = true --true -> left ,fase -> right
    local frame = 1.0 / 30
    MgrTimer.Cancel("PartLoading_Slider")
    MgrTimer.AddRepeat("PartLoading_Slider", frame, function()
        if M.SliderMap.gameObject ~= nil then
            -- statements
            local amount = M.SliderMap:GetComponent("Image").fillAmount
            if amount == 0 or amount == 1 then
                dir = not dir
                M.SliderMap:GetComponent("Image").fillClockwise = not M.SliderMap:GetComponent("Image").fillClockwise
            end
            if dir then
                amount = amount + frame
            else
                amount = amount - frame
            end
            M.SliderMap:GetComponent("Image").fillAmount = amount
        end
    end, nil, nil)

    -- 更新状态
    if not _stayTime then
        print("[MgrUI.Pop(UID.PartLoading, (number)停留时间),true],未指定停留时间时请手动关闭Event.Go('PartLoading_Close')")
        --未指定关闭时间，5秒后要求玩家确认重连
        MgrTimer.AddDelayNotRealTime("PartLoading_CloseTimer", 3, function()
            MgrUI.UnLock("battle_start")
            MgrUI.UnLock("Novice_LastStep")
            MgrUI.UnLock("OpenMail")
            -- 开始重连
            MgrNet.ReConnect()
        end, nil)
    else
        --指定了关闭时间
        MgrTimer.AddDelayNotRealTime("PartLoading_CloseTimer", _stayTime, function()
            M.OnBack()
        end, nil)
    end
    -- 超过15秒强制返回登录
    MgrTimer.AddDelayNotRealTime("PartLoading_ForceClose", 15, function()
        MgrTimer.Cancel("PartLoading_CloseTimer")
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips6").."(-999)", function ()
            MgrSdk.BackToLogin()
        end},true)
        M.OnBack()
    end, nil)
end

function M.OnBack()
    MgrUI.PopHide(UID.PartLoading_UI)
end

function M.OnClose()
    MgrTimer.Cancel("PartLoading_CloseTimer")
    MgrTimer.Cancel("PartLoading_ForceClose")
    MgrTimer.Cancel("DelayPartLoading")
end
function M.OnHide()
    MgrTimer.Cancel("PartLoading_CloseTimer")
    MgrTimer.Cancel("PartLoading_ForceClose")
    MgrTimer.Cancel("DelayPartLoading")
end

return M