require("LocalData/LoadingtextLocalData")

MgrHot = {}
MgrHot.CS = CMgrHot.Instance
MgrHot.UpdateUI = nil
MgrHot.URL = ""
MgrHot.Manifest = ""
MgrHot.Asset_URL = ""
MgrHot.APK_URL = ""
MgrHot.PersistPath = ""
---本地版本
MgrHot.LocalVer = nil
---服务器版本
MgrHot.Ver = nil
---服务器资源依赖
MgrHot.Dep = nil
---下载总大小
MgrHot.allSize = 0
---已下载大小
MgrHot.curSize = 0
---初始化
function MgrHot.Init()
    print("初始化热更管理器")
    -- MgrHot.URL = MgrHot.CS:GetUrl().."/"
    -- MgrHot.Asset_URL = MgrHot.CS:GetAssetUrl()
    -- MgrHot.PersistPath = MgrHot.CS:GetResPath(true)
end
---初始化游戏资源
function MgrHot.Update(state)
    print("当前更新进度："..state)
    if state == 0 then
        ---获取本地版本文件
        MgrHot.LocalVer = MgrHot.CS:GetLocalVer()
        if MgrHot.LocalVer == nil then
            ---本地版本文件不存在，视为首次下载，下载压缩包
            MgrHot.GetServerPatchVer(function (isContiune, info)
                MgrHot.CS:SaveLocalPatchHash(info.hash)
                local persist = MgrHot.Combine(MgrHot.PersistPath,"first.cwcx")
                if not isContiune then
                    MgrHot.CS:DeleteFile(persist)
                end
                local size = (info.size - MgrHot.CS:GetFileLength(persist) / 1024) / 1024
                MgrUI.Pop(UID.UpdateConfirm_UI,{string.format(MgrLanguageData.GetLanguageByKey("mgrhot_tips1"), size),function ()
                    MgrHot.DownloadFirstZip(persist)
                end,nil,function ()
                    MgrSdk.QuitApp()
                end})
            end)
        else
            MgrHot.Update(1)
        end
    elseif state == 1 then
        ---获取服务器依赖文件
        local persist = MgrHot.Combine(MgrHot.PersistPath,"dep")
        local dep = MgrHot.Create(MgrHot.Asset_URL.."dep",nil,0,persist)
        dep:OnFinish(function(load,data)
            if load.IsError then
                ---下载失败重新下载
                print("Server dep not find!!! " .. MgrHot.Asset_URL.."dep")
                MgrHot.Update(0)
                return
            end
            ---给予dep文件
            MgrHot.Dep = MgrHot.CS:GetDep()
            ---获取服务器资源版本文件
            local load = MgrHot.Create(MgrHot.Asset_URL.."ver")
            load:OnFinish(MgrHot.DownloadVersion)
            load:OnProgress(MgrHot.ShowProgress)
            MgrHot.Add(load)
        end)
        dep:OnProgress(MgrHot.ShowProgress)
        MgrHot.Add(dep)
    elseif state == 2 then
        ---编辑器模式直接跳转
        --if MgrHot.CS:IsEditor() then
        --    MgrHot.LocalVer = MgrHot.CS:GetLocalVer()
        --    MgrHot.Update(4)
        --else
        --    ---对比下载需要的文件
        --    MgrHot.DownLoadAssets()
        --end
        MgrHot.DownLoadAssets()
    elseif state == 3 then
        ---检查版本是否需要重启
        MgrHot.GetServerVer(function(sVer)
            if MgrHot.LocalVer.ver ~= sVer then
                MgrHot.SaveLocalVer(sVer)
                MgrSdk.ReloadApp()
            else
                MgrHot.Update(4)
            end
        end)
    elseif state == 4 then
        ---进入游戏
        MgrHot.Login()
    elseif state == -1 then
        MgrHot.CheckAppVer()
    end
