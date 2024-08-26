-- 全局变量
pb = require 'pb'
serpent = require 'PbTool/serpent'

RapidJson = require 'rapidjson'
--[[
RapidJsonAPI文档：https://github.com/xpol/lua-rapidjson/blob/master/API.md
简单用法示例：
    local testTab = {
        ["user_id"] = 1231324,
        ["timestamp"] = 3532523,
        ["cp_sign"] = "fdsfadfsaf",
        ["token"] = "fsadfasfasf0100210",
    }

    local testJs = RapidJson.encode(testTab)

    print(testJs)

    local testJt = RapidJson.decode(testJs)

    print(testJt.user_id)
]]

UIEvent = CS.UIEvent
GameObject = CS.UnityEngine.GameObject
UnityEngine = CS.UnityEngine
Vector2 = CS.UnityEngine.Vector2
Vector3 = CS.UnityEngine.Vector3
RectTransform = CS.UnityEngine.RectTransform
Quaternion = CS.UnityEngine.Quaternion
Color = CS.UnityEngine.Color
Mathf = CS.UnityEngine.Mathf
Input = CS.UnityEngine.Input
TouchPhase = CS.UnityEngine.TouchPhase

Tools = CS.Tools
CEXHead = CS.EXHead
CMgrUI = CS.CMgrUI
CMgrAudio = CS.CMgrAudio
CMgrFx = CS.CMgrFx
CMgrLua = CS.CMgrLua
CMgrNet = CS.CMgrNet
CMgrPool = CS.CMgrPool
CMgrRes = CS.CMgrRes
CMgrStory = CS.CMgrStory
CMgrTimer = CS.CMgrTimer
CMgrYim = CS.CMgrYim
CMgrHot = CS.CMgrHot
CMgrSdk = CS.CMgrSdk
CMgrScene = CS.CMgrScene
CMgrSpine = CS.CMgrSpine
CMgrCamera = CS.CMgrCamera
CMgrBattle = CS.CMgrBattle
CMgrChatNet = CS.CMgrChatNet
UIBattleChooseScroll = CS.UIBattleChooseScroll
CreatRoleData = CS.CreatRoleData
UIGirlCollection = CS.UIGirlCollection
CJNUIMgr = CS.CJNUIMgr
CJNBattleMgr = CS.CJNBattleMgr
CJNBattleLoop = CS.CJNBattleLoop
CAnimation = CS.CAnimation
CJNEffectShowMgr = CS.CJNEffectShowMgr
CBattleData = CS.CBattleData
UIScrollListener = CS.UIScrollListener
UISwitchGirlBtn = CS.UISwitchGirlBtn
CEffectVideo = CS.CEffectVideo
CMgrLanguage = CS.CMgrLanguage
CMgrLogicMap = CS.CMgrLogicMap

local Game = {}
---开始
function Game:Start()
    -- 初始化核心基础模块
    require 'Core/Class'
    require 'Core/Enum'
    require 'Core/Log'
    require 'Core/Event'
    require 'Core/Tool'
    require 'Core/MessageEvent'
    require 'Core/ServerError'
    require 'Core/Global'
    require 'Core/Bit2'

    -- 初始化UI及热更管理器
    require "Mgr/MgrRes"
    require "Mgr/MgrCamera"
    require "Mgr/MgrPool"
    require "Mgr/MgrTimer"
    require 'Mgr/MgrUI'
    require "Mgr/MgrHot"
    require "Mgr/MgrSdk"
    require "Mgr/MgrBattle"
    require "Mgr/MgrLink"
    require "Mgr/MgrLanguageData"
    require "Mgr/MgrChatNet"

    MgrRes.Init()
    MgrTimer.Init()
    MgrPool.Init()
    MgrUI.Init()
    MgrCamera.Init()
    MgrHot.Init()
    MgrSdk.Init()
    MgrBattle.Init()
    MgrLanguageData.Init()
    ---检查更新
    -- MgrHot.Update(-1)

    -- 直接启动
    MgrHot.Login()
end

return Game