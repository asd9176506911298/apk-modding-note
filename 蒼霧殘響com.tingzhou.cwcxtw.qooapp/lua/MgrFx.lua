MgrFx = {}
-- C# Pool管理器接口 提供一些
local CS_MgrFx = CMgrFx.Instance
-- [启动设置]
function MgrFx.Init()
    CS_MgrFx:Init()
    MgrPool.InitCache("FX", -1)
end

function MgrFx.ShowFx(pPath)
    CS_MgrFx:ShowFx(pPath)
end

function MgrFx.ShowFx(pPath, pPos)
    return CS_MgrFx:ShowFx(pPath, pPos)
end

function MgrFx.ShowUIFx(pPath, pParent)
    return CS_MgrFx:ShowUIFx(pPath, pParent)
end
function MgrFx.ShowUIFxText(pPath, pText, pParent)
    return CS_MgrFx:ShowUIFx(pPath, pText, pParent)
end
function MgrFx.ShowFxNoCheck(pPath, pPos)
    return CS_MgrFx:ShowFxCheckView(pPath, pPos, true)
end

function MgrFx.Clear()
    CS_MgrFx:Clear()
end

function MgrFx.SetFxSpeed(pGroup, pSpeed)
    CS_MgrFx:SetFxSpeed(pGroup, pSpeed)
end

---头像框跳动
function MgrFx.SelectFrameFlash(pImg,name)
    pImg.transform.localScale = Vector3(0.99,0.99,0.99)
    MgrTimer.AddRepeat(name,0.01,function()
        if pImg ~= nil then
            if pImg.transform.localScale.x >= 1.03  then
                --开始缩小
                MgrTimer.Cancel("pImgLarge")
                MgrTimer.AddRepeat("pImgShrink",0.01,function()
                    if pImg ~= nil then
                        pImg.transform.localScale = Vector3(pImg.transform.localScale.x - 0.002,pImg.transform.localScale.y - 0.002,1)
                    end
                 end,50,nil)

            elseif pImg.transform.localScale.x <= 1 then
                --开始放大
                MgrTimer.Cancel("pImgShrink")
                MgrTimer.AddRepeat("pImgLarge",0.01,function()
                    if pImg ~= nil then
                        pImg.transform.localScale = Vector3(pImg.transform.localScale.x + 0.002,pImg.transform.localScale.y + 0.002,1)
                    end
                end,50,nil)
            end
        end
    end,-1,pImg.gameObject)
end

function MgrFx.CancelSelectFrameFlash(pImg,name)
    if pImg then
        pImg.transform.localScale = Vector3(1,1,1)
    end
    MgrTimer.Cancel("pImgLarge")
    MgrTimer.Cancel("pImgShrink")
    MgrTimer.Cancel(name)
end

function MgrFx.GetFxObj(pPath, pName, pObj, pCallBack)
    local skillEff = pObj.transform:Find(pName)
    if skillEff and skillEff.gameObject ~= nil then
        skillEff.gameObject:SetActive(false)
        --skillEff.layer = LayerMask.NameToLayer("Hud") 
        if pCallBack then pCallBack(skillEff.gameObject) end
        return skillEff
    end
    for k,v in pairs(MgrBattle.GoEffList) do
        if k == pName then
            if type(v) ~= "userdata" then
                skillEff = GameObject.Instantiate(v)
            else
                --skillEff = MgrRes.GetPrefab(pPath)
            end
            skillEff:SetActive(false)
            skillEff.transform:SetParent(pObj.transform, false)
            skillEff.transform.localPosition = Vector3(0,0,0)
            skillEff.name = pName
            --skillEff.layer = LayerMask.NameToLayer("Hud") 
            if pCallBack then pCallBack(skillEff) end
            return skillEff
        end
    end
    if skillEff == nil then
        --local go = MgrRes.GetPrefab(pPath)
        --if go == nil then return end
        --go:SetActive(false)
        --go.transform:SetParent(pObj.transform, false)
        --go.transform.localPosition = Vector3(0,0,0)
        --MgrBattle.GoEffList[pName] = go
        --go.name = pName
        ----go.layer = LayerMask.NameToLayer("Hud")
        --if pCallBack then pCallBack(go) end
        return go
    end
    return skillEff
end