end
function MgrHot.DownloadFirstZip(persist)
    local zip = MgrHot.Create(MgrHot.Asset_URL.."first.cwcx",nil,0,persist,false,true)
    zip:OnFinish(function(load,data)
        if load.IsError then
            ---下载失败重新下载
            print("Server first not find!!! " .. MgrHot.Asset_URL.."first.cwcx")
            MgrHot.Update(0)
            return
        end
        ---1s后解压(若不做1秒延迟压缩包还在被占用的状态中)
        MgrTimer.AddDelayNoName(1,function()
            MgrHot.UnFirstZip(persist)
        end,nil)
    end)
    zip:OnProgress(function(pre, name, data)
        if MgrHot.allSize == 0 then
            MgrHot.allSize = (zip.Size - MgrHot.CS:GetFileLength(persist)) / 1024
        end
        MgrHot.ShowProgress(pre, name, {size = MgrHot.allSize})
    end)
    MgrHot.Add(zip)
end
---解压首次登陆资源包
function MgrHot.UnFirstZip(file)
    ---解压
    local locPre = 0.0001
    MgrHot.CS:UnZipFirstAsset(file,function(name)
        if locPre < 0.99 then
            locPre = locPre + 0.0002
        end
        MgrHot.ShowProgress(locPre,name,nil,2)
    end,function(result)
        if result == true then
            ---解压完成，生成本地版本文件
            MgrHot.CS:CreateLocalVer()
            ---删除压缩文件
            MgrHot.CS:DeleteFile(file)
            MgrHot.Update(1)
        else
            ---解压失败
            print("解压失败,请检查")
        end
    end)
end

---获取版本文件
function MgrHot.DownloadVersion(load,data)
    if load.IsError then
        ---下载失败重新下载
        print("Server ver not find!!! " .. MgrHot.Asset_URL.."ver")
        MgrHot.Update(1)
        return
    end
    MgrHot.Ver = load:GetVer()
    MgrHot.Update(2)
