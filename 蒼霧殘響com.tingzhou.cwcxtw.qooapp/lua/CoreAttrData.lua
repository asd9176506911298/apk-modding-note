---@class CoreAttrData 核心及共鸣装备属性数据
CoreAttrData = Class("CoreAttrData")
-------------构造方法-------------
function CoreAttrData:ctor()
    self.attrUID = 0        ---属性唯一id
    self.attrID = 0         ---属性类型（0.固定攻击，1.百分比攻击，2.固定生命，3.百分比生命，4.防御，5.暴击，6.爆伤，7.敏捷，8.支援力）
    self.attrName = ""      ---属性名
    self.attribute = 0      ---属性值
    self.attrType = 0       ---属性是否为百分比(0.值，1.百分比)
    self.attrIcon = string.format("Attribute/GearInfoIcon_%s",self.attrID)

    CoreAttrData.coreAttrName = {
        [0] = MgrLanguageData.GetLanguageByKey("coreattrdata_attack"),
        [1] = MgrLanguageData.GetLanguageByKey("coreattrdata_attack"),
        [2] = MgrLanguageData.GetLanguageByKey("coreattrdata_health"),
        [3] = MgrLanguageData.GetLanguageByKey("coreattrdata_health"),
        [4] = MgrLanguageData.GetLanguageByKey("backrub_ui_armor"),
        [5] = MgrLanguageData.GetLanguageByKey("ui_yangcheng_text17"),
        [6] = MgrLanguageData.GetLanguageByKey("ui_yangcheng_text18"),
        [7] = MgrLanguageData.GetLanguageByKey("coreattrdata_agile"),
        [8] = MgrLanguageData.GetLanguageByKey("coreattrdata_support"),
    }
end
local enum = {
    value = 0,      ---值
    percentage = 1, ---百分比
}

function CoreAttrData:PushData(uid,id,enum,attr)
    self.attrUID = uid
    self.attrID = id
    self.attrName = CoreAttrData.coreAttrName[id] --or "未知类型"
    self.attribute = attr
    self.type = enum
    self.attrIcon = string.format("Attribute/GearInfoIcon_%s",self.attrID)
end

return CoreAttrData