MgrNet = {}
MgrNet.CS = CMgrNet.Instance
---@class UserInfo
local userInfo = {
    name = "",
    password = "",
    userId = 0,
    token = "",
    gate = "",
}

---@type UserInfo Tcp校验信息
MgrNet.verifyInfo = {}

MgrNet.ipArr = {
    -- {"192.168.20.105", "192.168.20.105:8100", "192.168.20.105:8200"},
    -- {"192.168.20.53", "192.168.20.53:8100", "192.168.20.53:8200"},
    -- {"192.168.20.253", "192.168.20.253:8100", "192.168.20.253:8200"},
    -- {"47.103.127.62", "47.103.127.62:8100", "47.103.127.62:8200"},
    -- {"175.97.182.23", "175.97.182.23:8100", "175.97.182.23:8200"},
    -- {"139.196.93.228", "139.196.93.228:8100", "139.196.93.228:8200"},
    -- {"flyfun", "cw-login.sjgcnb.com", "cw-feiyoupay.sjgcnb.com"},
}

MgrNet.CacheInfo = {}
MgrNet.ResendMID = {                    -- 需要重发的协议ID
    -- MID.CLIENT_SET_LEVEL_STAR_EX_REQ,
    -- MID.CLIENT_HIGH_LADDER_BATTLE_EX_REQ,
    -- MID.CLIENT_TOWER_BATTLE_REQ,
    -- MID.CLIENT_GUIDE_BATTLE_REQ,
    MID.CLIENT_CHOOSE_BATTLE_REWARD_REQ,
    MID.CLIENT_TOWER_REWARD_REQ,
    MID.CLIENT_GUIDE_REWARD_REQ,
    MID.CLIENT_CHOOSE_LADDER_BATTLE_REWARD_REQ,
    MID.CLIENT_SET_LEVEL_STAR_REQ,
    MID.CLIENT_SAVE_PROGRESS_REQ,
}

MgrNet.DrawRepeat = false

MgrNet.LoginInit = false;
MgrNet.IsSocket = false
MgrNet.IsLogin = false

---获取登录服地址
function MgrNet.GetCurLoginServer()
    -- ---是否为开发模式
    -- if MgrNet.CS:GetIsDevelopment() == 1 then
    --     ---开发模式返回选择的ip
    --     local idx = MgrNet.CS:GetIpIndex()
    --     return MgrNet.ipArr[idx][2]
    -- else
    --     ---正式模式直接返回正式服ip
    --     return MgrNet.ipArr[7][2]
    -- end
    return MgrNet.CS:GetCurLoginServer()
end

---获取支付服地址
function MgrNet.GetCurPayServer()
    -- ---是否为开发模式
    -- if MgrNet.CS:GetIsDevelopment() == 1 then
    --     ---开发模式返回选择的ip
    --     local idx = MgrNet.CS:GetIpIndex()
    --     return MgrNet.ipArr[idx][3]
    -- else
    --     ---正式模式直接返回正式服ip
    --     return MgrNet.ipArr[7][3]
    -- end
    return MgrNet.CS:GetCurPayServer()
end

