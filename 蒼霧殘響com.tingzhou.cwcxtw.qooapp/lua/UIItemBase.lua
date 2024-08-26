UIItemBase = Class('UIItemBase')
function UIItemBase:ctor()
    self.ObjRoot = nil -- 模板对象
    self.PathPrefab = nil --模板路径
    self.CS_Template = nil -- 模板UITemplate组件
    self.CC = {} -- 模板缓存组建列表
    self.HasInit = false
    self.Data = nil -- 模板数据
    self.CE = {}
end
function UIItemBase:Load(pCallBack)
    MgrRes.GetPrefab(self.PathPrefab,function(go)
        self:LoadCallBack(pCallBack, go)
    end)
end
-- 用已有的Obj来初始化
function UIItemBase:Attach(pGo)
    self:LoadCallBack(nil, pGo)
end

function UIItemBase:LoadCallBack(pCallBack, go)
    self.ObjRoot = go
    self.CS_Template = self.ObjRoot:GetComponent("UITemplate")
    self:LoadCache()
    if not self.HasInit then
        self:OnInit()
        self.HasInit = true
    end
    if pCallBack then
        pCallBack(self)
    end
end
function UIItemBase:Copy(pCallBack)
    local copy = clone(self)
    copy:ClearCache()
    copy:Load(pCallBack)
end
function UIItemBase:Update(pData, pGo)
    self.Data = pData
    if pGo then
        self.ObjRoot = pGo
        self:LoadCache()
        if not self.HasInit then
            self:OnInit()
            self.HasInit = true
        end
    end
    self:OnUpdateUI(pData)
end
function UIItemBase:UpdateIndex(pList, pIndex, pGo)
    self.Data = pList[pIndex + 1]
    if pGo then
        self.ObjRoot = pGo
        self:LoadCache()
        if not self.HasInit then
            self:OnInit()
            self.HasInit = true
        end
    end
    self:OnUpdateUI(self.Data)
end

function UIItemBase:Find(pPath) -- 根据路径查找游戏对象，返回GameObject
    local trans = self.ObjRoot.transform:Find(pPath)
    if trans then return trans.gameObject end
    return nil
end
function UIItemBase:OFind(pGo, pPath, pType)
    local go = pGo.transform:Find(pPath).gameObject
    if pType == nil then
        return go
    end
    return go:GetComponent(pType)
end
function UIItemBase:ClearCache()
    for i,v in ipairs(self.CC) do
        v[4] = nil
        self[v[1]] = nil
    end
end
function UIItemBase:LoadCache()
    for i,v in ipairs(self.CC) do
        self[v[1]] = function()
            if v[4] then return v[4] end
            if v[2] == "/" then
                v[4] = self.ObjRoot:GetComponent(CCType[v[3]].Name)
            else
                local child = self:Find(v[2]) -- find obj by path
                if child then
                    v[4] = child:GetComponent(CCType[v[3]].Name)
                end
            end
            return v[4]
        end
    end
end
function UIItemBase:BindSelect(pFun)
    self.ItemSelectFun = pFun
end
function UIItemBase:SetClick(pGo, pFun, pIsSelect)
    if pGo == nil or pFun == nil then return end
    if self[pGo.name] == nil then
        self[pGo.name] = function()
            pFun()
            if self.ItemSelectFun and pIsSelect then
                self.ItemSelectFun(self)
            end
        end
        UIEvent.LuaClick(pGo, self[pGo.name])
    end
end

function UIItemBase:SetSelfActive(isShow)
    self.ObjRoot.gameObject:SetActive(isShow)
end

-- 需要重写
function UIItemBase:OnInit()
end

function UIItemBase:OnUpdateUI(pData)
end

function UIItemBase:ItemUpdate(pData)

end

return UIItemBase