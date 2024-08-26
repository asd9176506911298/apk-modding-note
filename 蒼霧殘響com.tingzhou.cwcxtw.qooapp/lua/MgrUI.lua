require 'UI/Base/UID'           ---UID
require 'UI/Base/UIEnum'        ---UI枚举
require 'UI/Base/UIBase'        ---UI基类
require 'UI/Base/UIItemBase'    ---UIItem基类
---------------------------------------------------全局函数&变量---------------------------------------------------
MgrUI = {} -- 界面管理器
MgrUI.CacheLuaUI = {} -- UIBase的lua类，存放界面的class，有就不需要在new一个class了
MgrUI.LockKeyTab = {} -- 锁定键存储列表
MgrUI.WaitKeyTab = {} -- 网络等待键存储列表
MgrUI.CacheTemplate = {} -- 缓存部件
MgrUI.AniState = {} -- 动画完成状态
---------------------------------------------------私有函数&变量---------------------------------------------------
-- C# UI管理器 提供一些接口
local CS_MgrUI = CMgrUI.Instance
-- 参数设置常量
local LAYER_SPAN = 1000 --层级之间预留顺序
-- 私有变量
local _UIList = {} -- 界面导航列表
local _PopList = {} -- 界面弹出列表
local _CacheUIDList = {} -- 缓存界面导航ID
local _newUICell = nil   -- 打开界面回调
MgrUI.CurShowUIName = nil

-- 会被隐藏需要特殊处理pop列表
local hidePopList = {
    "PartLoading_UI",
    "NoviceForce_UI",
    "NoviceFrame_UI",
}

-- 私有方法
local _GetUINum = function()
    return #_UIList
end
local _HasOnlyOneUI = function()
    return _GetUINum() < 2
end
local _GetCurUI = function()
    local len = _GetUINum()
    if len > 0 then
        return _UIList[len]
    end
    return nil
end
local _SetLayer = function(pUI)
    -- 设置界面层级
    local findUI = nil -- 找到最近一个相同层级的界面
    local len = _GetUINum()
    for i = len, 1, -1 do
        local tmpUI = _UIList[i]
        if tmpUI.Layer == pUI.Layer then
            findUI = tmpUI
            break
        end
    end
    if findUI then
        pUI:SetLayer(findUI:GetLayer() + findUI.Depth + 1)
    else
        pUI:SetLayer(LAYER_SPAN * pUI.Layer)
    end
end
local _GetLuaClass = function(pUid)
    if MgrUI.CacheLuaUI[pUid.Path] then
        for i, v in ipairs(_UIList) do
            if v.Uid == pUid then
                return require(pUid.Path).New()
            end
        end
        return MgrUI.CacheLuaUI[pUid.Path]
    else
        local newUI = require(pUid.Path).New()
        MgrUI.CacheLuaUI[pUid.Path] = newUI
        return newUI
    end
end
local _ShowNewUI = function(pUid, pCall)
    if pUid == nil then
        Log.Go('UID is Nil, Check your Spell', Log.KEY_UI)
        return
    end
    if pUid.Name == MgrUI.CurShowUIName then
        Log.Go('UID is already show', Log.KEY_UI)
        if _newUICell ~= nil then
            _newUICell()
        end
        return
    end
    MgrUI.CurShowUIName = pUid.Name
    if MgrUI.IsNotGuideUI(pUid) and MgrGuide then
        MgrGuide.OnClickBack()
    end
    local newUI = _GetLuaClass(pUid)
    MgrUI.Lock('ShowUILock' .. newUI.Uid.Name)
    newUI:Init(
        function()
            pCall()
            -- 加入导航队列
            _SetLayer(newUI)
            table.insert(_UIList, newUI)
            newUI:Show()
            CS_MgrUI:SetUIRoot(newUI.ObjRoot, newUI.IsScale)
            if (pUid.callback) then
                pUid.callback(newUI)
                pUid.callback = nil
            end
            MgrUI.UnLock('ShowUILock' .. newUI.Uid.Name)
            newUI:OnShowFinish()
            if _newUICell ~= nil then
                _newUICell()
            end
        end
    )