---消息缓存池（作用：相同消息id发送后，只有在收到消息或超时后才能再次发送，超时时间暂定为5秒）
MgrNet.CacheMsg = {}
---Socket请求(消息id，消息内容，标识，请求回调，接收验证回调，接收数据回调)
---发送请求（ACK委托给MgrNet.ReceiveError） 备注：tcp报文格式为[消息长度，消息id，自定义内容，用户id]16B(固定4*4) + [proto消息内容]65535B(最大值),报文拼接已在C#的CMgrNet实现
---@param msgId number 消息id（必填）
---@param buffer userdata 使用pb转换过的消息流（必填）
---@param tag number 标签，会在ack及ntf回调中原样返回，可用于业务逻辑自定义，不用时填0
---@param ReqFunc function 发送消息完成后的回调,不使用填nil
---@param ACKFunc function 服务器返回的确认回调,只包含了服务器对消息的处理状况Error,不使用填nil
---@param NTFFunc function 服务器返回的具体数据,不使用填nil
function MgrNet.SendReq(msgId, buffer, tag, ReqFunc, ACKFunc, NTFFunc)
    ---检查是否存在未结束的消息
    if MgrNet.CacheMsg[msgId + 1] ~= nil or MgrNet.CacheMsg[msgId + 2] ~= nil then
        Log.Error("请勿频繁发送消息")
        return
    end
    print("发送消息 ID: "..msgId.." ,Buffer:"..pb.tohex(buffer))
    if tag ~= nil and type(tag) ~= "number" then
        Log.Error('tag只能是number')
        return
    end

    MgrUI.Pop(UID.PartLoading_UI,nil,true)

    if MgrNet.IsResendReq(msgId) then
        UnityEngine.DebugEx.LogError("zqx set need reconnect req:"..msgId)
        MgrNet.CacheInfo = {}
        MgrNet.CacheInfo.msgId = msgId
        MgrNet.CacheInfo.buffer = buffer
        MgrNet.CacheInfo.tag = tag
        MgrNet.CacheInfo.ReqFunc = ReqFunc
        MgrNet.CacheInfo.ACKFunc = ACKFunc
        MgrNet.CacheInfo.NTFFunc = NTFFunc
    end

    if msgId ~= MID.CLIENT_RECONNECT_REQ then
        if msgId == MID.CLIENT_RECRUIT_REPEAT_REQ or msgId == MID.CLIENT_RECRUIT_REQ then
            MgrNet.DrawRepeat = true
        else
            MgrNet.DrawRepeat = false
        end
    end

    ---ACK统一打印
    MessageEvent.Add(msgId + 1,function(...)
        MgrNet.ReceiveACKLog(msgId,...)
    end)
    ---ACK回调，为空不添加
    if ACKFunc then
        MessageEvent.Add(msgId + 1,function(...)
            MgrNet.ReceiveACKLog(msgId,...)
            ACKFunc(...)
        end)
        ---记录消息占用
        MgrNet.CacheMsg[msgId + 1] = true
    end

    ---NTF回调，为空不添加
    if NTFFunc then
        MessageEvent.Add(msgId + 2, function (...)
            NTFFunc(...)
            ---将id从消息池中移除
            print("移除占用"..(msgId + 2))
            MgrNet.CacheMsg[msgId + 2] = nil
        end)
        ---记录消息占用
        MgrNet.CacheMsg[msgId + 2] = true
    end

    ---发送消息
    MgrNet.CS:SendReq(msgId,tag or -1,MgrNet.verifyInfo.userId,buffer,function(...)
        ---重置战斗结算
        FightVideoViewModel.isReturning = false
        ---消息发送回调统一打印
        MgrNet.SendError(...)
        ---Req回调，为空不通知
        if ReqFunc then
            ReqFunc(...)
        end
    end)
end

---注册推送消息,注册后服务器将会对推送消息到此接口
---@param msgId number 消息id
---@param callFunc function 推送回调
function MgrNet.RegisterNTF(msgId, callFunc)
    MessageEvent.Add(msgId, callFunc)
end

---Socket数据分发,所有收到的消息将在此处转发
---@param mid number 消息id
---@param tag number 标签
---@param userId number 用户id
---@param buffer userdata 需要pb转换的消息流
function MgrNet.ReceiveReq(mid,tag,userId,buffer)
    print("ReceiveMsgId = "..mid.." ,ReceiveTag = "..tag.." ,ReceiveUserId = "..userId)
    ---收到消息，将id从消息池中移除
    -- MgrNet.CacheMsg[mid] = nil
    -- print("移除占用"..mid)
    ---分发消息
    MessageEvent.Go(mid,buffer,tag)
end

---ACK统一打印
function MgrNet.ReceiveACKLog(msgId, buffer, tag)
    local table = assert(pb.decode('PBClient.ClientVerifyACK',buffer))
    if table.errNo == 0 then
        print(msgId.."消息ACK成功")
        ---将id从消息池中移除
        print("移除占用"..(msgId + 1))
        MgrNet.CacheMsg[msgId + 1] = nil
    else
        Log.Error("消息接收失败,错误原因:"..(ServerError[table.errNo] or table.errNo))
        ---将id从消息池中移除
        print("移除占用"..(msgId + 1))
        MgrNet.CacheMsg[msgId + 1] = nil
        print("移除占用"..(msgId + 2))
        MgrNet.CacheMsg[msgId + 2] = nil
    end
    if MgrNet.IsResendReq(msgId) then
        MgrNet.CacheInfo = {}
    end
    MgrUI.PopHide(UID.PartLoading_UI)
end

