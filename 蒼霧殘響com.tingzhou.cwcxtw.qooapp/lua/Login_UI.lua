-- Code Auto Create Begin
local M = Class('Login_UI', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.Login_UI
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[Login_UI].prefab'
    self.Name = 'Form[Login_UI]'
    self.Layer = UILayerLv.Normal
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Usm_Bg','Usm_Bg',2},{'Img_Logo','Img_Logo',2},{'Img_Touch','Img_Touch',2},{'Btn_Touch','Btn_Touch',2},{'Btn_Switch','RightPanel/Btn_Switch',2},{'Image','RightPanel/Btn_Switch/Image',2},{'Btn_Log','RightPanel/Btn_Log',2},{'Image01','RightPanel/Btn_Log/Image',2},{'Btn_Delete','RightPanel/Btn_Delete',2},{'Image02','RightPanel/Btn_Delete/Image',2},{'Btn_Fenxiang','RightPanel/Btn_Fenxiang',2},{'Image03','RightPanel/Btn_Fenxiang/Image',2},{'SharePanel','SharePanel',2},{'shareMask','SharePanel/shareMask',2},{'Panel','SharePanel/Panel',2},{'Img_Biaotixian','SharePanel/Panel/Img_Biaotixian',2},{'Btn_FB','SharePanel/Panel/Btn_FB',2},{'Img_FBicon','SharePanel/Panel/Btn_FB/Img_FBicon',2},{'FBRedDotIcon','SharePanel/Panel/Btn_FB/FBRedDotIcon',2},{'Btn_Discord','SharePanel/Panel/Btn_Discord',2},{'Img_Discordicon','SharePanel/Panel/Btn_Discord/Img_Discordicon',2},{'DiscordRedDotIcon','SharePanel/Panel/Btn_Discord/DiscordRedDotIcon',2},{'Btn_Line','SharePanel/Panel/Btn_Line',2},{'Img_Lineicon','SharePanel/Panel/Btn_Line/Img_Lineicon',2},{'LineRedDotIcon','SharePanel/Panel/Btn_Line/LineRedDotIcon',2},{'Img_Xian2','SharePanel/Img_Xian2',2},{'Img_Xian1','SharePanel/Img_Xian1',2},
        -- TextMeshProUGUI 列表
        {'Text_Ver','Text_Ver',20},{'Text_Touch','Img_Touch/Text_Touch',20},{'Text_Name','SharePanel/Panel/Text_Name',20},{'Text_FB','SharePanel/Panel/Btn_FB/Text_FB',20},{'Text_Discord','SharePanel/Panel/Btn_Discord/Text_Discord',20},{'Text_Line','SharePanel/Panel/Btn_Line/Text_Line',20},
    }
