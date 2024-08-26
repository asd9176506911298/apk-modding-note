---登录VM
LoginViewModel = {}

LoginViewModel.localInfo = {}

function LoginViewModel.Init()
    MgrRes.GetPrefab('ABOriginal/VFX/Prefab/UI_Prefab/llx_dianji.prefab',function(clickeff)
        CMgrUI.Instance:SetClickEffect(clickeff)
    end)
    ---打开LoginUI
    MgrUI.CurShowUIName = nil
    -- MgrTimer.AddDelayNoName(0.5, function ()
        MgrSce.Load(MgrSce.Scenes.Home, function ()
            MgrNet.LoginInit = true;
            MgrUI.GoFirst(UID.Login_UI)
        end)
    -- end)
end

function LoginViewModel.Close()
    ---卸载登录脚本相关
    MgrUI.ClosePop(UID.Login_UI)
end

function LoginViewModel.FirstLoginNotice(id)
    local curTimestamp = Global.GetCurTime()
    local nowDate = os.date("!*t", curTimestamp);
    local lastLoginTime = string.split(UnityEngine.PlayerPrefs.GetString(id .. "LastLoginTime"),"_")
    print("zqx nowDate:"..serpent.block(nowDate))
    print("zqx lastLoginTime:"..serpent.block(lastLoginTime))
    if (lastLoginTime ~= nil or lastLoginTime ~= "") and tonumber(lastLoginTime[1]) == nowDate.year and tonumber(lastLoginTime[2]) == nowDate.month and tonumber(lastLoginTime[3]) == nowDate.day then
        return
    else
        UnityEngine.PlayerPrefs.SetString(id .. "LastLoginTime",nowDate.year .. "_" .. nowDate.month .. "_" .. nowDate.day)
        MgrUI.Pop(UID.GongGaoPop)
    end
end

---进入Home
function LoginViewModel.EnterHome()
    ---引入Home脚本初始化
    require("UI/ViewModel/HomeViewModel").Init()
end

---销毁检查更新界面
function LoginViewModel.CloseCheckUpdate()
    local CheckUpdateObj = GameObject.Find("CheckUpdateUI")
    if CheckUpdateObj then
        GameObject.Destroy(CheckUpdateObj.gameObject)
    end
end

---@return UserInfo[] 获取本地保存的账户（最多100个有序数据，1为默认账户）
function LoginViewModel.GetUserList()
    local arr = {}
    for i = 1, 100 do
        local _name = UnityEngine.PlayerPrefs.GetString(string.format("userName%s",i))
        if _name ~= nil and _name ~= "" then
            ---@type UserInfo
            local user = {
                name = _name,
                password = UnityEngine.PlayerPrefs.GetString(string.format("passWord%s",i)),
                userId = UnityEngine.PlayerPrefs.GetInt(string.format("userID%s",i)),
                token = UnityEngine.PlayerPrefs.GetString(string.format("token%s",i)),
                gate = UnityEngine.PlayerPrefs.GetString(string.format("gate%s",i)),
            }
            arr[#arr + 1] = user
        end
    end
    return arr
end
---@param list UserInfo[] 保存账户（最多100个有序数据，1为默认账户）
function LoginViewModel.SaveUserList(list)
    ---先清空
    LoginViewModel.ClearUser()
    ---重新保存
    for i, v in ipairs(list) do
        UnityEngine.PlayerPrefs.SetString(string.format("userName%s",i),v.name)
        UnityEngine.PlayerPrefs.SetString(string.format("passWord%s",i),v.password)
        UnityEngine.PlayerPrefs.SetInt(string.format("userID%s",i),v.userId)
        UnityEngine.PlayerPrefs.SetString(string.format("token%s",i),v.token)
        UnityEngine.PlayerPrefs.SetString(string.format("gate%s",i),v.gate)
    end
end
---@param user UserInfo 保存账户
function LoginViewModel.SaveUser(user)
    ---新建账户队列
    local arr = {}
    ---将默认位（下标1的为默认账户）设置为当前账户
    arr[1] = user
    ---追加其他账户
    local list = LoginViewModel.GetUserList()
    for i, v in ipairs(list) do
        ---排除同名账户追加其他账户
        if v.name ~= user.name then
            arr[#arr + 1] = v
        end
    end
    ---保存到本地持久化
    LoginViewModel.SaveUserList(arr)
end
---@param user UserInfo 移除账户
function LoginViewModel.TryUser(user)
    for i = 1, 100 do
        local _name = UnityEngine.PlayerPrefs.GetString(string.format("userName%s",i))
        if _name ~= nil and _name ~= "" and _name == user.name then
            UnityEngine.PlayerPrefs.SetString(string.format("userName%s",i),"")
            UnityEngine.PlayerPrefs.SetString(string.format("passWord%s",i),"")
            UnityEngine.PlayerPrefs.SetInt(string.format("userID%s",i),0)
            UnityEngine.PlayerPrefs.SetString(string.format("token%s",i),"")
            UnityEngine.PlayerPrefs.SetString(string.format("gate%s",i),"")
            return
        end
    end
end
---移除所有账户
function LoginViewModel.ClearUser()
    for i = 1, 100 do
        UnityEngine.PlayerPrefs.SetString(string.format("userName%s",i),"")
        UnityEngine.PlayerPrefs.SetString(string.format("passWord%s",i),"")
        UnityEngine.PlayerPrefs.SetInt(string.format("userID%s",i),0)
        UnityEngine.PlayerPrefs.SetString(string.format("token%s",i),"")
        UnityEngine.PlayerPrefs.SetString(string.format("gate%s",i),"")
    end
end

function LoginViewModel.HasLocalAccount()
    if not UnityEngine.PlayerPrefs.HasKey("localInfo") then
        return false
    end
    local str = UnityEngine.PlayerPrefs.GetString("localInfo")
    local json = RapidJson.decode(str)
    print("zqx local:"..serpent.block(json))
    if json.ip == MgrNet.GetCurLoginServer() then
        LoginViewModel.localInfo = json
        return true
    end
    return false
end

function LoginViewModel.GetLocalAccount()
    return LoginViewModel.localInfo
end

function LoginViewModel.SaveLocalAccount(info)
    print("zqx SaveLocalAccount")
    local data = {
        account = info.account,
        pwd = info.password,
        platforms = {},
        ip = MgrNet.GetCurLoginServer(),
        userID = info.userID
    }
    LoginViewModel.localInfo = data
    UnityEngine.PlayerPrefs.SetString("localInfo",RapidJson.encode(data))
end

function LoginViewModel.DelLocalAccount()
    UnityEngine.PlayerPrefs.DeleteKey("localInfo");
end

function LoginViewModel.UpdateLocalPwd(nPwd)
    LoginViewModel.localInfo.pwd = nPwd
    UnityEngine.PlayerPrefs.SetString("localInfo",RapidJson.encode(LoginViewModel.localInfo))
end

return LoginViewModel


