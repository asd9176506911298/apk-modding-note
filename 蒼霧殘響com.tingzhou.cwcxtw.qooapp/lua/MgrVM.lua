MgrVM = {}
--------视图模型初始化---------
function MgrVM.Init()
    require("UI/ViewModel/LoginViewModel")
    require("UI/ViewModel/PlotViewModel")
    require("UI/ViewModel/SettingViewModel")
    require("UI/ViewModel/PostMailViewModel")---邮件
end

return MgrVM