end
-- Code Auto Create End
function M:OnInit()
    CJNBattleMgr.SetGameSpeed(1)
    self.isLogin = false
    self.isFastLogin = false
    local isTouchStart = false
    ---设置所有音量
    SettingViewModel.SetAllSound(SettingViewModel.GetAllSound())
    ---设置背景音量
    SettingViewModel.SetBGMSound(SettingViewModel.GetBGMSound())
    ---设置音效音量
    SettingViewModel.SetEffectSound(SettingViewModel.GetEffectSound())
    ---设置语音音量
    SettingViewModel.SetRoleSound(SettingViewModel.GetRoleSound())
    ---播放bgm
    MgrSound.PlayBGM(SteamLocalData.tab[113021][2],0.2)
    ---协议
    --self.isAgree = true
    --Tools.ToggleValueChange(self.Tog_Agree01(),function(isOn)
    --    self.isAgree = isOn
    --end,nil)
    self.Text_Ver().text = "Ver"..MgrHot.CS:GetAppVer()
    ---打开登录
    UIEvent.LuaClick(self.Btn_Touch().gameObject,function()
        --if not self.isAgree then
        --    MgrUI.Pop(UID.PopTip_UI,{"请先同意用户协议",1},true)
        --    return
        --end
        if MgrSdk.IsFlyFun() then
            if self.isLogin then
                self:ConnectServer()
                -- if not isTouchStart then
                --     isTouchStart = true
                --     ---点击“TOUCH TO STSRT”
                --     if MgrSdk.IsFlyFunQoo() then
                --         MgrSdk.FlyFunTrackEvent("hjz4br","ce_start_adventure")
                --     else
                --         MgrSdk.FlyFunTrackEvent("s2o2zs","ce_start_adventure")
                --     end
                -- end
            else
                -- self:ShowSdkLogin(not MgrSdk.isSwitchAccount)
                if not LoginViewModel.HasLocalAccount() then
                    MgrNet.HttpFastLogin(Handle(self, self.FastLoginReq))
                end
            end
        else
            MgrUI.Pop(UID.LoginPop_UI,{1},true)
        end
    end)
    ---检查客户端修复
    --UIEvent.LuaClick(self.Btn_Setting().gameObject,function()
    --    MgrUI.Pop(UID.ConfirmPop_UI,{"检查客户端完整性<color=#FF3C4E>约耗时10分钟</color>",function()
    --        MgrUI.Pop(UID.PopTip_UI,{"开发中",1},true)
    --    end,nil,2},true)
    --end)
    ---显示公告
    UIEvent.LuaClick(self.Btn_Log().gameObject,function()
        MgrUI.Pop(UID.GongGaoPop, { "login" })
        --MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("login_ui_develop"),1},true)
    end)
    ---切换账户
    UIEvent.LuaClick(self.Btn_Switch().gameObject,function()
        if MgrSdk.IsFlyFun() then
            if MgrSdk.GetPlatform() == "1" then
                MgrUI.Pop(UID.PartLoading_UI,1,true)
                MgrSdk.FlyFunLogout(function(code,request)
                    if code == 0 then
                        self.isLogin = false;
                        self:ShowSdkLogin(false)
                    else
                        ---飞游登出失败, 打印code及异常信息并关闭登录窗
                        UnityEngine.DebugEx.LogError("FlyFunLogout failed:"..code..":"..request)
                    end
                end)
            else
                --引继码输入框
                MgrUI.Pop(UID.LoginPop02_UI)
            end
        else
            MgrUI.Pop(UID.LoginPop_UI,{2},true)
        end
    end)
    ---Btn_FB
    --UIEvent.LuaClick(self.Btn_FB().gameObject,function()
    --    Tools.OpenUrl("http://www.facebook.com/groups/3kingdoms.fun")
    --end)
    --删除账号
    UIEvent.LuaClick(self.Btn_Delete().gameObject,function()
        if MgrSdk.IsFlyFun() then
            -- MgrSdk.FlyFunDelAcc(function(request)
            --     if request == "0" then
            --         self.isLogin = false;
            --         self:ShowSdkLogin(false)
            --     end
            -- end)
            if MgrSdk.GetPlatform() == "2" then
                MgrUI.Pop(UID.ConfirmPop_UI,{MgrLanguageData.GetLanguageByKey("ui_qita_text130"),function()
                    local localInfo = LoginViewModel.GetLocalAccount()
                    MgrNet.HttpUnbindSdk(localInfo.userID, MgrSdk.platform.Password, localInfo.account, localInfo.pwd, function (result)
                        if result.code == 1 then
                            print("zqx unbind success")
                            self.isLogin = false
                            LoginViewModel.DelLocalAccount()
                            self.Btn_Log().gameObject:SetActive(false)
                            self.Btn_Delete().gameObject:SetActive(false)
                        else
                            UnityEngine.DebugEx.LogError("zqx unbind error:"..serpent.block(result))
                        end
                    end)
                end,nil,2},true)
            end
        end
    end)
    self.SharePanel().gameObject:SetActive(false)
    UIEvent.LuaClick(self.Btn_Fenxiang().gameObject,function()
        self.SharePanel().gameObject:SetActive(true)
    end)
    UIEvent.LuaClick(self.shareMask().gameObject,function()
        self.SharePanel().gameObject:SetActive(false)
    end)
    UIEvent.LuaClick(self.Btn_FB().gameObject,function()
        Tools.OpenUrl("https://www.facebook.com/hazereverb/")
    end)
    UIEvent.LuaClick(self.Btn_Line().gameObject,function()
        Tools.OpenUrl("https://line.me/ti/g2/HLES3FK6gFC1rz1jgC4BVzRSEmzszBWWn40pMA?utm_source=invitation&utm_medium=link_copy&utm_campaign=default")
    end)
    UIEvent.LuaClick(self.Btn_Discord().gameObject,function()
        Tools.OpenUrl("https://discord.gg/ayf9Xp7d37")
    end)

    ---播放视频背景
    local criMana = self.Usm_Bg().gameObject:GetComponent("CriManaMovieControllerForUI")
    criMana.player:SetFile(nil,MgrRes.GetABPath("USM/Common/Common/title-A.usm"))
    criMana:Play()