---统一处理请求回调接口
---@param err userdata 错误信息
---@param msgId number 消息id
function MgrNet.SendError(err,msgId)
    if msgId == MID.HEARTBEAT then
        ---心跳消息
        if err == false then
            Log.Error("心跳发送失败")
            ---重连
            -- MgrNet.ReConnect()
        end
    else
        ---其他消息
        if err == true then
            print("消息发送成功")
        else
            -- MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips1"),1},true)
            Log.Error("消息发送失败")
            ---将异常消息移除消息池
            MgrNet.CacheMsg[msgId] = nil
            ---重连
            -- MgrNet.ReConnect()
        end
    end
end

---Get请求(完整url，回调)
function MgrNet.HttpGet(url,luaFun)
    --cs端方法
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    MgrNet.CS:HttpGet(url,function (buffer,error)
        if buffer then
            luaFun(buffer)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips2"),2},true)
            Log.Error("请求超时"..error)
        end
        MgrTimer.AddDelayNoName(0.1,function()
            MgrUI.PopHide(UID.PartLoading_UI)
        end)
    end)
end

---Post请求(请求地址,请求表单（key-value形式以,分隔）,回调函数)
function MgrNet.HttpPost(url,data,luaFun)
    --cs端方法
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    MgrNet.CS:HttpPost(url,data,function(buffer,error)
        if buffer then
            luaFun(buffer)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips2")..error,2},true)
            Log.Error("请求超时"..error)
        end
        MgrTimer.AddDelayNoName(0.1,function()
            MgrUI.PopHide(UID.PartLoading_UI)
        end)
    end)
end

---初始化
function MgrNet.Init()
    print("初始化网络管理器")
    --初始化cs端网络管理器
    MgrNet.CS:Init()
    --注入proto数据
    MgrNet.RegisterPB()
    --注册后台监听
    MgrNet.CS:RegisterFocus(function(time)
        MgrNet.OnFocusApp(time)
        ---后台切回之后恢复游戏速度
        local speed = SettingViewModel.GetBattleSpeed()
        if speed == 3 then
            speed = 2
        end
        SettingViewModel.SetBattleSpeed(speed)

    end)
    ---设置网络连接默认为外网
    -- MgrNet.CS:SetIpIndex(7)
end

---注入proto
function MgrNet.RegisterPB()
    --清空pb注册表，防止重复注入
    pb.clear()
    --注册转换为bytes的proto(assert等价于try-catch,第二个参数是抛出消息可不填)
    local path = MgrRes.LoadProtoFile("ABOriginal/Lua/Pb/ProtoAll.bytes")
    print(path)
    assert(pb.loadfile(path))
end

---请求tpc连接
function MgrNet.ConnectServer(recCell,ackCell,ntfCell,isReconnect)
    ---CS连接请求
    print("请求发起套接字连接")
    ---验证本地是否有存储
    if MgrNet.verifyInfo.gate == nil or MgrNet.verifyInfo.gate == "" then
        Log.Error("没有登录，请重新登录获取token")
        return false
    end
    --MgrUI.CloseAllPop()
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    ---添加跳转大厅回调     重新获取ClientSocket，C#与服务器进行连接，并添加Lua链接回调
    MgrNet.CS:ConnectServer(MgrNet.verifyInfo.gate,function(...)
        MgrNet.ConnectCallBack(...,recCell,ackCell,ntfCell,isReconnect)
    end)
    return true
end

---tcp连接回调
function MgrNet.ConnectCallBack(isConnect,recCell,ackCell,ntfCell,isReconnect)
    if isConnect then
        MgrNet.IsSocket = true
        ---开启长连接成功
        ---注册数据池回调
        MgrNet.CS:RegisterReceive(MgrNet.ReceiveReq)
        if isReconnect then
            MgrNet.SendReconnect(recCell,ackCell,ntfCell)
        else
            ---校验网关
            MgrNet.VerifyREQReceive(recCell,ackCell,ntfCell)
        end
    else
        ---开启长连接失败
        Log.Error("连接失败_3秒后重试 gate="..MgrNet.verifyInfo.gate)
        -- MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips3"),1},true)
        if recCell then
            recCell(false,0)
        end
    end