end
local _PopNewUI = function(pUid, pArg, pOnly)
    if pUid == nil then
        Log.Go('UID is Nil, Check your Spell', Log.KEY_UI)
        return
    end
    if MgrUI.IsNotGuideUI(pUid) and MgrGuide then
        MgrGuide.OnClickBack()
    end
    if pOnly then
        if pUid.WaitDataList and #pUid.WaitDataList > 0 then
            table.insert(pUid.WaitDataList, pArg)
            return
        end
        pUid.WaitDataList = {}
        table.insert(pUid.WaitDataList, pArg)
    end
    local newUI = require(pUid.Path).New()
    newUI:Init(
        function()
            -- 加入弹窗队列
            table.insert(_PopList, newUI)
            newUI:Show(pArg)
            CS_MgrUI:SetUIRoot(newUI.ObjRoot, newUI.IsScale)
            -- 设置界面层级
            local findUI = nil -- 找到最近一个相同层级的界面
            local len = #_PopList
            for i = len, 1, -1 do
                if _PopList[i].Layer == newUI.Layer and _PopList[i].Id ~= newUI.Id and _PopList[i]:GetLayer() >= LAYER_SPAN * newUI.Layer then
                    findUI = _PopList[i]
                    break
                end
            end
            if findUI then
                local targetLayer = findUI:GetLayer() + newUI.Depth
                targetLayer = targetLayer < LAYER_SPAN * newUI.Layer and LAYER_SPAN * newUI.Layer or targetLayer

                if findUI.Uid.Name == "SystemNotice_UI" and newUI.Uid.Name ~= "XiaoLoading_UI" then
                    newUI:SetLayer(findUI:GetLayer())
                    findUI:SetLayer(targetLayer)
                else
                    newUI:SetLayer(targetLayer)
                end
            else
                newUI:SetLayer(LAYER_SPAN * newUI.Layer + newUI.Depth)
            end
            if (pUid.callback) then
                pUid.callback(newUI)
                pUid.callback = nil
            end
            newUI:OnShowFinish()
        end,
        true
    )
end
local _BackShowUI = function(pNeedFade, callback)
    local curUIName = _GetCurUI().Uid.Name
    if curUIName == MgrUI.CurShowUIName then
        MgrUI.ClosePop(UID.Alpha)
        Log.Go('UID is already bakc show', Log.KEY_UI)
        return
    end
    MgrUI.CurShowUIName = curUIName
    _GetCurUI():BackShow(pNeedFade, callback)