end

function M:OnShowFinish()
    Event.Add("BackKey", Handle(self, self.OnBackKey))
    Event.Add("LoginSuccess", Handle(self, self.OnLoginSuccess))
    ---登录创建完成后销毁检测更新界面
    LoginViewModel.CloseCheckUpdate()
    ---创建PartLoading_UI
    MgrUI.Pop(UID.PartLoading_UI,1,true)
    --self.Btn_FB().gameObject:SetActive(false)
    self.Btn_Log().gameObject:SetActive(false)
    self.Btn_Switch().gameObject:SetActive(MgrSdk.GetPlatform() ~= "1")
    self.Btn_Delete().gameObject:SetActive(false)
    self.Btn_Fenxiang().gameObject:SetActive(false)
    MgrTimer.AddDelayNoName(0.5, function ()
        if MgrSdk.IsFlyFun() then
            if MgrSdk.GetPlatform() == "1" then
                ---弹sdk登录
                self:ShowSdkLogin(not MgrSdk.isSwitchAccount)
            else
                if MgrSdk.isSwitchAccount then
                    self.isLogin = true
                    self.Btn_Log().gameObject:SetActive(true)
                    self.Btn_Switch().gameObject:SetActive(true)
                    if MgrSdk.GetPlatform() == "2" then
                        self.Btn_Delete().gameObject:SetActive(true)
                    else
                        self.Btn_Delete().gameObject:SetActive(false)
                    end
                    --引继码输入框
                    MgrUI.Pop(UID.LoginPop02_UI)
                    return
                end
                if LoginViewModel.HasLocalAccount() then
                    local info = LoginViewModel.GetLocalAccount()
                    print("zqx auto login:"..serpent.block(info))
                    -- MgrNet.HttpLogin("Password",info.account,info.pwd,Handle(self,self.LoginReq))
                    MgrSdk.sdkUserInfo.platform = MgrSdk.platform.Password
                    MgrSdk.sdkUserInfo.openid = info.account
                    MgrSdk.sdkUserInfo.token = info.pwd
                    MgrNet.HttpSdkLogin(MgrSdk.platform.Password,info.account,info.pwd,Handle(self,self.LoginReq))
                end
            end
        end
    end)
end

