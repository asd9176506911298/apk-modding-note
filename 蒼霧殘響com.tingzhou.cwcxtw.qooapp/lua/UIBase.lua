UIBase = Class('UIBase')
function UIBase:ctor()
    self.Uid = nil -- 界面ID
    self.ObjRoot = nil -- 界面对象
    self.Id = nil -- 界面唯一id 取自界面GameOjbect的唯一InstanceID
    self.PathPrefab = nil --界面路径
    self.Name = nil -- 界面名称
    self.CS_Form = nil --界面UIForm组件
    self.CC = {} -- 界面缓存组建列表
    self.CE = {} -- 界面接收列表
    self.Layer = UILayerLv.Normal --界面层级
    self.Depth = 1 --界面占用层级数量
    self.CavOrder = 1 --界面Canvas的层级SortOrder
    self.UState = UIState.LoadLua -- 当前界面状态
    self.HasInit = false -- 已经初始化
    self.OnCloseFinish = nil -- 界面关闭动画回掉
    self.IsScale = false -- 界面是否参与缩放
    self.NeedLock = true -- 界面是否需要被锁
    self.FadeIn = 0 -- 是否接受界面fadein 0 关闭
    self.IsPopUI = false -- 是否为弹出UI
end
---------------------------------------------------界面通用API，子界面无需重写---------------------------------------------------
function UIBase:Init(pCallBack, pNoFade)
    -- print("开始Init事件self.Name"..self.Uid.Name)
    self:OnArg()
    if pCallBack and self:NeedFadeIn() and (not pNoFade) then
        MgrUI.Pop(UID.Alpha, {Mode = true, Finish = function() end}, true)
        MgrTimer.AddDelay(os.clock()..math.random(1000000), self.FadeIn, function()
            self:FinishInit(pCallBack)
        end)
    else
        self:FinishInit(pCallBack, pNoFade)
    end
end
function UIBase:NeedFadeIn()
    if self.FadeIn == nil or self.FadeIn == 0 or self.Uid.Name == UID.Alpha.Name or self.IsPopUI then
        return false
    else
        return true
    end
end
function UIBase:FinishInit(pCallBack, pNoFade)
    if self.HasInit then
        if pCallBack and self:NeedFadeIn() and (not pNoFade) then
            MgrUI.Pop(UID.Alpha, {Mode = false, Fade = self.FadeIn}, true)
        end
        if pCallBack then
            pCallBack()
        end
        return
    end
    self.HasInit = true
    local cacheForm = MgrPool.GetCache("UI", self.PathPrefab, nil)
    if cacheForm then
        if pCallBack and self:NeedFadeIn() and (not pNoFade) then
            MgrUI.Pop(UID.Alpha, {Mode = false, Fade = self.FadeIn}, true)
        end
        self:LoadCallBack(pCallBack, cacheForm)
    else
        MgrRes.GetPrefab(self.PathPrefab,function(go)
            if pCallBack and self:NeedFadeIn() and (not pNoFade) then
                MgrUI.Pop(UID.Alpha, {Mode = false, Fade = self.FadeIn}, true)
            end
            self:LoadCallBack(pCallBack, go)
        end)
    end
end

function UIBase:LoadCallBack(pCallBack, go)
    self.ObjRoot = go
    self.ObjRoot.name = self.Name
    self.Id = self.ObjRoot:GetInstanceID()
    self.CS_Form = self.ObjRoot:GetComponent("UIForm")
    self.CS_Form:SetFunc(Handle(self, self.OnFinishEvent))
    if self.Layer == UILayerLv.Normal then
        self.CS_Form:AddPanel()
    end
    self:LoadCache()
    self:OnInit()
    if pCallBack then
        pCallBack()
    end
end
function UIBase:Show(pArg)
    self.ObjRoot:SetActive(true)
    self:Init()
    self:SetLayer(self.CavOrder)
    if self.Uid.WaitDataList and #self.Uid.WaitDataList > 0 then
        for i,v in ipairs(self.Uid.WaitDataList) do
            self:OnShow(v)
        end
        self.Uid.WaitDataList = nil
    else
        self:OnShow(pArg)
    end
    self:OnUpdateUI()
    self:AddLinster()
    self:ChangeState(UIState.Show)
end
function UIBase:BackShow(pNeedFade, pCallBack)
    if pNeedFade and self:NeedFadeIn() then
        MgrUI.Pop(UID.Alpha, {Mode = false, Fade = self.FadeIn}, true)
    else
        if self.Uid.Name ~= UID.Alpha.Name and MgrUI.IsShowState(UID.Alpha) then
            MgrUI.ClosePop(UID.Alpha)
        end
    end
    self.ObjRoot:SetActive(true)
    self:Init(nil, true)
    self:SetLayer(self.CavOrder)
    self:OnBackShow()
    self:OnUpdateUI()
    self:AddLinster()
    self:ChangeState(UIState.BackShow)
    if pCallBack then
        pCallBack()
    end
end
function UIBase:Stay()
    self:OnStay()
    self:ChangeState(UIState.Stay)
end
function UIBase:Hide()
    self:OnHide()
    self:RemoveLinster()
    self:ChangeState(UIState.Hide)
    -- self.OnCloseFinish = function()
    --     self.ObjRoot:SetActive(false)
    -- end
    --self.ObjRoot:SetActive(false)
