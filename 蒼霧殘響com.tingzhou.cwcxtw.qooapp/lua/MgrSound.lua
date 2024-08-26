---------------------------------------------------全局函数&变量---------------------------------------------------
-- 音频管理器
MgrSound = {}

local CMgrSound = CMgrAudio.Instance
---------------------------------------------------公开函数&变量---------------------------------------------------
-- [启动设置]
function MgrSound.Init()
    CMgrSound:Init()

    ---初始化默认音频
    MgrSound.AddCue("Audio/common/BGM.acb")
    MgrSound.AddCue("Audio/common/Effect.acb")
    MgrSound.AddCue("Audio/common/Fight.acb")
    MgrSound.AddCue("Audio/common/settingsample.acb")
    MgrSound.AddCue("Audio/common/Tutorial.acb")
end
---添加CueSheet
function MgrSound.AddCue(path)
    local str = string.lower(path)
    CMgrSound:AddCueSheet(str)
end
-- 移除CueSheet
function MgrSound.RemoveCue(path)
    local str = string.lower(path)
    CMgrSound:RemoveCurSheet(str)
end
---播放背景音乐
function MgrSound.PlayBGM(pName,volume,delay,isLoop,fadeIn,fadeOut,aid)
    local v = volume == nil and 1 or volume
    local d = delay == nil and 0 or delay
    local l = isLoop == nil and true or isLoop
    local fi = fadeIn == nil and 1000 or fadeIn
    local fo = fadeOut == nil and 1000 or fadeOut
    local a = aid == nil and "Normal" or aid
    CMgrSound:PlayBGM(pName, v, d, l, fi, fo, a)
end
---播放特效
function MgrSound.PlayEffect(pName,volume,delay,isLoop,fadeIn,fadeOut,aid)
    local v = volume == nil and 1 or volume
    local d = delay == nil and 0 or delay
    local l = isLoop == nil and true or isLoop
    local fi = fadeIn == nil and 1000 or fadeIn
    local fo = fadeOut == nil and 1000 or fadeOut
    local a = aid == nil and "Normal" or aid
    CMgrSound:PlayEffect(pName, v, d, l, fi, fo, a)
end
---播放角色语音
function MgrSound.PlayRole(pName,volume,delay,isLoop,fadeIn,fadeOut,aid)
    local v = volume == nil and 1 or volume
    local d = delay == nil and 0 or delay
    local l = isLoop == nil and true or isLoop
    local fi = fadeIn == nil and 1000 or fadeIn
    local fo = fadeOut == nil and 1000 or fadeOut
    local a = aid == nil and "Normal" or aid
    CMgrSound:PlayRole(pName, v, d, l, fi, fo, a)
end
---播放战斗音效
function MgrSound.PlayFight(pName,volume,delay,isLoop,fadeIn,fadeOut,aid)
    local v = volume == nil and 1 or volume
    local d = delay == nil and 0 or delay
    local l = isLoop == nil and true or isLoop
    local fi = fadeIn == nil and 1000 or fadeIn
    local fo = fadeOut == nil and 1000 or fadeOut
    local a = aid == nil and "Normal" or aid
    CMgrSound:PlayFight(pName, v, d, l, fi, fo, a)
end
---播放战斗音效（自动生成aid，每个音效独立存在）
function MgrSound.PlayFightLap(pName,volume,delay,isLoop,fadeIn,fadeOut)
    local v = volume == nil and 1 or volume
    local d = delay == nil and 0 or delay
    local l = isLoop == nil and true or isLoop
    local fi = fadeIn == nil and 1000 or fadeIn
    local fo = fadeOut == nil and 1000 or fadeOut
    CMgrSound:PlayFightLap(pName, v, d, l, fi, fo)
