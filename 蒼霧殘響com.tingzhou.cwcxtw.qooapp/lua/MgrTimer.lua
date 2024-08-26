-- 定时器管理器
MgrTimer = {}
-- C# Timer管理器接口 提供一些
local CS_MgrTimer = CMgrTimer.Instance

-- [启动设置]
function MgrTimer.Init()
    CS_MgrTimer:Init()
end
function MgrTimer.Reset()
    CS_MgrTimer:CancelAllTimers()
end
-- api说明
-- name 定时器名称，重复名称不能加入
-- duration 时间
-- count 定时器循环次数，次数满足后定时器结束
-- complete 时间到了回调
-- update 定时器未结束 每帧回掉
-- loop 循环 说明--> ture：重复duration回调complete 无结束时间 | false：duration结束一次回调，定时器结束
-- usesrealtime 使用时间类型 说明--> true: 不受Time.timeScale控制，始终正常时间 | false ：受Time.timeScale控制，使用快进慢放的时间
-- autodesotryowner 说明--> 空：使用默认定时器生命周期 | 非空：如果传入的对象销毁了，定时器自动结束


function MgrTimer.AddRepeat(pName, pDuration, pOnRepeatCall, pRepeatCout, pAutoDestroyOwner)
    local count = 0
    if pRepeatCout then
        count = pRepeatCout
    end
    CS_MgrTimer:LuaAdd(pName, pDuration, count, pOnRepeatCall, nil, true, true, pAutoDestroyOwner)
end
function MgrTimer.Cancel(pName)
    CS_MgrTimer:Cancel(pName)
end
function MgrTimer.IsTimerExist(pName)
    return CS_MgrTimer:IsTimerExist(pName)
end
function MgrTimer.Pause(pName)
    CS_MgrTimer:Pause(pName)
end
function MgrTimer.Resume(pName)
    CS_MgrTimer:Resume(pName)
end
function MgrTimer.Add(pName, pDuration, pCount, pOnComplete, pOnUpdate, pIsLooped, pUsesRealTime, pAutoDestroyOwner)
    CS_MgrTimer:LuaAdd(pName, pDuration, pCount, pOnComplete, pOnUpdate, pIsLooped, pUsesRealTime, pAutoDestroyOwner)
end
--每个延迟都不同命
MgrTimer.NameIndex=1
function MgrTimer.AddDelayNoName( pDelay, pFunc, pAutoDestroyOwner)
    MgrTimer.NameIndex=MgrTimer.NameIndex+1
    CS_MgrTimer:LuaAdd("N".. MgrTimer.NameIndex, pDelay, 0, pFunc, nil, false, true, pAutoDestroyOwner)
end

function MgrTimer.AddBattleDelay(pName,pDelay, pFunc, pAutoDestroyOwner)
    CS_MgrTimer:LuaAdd_FixedUpData(pName, pDelay, 0, pFunc, nil, false, false, pAutoDestroyOwner)
end

---- pName 延迟器名   pDelay延迟时间  pFunc函数体 是否删除
function MgrTimer.AddDelay(pName, pDelay, pFunc, pAutoDestroyOwner)
    CS_MgrTimer:LuaAdd(pName, pDelay, 0, pFunc, nil, false, true, pAutoDestroyOwner)
end

function MgrTimer.AddDelayNotRealTime(pName, pDelay, pFunc, pAutoDestroyOwner)
    CS_MgrTimer:LuaAdd(pName, pDelay, 0, pFunc, nil, false, false, pAutoDestroyOwner)
end

-- 逻辑定时器
function MgrTimer.AddDelayLogic(pName, pDelay, pFunc, pAutoDestroyOwner)
    MgrTimer.AddDelay(pName, pDelay, pFunc, pAutoDestroyOwner)
end

function MgrTimer.ResetAll()
    CS_MgrTimer:ResetAll()
end