end
function UIBase:Close()
    self:OnClose()
    self:RemoveLinster()
    self:ChangeState(UIState.Close)
    if self.Uid ~= UID.PopTip_UI and self.Uid ~= UID.FullLoading_UI and self.Uid ~= UID.PartLoading_UI and self.Uid ~= UID.NoviceFrame_UI then
        -- MgrRes.UnLoadAssetBundle(self.PathPrefab)
    end
    --MgrPool.PushCache("UI", self.PathPrefab, self.ObjRoot)
    ---- 清除界面Compnent缓存
    --self.HasInit = false
    --self.CS_Form = nil
    --self.ObjRoot = nil
    --for i,v in ipairs(self.CC) do
    --    v[4] = false
    --end
end
function UIBase:ChangeState(pState)
    
    self.WantState = pState
    if self.NeedLock then
        MgrUI.Lock(self.Uid.Name)
    end
    if MgrUI.IsNotGuideUI(self.Uid) then
        Log.Go(string.format('Form[%s] %s Enter', self.Uid.Name, UIStateName[pState]), Log.KEY_UI)
    end
    self.CS_Form:SetState(UIStateName[pState])
end
function UIBase:LoadCache()
    -- v[1] txtTitle() | v[2] GrpTop/txtTitle | v[3] CCTypeEnum.Img | v[4] Image
    for i,v in ipairs(self.CC) do
        self[v[1]] = function()
            if v[4] then return v[4] end -- return cache component
            if v[2] == "/" then
                v[4] = self.ObjRoot:GetComponent(CCType[v[3]].Name)
            else
                local child = self:Find(v[2]) -- find obj by path
                if child then
                    v[4] = child:GetComponent(CCType[v[3]].Name)
                end
            end
            return v[4]     -- return false if find nothing
        end
    end
end
function UIBase:AddLinster()
    for k,v in pairs(self.CE) do
        if not v.flagAdd then
            v.flagAdd = true
            Event.Add(k, v.funback)
        end
    end
end
function UIBase:RemoveLinster()
    for k,v in pairs(self.CE) do
        if v.flagAdd then
            v.flagAdd = false
            Event.Remove(k, v.funback)
        end
    end
end
function UIBase:SetLayer(pLayer)
    self.CavOrder = pLayer
    if self.CS_Form then
        self.CS_Form:SetCanvasLayer(self.CavOrder)
    end
end

function UIBase:GetLayer()
    return self.CavOrder
end
function UIBase:OnFinishEvent(pEventName)
    if self.NeedLock then
        MgrUI.UnLock(self.Uid.Name)
    end
    self.UState = self.WantState 
    Log.Go(string.format('Form[%s] %s Finish', self.Uid.Name, pEventName), Log.KEY_UI)
    if MgrUI.IsNotGuideUI(self.Uid) then
        Event.Go(EID.UI_State_Change, self.Uid, self.UState)
    end

    self:OnAnimationFinish()
    if pEventName == "Close" then
        GameObject.Destroy(self.ObjRoot)
        -- MgrPool.PushCache("UI", self.PathPrefab, self.ObjRoot)
        self.HasInit = false
        self.CS_Form = nil
        self.ObjRoot = nil
        for i,v in ipairs(self.CC) do
            v[4] = false
        end
    elseif pEventName == "Hide" then
        self.ObjRoot:SetActive(false)
    end
end
---------------------------------------------------界面快捷API---------------------------------------------------
function UIBase:Find(pPath) -- 根据路径查找游戏对象，返回GameObject
    if self.ObjRoot == nil then
        return nil
    end
    local trans = self.ObjRoot.transform:Find(pPath)
    if trans then return trans.gameObject end
    return nil
end
function UIBase:OFind(pGo, pPath, pType)
    local go = pGo.transform:Find(pPath).gameObject
    if pType == nil then
        return go
    end
    return go:GetComponent(pType)
end
function UIBase:Regist(pEventName, pFun) -- 注册界面监听事件
    self.CE[pEventName] = {funback = pFun, flagAdd = false}
end
function UIBase:SetActive(pObj, pEnabled)
    self.CS_Form:SetActive(pObj, pEnabled)
end
function UIBase:SetText(pObj, pText)
    self.CS_Form:SetText(pObj, pText)
end
function UIBase:SetClick(pObj, pFunc)
    self.CS_Form:SetClick(pObj, pFunc)
end
---------------------------------------------------子界面复用重写---------------------------------------------------
function UIBase:OnArg() -- 参数重置
end
function UIBase:OnInit() -- 初始化，只调用一次，用于缓存组建，设置点击事件等一次性操作
end
function UIBase:OnShow(...) -- 每次界面主动显示都会被调用
end
function UIBase:OnBackShow() -- 每次之前界面返回至该界面被调用
end
function UIBase:OnUpdateUI() -- 刷新游戏内容，主动Show 和 被动BackShow 都会触发
end
function UIBase:OnStay() -- 显示新界面，自己保持的时候触发
end
function UIBase:OnHide() -- 显示新界面，自己隐藏的时候触发
end
function UIBase:OnClose() -- 关闭界面触发
end
function UIBase:OnShowFinish() -- 显示完毕
end
function UIBase:OnAnimationFinish() -- ui动画结束
end
return UIBase