end
---播放剧情音效
function MgrSound.PlayPlot(pName,volume,delay,isLoop,fadeIn,fadeOut,aid)
    local v = volume == nil and 1 or volume
    local d = delay == nil and 0 or delay
    local l = isLoop == nil and true or isLoop
    local fi = fadeIn == nil and 1000 or fadeIn
    local fo = fadeOut == nil and 1000 or fadeOut
    local a = aid == nil and "Normal" or aid

    ---排除领航语音
    if SettingViewModel.GetPlotLH() == 2 then
        local find,_ = string.find(pName,"linghang")
        if find ~= nil then
            v = 0
        end
    end
    ---排除吉雅语音
    if SettingViewModel.GetPlotJY() == 2 then
        local find,_ = string.find(pName,"jiya")
        if find ~= nil then
            v = 0
        end
    end
    ---排除史蒂芬妮语音
    if SettingViewModel.GetPlotSDFN() == 2 then
        local find,_ = string.find(pName,"shidifenni")
        if find ~= nil then
            v = 0
        end
    end
    ---排除查丽莎语音
    if SettingViewModel.GetPlotCLS() == 2 then
        local find,_ = string.find(pName,"chalisha")
        if find ~= nil then
            v = 0
        end
    end
    ---排除朱利乌斯语音
    if SettingViewModel.GetPlotZLWS() == 2 then
        local find,_ = string.find(pName,"zhuliwusi")
        if find ~= nil then
            v = 0
        end
    end
    ---排除弗兰卡语音
    if SettingViewModel.GetPlotFLK() == 2 then
        local find,_ = string.find(pName,"fulanka")
        if find ~= nil then
            v = 0
        end
    end
    ---排除其他语音
    if SettingViewModel.GetPlotOther() == 2 then
        local isPlay = false
        local find,_ = string.find(pName,"linghang")
        if find ~= nil then
            isPlay = true
        end
        find,_ = string.find(pName,"jiya")
        if find ~= nil then
            isPlay = true
        end
        find,_ = string.find(pName,"shidifenni")
        if find ~= nil then
            isPlay = true
        end
        find,_ = string.find(pName,"chalisha")
        if find ~= nil then
            isPlay = true
        end
        find,_ = string.find(pName,"zhuliwusi")
        if find ~= nil then
            isPlay = true
        end
        find,_ = string.find(pName,"fulanka")
        if find ~= nil then
            isPlay = true
        end
        if isPlay == false then
            v = 0
        end
    end
    CMgrSound:PlayPlot(pName, v, d, l, fi, fo, a)
end
---移除战斗音效
function MgrSound.ClearFight()
    CMgrSound:ClearFightAudio()
end
---调整总音量
function MgrSound.SetAllVol(volume)
    CMgrAudio.Vol_All = volume
end
---调整背景音量
function MgrSound.SetBGMVol(volume)
    CMgrAudio.Vol_BGM = volume
end
---调整特效音量
function MgrSound.SetEffectVol(volume)
    CMgrAudio.Vol_Effect = volume
end
---调整角色音量
function MgrSound.SetRoleVol(volume)
    CMgrAudio.Vol_Role = volume
end
---调整战斗音量
function MgrSound.SetFightVol(volume)
    CMgrAudio.Vol_Fight = volume
end
---调整剧情音量
function MgrSound.SetPlotVol(volume)
    CMgrAudio.Vol_Plot = volume
end
---暂停/继续播放所有音频
function MgrSound.PauseAll()
    CMgrSound:PauseAll()
end
---暂停/继续播放指定音频
---@param type number 类型 1、背景音  2、特效音  3、角色音  4、战斗音  5、剧情音
---@param aid string 子类型（默认可不填）
function MgrSound.Pause(type,aid)
    local _aid = aid or ""
    if type == 1 then
        CMgrSound:PauseBGM(_aid)
    elseif type == 2 then
        CMgrSound:PauseEffect(_aid)
    elseif type == 3 then
        CMgrSound:PauseRole(_aid)
    elseif type == 4 then
        CMgrSound:PauseFight(_aid)
    elseif type == 5 then
        CMgrSound:PausePlot(_aid)
    end
end
---停止所有音频
function MgrSound.StopAll()
    CMgrSound:StopAll()
end
---停止指定音频
---@param type number 类型 1、背景音  2、特效音  3、角色音  4、战斗音  5、剧情音
---@param aid string 子类型（默认可不填）
---@param cFade boolean 淡入淡出状态时是否关闭
function MgrSound.Stop(type,aid,cFade)
    local _aid = aid or ""
    local fade = cFade == nil and true or cFade
    if type == 1 then
        CMgrSound:StopBGM(_aid,fade)
    elseif type == 2 then
        CMgrSound:StopEffect(_aid,fade)
    elseif type == 3 then
        CMgrSound:StopRole(_aid,fade)
    elseif type == 4 then
        CMgrSound:StopFight(_aid,fade)
    elseif type == 5 then
        CMgrSound:StopPlot(_aid,fade)
    end
end
---获取角色音频状态
function MgrSound.CheckRoleStatus(aid)
    local a = "Normal"
    if aid ~= nil then
        a = aid
    end
    return CMgrSound:CheckRoleStatus(a)
end
---获取剧情音频状态
function MgrSound.CheckPlotStatus(aid)
    local a = "Normal"
    if aid ~= nil then
        a = aid
    end
    return CMgrSound:CheckPlotStatus(a)
end
---获取指定音频状态
---@param type number 类型 1、背景音  2、特效音  3、角色音  4、战斗音  5、剧情音
---@param aid string 子类型（默认可不填）
---@return number 当前状态: -1未找到音效，0无音效，1准备中，2播放中，3播放结束，4播放错误
function MgrSound.CheckStatus(type,aid)
    local a = "Normal"
    if aid ~= nil then
        a = aid
    end
    return CMgrSound:CheckStatus(type,a)
end
