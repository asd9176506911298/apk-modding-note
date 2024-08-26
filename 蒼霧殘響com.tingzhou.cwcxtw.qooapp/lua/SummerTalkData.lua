---@class SummerTalkData 物品数据
SummerTalkData = Class("SummerTalkData")
-------------构造方法-------------
function SummerTalkData:ctor()
    self.id = 0
    self.groupid = 0           ---组id
    self.icon = ""             ---头像资源
    self.name = ""             ---名字
    self.text = ""             ---对话文本
    self.locat = 0             ---对话框位置
    self.sound = ""            ---配音文件
    self.spine = ""            ---表情动作
end

function SummerTalkData:PushData(_data)
    self.id = _data.id
    self.groupid = _data.groupid
    self.icon = _data.icon
    self.name = _data.name
    self.text = _data.text
    self.locat = _data.locat
    self.sound = _data.sound
    self.spine = _data.spine
end

return SummerTalkData