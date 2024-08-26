MgrChatNet = {}
MgrChatNet.CS = CMgrChatNet.Instance

MgrChatNet.CacheInfo = {}
MgrChatNet.ResendMID = {                    -- 需要重发的协议ID
    MID.CLIENT_CHOOSE_BATTLE_REWARD_REQ,
    MID.CLIENT_TOWER_REWARD_REQ,
    MID.CLIENT_GUIDE_REWARD_REQ,
    MID.CLIENT_CHOOSE_LADDER_BATTLE_REWARD_REQ,
    MID.CLIENT_SET_LEVEL_STAR_REQ,
    MID.CLIENT_SAVE_PROGRESS_REQ,
}

MgrChatNet.LoginInit = false;
MgrChatNet.Chat = nil;

---消息缓存池（作用：相同消息id发送后，只有在收到消息或超时后才能再次发送，超时时间暂定为5秒）
MgrChatNet.CacheMsg = {}
---Socket请求(消息id，消息内容，标识，请求回调，接收验证回调，接收数据回调)
---发送请求（ACK委托给MgrNet.ReceiveError） 备注：tcp报文格式为[消息长度，消息id，自定义内容，用户id]16B(固定4*4) + [proto消息内容]65535B(最大值),报文拼接已在C#的CMgrNet实现
---@param msgId number 消息id（必填）
---@param buffer userdata 使用pb转换过的消息流（必填）
---@param tag number 标签，会在ack及ntf回调中原样返回，可用于业务逻辑自定义，不用时填0
---@param ReqFunc function 发送消息完成后的回调,不使用填nil
---@param ACKFunc function 服务器返回的确认回调,只包含了服务器对消息的处理状况Error,不使用填nil
---@param NTFFunc function 服务器返回的具体数据,不使用填nil
function MgrChatNet.SendReq(msgId, buffer, tag, ReqFunc, ACKFunc, NTFFunc)
    ---检查是否存在未结束的消息
    if MgrChatNet.CacheMsg[msgId] ~= nil then
        Log.Error("请勿频繁发送消息")
        return
    end
    print("发送消息 ID: "..msgId.." ,Buffer:"..pb.tohex(buffer))
    if tag ~= nil and type(tag) ~= "number" then
        Log.Error('tag只能是number')
        return
    end

    if MgrChatNet.IsResendReq(msgId) then
        UnityEngine.DebugEx.LogError("chat set need reconnect req:"..msgId)
        MgrChatNet.CacheInfo = {}
        MgrChatNet.CacheInfo.msgId = msgId
        MgrChatNet.CacheInfo.buffer = buffer
        MgrChatNet.CacheInfo.tag = tag
        MgrChatNet.CacheInfo.ReqFunc = ReqFunc
        MgrChatNet.CacheInfo.ACKFunc = ACKFunc
        MgrChatNet.CacheInfo.NTFFunc = NTFFunc
    end

    ---ACK统一打印
    MessageEvent.Add(msgId + 1,function(...)
        MgrChatNet.ReceiveACKLog(msgId,...)
    end)
    ---ACK回调，为空不添加
    if ACKFunc then
        MessageEvent.Add(msgId + 1,function(...)
            MgrChatNet.ReceiveACKLog(msgId,...)
            ACKFunc(...)
        end)
        ---记录消息占用
        MgrChatNet.CacheMsg[msgId + 1] = true
    end

    ---NTF回调，为空不添加
    if NTFFunc then
        MessageEvent.Add(msgId + 2, NTFFunc)
        ---记录消息占用
        MgrChatNet.CacheMsg[msgId + 2] = true
    end
    print("占用"..msgId)
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    ---发送消息
    MgrChatNet.CS:SendReq(msgId,tag or -1,MgrNet.verifyInfo.userId,buffer,function(...)
        ---重置战斗结算
        FightVideoViewModel.isReturning = false
        ---消息发送回调统一打印
        MgrChatNet.SendError(...)
        ---Req回调，为空不通知
        if ReqFunc then
            ReqFunc(...)
        end
    end)
end

---注册推送消息,注册后服务器将会对推送消息到此接口
---@param msgId number 消息id
---@param callFunc function 推送回调
function MgrChatNet.RegisterNTF(msgId, callFunc)
    MessageEvent.Add(msgId, callFunc)
end

---Socket数据分发,所有收到的消息将在此处转发
---@param mid number 消息id
---@param tag number 标签
---@param userId number 用户id
---@param buffer userdata 需要pb转换的消息流
function MgrChatNet.ReceiveReq(mid,tag,userId,buffer)
    print("ReceiveMsgId = "..mid.." ,ReceiveTag = "..tag.." ,ReceiveUserId = "..userId)
    ---收到消息，将id从消息池中移除
    MgrChatNet.CacheMsg[mid] = nil
    print("移除占用"..mid)
    ---分发消息
    MessageEvent.Go(mid,buffer,tag)
