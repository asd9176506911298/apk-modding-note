MgrPool = {} -- 对象池管理器

-- C# Pool管理器接口 提供一些
local CS_MgrPool = CMgrPool.Instance

-- [启动设置]
function MgrPool.Init()
    -- [Todo] 调用C#接口
    CS_MgrPool:Setup()
end

-- 场景初始化的时候，预先加载对象及个数到对象池中，例如多个模型，英雄头像
-- 存入对象池 obj：游戏对象；num：数量
function MgrPool.PushMass(pObj, pNum)
    CS_MgrPool:PushToMass(pObj, pNum)
end
-- 从对象池读取 name:取出对象名称；funBack:将对象重置归还
function MgrPool.Get(pName, pFunResetBack)

end

function MgrPool.InitCache(pName, pMax)
    CS_MgrPool:InitCache(pName, pMax)
end
function MgrPool.ClearCache(pName)
    CS_MgrPool:ClearCache(pName)
end
-- 从缓冲池读取并且从缓存池中移除
function MgrPool.GetCache(pGroupName, pName, pParent)
    return CS_MgrPool:GetCache(pGroupName, pName, pParent)
end
-- 进入缓存池 group：缓存组（不同的组有不同的缓存策略）；obj：缓存对象
function MgrPool.PushCache(pGroup, pName, pGo)
    CS_MgrPool:PushToCache(pGo, pName, pGroup)
end

-- 将对象删除 obj：对象名称
function MgrPool.PushDestory(pObj, delay)
    if delay == nil then
        delay = 0
    end
    CS_MgrPool:PushToDestory(pObj, delay)
end
-- 立刻销毁所有
function MgrPool.Clear()
end