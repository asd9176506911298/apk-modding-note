require("LocalData/LanguageLocalData")

MgrLanguageData = {}
CSMgrLua = CMgrLua.Instance
---多语言数据
MgrLanguageData.LanguageDatas = {}

MgrLanguageData.LanguageEnum = {
    chs = 0,
    cht = 1,
    En = 2,
    Jp = 3
}
function MgrLanguageData.Init()
    ---多语言配置加载
    MgrLanguageData.OnStart()
end

function MgrLanguageData.OnStart()
    for i, v in pairs(LanguageLocalData.tab) do
        local tId = v[1]
        local tStrKey = v[2]
        local tLangChs = v[3] and v[3] or ""
        local tLangTC = v[4] and v[4] or ""
        local tLangJP = v[5] and v[5] or ""
        ---传入Lua数据至C#
        CMgrLanguage.Creat_Id_Data(tId,tStrKey,tLangChs,tLangTC,tLangJP)
        ---多语言数据
        MgrLanguageData.LanguageDatas[tStrKey] = {
            id = tId,
            strKey = tStrKey,
            LangChs = tLangChs,
            LangTC = tLangTC,
            LangJP = tLangJP
        }
    end
end
---用字符串获取多语言
function MgrLanguageData.GetLanguageByKey(_key)
    if MgrLanguageData.LanguageDatas[_key] ~= nil then
        return MgrLanguageData.LanguageDatas[_key].LangChs
    end
    --print("多语言无索引".._key)
    return _key
end
---多语言类型
function MgrLanguageData.GetLanguageType()
    return CSMgrLua:GetLanguageType()
end

return MgrLanguageData