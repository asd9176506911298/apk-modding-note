-- 资源管理器
MgrRes = {}
-- C# Res管理器接口 提供一些
local CS_MgrRes = CMgrRes.Instance

-- [启动设置]
function MgrRes.Init()
    CS_MgrRes:Init()
end

function MgrRes.Reset()
    CS_MgrRes:ReSet()
end

function MgrRes.GetPrefab(pPath,cell)
    CS_MgrRes:LoadPrefabLua(pPath,true,cell)
end

function MgrRes.PreLoad(pPath,cell)
    CS_MgrRes:LoadPrefabLua(pPath,false,cell)
end

function MgrRes.LoadSprite(pImage, pPath, cell, pSize)
    if pSize == nil then pSize = false end
    if cell == nil then
        CS_MgrRes:SetSprite(pImage, pPath, pSize, nil)
    else
        CS_MgrRes:SetSprite(pImage, pPath, pSize, cell)
    end
end

function MgrRes.SetMaterialByMesh(obj, pPath, attrName)
    CS_MgrRes:SetMaterialByMesh(obj,pPath,attrName)
end

function MgrRes.SetRoleMaterial(obj, roleID, roleName, attrName)
    CS_MgrRes:SetRoleMaterial(obj, roleID, roleName, attrName)
end

function MgrRes.SetShader(material, shaderName)
    return CS_MgrRes:SetShader(material, shaderName)
end

function MgrRes.GetBytes(path)
    return CS_MgrRes:LoadBytes(path)
end

function MgrRes.GetABPath(path,isCri)
    if isCri == nil then isCri = true end
    local str = string.lower(path)
    return CS_MgrRes:GetResPath(str,isCri)
end
function MgrRes.GetResPath(path)
    return CS_MgrRes:GetResPath(path)
end

function MgrRes.LoadProtoFile(path, cell)
    return CS_MgrRes:LoadProtoFile(path, cell)
end

---卸载AB
function MgrRes.UnLoadAssetBundle(pPathPrefab)
    --CS_MgrRes:UnLoadAssetBundle(pPathPrefab)
    ---清理内存
    MgrRes.ClearImmediate()
end

---回收内存计数器
MgrRes.GcCount = 0
---最大回收次数
MgrRes.GcMax = 7
---卸载资源并GC
function MgrRes.ClearImmediate()
    --print("内存为：", collectgarbage("count"))
    ---回收逻辑，当回收次数超过最大回收次数后执行回收
    MgrRes.GcCount = MgrRes.GcCount + 1
    if MgrRes.GcCount > MgrRes.GcMax then
        MgrRes.GcCount = 0
        CS_MgrRes:UnLoadImmediate()
    end
end

---立刻回收内存
function MgrRes.NowClearImmediate()
    MgrRes.GcCount = 0
    CS_MgrRes:UnLoadImmediate()
end

-----------------------------分包资源加载-------------------------------------
---自动区分spine和live2D加载
function MgrRes.LoadWatchAuto(parentObj, rid, x, y, scale, normalAniName, cell)
    if rid == 90000 then
        MgrRes.LoadWatchLive2D(parentObj, rid,x,y,scale,cell)
        return
    end
    MgrRes.LoadWatchSpine(parentObj, rid,x,y,scale,normalAniName,cell)
end