end
---获取更新资源文件
function MgrHot.DownLoadAssets()
    MgrHot.LocalVer = MgrHot.CS:GetLocalVer()
    ---获取下载列表
    local list = {}
    for i = 0, MgrHot.Ver.list.Count - 1 do
        local tmp = MgrHot.LocalVer:GetDataByFullName(MgrHot.Ver.list[i].fullName)
        local l_hash = tmp ~= nil and tmp.hash or nil
        ---若hash不存在或hash不同添加在下载列表
        if l_hash == nil or l_hash ~= MgrHot.Ver.list[i].hash then
            ---排除对应资源分包加载(需要分包别的资源自行添加)
            if string.find(MgrHot.Ver.list[i].fullName,"ABOriginal/Plot/PlotAssets") ~= nil then --排除剧情
            --elseif string.find(MgrHot.Ver.list[i].fullName,"ABOriginal/Role/") ~= nil then --排除角色
            --elseif string.find(MgrHot.Ver.list[i].fullName,"ABOriginal/Map/") ~= nil then --排除场景
            else
                ---添加到下载列表，通过lowName筛除相同资源
                list[#list + 1] = MgrHot.Ver.list[i]
            end
        end
    end

    local count = #list
    MgrHot.allSize = 0
    MgrHot.curSize = 0
    if count > 0 then
        ---创建下载
        local loadGroup = {}
        for i = 1, #list do
            MgrHot.allSize = MgrHot.allSize + list[i].size
            local url = MgrHot.Combine(MgrHot.Asset_URL, list[i].lowName)
            local persist = MgrHot.Combine(MgrHot.PersistPath, list[i].lowName)
            local load = MgrHot.Create(url, list[i],0,persist)
            load:OnFinish(MgrHot.DownLoadAsset)
            load:OnProgress(MgrHot.ShowProgress)
            table.insert(loadGroup,load)
        end
        MgrUI.Pop(UID.UpdateConfirm_UI,{string.format(MgrLanguageData.GetLanguageByKey("mgrhot_tips1"), MgrHot.allSize/1024),function ()
            ---添加下载组
            MgrHot.AddGroup(loadGroup,function(errorList)
                if errorList.Count > 0 then
                    ---下载失败处理：此处若异常一定是重下了30次后依旧失败
                    ---1.玩家网络条件极差的情况
                    ---2.资源服务器没有这份资源
                    ---弹窗通知资源异常
                    print("下载失败数量："..errorList.Count)
                    MgrUI.Pop(UID.ClosePop_UI,MgrLanguageData.GetLanguageByKey("mgrhot_tips2"),true)
                    return
                end
                ---组下载完毕，继续执行
                MgrHot.Update(3)
            end)
        end,nil,function ()
            MgrSdk.QuitApp()
        end})
    else
        ---无需下载，继续执行
        MgrHot.Update(3)
    end
end
---资源下载
function MgrHot.DownLoadAsset(load, data)
    if load.IsError then
        ---下载失败
        print("download data error!!! " ..load.Url)
        return
    else
        MgrHot.curSize = MgrHot.curSize + data.size
        ---保存本地版本
        MgrHot.CS:ReLocalVer(MgrHot.LocalVer,data)
    end
end
---显示进度
function MgrHot.ShowProgress(progress, name, data, type)
    if MgrHot.UpdateUI == nil then
        MgrHot.UpdateUI = MgrUI.GetPopUI(UID.Update_UI,nil)
    end
    local size = data == nil and 0 or data.size
    if MgrHot.UpdateUI == nil then
        MgrUI.Pop(UID.Update_UI,{progress, name, size, type},true)
    else
        MgrHot.UpdateUI:OnShow({progress, name, size, type})
    end
end
---获取服务器版本
function MgrHot.GetServerVer(cell)
    ---重新获取url
    MgrHot.Asset_URL = MgrHot.CS:GetAssetUrl()
    ---重新获取服务器版本文件
    local load = MgrHot.Create(MgrHot.Asset_URL.."ov")
    load:OnFinish(function(load, data)
        if load.IsError then
            ---获取版本失败，当作与本地版本相同
            print("获取版本失败，请检查!!!")
            cell(MgrHot.LocalVer.ver)
            return
        end
        ---获取版本成功，对比版本
        local ov = load:GetVer()
        cell(ov.ver)
    end)
    MgrHot.Add(load)
end

---修改本地版本<版本号>
function MgrHot.SaveLocalVer(ver)
    MgrHot.LocalVer.ver = ver
    MgrHot.CS:SaveLocalVer(MgrHot.LocalVer)
end

---获取服务器压缩包版本
function MgrHot.GetServerPatchVer(cell)
    ---重新获取url
    MgrHot.Asset_URL = MgrHot.CS:GetAssetUrl()
    ---重新获取服务器版本文件
    local load = MgrHot.Create(MgrHot.Asset_URL.."patchhash")
    load:OnFinish(function(load, data)
        if load.IsError then
            ---获取版本失败，重试
            print("获取压缩包版本失败，请检查!!!")
            MgrHot.Update(0)
            return
        end
        ---获取版本成功，对比版本
        local localHash = MgrHot.CS:GetLocalPatchHash()
        local remoteInfo = load:GetPatchHash()
        if localHash == "" or localHash ~= remoteInfo.hash then
            cell(false, remoteInfo)
            return
        end
        cell(true, remoteInfo)
    end)
    MgrHot.Add(load)
end

---创建下载
function MgrHot.Create(url, userData, timeOut, savePath, isLocal, isHeader)
    if timeOut == nil then
        timeOut = 30
    end
    if savePath == nil then
        savePath = ""
    end
    if isLocal == nil then
        isLocal = false
    end
    if isHeader == nil then
        isHeader = false
    end
    return MgrHot.CS:Create(url,userData,timeOut,savePath,isLocal,isHeader)
end

---添加到下载池
function MgrHot.Add(load)
    MgrHot.CS:Add(load)
end

---添加组到下载池
function MgrHot.AddGroup(loadList,cell)
    MgrHot.CS:AddGroup(loadList,cell)
end

---拼接路径
function MgrHot.Combine(s1,s2)
    return MgrHot.CS:Combine(s1,s2)
end

---跳转到登录
function MgrHot.Login()
    --关闭远程加载
    MgrHot.CS:ChangeOpenSA(false)
    --隐藏更新界面
    if MgrHot.UpdateUI ~= nil then
        MgrTimer.AddDelayNoName(1, function ()
            MgrHot.UpdateUI:OnHide()
        end)
    end

    -- 初始化各类管理器
    require 'Mgr/MgrSce'
    require "Mgr/MgrFx"
    require "Mgr/MgrNet"
    require "Mgr/MgrSound"
    require "Mgr/MgrTask"
    require "Mgr/MgrGuide"
    require "Mgr/MgrModel"
    require "Mgr/MgrVM"
    require "Mgr/MgrSce"

    -- 系统管理器启动
    MgrSce.Init()
    MgrNet.Init()
    MgrSound.Init()
    MgrFx.Init()
    MgrModel.Init()
    MgrVM.Init()


    ---通用脚本
    require("JNBattle/JNStrTool") ---战斗工具类
    require("UI/Base/TableToObject") ---表转对象工具
    require("UI/Base/UISysTools") ---工具类
    ---管理器
    require("JNBattle/BattleRole") ---战斗角色
    require("JNBattle/BattleManager") ---战斗管理器
    require("JNBattle/JNSkill") ---技能管理器

    require("ReadData/CollectionData").InitAllData() ---加载机娘数据并初始化,此脚本应该改为机娘管理器
    ---...
    ---各类通用配置
    require("LocalData/SteamLocalData")---系统杂项表
    require("LocalData/PlayheadLocalData")


    ---初始化登录模块
    LoginViewModel.Init()
    ---初始化剧情模块
    PlotViewModel.Init()
    ---开启更新自检
    -- MgrHot.StartAutoUpdate()

end

-------------------------自动更新器----------------------------------
function MgrHot.StartAutoUpdate()
    MgrHot.allSize = 0
    MgrHot.curSize = 0
    ---角色、地图、剧情更新器
    MgrTimer.AddRepeat("AutoUpdate",0,function()
        -- 去除角色热更新 2022/06/15
        -- ---@type UpdateAsset 角色更新
        -- local id,uRole = table.minn(MgrHot.RoleList)
        -- if uRole and not uRole.isStart then
        --     uRole.isStart = true

        --     ---组装移除方法
        --     local remove = function()
        --         for _, cell in pairs(uRole.cells) do
        --             cell()
        --         end
        --         MgrHot.RoleList[id] = nil
        --         ---添加角色音频
        --         MgrSound.AddCue("ABOriginal/Role/"..id.."/CriAcb/role.acb")
        --     end

        --     ---检查是否需要更新
        --     local hotList = MgrHot.CheckRoleUpdate(id)
        --     local count = #hotList
        --     if count > 0 then
        --         ---需要更新，更新完成后移除
        --         MgrHot.UpdatePackage(hotList,function()
        --             ---完成单个角色的下载了下载，移除队列
        --             remove()
        --         end)
        --     else
        --         ---不需要更新，直接移除
        --         remove()
        --     end
        -- end
        ---@type UpdateAsset 剧情更新
        local pName,uPlot = table.minn(MgrHot.PlotList)
        if uPlot and not uPlot.isStart then
            print("开始剧情更新资源")
            uPlot.isStart = true
            ---组装移除方法
            local remove = function()
                for _, cell in pairs(uPlot.cells) do
                    cell(uPlot.data)
                end
                MgrHot.PlotList[pName] = nil
                MgrSound.AddCue("Audio/plot/"..uPlot.name..".acb")
            end

            ---检查是否需要更新
            local hotList = MgrHot.CheckPlotUpdate(pName,uPlot.data)
            local count = #hotList
            if count > 0 then
                ---需要更新，更新完成后移除
                MgrHot.UpdatePackage(hotList,function()
                    ---完成下载，移除队列
                    print("下载剧情资源结束")
                    remove()
                end)
            else
                ---不需要更新，直接移除
                print("不需要更新剧情资源")
                remove()
            end
        end
        ---场景更新
        ---检查是否关闭更新界面
        if MgrHot.UpdateUI ~= nil then
            for i, v in pairs(MgrHot.RoleList) do
                return
            end
            for i, v in pairs(MgrHot.PlotList) do
                return
            end
            MgrHot.UpdateUI:OnHide()
        end
    end,-1,nil)

    ---重启检测器，检测是否有更新需要重启
    -- MgrTimer.AddRepeat("AutoUpdateReloadApp",60,function()
    --     -----登录界面跳过
    --     --if MgrUI.GetCurUI().Uid == UID.Login_UI then
    --     --    return
    --     --end
    --     print("检查是否需要更新重启")
    --     ---在更新角色时跳过
    --     for i, v in pairs(MgrHot.RoleList) do
    --         return
    --     end
    --     ---在更新剧情时跳过
    --     for i, v in pairs(MgrHot.PlotList) do
    --         return
    --     end
    --     ---在更新地图时跳过

    --     ---检查是否重启
    --     --if MgrHot.CS:IsEditor() then
    --     --    return
    --     --end
    --     MgrHot.GetServerVer(function(sVer)
    --         if MgrHot.LocalVer.ver ~= sVer then
    --             MgrUI.Pop(UID.ClosePop_UI,"领航，监测站告知有更新！",true)
    --         else
    --             print("与服务器版本相同,无更新")
    --         end
    --     end)
    -- end)
end

---更新包
function MgrHot.UpdatePackage(hotList, cell, notShow)
    local listGroup = {}
    local size = 0
    for _, verData in pairs(hotList) do
        size = size + verData.size
        local url = MgrHot.Combine(MgrHot.Asset_URL, verData.lowName)
        local persist = MgrHot.Combine(MgrHot.PersistPath, verData.lowName)
        local load = MgrHot.Create(url,verData,0,persist)
        load:OnFinish(MgrHot.Download)
        if not notShow then
            load:OnProgress(MgrHot.ShowProgress)
        end
        table.insert(listGroup,load)
    end
    MgrHot.allSize = MgrHot.allSize + size
    MgrHot.AddGroup(listGroup,function(errorList)
        if errorList.Count > 0 then
            ---下载失败处理：此处若异常一定是重下了30次后依旧失败
            ---1.玩家网络条件极差的情况
            ---2.资源服务器没有这份资源
            ---弹窗通知资源异常
            print("下载失败数量："..#errorList.Count)
            MgrUI.Pop(UID.ClosePop_UI,MgrLanguageData.GetLanguageByKey("mgrhot_tips2"),true)
            return
        end
        ---角色组下载完成
        MgrHot.allSize = MgrHot.allSize - size
        MgrHot.curSize = MgrHot.curSize - size
        cell()
    end)
end

function MgrHot.Download(load, data)
    if load.IsError then
        ---组下载失败
        print("download data error!!! " ..load.Url)
        return
    else
        MgrHot.curSize = MgrHot.curSize + data.size
        MgrHot.CS:ReLocalVer(MgrHot.LocalVer,data)
    end
end

---分析资源
function MgrHot.Analyse(fullNameList)
    local hotList = {}
    for fullName, _ in pairs(fullNameList) do
        ---检查服务器版本中是否存在
        local data = MgrHot.Ver:GetDataByFullName(fullName)
        if data ~= nil then
            ---服务器版本里存在,检查本地版本是否存在
            local localData = MgrHot.LocalVer:GetDataByFullName(fullName)
            if localData ~= nil then
                ---本地版本存在，对比hash
                if localData.hash ~= data.hash then
                    ---哈希不同，添加到待处理
                    hotList[#hotList + 1] = data
                else
                    ---哈希相同，不处理
                end
            else
                ---本地版本不存在添加到待处理
                hotList[#hotList + 1] = data
            end
        else
            ---服务器版本里不存在，不处理
        end
    end
    return hotList
end

-------------------------------动态更新角色资源加载-----------------------------------
---@class UpdateAsset 更新消息池<id,回调池> 用作相同不重复更新
---@field name string 名称
---@field cells function[] 回调池
---@field isStart boolean[] 是否已经开始检测
---@field data table 自定义参数
local UpdateAsset = {}
---@type UpdateAsset[] 角色消息池
MgrHot.RoleList = {}
---角色包
function MgrHot.RolePackage(id,cell)
    ---编辑器模式直接加载
    --if MgrHot.CS:IsEditor() then
    --    ---添加角色音频
    --    MgrSound.AddCue("ABOriginal/Role/"..id.."/CriAcb/role.acb")
    --    cell()
    --    return
    --end
    -- print("添加角色加载：" ..id)
    -- ---添加到角色消息池
    -- if MgrHot.RoleList[id] == nil then
    --     ---若池中没有则创建角色消息并添加回调
    --     MgrHot.RoleList[id] = {cells = {}}
    --     table.insert(MgrHot.RoleList[id].cells,cell)
    --     MgrHot.RoleList[id].isStart = false
    -- else
    --     ---若已存在则只添加回调
    --     table.insert(MgrHot.RoleList[id].cells,cell)
    -- end
    MgrSound.AddCue("Audio/role/"..id..".acb")
    if cell ~= nil then
        cell()
    end
end
---检查角色是否需要更新
function MgrHot.CheckRoleUpdate(id)
    ---角色资源组
    local nList = {
        ["ABOriginal/Role/"..id.."/WatchSpine/Watch_UI.prefab"] = 0,
        ["ABOriginal/Role/"..id.."/WatchSpine/Watch_3D.prefab"] = 0,
        ["ABOriginal/Role/"..id.."/FightSpine/Watch_UI.prefab"] = 0,
        ["ABOriginal/Role/"..id.."/FightSpine/Watch_3D.prefab"] = 0,
        ["ABOriginal/Role/"..id.."/WatchLive2D/live2D.prefab"] = 0,
        ["ABOriginal/Role/"..id.."/NormalIcon/normal.png"] = 0,
        ["ABOriginal/Role/"..id.."/HDIcon/hd.png"] = 0,
        ["ABOriginal/Role/"..id.."/RectIcon/rect.png"] = 0,
        ["ABOriginal/Role/"..id.."/LongIcon/long.png"] = 0,
        ["ABOriginal/Role/"..id.."/QIcon/q.png"] = 0,
        ["ABOriginal/Role/"..id.."/CircleIcon/cir.png"] = 0,
        ["ABOriginal/Role/"..id.."/FightIcon/fight.png"] = 0,
        ["ABOriginal/Role/"..id.."/CriAcb/role.acb"] = 0,
        ["ABOriginal/Role/"..id.."/CriUsm/role.usm"] = 0,
    }
    ---角色SpineUI依赖组
    local watchData = MgrHot.Dep:GetDataByFullName("ABOriginal/Role/"..id.."/WatchSpine/Watch_UI.prefab")
    if watchData then
        for i, v in pairs(watchData:GetAllDep()) do
            nList[v.fullPath] = 0
        end
    end
    watchData = MgrHot.Dep:GetDataByFullName("ABOriginal/Role/"..id.."/WatchSpine/Watch_3D.prefab")
    if watchData then
        for i, v in pairs(watchData:GetAllDep()) do
            nList[v.fullPath] = 0
        end
    end
    ---角色SpineFight依赖组
    local fightData = MgrHot.Dep:GetDataByFullName("ABOriginal/Role/"..id.."/FightSpine/Watch_UI.prefab")
    if fightData then
        for i, v in pairs(fightData:GetAllDep()) do
            nList[v.fullPath] = 0
        end
    end
    fightData = MgrHot.Dep:GetDataByFullName("ABOriginal/Role/"..id.."/FightSpine/Watch_3D.prefab")
    if fightData then
        for i, v in pairs(fightData:GetAllDep()) do
            nList[v.fullPath] = 0
        end
    end
    ---角色Live2D依赖组
    local live2DData = MgrHot.Dep:GetDataByFullName("ABOriginal/Role/"..id.."/WatchLive2D/live2D.prefab")
    if live2DData then
        for i, v in pairs(live2DData:GetAllDep()) do
            nList[v.fullPath] = 0
        end
    end
    ---分析资源
    return MgrHot.Analyse(nList)
end

--------------------------------动态更新剧情资源加载-----------------------------------
---@type UpdateAsset[] 剧情消息池
MgrHot.PlotList = {}
---剧情包
function MgrHot.PlotPackage(plot, cell)
    -- local pName = string.format("ABOriginal/Plot/PlotData/%s.plot",plot)
    -- if pName == nil and pName == "" then
    --     print("请先选择剧情")
    --     return
    -- end
    -- local byte = MgrRes.GetBytes(pName)
    -- local plotData = assert(pb.decode('PBPlot.Plot',byte))
    -- ---编辑器模式直接加载
    -- --if MgrHot.CS:IsEditor() then
    -- --    MgrSound.AddCue("ABOriginal/Plot/PlotAssets/Audio/"..plot..".acb")
    -- --    cell(plotData)
    -- --    return
    -- --end
    -- print("添加剧情加载")
    -- ---添加到角色消息池
    -- if MgrHot.PlotList[pName] == nil then
    --     ---若池中没有则创建角色消息并添加回调
    --     MgrHot.PlotList[pName] = { name = plot, cells = {}}
    --     table.insert(MgrHot.PlotList[pName].cells,cell)
    --     MgrHot.PlotList[pName].isStart = false
    --     MgrHot.PlotList[pName].data = plotData
    -- else
    --     ---若已存在则只添加回调
    --     table.insert(MgrHot.PlotList[pName].cells,cell)
    -- end
    local pName = string.format("ABOriginal/Plot/PlotData/%s.plot.bytes",plot)
    if pName == nil and pName == "" then
        print("请先选择剧情")
        return
    end
    local byte = MgrRes.GetBytes(pName)
    local plotData = assert(pb.decode('PBPlot.Plot',byte))
    MgrSound.AddCue("Audio/plot/"..plot..".acb")
    if cell ~= nil then
        cell(plotData)
    end
end
---检查剧情包是否需要更新
function MgrHot.CheckPlotUpdate(pName,data)
    local nList = {
        ["ABOriginal/Plot/PlotAssets/Image/Box/tongxunkuang(di).png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Box/tongxunkuang(shang).png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Common/ZZZ.UIMask.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Common/ZZZ.UIMask1.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Common/ZZZ.UIMask_1.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/00.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/00_w.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/01.jpg"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/01.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/01_w.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/02.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/03.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/04.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/05.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/06.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/07.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/Mask/08.png"] = 0,
        ["ABOriginal/Plot/PlotAssets/Image/DialogBox/DialogBox_0.png"] = 0,
    }
    ---剧情资源组
    for _, curtain in pairs(data.curtains) do
        ---添加背景
        for i, imageData in pairs(curtain.btmImages) do
            if imageData.path ~= "" and imageData.path ~= nil then
                local path = string.gsub(imageData.path,"Assets/PlotAssets/","ABOriginal/Plot/PlotAssets/")
                path = string.gsub(path," ","_")
                nList[path] = 0
            end
        end
        ---添加前景
        for i, imageData in pairs(curtain.topImages) do
            if imageData.path ~= "" and imageData.path ~= nil then
                local path = string.gsub(imageData.path,"Assets/PlotAssets/","ABOriginal/Plot/PlotAssets/")
                path = string.gsub(path," ","_")
                nList[path] = 0
            end
        end
        ---添加立绘
        for i, spineData in pairs(curtain.spines) do
            if spineData.path ~= "" and spineData.path ~= nil then
                local path = string.gsub(spineData.path,"Assets/PlotAssets/","ABOriginal/Plot/PlotAssets/")
                path = string.gsub(path," ","_")
                nList[path] = 0
            end
        end
        ---添加音效
        nList["ABOriginal/Plot/PlotAssets/Audio/"..Tools.GetFileName(pName)..".acb"] = 0
        ---添加剧本
        if curtain.drama.boxPath ~= "" and curtain.drama.boxPath ~= nil then
            local path = string.gsub(curtain.drama.boxPath,"Assets/PlotAssets/","ABOriginal/Plot/PlotAssets/")
            path = string.gsub(path," ","_")
            nList[path] = 0
        end
        ---添加视频
        for i, usmData in pairs(curtain.USMs) do
            if usmData.path ~= "" and usmData.path ~= nil then
                local path = string.gsub(usmData.path,"Assets/PlotAssets/Usm/","ABOriginal/Plot/PlotAssets/Usm/")
                path = string.gsub(path," ","_")
                nList[path] = 0
            end
        end
    end

    return nList
end
---加载剧情图片
function MgrHot.PlotSprite(fName, cell)
    --if MgrHot.CS:IsEditor() then
    --    cell()
    --    return
    --end
    local nList = {
        [fName] = 0
    }
    local hotList = MgrHot.Analyse(nList)
    if #hotList > 0 then
        MgrHot.UpdatePackage(hotList,function()
            ---完成下载
            cell()
        end,true)
    else
        ---无需下载
        cell()
    end
end

function MgrHot.DownloadPlotAssets(list, cell, force, closeCell)
    local temp = {}
    for id, _ in pairs(list) do
        local pName = string.format("ABOriginal/Plot/PlotData/%s.plot",id)
        if pName == nil and pName == "" then
            print("剧情文件不存在：", pName)
        else
            local byte = MgrRes.GetBytes(pName)
            local plotData = assert(pb.decode('PBPlot.Plot',byte))
            local info = MgrHot.CheckPlotUpdate(pName, plotData);
            for k, v in pairs(info) do
                if temp[k] == nil then
                    temp[k] = v
                end
            end
        end
    end
    local list = MgrHot.Analyse(temp)
    local count = #list
    MgrHot.allSize = 0
    MgrHot.curSize = 0
    if count > 0 then
        ---创建下载
        local loadGroup = {}
        for i = 1, #list do
            MgrHot.allSize = MgrHot.allSize + list[i].size
            local url = MgrHot.Combine(MgrHot.Asset_URL, list[i].lowName)
            local persist = MgrHot.Combine(MgrHot.PersistPath, list[i].lowName)
            local load = MgrHot.Create(url, list[i],0,persist)
            load:OnFinish(MgrHot.DownLoadAsset)
            load:OnProgress(MgrHot.ShowProgress)
            table.insert(loadGroup,load)
        end
        MgrUI.Pop(UID.UpdateConfirm_UI,{string.format(MgrLanguageData.GetLanguageByKey("mgrhot_tips1"), MgrHot.allSize/1024),function ()
            ---添加下载组
            MgrHot.AddGroup(loadGroup,function(errorList)
                if errorList.Count > 0 then
                    ---下载失败处理：此处若异常一定是重下了30次后依旧失败
                    ---1.玩家网络条件极差的情况
                    ---2.资源服务器没有这份资源
                    ---弹窗通知资源异常
                    print("下载失败数量："..errorList.Count)
                    MgrUI.Pop(UID.ClosePop_UI,MgrLanguageData.GetLanguageByKey("mgrhot_tips2"),true)
                    return
                end
                ---组下载完毕，继续执行
                MgrHot.UpdateUI:OnHide()
                cell()
            end)
        end,nil,function ()
            if force then
                MgrSdk.QuitApp()
            else
                if closeCell ~= nil then
                    closeCell()
                end
            end
        end})
    else
        ---无需下载，继续执行
        cell()
    end
end
--------------------------------动态更新地图资源加载-----------------------------------
---动态加载地图
function MgrHot.DynLoadMap()

end
---动态加载剧情相关
function MgrHot.DynLoadMap()

end

function MgrHot.CheckAppVer()
    local load = MgrHot.Create(MgrHot.Asset_URL.."ov.txt")
    load:OnFinish(function (load,data)
        if load.IsError then
            ---下载失败重新下载
            MgrUI.Pop(UID.ClosePop_UI,MgrLanguageData.GetLanguageByKey("mgrhot_tips3"),true)
            return
        end
        local ov = load:GetVer()
        local str = string.split(MgrHot.CS:GetAppVer(),".")
        local ver = str[1] * 1000 + str[2] * 100 + str[3]
        if ver ~= ov.appver then
            MgrUI.Pop(UID.UpdateApp_UI,MgrLanguageData.GetLanguageByKey("mgrhot_tips4"),true)
        else
            MgrHot.Update(0)
        end
    end)
    MgrHot.Add(load)
end

return MgrHot