function M:ShowSdkLogin(isAuto)
    --self.Btn_FB().gameObject:SetActive(false)
    self.Btn_Log().gameObject:SetActive(false)
    self.Btn_Switch().gameObject:SetActive(false)
    self.Btn_Delete().gameObject:SetActive(false)
    MgrSdk.FlyFunLogin(isAuto, function(code,request)
        if code == 0 then
            self.isLogin = true;
            MgrSdk.isSwitchAccount = false
            ---飞游登录成功，打印用户信息
            UnityEngine.DebugEx.LogError("FlyFunLogin success:"..code..":"..request)
            local json = RapidJson.decode(request)
            MgrSdk.sdkUserInfo.platform = MgrSdk.platform.Qoo
            MgrSdk.sdkUserInfo.openid = json.data.user_id
            MgrSdk.sdkUserInfo.token = json.data.user_id
            -- MgrSdk.flyUserInfo = RapidJson.decode(request)
            MgrNet.HttpSdkLogin(MgrSdk.sdkUserInfo.platform,MgrSdk.sdkUserInfo.openid,MgrSdk.sdkUserInfo.token,Handle(self,self.LoginReq))
        else
            ---飞游登录失败, 打印code及异常信息并关闭登录窗
            UnityEngine.DebugEx.LogError("FlyFunLogin failed:"..code..":"..request)
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips30"), function ()
                self:LoginError()
            end},true)
        end
    end)
end

function M:LoginReq(info)
    -- print("zqx LoginReq:"..serpent.block(info))
    if info.errNo == 0 then
        self.isLogin = true
        self.isFastLogin = false
        --self.Btn_FB().gameObject:SetActive(true)
        self.Btn_Log().gameObject:SetActive(true)
        self.Btn_Switch().gameObject:SetActive(true)
        if MgrSdk.GetPlatform() == "2" then
            self.Btn_Delete().gameObject:SetActive(true)
        else
            self.Btn_Delete().gameObject:SetActive(false)
        end
        ---@type UserInfo 保存输入
        local user = {
            name = info.account,
            userId = info.userID,
            token = info.token,
            gate = info.addrGate
        }
        MgrNet.verifyInfo = user
        ---储存本地账号信息
        LoginViewModel.SaveLocalAccount(info)
        ---检查服务器公告版本一致性
        NoticeControl.CheckVersion(info.noticeVersion)
        ---跳公告界面
        LoginViewModel.FirstLoginNotice(info.userID)
        MgrNet.IsSocket = false
    else
        if info.errNo == 20000 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("servererror_tips20000"), function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        elseif info.errNo == 20001 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips17"), function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        elseif info.errNo == 20002 then
            MgrUI.Pop(UID.NoticePop_UI, {info.errMsg, function ()
                MgrSdk.QuitApp()
            end}, true)
        else
            ---登录失败
            local str = MgrLanguageData.GetLanguageByKey("loginpop_ui_tips18")..string.format(":(%d)",info.errNo)
            MgrUI.Pop(UID.ClosePop_UI,{str, function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        end
    end
end

function M:FastLoginReq(info)
    if info.errNo == 0 then
        self.isLogin = true
        self.isFastLogin = true
        --self.Btn_FB().gameObject:SetActive(true)
        self.Btn_Log().gameObject:SetActive(true)
        -- self.Btn_Switch().gameObject:SetActive(true)
        if MgrSdk.GetPlatform() == "2" then
            self.Btn_Delete().gameObject:SetActive(true)
        else
            self.Btn_Delete().gameObject:SetActive(false)
        end
        ---@type UserInfo 保存输入
        local user = {
            name = info.account,
            userId = info.userID,
            token = info.token,
            gate = info.addrGate
        }
        MgrNet.verifyInfo = user
        ---储存本地账号信息
        LoginViewModel.SaveLocalAccount(info)
        MgrNet.IsSocket = false
        self:ConnectServer()
    else
        if info.errNo == 20000 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("servererror_tips20000"), function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        elseif info.errNo == 20001 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips17"), function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        elseif info.errNo == 20002 then
            MgrUI.Pop(UID.NoticePop_UI, {info.errMsg, function ()
                MgrSdk.QuitApp()
            end}, true)
        else
            ---登录失败
            local str = MgrLanguageData.GetLanguageByKey("loginpop_ui_tips18")..string.format(":(%d)",info.errNo)
            MgrUI.Pop(UID.ClosePop_UI,{str, function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        end
    end
end

function M:ConnectServer()
    if MgrNet.IsSocket then
        return
    end
    if not MgrNet.ConnectServer(Handle(self,self.LauncherGameReq),Handle(self,self.LauncherGameAck),Handle(self,self.LauncherGameNtf)) then
        ---验证失败（网络异常或未保存token）
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"), function ()
            -- self:ShowSdkLogin(false)
            self:LoginError()
        end},true)
    end
end

---进入游戏Req
function M:LauncherGameReq(err,msgId)
    if err == false then
        ---网络异常处理
        MgrNet.IsSocket = false
        MgrUI.Pop(UID.PopTip_UI,{string.format(MgrLanguageData.GetLanguageByKey("mgrnet_tips1"),err),1},true)
    end
end
---进入游戏Ack
function M:LauncherGameAck(buffer, tag)
    local info = assert(pb.decode('PBClient.ClientVerifyACK',buffer))
    if info.errNo ~= 0 then
        ---失败
        MgrNet.IsSocket = false
        if info.errNo >= 20000 then
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("servererror_tips20000"),1},true)
        else
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"), function ()
                self:LoginError()
                -- self:ShowSdkLogin(false)
            end},true)
        end
    end