end
---网关校验请求
function MgrNet.VerifyREQReceive(recCell,ackCell,ntfCell)

    ---开启结束测试监听
    MgrNet.RegisterNTF(MID.CLIENT_SERVICE_CLOSE_NTF, function(...)
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips4"), function ()
            MgrSdk.BackToLogin()
        end},true)
    end)

    print("验证验证网关, token = "..MgrNet.verifyInfo.token)
    local tab = {
        token = MgrNet.verifyInfo.token,
        isText = 1,
    }
    local bytes = assert(pb.encode('PBClient.ClientVerifyREQ', tab))
    MgrNet.SendReq(MID.CLIENT_VERIFY_REQ,bytes,0,recCell,function(buffer,tag)
        local info = assert(pb.decode('PBClient.ClientVerifyACK',buffer))
        ---查看table内容
        if info.errNo == 0 then
            print("网关校验成功, 开启心跳")
            ---成功,注册心跳回调
            MessageEvent.Add(MID.HEARTBEAT,MgrNet.HeartbeatReceive)
            local tab = {}
            local bytes = assert(pb.encode('PBClient.HeartbeatMSG',tab))
            ---开启心跳
            MgrNet.CS:OpenHeartbeat(MID.HEARTBEAT, 0, MgrNet.verifyInfo.userId, bytes,MgrNet.SendError)
        end
        if ackCell ~= nil then
            ackCell(buffer,tag)
        end
    end,ntfCell)

end
--- 心跳回调
function MgrNet.HeartbeatReceive(buffer, tag)
    -- local tab = assert(pb.decode('PBClient.HeartbeatMSG',buffer))
    -- --查看table内容
    -- if tab ~= 0 then
    --     Log.Error("心跳断开"..ServerError[tab.errNo])
    --     ---重连
    --     MgrNet.ReConnect()
    -- end
end

---是否正在重连
MgrNet.hasReConnect = false
MgrNet.reconnectTimes = 0
---重连
function MgrNet.ReConnect()
    if not MgrNet.IsLogin then
        return
    end
    print("zqx Start ReConnect:", MgrNet.hasReConnect)
    if MgrNet.hasReConnect == false then
        MgrUI.Pop(UID.PartLoading_UI,nil,true)
        MgrUI.Pop(UID.XiaoLoading_UI,nil,true)
        MgrNet.hasReConnect = true
        ---关闭网络连接
        print("关闭网络连接")
        -- MgrNet.CS:CloseSocket()
        print("重新请求连接")
        MgrNet.CacheMsg = {}
        if not MgrNet.ConnectServer(function(err,msgId)
            if err == false then
                ---发送异常
                MgrUI.PopHide(UID.PartLoading_UI)
                if MgrNet.reconnectTimes < 3 then
                    MgrNet.reconnectTimes = MgrNet.reconnectTimes + 1
                    MgrNet.hasReConnect = false
                    MgrNet.ReConnect()
                    return
                end
                MgrUI.PopHide(UID.XiaoLoading_UI)
                MgrNet.ConfirmReconnect()
            end
        end,function(buffer,tag)
            MgrUI.PopHide(UID.PartLoading_UI)
            MgrUI.PopHide(UID.XiaoLoading_UI)
            MgrNet.reconnectTimes = 0
            MgrNet.hasReConnect = false
            local info = assert(pb.decode('PBClient.ClientReconnectACK',buffer))
            if info.errNo ~= 0 then
                print("Reconnect error:"..info.errNo) ---查看table内容
                if info.errNo == 203 then  ---被顶号
                    MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips5").."("..info.errNo..")", function ()
                        MgrSdk.BackToLogin()
                    end},true)
                else
                    MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips6").."("..info.errNo..")", function ()
                        MgrSdk.BackToLogin()
                    end},true)
                end
            else
                ---连接成功
                UnityEngine.DebugEx.LogError("zqx ReconnetSucc")
                local tab = {}
                local bytes = assert(pb.encode('PBClient.HeartbeatMSG',tab))
                ---开启心跳
                MgrNet.CS:OpenHeartbeat(MID.HEARTBEAT, 0, MgrNet.verifyInfo.userId, bytes,MgrNet.SendError)
                if next(MgrNet.CacheInfo) ~= nil and MgrNet.IsResendReq(MgrNet.CacheInfo.msgId) then
                    print("Reconnect req:"..serpent.block(MgrNet.CacheInfo)) ---查看table内容
                    UnityEngine.DebugEx.LogError("zqx send need reconnect req:"..serpent.block(MgrNet.CacheInfo))
                    local temp = MgrNet.CacheInfo
                    MgrNet.SendReq(temp.msgId, temp.buffer, temp.tag, temp.ReqFunc, temp.ACKFunc, temp.NTFFunc)
                else
                    UnityEngine.DebugEx.LogError("zqx no need reconnect req")
                end
                Event.Go("ReconnetSucc")
            end
        end,nil,true) then
            ---验证失败（本地token无效）
            MgrUI.PopHide(UID.PartLoading_UI)
            MgrUI.PopHide(UID.XiaoLoading_UI)
            MgrNet.reconnectTimes = 0
            MgrNet.hasReConnect = false
            ---移除保存的账户
            LoginViewModel.TryUser(MgrNet.verifyInfo)
            ---重启游戏
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips7"), function ()
                MgrSdk.BackToLogin()
            end},true)
        end
    end