end

---ACK统一打印
function MgrChatNet.ReceiveACKLog(msgId, buffer, tag)
    local table = assert(pb.decode('PBClient.ClientVerifyACK',buffer))
    if table.errNo == 0 then
        print(msgId.."消息ACK成功")
    else
        Log.Error("消息接收失败,错误原因:"..(ServerError[table.errNo] or table.errNo))
    end
    if MgrChatNet.IsResendReq(msgId) then
        MgrChatNet.CacheInfo = {}
    end
    MgrUI.PopHide(UID.PartLoading_UI)
end

---统一处理请求回调接口
---@param err userdata 错误信息
---@param msgId number 消息id
function MgrChatNet.SendError(err,msgId)
    if msgId == MID.HEARTBEAT then
        ---心跳消息
        if err == false then
            Log.Error("心跳发送失败")
            ---重连
            -- MgrChatNet.ReConnect()
        end
    else
        ---其他消息
        if err == true then
            print("消息发送成功")
        else
            -- MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips1"),1},true)
            Log.Error("消息发送失败")
            ---将异常消息移除消息池
            MgrChatNet.CacheMsg[msgId] = nil
            ---重连
            -- MgrChatNet.ReConnect()
        end
    end
end

---Get请求(完整url，回调)
function MgrChatNet.HttpGet(url,luaFun)
    --cs端方法
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    MgrChatNet.CS:HttpGet(url,function (buffer,error)
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
function MgrChatNet.HttpPost(url,data,luaFun)
    --cs端方法
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    MgrChatNet.CS:HttpPost(url,data,function(buffer,error)
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
function MgrChatNet.Init(_chatAddress)
    MgrChatNet.Chat = _chatAddress
end

---请求tpc连接
function MgrChatNet.ConnectServer(recCell,ackCell,ntfCell,isReconnect)
    ---CS连接请求
    print("请求发起套接字连接")
    ---验证本地是否有存储
    if MgrChatNet.Chat == nil or MgrChatNet.Chat == "" then
        Log.Error("没有登录，请重新登录获取token")
        return false
    end
    --MgrUI.CloseAllPop()
    MgrUI.Pop(UID.PartLoading_UI,nil,true)
    ---添加跳转大厅回调     重新获取ClientSocket，C#与服务器进行连接，并添加Lua链接回调
    MgrChatNet.CS:ConnectChatServer(MgrChatNet.Chat,function(...)
        MgrChatNet.ConnectCallBack(...,recCell,ackCell,ntfCell,isReconnect)
    end)
    return true
end

---tcp连接回调
function MgrChatNet.ConnectCallBack(isConnect,recCell,ackCell,ntfCell,isReconnect)
    if isConnect then
        ---开启长连接成功
        ---注册数据池回调
        MgrChatNet.CS:RegisterReceive(MgrChatNet.ReceiveReq)
        if isReconnect then
            MgrChatNet.SendReconnect(recCell,ackCell,ntfCell)
        else
            ---校验网关
            MgrChatNet.VerifyREQReceive(recCell,ackCell,ntfCell)
        end
    else
        ---开启长连接失败
        Log.Error("连接失败_3秒后重试 gate="..MgrChatNet.Chat)
        -- MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips3"),1},true)
        if recCell then
            recCell(false,0)
        end
    end
end
---网关校验请求
function MgrChatNet.VerifyREQReceive(recCell,ackCell,ntfCell)

    -----开启结束测试监听
    --MgrChatNet.RegisterNTF(MID.CLIENT_SERVICE_CLOSE_NTF, function(...)
    --    MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips4"), function ()
    --        MgrSdk.BackToLogin()
    --    end},true)
    --end)

    print("验证验证网关, token = "..MgrNet.verifyInfo.token)
    local tab = {
        token = MgrNet.verifyInfo.token,
        channel = 100,
    }
    local bytes = assert(pb.encode('PBClient.ClientJoinChatREQ', tab))
    MgrChatNet.SendReq(MID.CLIENT_JOIN_CHAT_REQ,bytes,0,recCell,function(buffer,tag)
        local info = assert(pb.decode('PBClient.ClientJoinChatACK',buffer))
        ---查看table内容
        if info.errNo == 0 then
            print("网关校验成功, 开启心跳")
            ---成功,注册心跳回调
            MessageEvent.Add(MID.HEARTBEAT,MgrChatNet.HeartbeatReceive)
            local tab = {}
            local bytes = assert(pb.encode('PBClient.HeartbeatMSG',tab))
            ---开启心跳
            MgrChatNet.CS:OpenHeartbeat(MID.HEARTBEAT, 0, MgrNet.verifyInfo.userId, bytes,MgrChatNet.SendError)
        end
        if ackCell ~= nil then
            ackCell(buffer,tag)
        end
    end,ntfCell)

end