end
---进入游戏Ntf
function M:LauncherGameNtf(buffer, tag)
    local info = assert(pb.decode('PBClient.ClientVerifyNTF',buffer))
    print("登录推送："..serpent.block(info)) ---查看table内容
    if info.errNo == 0 then
        MgrNet.IsLogin = true
        ---更新网关推送数据
        MgrModel.PushData(info, false)
        local localInfo = LoginViewModel.GetLocalAccount()
        local status = UnityEngine.PlayerPrefs.GetString(localInfo.account .. "_Platform9000")
        if status ~= "bind" then
            MgrNet.HttpBindSdk(info.userID, MgrSdk.platform.Password, localInfo.account, localInfo.pwd, function (result)
                UnityEngine.PlayerPrefs.SetString(localInfo.account .. "_Platform9000", "bind")
                if result.code == 1 then
                    print("zqx bind success")
                else
                    UnityEngine.DebugEx.LogError("zqx bind error:"..serpent.block(result))
                end
            end)
        end
        if MgrUI.GetCurUI().Uid == UID.Login_UI then
            ---跳转到大厅
            LoginViewModel.EnterHome()
            ---Qoo恢復已購商品
            MgrSdk.CS:RestorePurchase()
            ShopViewModel.RestoreIOS()
        end
    else
        ---验证失败（服务器未通过）
        MgrNet.IsSocket = false
        UnityEngine.DebugEx.LogError("连接tcp失败"..info.errNo)
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"),function ()
            self:LoginError()
            -- self:ShowSdkLogin(false)
        end},true)
    end
end

function M:LoginError()
    if MgrSdk.GetPlatform() == "1" then
        ---弹sdk登录
        self:ShowSdkLogin(false)
    end
end

function M:OnBackKey()
    print("Login OnBackKey:", MgrUI.IsPopOpen())
    local isSharePanel = self.SharePanel().gameObject.activeSelf --分享选择界面是否打开

    if not MgrUI.IsPopOpen() then --没有pop打开
        if isSharePanel then
            self.SharePanel().gameObject:SetActive(false)
            return
        else
            MgrSdk.CS:ShowExitView()
        end
    end
end

function M:OnLoginSuccess()
    self.isLogin = true
    self.isFastLogin = false
    --self.Btn_FB().gameObject:SetActive(true)
    self.Btn_Log().gameObject:SetActive(true)
    -- self.Btn_Switch().gameObject:SetActive(true)
    if MgrSdk.GetPlatform() == "2" then
        self.Btn_Delete().gameObject:SetActive(true)
    else
        self.Btn_Delete().gameObject:SetActive(false)
    end
end

function M:OnClose()
    Event.Remove("BackKey", Handle(self, self.OnBackKey))
    Event.Remove("LoginSuccess", Handle(self, self.OnLoginSuccess))
end

return M