end

---请求登录公司账户
---@param loginType string 登录类型：Text测试账户，Password正式账户
---@param username string 用户名
---@param password string 密码
---@param func function 回调（UserInfo）
function MgrNet.HttpLogin(loginType, username, password, func)
    ---登录的http路径
    local login_url = "http://&url/login"

    local from = {
        "Channel=100",
        "LoginType="..loginType,
        "Account="..username,
        "Password="..password,
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        ---解析服务器返回的buffer
        local info = assert(pb.decode('PBClient.ClientLoginResult', buffer))
        print(serpent.block(info))
        print("errNo = "..info.errNo)
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---请求登录飞游账户
---@param userId string 用户id
---@param timestamp string 时间戳
---@param sign string 签名
---@param func function 回调（UserInfo）
function MgrNet.HttpLoginFly(userId, timestamp, sign, func)
    ---登录的http路径
    local login_url = "http://&url/login"

    local from = {
        "Channel=101",
        "LoginType=FlyFunGame",
        "user_id="..userId,
        "timestamp="..timestamp,
        "sign="..sign,
        "Platform="..MgrSdk.GetPlatform(),
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        ---解析服务器返回的buffer
        local info = assert(pb.decode('PBClient.ClientLoginResult', buffer))
        print(serpent.block(info))
        print("errNo = "..info.errNo)
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---请求注册
---@param username string 用户名
---@param password string 密码
---@param actNumber string 重复一次密码
---@param func function 回调(userInfo)
function MgrNet.HttpRegister(username,password,actNumber,func,type)
    ---注册的http路径
    local register_url = "http://&url/register"

    ---服务器定义的注册表单格式Channel为服务号不用改，RegisterType为注册类型后期接入第三方登录会改，账户，密码 ，激活码
    ---调试用（无需激活码）
    local from = {
        "Channel=100",
        "RegisterType="..type,
        "Account="..username,
        "Password="..password,
        "Platform="..MgrSdk.GetPlatform(),
        "ActCode="..actNumber,
    }
    -----内测用（需要激活码）
    --local from = {
    --    "Channel=100",
    --    "RegisterType=ActCode",
    --    "Account="..username,
    --    "Password="..password,
    --    "ActCode="..actNumber,
    --}
    ---发送注册消息
    MgrNet.HttpPost(string.gsub(register_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        ---解析
        local info = assert(pb.decode('PBClient.ClientRegisterResult', buffer))
        ---打印table查看格式
        print("HttpRegister:", serpent.block(info))
        ---通知UI回调
        if func then
            func(info)
        end
    end)
end

---获取商品订单
function MgrNet.HttpGetOrder(userId,productId,callback)
    ---获取订单的http路径
    local get_url = "http://&url/GetOrder"
    ---配置表单
    local from = {
        "account="..userId,
        "product_id="..productId,
    }
    ---发送商品消息
    MgrNet.HttpPost(string.gsub(get_url,"&url",MgrNet.GetCurPayServer()),table.concat(from,","),function(request)
        ---解析
        local info = RapidJson.decode(request)
        ---查看json格式
        print(serpent.block(info))
        if callback then
            callback(info)
        end
    end)
end

---创建计时用时间戳
function MgrNet.CreateLocalTime(curServerTime)
    MgrNet.CS:CreateLocalTime(curServerTime)
end

---获取服务器时间
function MgrNet.GetServerTime()
    return tonumber(MgrNet.CS:GetServerTime())
end

---矫正服务器时间
function MgrNet.SetServerTime(curServerTime)
    if curServerTime == nil then
        return
    end
    MgrNet.CS:SetServerTime(curServerTime)
end

---后台切换通知(后台持续时间)
function MgrNet.OnFocusApp(time)
    print("程序进入了前台,此次前后台切换间隔为："..time)
    if MgrUI.GetCurUI() ~= nil and MgrUI.GetCurUI().Uid ~= UID.Login_UI and MgrNet.LoginInit == true then
        if time > 5 then
            local tab = {}
            local bytes = assert(pb.encode('PBClient.HeartbeatMSG',tab))
            -- MgrNet.CS:SendReq(MID.HEARTBEAT, 0, MgrNet.verifyInfo.userId, bytes,MgrNet.SendError)
        end
    end
end

function MgrNet.IsResendReq(msgId)
    for index, value in pairs(MgrNet.ResendMID) do
        if msgId == value then
            return true
        end
    end
    return false
end

function MgrNet.ConfirmReconnect()
    ---连接失败处理逻辑
    MgrUI.Pop(UID.ReconnectPop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips8"),function()
        ---继续重连
        MgrUI.Pop(UID.PartLoading_UI,nil,true)
        MgrNet.hasReConnect = false
        MgrNet.ReConnect()
    end,nil,function()
        ---重启游戏
        MgrSdk.BackToLogin()
    end},true)
end

function MgrNet.ConfirmReLogin()
    ---连接失败处理逻辑
    MgrUI.Pop(UID.ReconnectPop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips8"),function()
        ---继续重连
        MgrUI.Pop(UID.PartLoading_UI,nil,true)
        MgrNet.hasReConnect = false
        MgrNet.ReLogin()
    end,nil,function()
        ---重启游戏
        MgrSdk.BackToLogin()
    end},true)
end

function MgrNet.GetServerNameList()
    return MgrNet.CS:GetServerNameList()
end

function MgrNet.SendReconnect(recCell,ackCell,ntfCell)
    local tab = {
        token = MgrNet.verifyInfo.token,
        isText = 1,
    }
    local bytes = assert(pb.encode('PBClient.ClientReconnectREQ', tab))
    MgrNet.SendReq(MID.CLIENT_RECONNECT_REQ,bytes,0,recCell,function(buffer,tag)
        if ackCell ~= nil then
            ackCell(buffer,tag)
        end
    end,ntfCell)
end

function MgrNet.ReLogin()
    MgrNet.VerifyREQReceive(function(err,msgId)
        if err == false then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips6").."(Relogin req)", function ()
                MgrSdk.BackToLogin()
            end},true)
        end
    end,function(buffer,tag)
        MgrUI.PopHide(UID.PartLoading_UI)
        local info = assert(pb.decode('PBClient.ClientVerifyACK',buffer))
        if info.errNo ~= 0 then
            print("ReLogin error:"..info.errNo) ---查看table内容
            if info.errNo == 203 then
                MgrUI.PopHide(UID.XiaoLoading_UI)
                MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips5").."(Relogin ack:"..info.errNo..")", function ()
                    MgrSdk.BackToLogin()
                end},true)
                return
            else
                MgrUI.PopHide(UID.XiaoLoading_UI)
                MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips6").."(Relogin ack:"..info.errNo..")", function ()
                    MgrSdk.BackToLogin()
                end},true)
                return
            end
        else
            ---连接成功
            MgrUI.PopHide(UID.XiaoLoading_UI)
            MgrNet.reconnectTimes = 0
        end
    end,function(buffer,tag)
        MgrUI.PopHide(UID.PartLoading_UI)
        MgrUI.PopHide(UID.XiaoLoading_UI)
        local info = assert(pb.decode('PBClient.ClientVerifyNTF',buffer))
        print("登录推送："..serpent.block(info)) ---查看table内容
        if info.errNo ~= 0 then
            ---连接失败处理逻辑
            ---验证失败（服务器token无效）
            ---移除保存的账户
            LoginViewModel.TryUser(MgrNet.verifyInfo)
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips7").."(Relogin ntf:"..info.errNo..")", function ()
                MgrSdk.BackToLogin()
            end},true)
        else
            ---连接成功处理逻辑
            MgrNet.hasReConnect = false
            ---更新网关推送数据
            MgrModel.PushData(info, true)
            print("已重登录")
            Event.Go("ReconnetSucc")
            if next(MgrNet.CacheInfo) ~= nil and MgrNet.IsResendReq(MgrNet.CacheInfo.msgId) then
                print("ReLogin req:"..serpent.block(MgrNet.CacheInfo)) ---查看table内容
                local temp = MgrNet.CacheInfo
                MgrNet.SendReq(temp.msgId, temp.buffer, temp.tag, temp.ReqFunc, temp.ACKFunc, temp.NTFFunc)
            end
        end
    end)
