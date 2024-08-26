---剧情 VM
PlotViewModel = {}
---当前播放的剧情
PlotViewModel.curPlot = ""
PlotViewModel.curPlotPb = nil
PlotViewModel.isNotAutoBack = nil
---剧情播放完毕后回调
PlotViewModel.Callback = nil
---将要播放的剧情
PlotViewModel.CurPointData = nil
---初始化
function PlotViewModel.Init()

end
---进入剧情
---@param plot string 剧情名称
---@param callback function 剧情回调
---@param isGoClose boolean 是否使用GoClose
---@param isNotAutoBack boolean 是否关闭播放结束时使用GoBack
---@param isNovice boolean 是否关闭其他所有界面打开剧情
function PlotViewModel.OpenPlotUI(plot,callback,isGoClose,isNotAutoBack,isNovice)
    ---关掉系统公告界面
    SysNoticeControl.CloseSysNoticeUI()
    MgrSce.Load(MgrSce.Scenes.Battle,function()
        -- MgrRes.NowClearImmediate()
        if plot == nil or callback == nil then
            Log.Error("未指定剧情名称或结束事件")
            return
        end
        StormViewModel.IsPlotStarting = true
        PlotViewModel.curPlot = string.format("ABOriginal/Plot/PlotData/%s.plot.bytes",plot)
        print("打开剧情:"..PlotViewModel.curPlot)
        PlotViewModel.Callback = callback
        PlotViewModel.isNotAutoBack = isNotAutoBack
        MgrHot.PlotPackage(plot,function(data)
            print("剧情加载完毕，开始播放")
            PlotViewModel.curPlotPb = data
            MgrSound.StopAll()
            if isNovice == true then
                MgrUI.GoFirst(UID.Plot_UI)
            else
                if isGoClose == true then
                    MgrUI.GoFirst(UID.Plot_UI)
                else
                    MgrUI.GoHide(UID.Plot_UI)
                end
            end
        end)
    end)
end
---剧情播放结束
function PlotViewModel.PlotEnd()
    print("剧情播放结束，通知回调")
    MgrSound.StopAll()
    if PlotViewModel.isNotAutoBack ~= nil then
        if MgrUI.GetCurUI().Uid == UID.Plot_UI then
            MgrUI.GetCurUI().ObjRoot:SetActive(false)
        end
        PlotViewModel.Callback()
    else
        MgrUI.GoBack()
        MgrBattle.CloseFight(false, PlotViewModel.Callback)
    end
    StormViewModel.IsPlotStarting = false
    SysNoticeControl.CheckNotice(SysNoticeControl.SysNoticeData)
end

function PlotViewModel.Clear()
    PlotViewModel.curPlot = ""
    PlotViewModel.curPlotPb = nil
    PlotViewModel.isNotAutoBack = nil
    PlotViewModel.Callback = nil
    PlotViewModel.CurPointData = nil
end

return PlotViewModel