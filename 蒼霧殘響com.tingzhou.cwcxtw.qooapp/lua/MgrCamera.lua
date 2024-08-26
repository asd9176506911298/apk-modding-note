MgrCamera = {}

local CS_MgrCamera = CMgrCamera.Instance

MgrCamera.timeToCharacter = CS_MgrCamera.timeToCharacter
MgrCamera.timeStayOnCharacter = CS_MgrCamera.timeStayOnCharacter

MgrCamera.cameraParasData = {
    {0,430,-1350,20,0,0,20,0.3,100000},   --全局机位
    {0,210,-755,19,0,0,40,0.3,100000},    --round机位
    {0,111,-660,11.5,0,0,40,0.3,100000},     --默认战斗机位
    {-106,100,-650,10,3,0,35,0.3,100000},   --左一机位
    {-215,85,-650,11,7,0,35,0.3,100000},   --左二机位
    {106,100,-650,16,-6,0,35,0.3,100000},    --右一机位
    {240,85,-650,13,-12.5,0,35,0.3,100000},    --右二机位
}
MgrCamera.cameraParasData_New = {
    {0,418,-809,35.6,0,0,32,0.3,100000},   --全局机位
    {0,211,-756,19,0,0,40,0.3,100000},    --round机位
    {0,111,-660,11.5,0,0,35,0.3,100000},     --默认战斗机位
    {-106,100,-650,10,3,0,35,0.3,100000},   --左一机位
    {-215,85,-650,11,7,0,35,0.3,100000},   --左二机位
    {106,100,-650,16,-6,0,35,0.3,100000},    --右一机位
    {240,85,-650,13,-12.5,0,35,0.3,100000},    --右二机位
}

function MgrCamera.Init()
    CS_MgrCamera:Init()
end
--初始化所有虚拟相机
function MgrCamera.VirCamerasInit(cameraParas)
    CS_MgrCamera:VirCamerasInit(cameraParas)
end
--移动到这个相机
function MgrCamera.MoveToCamera(Id)
    local cameraIndex
    if BattleManager.AllRole[Id] then
        if BattleManager.AllRole[Id].IsLeft then
            cameraIndex = 4 - math.modf((BattleManager.AllRole[Id].PosX - 1)/2)
        else
            cameraIndex = math.modf((BattleManager.AllRole[Id].PosX - 1)/2) + 5
            if cameraIndex == 5 then
                cameraIndex = 2
            else
                cameraIndex = cameraIndex - 1
            end
        end
        CS_MgrCamera:MoveToCamera(cameraIndex)
    end
end

--根据角色移动相机
function MgrCamera.MoveToCharacter(Id)
    UnityEngine.DebugEx.Log("相机朝 ".. Id .." 移动")
    if BattleManager.AllRole[Id] then
        CS_MgrCamera:MoveToCharacter(BattleManager.AllRole[Id].PosX,BattleManager.AllRole[Id].PosY,BattleManager.AllRole[Id].IsLeft)
    end
end

--添加延迟
function MgrCamera.AddDelay(delayTime)
    CS_MgrCamera:AddDelay(delayTime)
end
--看向新的目标
function MgrCamera.CameraLookAt(Id)
    local index
    if BattleManager.AllRole[Id].IsLeft then
        index = math.modf((BattleManager.AllRole[Id].PosX - 1)/2) + 1
    else
        index = math.modf((BattleManager.AllRole[Id].PosX - 1)/2) + 3
        if index == 3 then
            index = 1
        end
    end
    CS_MgrCamera:CameraLookAt(index,BattleManager.AllRole[Id].myAni)
end

--相机震动                      延迟
function MgrCamera.CameraShake(cani)
    CS_MgrCamera:Lua_CameraShake(cani)
end

--回到默认机位
function MgrCamera.BackToDefaultPosition()
    CS_MgrCamera:BackToDefaultPosition()
end

--回到round机位
function MgrCamera.BackToRoundEndPosition()
    CS_MgrCamera:BackToRoundEndPosition()
end

--回到All机位
function MgrCamera.BackToAllCamera()
    CS_MgrCamera:BackToAllCamera()
end

--更改相机移动时间  0:看攻击者 1:看被攻击者
function MgrCamera.ChangeBlendTime(type)
    CS_MgrCamera:ChangeBlendTime(type)
end

--切换战斗主相机
function MgrCamera.SwitchToFightCam()
    CS_MgrCamera:SwitchToFightCam()
end

--切换UI主相机
function MgrCamera.SwitchToUICam()
    CS_MgrCamera:SwitchToUICam()
end

return MgrCamera