end

---请求快速登录账户（相当于游客）
---@param func function 回调（UserInfo）
function MgrNet.HttpFastLogin(func)
    ---登录的http路径
    local login_url = "http://&url/login"

    local device = Tools.GetDeviceId()
    local time = os.time()

    local from = {
        "Channel=100",
        "LoginType=FastLogin",
        "Device="..device,
        "timestamp="..time,
        "sign="..Tools.GetMD5(MgrSdk.bindkey..device..time),
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        ---解析服务器返回的buffer
        local info = assert(pb.decode('PBClient.ClientLoginResult', buffer))
        print("zqx FastLogin:"..serpent.block(info))
        print("errNo = "..info.errNo)
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---请求登录sdk账户
---@param platform integer 平台ID
---@param openid string openid
---@param token string token
---@param func function 回调（UserInfo）
function MgrNet.HttpSdkLogin(platform, openid, token, func)
    ---登录的http路径
    local login_url = "http://&url/login"

    local from = {
        "LoginType=SDKLogin",
        "Channel=100",
        "platform="..platform,
        "openid="..openid,
        "token="..token,
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        ---解析服务器返回的buffer
        local info = assert(pb.decode('PBClient.ClientLoginResult', buffer))
        print(serpent.block(info))
        print("errNo = "..info.errNo)
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---修改引继码
---@param account string 账号
---@param oldpass string 旧密码
---@param newpass string 新密码
---@param func function 回调（UserInfo）
function MgrNet.HttpResetPassword(account, oldpass, newpass, func)
    ---登录的http路径
    local login_url = "http://&url/Reset"

    local from = {
        "Channel=100",
        "Account="..account,
        "OldPassword="..oldpass,
        "NewPassword="..newpass,
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        ---解析服务器返回的buffer
        local info = assert(pb.decode('PBClient.ClientResetResult', buffer))
        print(serpent.block(info))
        print("errNo = "..info.errNo)
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---绑定sdk账号
---@param userId string UID
---@param platform integer 平台ID
---@param openid string openid
---@param token string token
---@param func function 回调（UserInfo）
function MgrNet.HttpBindSdk(userId, platform, openid, token, func)
    ---登录的http路径
    local login_url = "http://&url/bind"

    local time = os.time()

    local from = {
        "user_id="..userId,
        "Platform_type="..platform,
        "open_id="..openid,
        "token="..token,
        "timestamp="..time,
        "sign="..Tools.GetMD5(MgrSdk.bindkey..userId..time),
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        local info = RapidJson.decode(buffer)
        print(serpent.block(info))
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---解绑sdk账号
---@param userId string UID
---@param platform integer 平台ID
---@param openid string openid
---@param token string token
---@param func function 回调（UserInfo）
function MgrNet.HttpUnbindSdk(userId, platform, openid, token, func)
    ---登录的http路径
    local login_url = "http://&url/release"

    local time = os.time()

    local from = {
        "user_id="..userId,
        "Platform_type="..platform,
        "open_id="..openid,
        "token="..token,
        "timestamp="..time,
        "sign="..Tools.GetMD5(MgrSdk.bindkey..userId..time),
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        local info = RapidJson.decode(buffer)
        print(serpent.block(info))
        ---通知界面
        if func then
            func(info)
        end
    end)
end

---换绑账号
---@param userId string UID
---@param platform integer 平台ID
---@param openid string openid
---@param token string token
---@param func function 回调（UserInfo）
function MgrNet.HttpChangeBind(userId, platform, openid, token, newToken, func)
    ---登录的http路径
    local login_url = "http://&url/changeBind"

    local time = os.time()

    local from = {
        "user_id="..userId,
        "Platform_type="..platform,
        "open_id="..openid,
        "token="..token,
        "newToken="..newToken,
        "timestamp="..time,
        "sign="..Tools.GetMD5(MgrSdk.bindkey..userId..time),
    }

    ---发送消息
    MgrNet.HttpPost(string.gsub(login_url,"&url",MgrNet.GetCurLoginServer()),table.concat(from,','), function(buffer)
        local info = RapidJson.decode(buffer)
        print(serpent.block(info))
        ---通知界面
        if func then
            func(info)
        end
    end)
end

function MgrNet.HttpGetOrderGenernal(userId,productId,callback)
    ---获取订单的http路径
    local get_url = "http://&url/GetOrderGeneral"
    ---配置表单
    local from = {
        "user_id="..userId,
        "product_id="..productId,
    }
    ---发送商品消息
    MgrNet.HttpPost(string.gsub(get_url,"&url",MgrNet.GetCurPayServer()),table.concat(from,","),function(request)
        ---解析
        local info = RapidJson.decode(request)
        ---查看json格式
        print(serpent.block(info))
        if callback then
            callback(info)
        end
    end)
end

function MgrNet.HttpPurchaseVerify(userId, orderId, receipt, transactionID, callback)
    ---http路径
    local get_url = "http://&url/iosPurchase"
    ---配置表单
    local from = {
        "userID="..userId,
        "transaction_id="..transactionID,
        "receipt="..receipt,
        "cpOrderID="..orderId,
    }
    ---发送商品消息
    MgrNet.HttpPost(string.gsub(get_url,"&url",MgrNet.GetCurPayServer()),table.concat(from,","),function(request)
        ---解析
        local info = RapidJson.decode(request)
        ---查看json格式
        print(serpent.block(info))
        if callback then
            callback(info)
        end
    end)
end

--- 注意事项
-- 使用Http登录请求获取服务器tcp地址后，全程使用tcp通信
-- tcp报文格式为[消息长度，消息id，自定义内容，用户id]16B + [proto消息内容]65535B
-- 发送报文后，服务器会返回[client请求内容];[client请求结果]两条报文，内容先到
-- 引用pb.dll，pb.dll包含在tolua的各个平台库里，在LuaDLL.cs和CMgrLua.cs下注册
-- 用法简介：先将要使用的proto文件转换为二进制后注册到pb里，后创建与proto里结构相同的table消息，
-- 再然后通过assert(pb.encode(包名.消息名,teble))生成对应的proto协议消息数据,后发送给服务器(例:local bytes = assert(pb.encode('PBClient.GPS', data)))
-- 接收服务器消息通过assert(pb.decode(包名.消息名, bytes))解析消息（例:local data2 = assert(pb.decode('PBClient.GPS', bytes)))
-- 引用pb库，Game.lua已经引用过请勿重复引用
-- local pb = require 'pb'
-- 清空pb注册表，防止重复注册，
-- pb.clear()
-- 注册转换为bytes的proto(assert()等价于try-catch,第二个参数是抛出消息)
-- assert(pb.loadfile("E:/development/development/Assets/LuaFramework/ToLua/Pb/ProtoAll.bytes"))
-- 注册二进制的proto数据(热更时C#读取后传bytes过来)
-- assert(pb.load(bytes))
--- 示例
-- function Test.Login()
-- 发送消息
-- 定义与pb消息结构相同的table及数据
-- local data = {
--    lat = 12,
--    lng  = 18,
-- }

-- 通过包名.消息名匹配与table相同的ProtoMessage, 返回bytes, assert()等价于try-catch,第二个参数是抛出的异常
-- local bytes = assert(pb.encode('PBClient.GPS', data),err)

-- 查看bytes内容
-- print(pb.tohex(bytes))

-- 注册回调到MessageEvent, MID请与服务器协商定义
-- MessageEvent.Add(MID.CLIENT_VERIFY_NTF,Test.LoginReceive)

-- 发送消息给服务器, MID请与服务器协商定义，第三个参数tag只能是number且不超过4位, 作用于收到消息时原样返回, 可以忽略不填
-- MgrNet.SendReq(MID.CLIENT_VERIFY_NTF,bytes,10086) --or MgrNet.SendReq(MID.CLIENT_VERIFY_NTF,bytes)
-- end

-- function Test.LoginReceive(buffer,tag)
-- 接收到服务器消息tag原样返回
-- 通过包名.消息名匹配与table相同的消息结构,匹配成功返回table
-- local table = assert(pb.decode('PBClient.ClientVerifyACK', str))

-- 查看table内容
-- print(require 'lua-protobuf.serpent'.block(table))
-- end