---是否正在重连
MgrChatNet.hasReConnect = false
MgrChatNet.reconnectTimes = 0
---重连
function MgrChatNet.ReConnect()
    print("chat Start ReConnect:", MgrChatNet.hasReConnect)
    if MgrChatNet.hasReConnect == false then
        MgrUI.Pop(UID.PartLoading_UI,nil,true)
        MgrUI.Pop(UID.XiaoLoading_UI,nil,true)
        MgrChatNet.hasReConnect = true
        ---关闭网络连接
        print("关闭网络连接")
        -- MgrChatNet.CS:CloseSocket()
        print("重新请求连接")
        if not MgrChatNet.ConnectServer(function(err,msgId)
            if err == false then
                ---发送异常
                MgrUI.PopHide(UID.PartLoading_UI)
                if MgrChatNet.reconnectTimes < 3 then
                    MgrChatNet.reconnectTimes = MgrChatNet.reconnectTimes + 1
                    MgrChatNet.hasReConnect = false
                    MgrChatNet.ReConnect()
                    return
                end
                MgrUI.PopHide(UID.XiaoLoading_UI)
                MgrChatNet.ConfirmReconnect()
            end
        end,function(buffer,tag)
            MgrUI.PopHide(UID.PartLoading_UI)
            MgrUI.PopHide(UID.XiaoLoading_UI)
            MgrChatNet.reconnectTimes = 0
            MgrChatNet.hasReConnect = false
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
                UnityEngine.DebugEx.LogError("chat ReconnetSucc")
                local tab = {}
                local bytes = assert(pb.encode('PBClient.HeartbeatMSG',tab))
                ---开启心跳
                MgrChatNet.CS:OpenHeartbeat(MID.HEARTBEAT, 0, MgrNet.verifyInfo.userId, bytes,MgrChatNet.SendError)
                if next(MgrChatNet.CacheInfo) ~= nil and MgrChatNet.IsResendReq(MgrChatNet.CacheInfo.msgId) then
                    print("Reconnect req:"..serpent.block(MgrChatNet.CacheInfo)) ---查看table内容
                    UnityEngine.DebugEx.LogError("chat send need reconnect req:"..serpent.block(MgrChatNet.CacheInfo))
                    local temp = MgrChatNet.CacheInfo
                    MgrChatNet.SendReq(temp.msgId, temp.buffer, temp.tag, temp.ReqFunc, temp.ACKFunc, temp.NTFFunc)
                else
                    UnityEngine.DebugEx.LogError("chat no need reconnect req")
                end
                Event.Go("ReconnetSucc")
            end
        end,nil,true) then
            ---验证失败（本地token无效）
            MgrUI.PopHide(UID.PartLoading_UI)
            MgrUI.PopHide(UID.XiaoLoading_UI)
            MgrChatNet.reconnectTimes = 0
            MgrChatNet.hasReConnect = false
            ---移除保存的账户
            LoginViewModel.TryUser(MgrNet.verifyInfo)
            ---重启游戏
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips7"), function ()
                MgrSdk.BackToLogin()
            end},true)
        end
    end
end

function MgrChatNet.IsResendReq(msgId)
    for index, value in pairs(MgrChatNet.ResendMID) do
        if msgId == value then
            return true
        end
    end
    return false
end

function MgrChatNet.ConfirmReconnect()
    ---连接失败处理逻辑
    MgrUI.Pop(UID.ReconnectPop_UI,{MgrLanguageData.GetLanguageByKey("mgrnet_tips8"),function()
        ---继续重连
        MgrUI.Pop(UID.PartLoading_UI,nil,true)
        MgrChatNet.hasReConnect = false
        MgrChatNet.ReConnect()
    end,nil,function()
        ---重启游戏
        MgrSdk.BackToLogin()
    end},true)
end

function MgrChatNet.SendReconnect(recCell,ackCell,ntfCell)
    local tab = {
        token = MgrNet.verifyInfo.token,
        channel = 100,
    }
    local bytes = assert(pb.encode('PBClient.ClientJoinChatREQ', tab))
    MgrChatNet.SendReq(MID.CLIENT_JOIN_CHAT_REQ,bytes,0,recCell,function(buffer,tag)
        if ackCell ~= nil then
            ackCell(buffer,tag)
        end
    end,ntfCell)
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
-- MgrChatNet.SendReq(MID.CLIENT_VERIFY_NTF,bytes,10086) --or MgrChatNet.SendReq(MID.CLIENT_VERIFY_NTF,bytes)
-- end

-- function Test.LoginReceive(buffer,tag)
-- 接收到服务器消息tag原样返回
-- 通过包名.消息名匹配与table相同的消息结构,匹配成功返回table
-- local table = assert(pb.decode('PBClient.ClientVerifyACK', str))

-- 查看table内容
-- print(require 'lua-protobuf.serpent'.block(table))
-- end