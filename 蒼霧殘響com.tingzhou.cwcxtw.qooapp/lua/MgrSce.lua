-- 场景管理器
MgrSce = {}
local CMgrSce = CMgrScene.Instance
MgrSce.Path = "Scenes/Battle"

MgrSce.Scenes = {
    Home = "Home",
    Battle = "Battle",
    Clear = "Clear",
}

local curSce = nil

function MgrSce.Init()
    -- MgrSce.Load(MgrSce.Scenes.Home)
    CMgrSce:Init()
end

local _cell
function MgrSce.Load(sceName, cell)
    ---上个Scene为Home时缓存Home界面id
    if curSce == MgrSce.Scenes.Home then
        MgrUI.SaveAllUID()
    end
    _cell = cell
    curSce = sceName
    MgrSce.ClearBack(function ()
        MgrCamera.SwitchToUICam()
        CMgrSce:Load(sceName, MgrSce.Respond)
    end)
end

function MgrSce.GetCurScene()
    return curSce
end

function MgrSce.LoadBattle(sceName, cell)
    ---上个Scene为Home时缓存Home界面id
    if curSce == MgrSce.Scenes.Home then
        MgrUI.SaveAllUID()
    end
    _cell = cell
    curSce = sceName
    MgrSce.ClearBack(function ()
        MgrCamera.SwitchToFightCam()
        CMgrSce:LoadABScene(sceName, MgrSce.Respond)
    end)
end

function MgrSce.Respond(...)
    -- MgrTimer.AddDelayNoName(0.1, function (...)
        if _cell then
            _cell(...)
        end
    -- end)
end

local _clearCell
function MgrSce.Clear(cell)
    _clearCell = cell
    CMgrSce:Load(MgrSce.Scenes.Clear,MgrSce.ClearBack)
end

function MgrSce.ClearBack(call)
    ---清除所有界面
    MgrTimer.AddDelayNoName(0.1, function ()
        MgrUI.GoFirst(UID.ClearSce_UI)
        MgrUI.CloseAllPop()
        MgrRes.NowClearImmediate()
        call()
    end)
end

return MgrSce