---加载观看用spine
function MgrRes.LoadWatch3DSpine(parentObj, rid, x, y, scale, normalAniName, cell,r,g,b,flip)
    if rid == nil then
        rid = 10000
        print("<color=red>创建立绘时未指定id</color>！暂时用露露啦代替！ 请检查id:" .. rid)
    end

    MgrHot.RolePackage(rid,function()
        local pName = "ABOriginal/Role/"..rid.."/WatchSpine/Watch_3D.prefab"
        MgrRes.GetPrefab(pName,function(obj)
            obj.transform:SetParent(parentObj.transform,false)
            if not CJNBattleMgr.Instance == nil then
                CJNBattleMgr.Instance:SetLayer(parentObj,"Role")
            end
            obj.transform.localPosition = Vector3(tonumber(x),tonumber(y),0)
            if scale ~= nil then
                obj.transform.localScale = Vector3.one * tonumber(scale)
            end
            if flip and flip==1 then
                obj.transform.localRotation = Quaternion(0,180,0,0)
            end
            local stg = obj:GetComponent("SkeletonAnimation")
            local norAni = normalAniName == nil and "idle" or normalAniName
            stg.AnimationState:SetAnimation(0,norAni,true)
            if r and g and b and stg.color ~= nil then
                stg.color = Color(r,g,b,1)
            end
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end

---加载观看用spine
function MgrRes.LoadWatchSpine(parentObj, rid, x, y, scale, normalAniName, cell,r,g,b,flip)
    if rid == nil then
        rid = 10000
        print("<color=red>创建立绘时未指定id</color>！暂时用露露啦代替！ 请检查id:" .. rid)
    end
    MgrHot.RolePackage(rid,function()
        local pName = "ABOriginal/Role/"..rid.."/WatchSpine/Watch_UI.prefab"
        MgrRes.GetPrefab(pName,function(obj)
            obj.transform:SetParent(parentObj.transform,false)
            obj.transform.localPosition = Vector3(tonumber(x),tonumber(y),0)
            obj.transform.localScale = Vector3.one * tonumber(scale)
            if flip and flip==1 then
                obj.transform.localRotation = Quaternion(0,180,0,0)
            end
            local stg = obj:GetComponent("SkeletonGraphic")
            local norAni = normalAniName == nil and "idle" or normalAniName
            stg.AnimationState:SetAnimation(0,norAni,true)
            if r and g and b then
                stg.color=Color(r,g,b,1)
            end
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end

function MgrRes.LoadWatch3DSpineInUI(parentObj, rid, x, y, scale, normalAniName, cell,r,g,b,flip)
    if rid == nil then
        rid = 10000
        print("<color=red>创建立绘时未指定id</color>！暂时用露露啦代替！ 请检查id:" .. rid)
    end
    MgrHot.RolePackage(rid,function()
        local pName = "ABOriginal/Role/"..rid.."/WatchSpine/Watch_3D.prefab"
        MgrRes.GetPrefab(pName,function(obj)
            obj.transform:SetParent(parentObj.transform,false)
            obj.transform.localPosition = Vector3(tonumber(x),tonumber(y),0)
            obj.transform.localScale = Vector3.one * tonumber(scale)
            if flip and flip==1 then
                obj.transform.localRotation = Quaternion(0,180,0,0)
            end
            local stg = obj:GetComponent("SkeletonAnimation")
            local norAni = normalAniName == nil and "idle" or normalAniName
            stg.AnimationState:SetAnimation(0,norAni,true)
            if r and g and b then
                stg.color=Color(r,g,b,1)
            end
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end

function MgrRes.LoadCgSpine(parentObj, rid, path, x, y, scale, normalAniName, cell,is3D,r,g,b,flip)
    if rid == nil then
        rid = 10000
        print("<color=red>创建立绘时未指定id</color>！暂时用露露啦代替！ 请检查id:" .. rid)
    end

    MgrHot.RolePackage(rid,function()
        MgrRes.GetPrefab(path,function(obj)
            obj.transform:SetParent(parentObj.transform,false)
            obj.transform.localPosition = Vector3(tonumber(x),tonumber(y),0)
            obj.transform.localScale = Vector3.one * tonumber(scale)
            if flip and flip==1 then
                obj.transform.localRotation = Quaternion(0,180,0,0)
            end
            local stg = nil
            local norAni = normalAniName == nil and "idle" or normalAniName
            if is3D == nil or is3D == true then
                stg = obj:GetComponent("SkeletonAnimation")
                if stg then
                    stg.AnimationName = normalAniName
                    stg.AnimationState:SetAnimation(0,norAni,true)
                end
            else
                stg = obj:GetComponent("SkeletonGraphic")
                stg.AnimationState:SetAnimation(0,norAni,true)
            end
            if r and g and b then
                stg.color=Color(r,g,b,1)
            end
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end
---加载皮肤前景
function MgrRes.LoadSkinFrontBG(picType,pImage,path,parent,x,y,scale,normalAniName,cell)
    if picType == 0 then
        MgrRes.LoadHotSpriteImmediately(1, pImage, path, nil, true)
    else
        local newPath = path --..".prefab"
        MgrRes.GetPrefab(newPath,function(go)
            go.transform:SetParent(parent.transform,false)
            if x ~= nil and y ~= nil then
                go.transform.localPosition = Vector3(x,y,0)
                go.transform.localScale = Vector3.one * tonumber(scale)
            end

            local stg = nil
            local norAni = normalAniName == nil and "idle" or normalAniName
            stg = go:GetComponent("SkeletonAnimation")
            if stg then
                stg.AnimationName = normalAniName
                stg.AnimationState:SetAnimation(0,norAni,true)
            end
            stg = go:GetComponent("SkeletonGraphic")
            if stg then
                stg.AnimationState:SetAnimation(0,norAni,true)
            end

            if cell then
                cell(go)
            end
        end)

    end
end
---加载观看用live2D
function MgrRes.LoadWatchLive2D(parentObj, rid, x, y, scale, cell)
    MgrHot.RolePackage(rid,function()
        local pName = "ABOriginal/Role/"..rid.."/WatchLive2D/live2D.prefab"
        MgrRes.GetPrefab(pName,function(obj)
            obj.transform:SetParent(parentObj.transform,false)
            obj.transform.localPosition = Vector3(x,y,0)
            obj.transform.localScale = Vector3.one * scale
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end
---加载观看用战斗spine
function MgrRes.LoadFightSpine(parentObj, rid, x, y, scale, normalAniName, cell, _skinName)
    if rid == nil then
        rid = 10000
        print("<color=red>创建观看用战斗spine时未指定id</color>！暂时用露露啦代替！ 请检查id:" .. rid)
    end
    MgrHot.RolePackage(rid,function()
        local pName = "ABOriginal/Role/" .. rid .. "/FightSpine/Watch_3D.prefab"
        MgrRes.GetPrefab(pName,function (obj)
            obj.transform:SetParent(parentObj.transform,false)
            obj.transform.localPosition = Vector3(x,y,0)
            obj.transform.localScale = Vector3.one * scale

            local sta = obj:GetComponent("SkeletonAnimation")
            sta.AnimationName = normalAniName
            sta.AnimationState:SetAnimation(0,normalAniName,true)
            if _skinName ~= nil and _skinName ~= "" then
                sta.initialSkinName = _skinName
                sta:Initialize(true);
            end
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end
---加载战斗用spine
function MgrRes.LoadFightSpineUI(parentObj,rid,x,y,scale,normalAniName,cell)
    if rid == nil then
        rid = 10000
        print("<color=red>创建观看用战斗spine时未指定id</color>！暂时用露露啦代替！ 请检查id:" .. rid)
    end
    MgrHot.RolePackage(rid,function()
        local pName = "ABOriginal/Role/" .. rid .. "/FightSpine/Watch_UI.prefab"
        MgrRes.GetPrefab(pName,function (obj)
            obj.transform:SetParent(parentObj.transform,false)
            obj.transform.localPosition = Vector3(x,y,0)
            obj.transform.localScale = Vector3.one * scale

            local stg = obj:GetComponent("SkeletonGraphic")
            stg.AnimationState:SetAnimation(0,normalAniName,true)
            if cell ~= nil then
                cell(obj)
            end
        end)
    end)
end

---ABOriginal/Spine UI用Spine
function MgrRes.LoadUISpine(parentObj, rid, x, y, layer, normalAniName, cell)
    local pName = "ABOriginal/Spine/" .. rid .. "/Watch3D_".. rid ..".prefab"
    MgrRes.GetPrefab(pName,function (obj)
        obj.transform:SetParent(parentObj.transform,false)
        obj.transform.localPosition = Vector3(x,y,0)

        local sta = obj:GetComponent("SkeletonAnimation")
        sta.AnimationName = normalAniName
        sta.AnimationState:SetAnimation(0,normalAniName,true)
        sta:SetOrderLayer(layer + 1,"Default")
        if cell ~= nil then
            cell(obj)
        end
    end)
end

---加载默认贴图
function MgrRes.LoadNormalIcon(image,roleId)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/NormalIcon/normal.png",roleId))
    end)
end
---加载高清贴图
function MgrRes.LoadHDIcon(image,roleId)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/HDIcon/hd.png",roleId))
    end)
end
---按原尺寸加载高清贴图
function MgrRes.LoadHDIcon_OriginalSize(image,roleId)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/HDIcon/hd.png",roleId),nil,true)
    end)
end
---加载方形贴图
function MgrRes.LoadRectIcon(image,roleId)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/RectIcon/rect.png",roleId))
    end)
end
---加载长条贴图
function MgrRes.LoadLongIcon(image,roleId,alpha,immediately)
    MgrHot.RolePackage(roleId,function()
        if alpha then
            if immediately then
                MgrRes.LoadHotSpriteImmediately(alpha,image,string.format("ABOriginal/Role/%s/LongIcon/long.png",roleId))
            else
                MgrRes.LoadHotSpriteWithAlpha(alpha,image,string.format("ABOriginal/Role/%s/LongIcon/long.png",roleId))
            end
        else
            MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/LongIcon/long.png",roleId))
        end

    end)
end
---加载长条贴图有回调
function MgrRes.LoadLongIcon_CallBack(image,roleId,cell,pSize)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/LongIcon/long.png",roleId),cell,pSize)
    end)
end
---加载Q版贴图
function MgrRes.LoadQIcon(image,roleId,cell)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/QIcon/q.png",roleId),cell)
    end)
end

---加载Q版贴图
function MgrRes.LoadQIconNotAni(image,roleId,cell,notAni)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/QIcon/q.png",roleId),cell,nil,notAni)
    end)
end

---加载圆形贴图
function MgrRes.LoadCircleIcon(image,roleId)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/CircleIcon/cir.png",roleId))
    end)
end
---加载战斗贴图
function MgrRes.LoadFightIcon(image,roleId)
    MgrHot.RolePackage(roleId,function()
        MgrRes.LoadHotSprite(image,string.format("ABOriginal/Role/%s/FightIcon/fight.png",roleId))
    end)
end
---加载角色音频
function MgrRes.LoadCriAcb(roleId)
    MgrHot.RolePackage(roleId,function()
        MgrSound.AddCue("Audio/role/"..roleId..".acb")
    end)
end
---加载角色ex动画(角色id，回调<路径>)
function MgrRes.LoadCriUsm(roleId,cell)
    MgrHot.RolePackage(roleId,function()
        cell(MgrRes.GetABPath("USM/role/"..roleId..".usm",true))
    end)
end
---加载剧情图片
function MgrRes.LoadPlotSprite(pImage, pPath, callback ,pSize, notAnim)
    if pSize == nil then pSize = false end
    if notAnim == nil then notAnim = false end
    local fullPath = "ABOriginal/Plot/PlotAssets/"..pPath
    -- MgrHot.PlotSprite(fullPath,function()
        MgrRes.LoadHotSprite(pImage, fullPath, callback, pSize, notAnim)
    -- end)
end

function MgrRes.LoadHotSprite(pImage, pPath, cell, pSize, notAnim)
    if pSize == nil then pSize = false end
    if notAnim ~= true then
        Tools.DoImageAlpha(pImage,0,0,0)
    end
    CS_MgrRes:SetHotSprite(pImage, pPath, pSize, function(...)
        if notAnim ~= true then
            Tools.DoImageAlpha(pImage,0,1,0.5)
        end
        if cell ~= nil then
            cell(...)
        end
    end)
end

function MgrRes.LoadHotSpriteWithAlpha(alpha, pImage, pPath, cell, pSize, notAnim)
    if pSize == nil then pSize = false end
    if notAnim ~= true then
        Tools.DoImageAlpha(pImage,0,0,0)
    end
    CS_MgrRes:SetHotSprite(pImage, pPath, pSize, function(...)
        if notAnim ~= true then
            Tools.DoImageAlpha(pImage,0,alpha,0.5)
        end
        if cell ~= nil then
            cell(...)
        end
    end)
end

function MgrRes.LoadHotSpriteImmediately(alpha, pImage, pPath, cell, pSize)
    if pSize == nil then pSize = false end
    CS_MgrRes:SetHotSprite(pImage, pPath, pSize, function(...)
        Tools.DoImageAlpha(pImage,0,alpha,0)
        if cell ~= nil then
            cell(...)
        end
    end)
end

---加载网络图片
function MgrRes.LoadUrlSprite(pImage, url, cell, pSize)
    if pSize == nil then pSize = false end
    if cell == nil then
        CS_MgrRes:SetUrlSprite(pImage, url, nil ,pSize)
    else
        CS_MgrRes:SetUrlSprite(pImage, url, cell, pSize)
    end
end

---加载Resources图片
function MgrRes.LoadResourceSprite(pImage, url, cell, pSize)
    if pSize == nil then pSize = false end
    if cell == nil then
        CS_MgrRes:SetResourceSprite(pImage, url, nil ,pSize)
    else
        CS_MgrRes:SetResourceSprite(pImage, url, cell, pSize)
    end
end

---加载皮肤背景
function MgrRes.LoadSkinBG(path,parent,x,y)
    MgrRes.GetPrefab(path,function(go)
        go.transform:SetParent(parent.transform,false)
        if x ~= nil and y ~= nil then
            go.transform.localPosition = Vector3(x,y,0)
        end
    end)
end


return MgrRes