end
---------------------------------------------------公开函数&变量---------------------------------------------------
-- 界面导航说明：[小写-隐藏][大写-显示]    -- 当前界面  -- 调用示例 	                  -- 结果                 -- MgrUI.GoBack()
-- Go          保持原界面，进入新界面	Eg: | a - b - C | MgrUI.Go(D)                   | a - b - C - D         | a - b - C         |
-- GoHide      隐藏原界面，进入新界面	Eg: | a - b - C | MgrUI.GoHide(D)               | a - b - c - D         | a - b - C         |
-- GoClose     关闭原界面，进入新界面	Eg: | a - b - C | MgrUI.GoClose(D)              | a - b - D             | a - B             |
-- GoFirstEx   回到某界面，进入新界面	Eg: | a - b - C | MgrUI.GoFirstEx(D, a)	        | a - D                 | A                 |
-- GoFirst     关所有界面，进入新界面	Eg: | a - b - C | MgrUI.GoFirst(D)              | D                     | D                 |
-- GoAdd       跳过某界面，进入新界面	Eg: | a - b - C | MgrUI.GoAdd(D, {e, h})        | a - b - c - e - h - D | a - b - c - e - H |
-- GoFirstAdd  清空并跳过，进入新界面	Eg: | a - b - C | MgrUI.GoFirstAdd(D, {e, h})   | e - h - D             | e - H
function MgrUI.Go(pUid, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local oldUI = _GetCurUI()
        if oldUI then
            oldUI:Stay()
        end
    end
    _ShowNewUI(pUid, call)
end
function MgrUI.GoHide(pUid, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local oldUI = _GetCurUI()
        if oldUI then
            oldUI:Hide()
        end
    end
    _ShowNewUI(pUid, call)
end
function MgrUI.GoHideAll(pUid, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local oldUI = _GetCurUI()
        if oldUI and not _HasOnlyOneUI() then --只有主界面的情况下，使用GoClose，主界面将不被Close
            oldUI:Close()
            table.remove(_UIList, _GetUINum())
        end
        for i, v in ipairs(_UIList) do
            v:Hide()
        end
        if _newUICell ~= nil then
            _newUICell()
        end
    end
    _ShowNewUI(pUid, call)
end
-- function MgrUI.HideCurrent(pShow)
--     local oldUI = _GetCurUI()
--     if oldUI then
--         if not pShow then
--             oldUI:Show()
--         else
--             oldUI:Hide()
--         end
--     end
-- end
function MgrUI.GetCurrentPopNum()
    return #_PopList
end
function MgrUI.GoClose(pUid, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local oldUI = _GetCurUI()
        if oldUI and not _HasOnlyOneUI() then --只有主界面的情况下，使用GoClose，主界面将不被Close
            oldUI:Close()
            table.remove(_UIList, _GetUINum())
        end
    end
    _ShowNewUI(pUid, call)
end
function MgrUI.CurrentPopIsHave(pUid)
    if #_PopList < 1 then
        return false
    end
    for i = 1, #_PopList do
        if _PopList[i].Uid == pUid then
            return true
        end
    end
    return false
end
function MgrUI.GoFirstEx(pUid, pExUid, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local len = _GetUINum()
        for i = len, 1, -1 do
            if i < 2 or _UIList[i].Uid == pExUid then
                _UIList[i]:Hide()
                break
            end
            _UIList[i]:Close()
            table.remove(_UIList, i)
        end
    end
    _ShowNewUI(pUid,call)
end
function MgrUI.GoFirst(pUid, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local len = #_UIList
        for i = len, 1, -1 do
            _UIList[i]:Close()
            table.remove(_UIList, i)
        end
    end
    _ShowNewUI(pUid, call)
end
function MgrUI.GoAdd(pUid, pUIList, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        for i, v in ipairs(pUIList) do
            local newUI = _GetLuaClass(pUid)
            newUI:Init(
                function()
                    CS_MgrUI:SetUIRoot(newUI.ObjRoot, newUI.IsScale)
                    newUI.ObjRoot:SetActive(false)
                end,
                true
            )
            _SetLayer(newUI)
            table.insert(_UIList, newUI)
        end
    end
    _ShowNewUI(pUid,call)
end
function MgrUI.GoFirstAdd(pUid, pUIList, callback)
    _newUICell = nil
    if callback then
        _newUICell = callback
    end

    MgrUI.Pop(
            UID.Alpha,
            {Mode = false, Finish = function()
            end},
            true
    )
    local call = function()
        local len = #_UIList
        for i = len, 1, -1 do
            _UIList[i]:Close()
            table.remove(_UIList, i)
        end
        for i, v in ipairs(pUIList) do
            local newUI = _GetLuaClass(v)
            newUI:Init(
                function()
                    CS_MgrUI:SetUIRoot(newUI.ObjRoot, newUI.IsScale)
                    newUI.ObjRoot:SetActive(false)
                end,
                true
            )
            _SetLayer(newUI)
            table.insert(_UIList, newUI)
        end
    end
    _ShowNewUI(pUid, call)
end
--  界面返回说明：[小写-隐藏][大写-显示]    -- 当前界面      -- 调用示例 	          -- 结果
-- GoBack	        返回上一界面      Eg: | a - b - c - D | MgrUI.GoBack()        | a - b - C |
-- GoBackToFirst    返回到主界面      Eg: | a - b - c - D | MgrUI.GoBackToFirst() | A         |
-- GoBackTo         返回到某界面      Eg: | a - b - c - D | MgrUI.GoBackTo(b)     | a - B     |
function MgrUI.GoBack(callback)

    local popMsg = MgrUI.CheckPopBack()
    if popMsg then
        MgrUI.ClosePop(UID.MsgBox, popMsg.Id)
        return
    end
    if _HasOnlyOneUI() then
        return
    end
    if MgrGuide then
        MgrGuide.OnClickBack()
    end

    local curUI = _GetCurUI()
    if curUI:NeedFadeIn() then
        MgrUI.Pop(
            UID.Alpha,
            {Mode = true, Finish = function()
                end},
            true
        )
        MgrTimer.AddDelay(
            os.clock() .. math.random(1000000),
            curUI.FadeIn,
            function()
                curUI:Close()
                table.remove(_UIList, _GetUINum())
                _BackShowUI(true, callback)
            end
        )
    else
        MgrUI.Pop(
                UID.Alpha,
                {Mode = false, Finish = function()
                end},
                true
        )
        if curUI.Uid.Name ~= UID.Alpha.Name and MgrUI.IsShowState(UID.Alpha) then
            MgrUI.ClosePop(UID.Alpha)
        end
        curUI:Close()
        table.remove(_UIList, _GetUINum())
        _BackShowUI(false, callback)
    end
end
function MgrUI.GoBackToFirst(callback)


    if MgrUI.HasBackLockUI() then
        return
    end
    if MgrGuide then
        MgrGuide.OnClickBack()
    end

    MgrUI.Pop(
        UID.Alpha,
        {Mode = true, Finish = function()
            end},
        true
    )
    MgrTimer.AddDelay(
        os.clock() .. math.random(1000000),
        0.3,
        function()
            MgrUI.CloseAllMsgBox()
            local len = _GetUINum()
            for i = len, 2, -1 do
                _UIList[i]:Close()
                table.remove(_UIList, i)
            end
            _BackShowUI(true, callback)
        end
    )
end
function MgrUI.GoBackTo(pUid, callback)

    if MgrUI.HasBackLockUI() then
        return
    end
    if MgrGuide then
        MgrGuide.OnClickBack()
    end

    MgrUI.Pop(
        UID.Alpha,
        {Mode = true, Finish = function()
            end},
        true
    )

    MgrTimer.AddDelay(
        os.clock() .. math.random(1000000),
        0.3,
        function()
            MgrUI.CloseAllMsgBox()
            local findUI = nil
            local len = _GetUINum()
            for i = len, 1, -1 do
                local tmpUI = _UIList[i]
                if tmpUI.Uid == pUid then
                    findUI = tmpUI
                    break
                end
            end
            if findUI then -- 找到UI了再去删除，如果没找到，不执行其他UI关闭操作
                for i = len, 1, -1 do
                    local tmpUI = _UIList[i]
                    if tmpUI == findUI then
                        break
                    end
                    tmpUI:Close()
                    table.remove(_UIList, i)
                end
            end
            _BackShowUI(true, callback)
        end
    )
end
function MgrUI.CheckPopBack()
    local len = #_PopList
    for i = len, 1, -1 do
        local tmpUI = _PopList[i]
        if tmpUI.Uid == UID.MsgBox then
            if tmpUI.Data.CanBack then
                return tmpUI
            end
        end
    end
    return nil
end
function MgrUI.HasBackLockUI()
    local len = #_PopList
    for i = len, 1, -1 do
        local tmpUI = _PopList[i]
        if tmpUI.Uid == UID.MsgBox then
            if tmpUI.Data.CanBack == false then
                return true
            end
        end
    end
    return false
end
function MgrUI.CloseAllMsgBox()
    local closes = {}
    local len = #_PopList
    for i = len, 1, -1 do
        local tmpUI = _PopList[i]
        if tmpUI.Uid == UID.MsgBox then
            table.insert(closes, tmpUI)
        end
    end
    for i, v in ipairs(closes) do
        MgrUI.ClosePop(UID.MsgBox, v.Id)
    end
end
-- 界面弹出说明：一些常用的UI部件（警示文字，成就消息，公告，Tips提示框）pArg：界面参数
function MgrUI.Pop(pUid, pArg, pOnly)
    if pOnly then
        local tmp_ui = MgrUI.GetPopUI(pUid)
        if tmp_ui
        then
            -- 设置界面层级
            local findUI = nil -- 找到最近一个相同层级的界面
            local len = #_PopList
            for i = len, 1, -1 do
                if _PopList[i].Layer == tmp_ui.Layer and _PopList[i].Id ~= tmp_ui.Id and _PopList[i]:GetLayer() >= LAYER_SPAN * tmp_ui.Layer then
                    findUI = _PopList[i]
                    break
                end
            end
            if findUI then
                local targetLayer = findUI:GetLayer() + tmp_ui.Depth
                targetLayer = targetLayer < LAYER_SPAN * tmp_ui.Layer and LAYER_SPAN * tmp_ui.Layer or targetLayer
                tmp_ui:SetLayer(targetLayer)
            else
                tmp_ui:SetLayer(LAYER_SPAN * tmp_ui.Layer + tmp_ui.Depth)
            end
            tmp_ui:Show(pArg)
        else
            _PopNewUI(pUid, pArg, pOnly)
        end
    else
        _PopNewUI(pUid, pArg)
    end
end
function MgrUI.ClosePop(pUid, pId,callback)
    local find, index = MgrUI.GetPopUI(pUid, pId)
    if find ~= nil then
        find:Close()
        table.remove(_PopList, index)
    end
    if callback then
        callback()
    end
end
---移除所有Pop层弹窗
function MgrUI.CloseAllPop()
    local newPop = {}
    for idx, pop in pairs(_PopList) do
        if pop.Layer == UILayerLv.Pop and pop.Uid.Name ~= "SystemNotice_UI" and pop.Uid.Name ~= "NewRoleSkill_UI" and pop.Uid.Name ~= "NewRoleFormation_UI" then
            pop:Close()
        else
            table.insert(newPop, pop)
        end
    end
    _PopList = newPop
end
function MgrUI.GetPopUI(pUid, pId)
    local findUI = nil
    local index = nil
    local len = #_PopList
    for i = len, 1, -1 do
        local tmpUI = _PopList[i]
        if tmpUI.Uid == pUid and ((pId == nil) or (pId ~= nil and tmpUI.Id == pId)) then
            findUI = tmpUI
            index = i
            break
        end
    end
    return findUI, index
end
function MgrUI.PopHide(pUid)
    local PopUI,_ =  MgrUI.GetPopUI(pUid)
    if PopUI ~= nil then
        PopUI:Hide()
    end
end
function MgrUI.ShowBox(pData)
    MgrUI.Pop(UID.MsgBox, pData)
end
function MgrUI.Wait(pReason, pDelay)
    MgrUI.WaitKeyTab[pReason] = true
    MgrUI.Pop(UID.Wait, {Reason = pReason, Delay = pDelay}, true)
end
function MgrUI.UnWait(pReason, pForce)
    if pForce then
        MgrUI.ClosePop(UID.Wait)
        MgrUI.WaitKeyTab = {}
    else
        MgrUI.WaitKeyTab[pReason] = nil
        local existLock = false
        for k, v in pairs(MgrUI.WaitKeyTab) do
            if v then
                existLock = true
                break
            end
        end
        if not existLock then
            MgrUI.ClosePop(UID.Wait)
        end
    end
end
function MgrUI.Lock(reason, data)
    MgrUI.LockKeyTab[reason] = true
    local d = data or {}
    MgrUI.Pop(UID.Lock, d, true)
end
function MgrUI.UnLock(pLockKey, pForce)
    if pForce then
        MgrUI.ClosePop(UID.Lock)
        MgrUI.LockKeyTab = {}
    else
        MgrUI.LockKeyTab[pLockKey] = nil
        local existLock = false
        for k, v in pairs(MgrUI.LockKeyTab) do
            if v then
                existLock = true
                break
            end
        end
        if not existLock then
            MgrUI.ClosePop(UID.Lock)
        end
    end
end
function MgrUI.ShowReward(pRewards, pCallBack, pShowBg)
    if pRewards == nil or #pRewards == 0 then
        pCallBack()
        return
    end
    MgrUI.Rewards = pRewards
    MgrUI.CallBack = pCallBack
    if pShowBg == nil then
        pShowBg = true
    end
    MgrUI.ShowBg = pShowBg
    if #pRewards == 1 then
        MgrUI.Go(UID.RewardOne)
    elseif #pRewards >= 2 then
        MgrUI.Go(UID.RewardTwo)
    end
end
function MgrUI.ShowVideo(pData)
    MgrUI.Pop(UID.Video, pData, true)
end
function MgrUI.ShowNotice(pData)
    MgrUI.Pop(UID.NoticeMsg, pData)
end
local GuideUI = {
    'Click',
    'Guide',
    'Lock',
    'Wait',
    'Copy',
    'Alpha',
    'NoticeMsg'
}
function MgrUI.IsNotGuideUI(pUid)
    for i, v in ipairs(GuideUI) do
        if v == pUid.Name then
            return false
        end
    end
    return true
end
--------------------------------------------API---------------------------------------------------
-- [启动设置]
function MgrUI.Init()
    CS_MgrUI:Init()
    MgrPool.InitCache('UI', -1)
    MgrUI.SeteResolution(1920, 1080)
    CS_MgrUI:registBackKeyCell(function ()
        print('MgrUI onBackKeyDown')
        Event.Go('BackKey')
    end)
end

function MgrUI.SeteResolution(pWidth, pHeight)
    CS_MgrUI:SeteResolution(pWidth, pHeight)
end
-- 打开/关闭UI
function MgrUI.OpenUI(pShow)
    CS_MgrUI:GetFullRoot():SetActive(pShow)
    CS_MgrUI:GetUIScaleRoot():SetActive(pShow)
    -- CS_MgrUI:GetUICamera().gameObject:SetActive(pShow)
    if pShow then
        MgrGuide.FroceHide = false
        Event.Go(EID.UI_Force_Change)
    end
end
function MgrUI.OpenCamera(pShow)
    CS_MgrUI:GetUICamera().gameObject:SetActive(pShow)
end
function MgrUI.GetUICamera()
    return CS_MgrUI:GetUICamera()
end
function MgrUI.ResetLayer(pUI)
    _SetLayer(pUI)
end

--关闭MgrUI
-- function MgrUI.OpenMgrUI(pShow)
--     CS_MgrUI:GetMgrUI().gameObject:SetActive(pShow)
-- end
function MgrUI.OpenEvent(pShow)
    CS_MgrUI:GetEvent().gameObject:SetActive(pShow)
end
function MgrUI.GetFullRoot()
    return CS_MgrUI:GetFullRoot()
end
-- 获取当前界面
function MgrUI.GetCurUI()
    return _GetCurUI()
end
function MgrUI.GetPreUI(pNum)
    local min = #_UIList - 1
    min = math.min(min, pNum)
    return _UIList[#_UIList - min]
end
function MgrUI.Clear()
    local len = #_UIList
    for i = len, 1, -1 do
        _UIList[i]:Close()
        table.remove(_UIList, i)
    end
end
-- 缓存UI到对象池
function MgrUI.CacheUI(pUid, pEventName)
    if pUid == nil then
        Log.Go('UID is Nil, Check your Spell', Log.KEY_UI)
        return
    end
    local newUI = _GetLuaClass(pUid)
    MgrRes.GetPrefab(newUI.PathPrefab,function(go)
        MgrPool.PushCache('UI', newUI.PathPrefab, go)
        Event.Go(pEventName)
    end)
end
-- 获取指定界面，返回GameObject
function MgrUI.GetUIGo(pUid)
    local len = #_UIList
    for i = len, 1, -1 do
        local tmpUI = _UIList[i]
        if tmpUI.Uid == pUid then
            return tmpUI.ObjRoot
        end
    end
    return nil
end
-- 获取UIBase
function MgrUI.GetUIBase(pUid)
    local len = #_UIList
    for i = len, 1, -1 do
        local tmpUI = _UIList[i]
        if tmpUI.Uid == pUid then
            return tmpUI
        end
    end
    return nil
end
function MgrUI.FindUI(pUid, pPath)
    local tmpui = MgrUI.GetUIBase(pUid)
    if tmpui then
        return tmpui:Find(pPath)
    end
    tmpui = MgrUI.GetPopUI(pUid)
    if tmpui then
        return tmpui:Find(pPath)
    end
    return nil
end
-- 判断界面是否显示中
function MgrUI.IsShow(pUid)
    local go = MgrUI.GetUIGo(pUid)
    if go then
        return go.activeInHierarchy
    end
    return false
end
function MgrUI.IsShowState(pUid)
    local go = MgrUI.GetPopUI(pUid)
    if go then
        return (go.UState == UIState.Show or go.UState == UIState.BackShow) or
            (go.ObjRoot and go.ObjRoot.activeInHierarchy)
    end
    return false
end
-- 热更新UI
function MgrUI.Reload(pUid)
    local len = #_UIList
    local reloadUID = UID[pUid]
    local tbName = string.gsub(reloadUID.Path, '/', '.')
    for i = len, 1, -1 do
        local oldUI = _UIList[i]
        local findOldUI = false
        if oldUI.Uid == reloadUID then
            package.loaded[tbName] = nil
            local newUI = require(reloadUID.Path).New()
            setmetatable(oldUI, newUI)
            -- Reflash UI
            if oldUI.UState == UIState.Show then
                newUI:Show()
            elseif oldUI.UState == UIState.Show then
                newUI:Stay()
            end
            MgrPool.PushDestory(oldUI.ObjRoot)
            CS_MgrUI:SetUIRoot(newUI.ObjRoot, newUI.IsScale)
            newUI:SetLayer(oldUI.CavOrder)
            oldUI = nil
            _UIList[i] = newUI
            findOldUI = true
            break
        end
    end
    if not findOldUI then
        package.loaded[tbName] = nil
    end
end
-- 打印UI状态 [a-stay-order][b-hide-order][c-show-order]
function MgrUI.LogState()
    local t = {}
    for i, v in ipairs(_UIList) do
        local item = string.format('[%s-%s-%s]', v.Uid.Name, UIStateName[v.UState], v:GetLayer())
        table.insert(t, item)
    end
    Log.Go(string.format('UI List :%s', table.concat(t, '')), Log.KEY_UI)
end
-- 打印UI数量
function MgrUI.LogCount()
    Log.Go(string.format('UI List Count:%s', _GetUINum()), Log.KEY_UI)
end

---保存当前所有界面导航id
function MgrUI.SaveAllUID()
    ---清空缓存
    _CacheUIDList = {}
    ---添加
    for i, v in ipairs(_UIList) do
        if v.Uid ~= UID.Login_UI and v.Uid ~= UID.ClearSce_UI and v.Uid ~= UID.NoviceRename_UI then --排除部分界面
            table.insert(_CacheUIDList, v.Uid)
        end
    end
end

---加载所有uid缓存里的ui
function MgrUI.ShowCacheUI(cell)
    if next(_CacheUIDList) == nil then
        if cell then
            cell()
        end
        return
    end

    local once = true
    for i, uid in ipairs(_CacheUIDList) do
        if i ~= #_CacheUIDList then
            if once then
                MgrUI.GoFirst(uid)
                once = false
            else
                MgrUI.GoHide(uid)
            end
        else
            if once then
                MgrUI.GoFirst(uid, cell)
                once = false
            else
                MgrUI.GoHide(uid, cell)
            end
        end
    end
end

function MgrUI.IsPopOpen()
    local isOpen = false
    for idx, pop in pairs(_PopList) do
        if pop.Uid.Name ~= "SystemNotice_UI" and pop.Uid.Name ~= "XiaoLoading_UI" and (not MgrUI.IsInHideList(pop.Uid.Name) or MgrUI.IsShowState(pop.Uid)) then
            isOpen = true
        end
    end
    return isOpen
end


function MgrUI.IsPopOpenOutSelf(_name)
    local isOpen = false
    for idx, pop in pairs(_PopList) do
        if pop.Uid.Name ~= "SystemNotice_UI" and pop.Uid.Name ~= "XiaoLoading_UI" and (not MgrUI.IsInHideList(pop.Uid.Name) or MgrUI.IsShowState(pop.Uid)) then
            if _name ~= pop.Uid.Name then
                isOpen = true
            end
        end
    end
    return isOpen
end
--除了指定界面
function MgrUI.IsPopOpenOutCou(_name,_list)
    local isOpen = false
    for idx, pop in pairs(_PopList) do
        print(pop.Uid.Name)
        if pop.Uid.Name ~= "SystemNotice_UI" and pop.Uid.Name ~= "XiaoLoading_UI" and (not MgrUI.IsInHideList(pop.Uid.Name) or MgrUI.IsShowState(pop.Uid)) and not MgrUI.IsInTable(pop.Uid.Name,_list) then
            if _name ~= pop.Uid.Name then
                isOpen = true
            end
        end
    end
    return isOpen
end

function MgrUI.IsInTable(_value,_list)
    local isIn = false
    for index, value in ipairs(_list) do
        if _value ==  value then
            isIn = true
            break
        end
    end
    return isIn
end

function MgrUI.IsInHideList(name)
    for index, value in pairs(hidePopList) do
        if name == value then
            return true
        end
    end
    return false
end