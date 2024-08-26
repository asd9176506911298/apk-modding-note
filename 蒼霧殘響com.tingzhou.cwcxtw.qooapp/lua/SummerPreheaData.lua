---@class SummerPreheaData 物品数据
SummerPreheaData = Class("SummerPreheaData")
-------------构造方法-------------
function SummerPreheaData:ctor(id)
    local config = SummerlogawardLocalData.tab[id]
    self.id = config.activityid
    self.open_time = config.open_time       ---开启时间
    self.end_time = config.end_time         ---结束时间
    self.picIdA = "0"                       ---角色A
    self.dialogueA = "0"                    ---角色A对话
    self.positionAx = "0"                   ---角色A坐标x
    self.positionAy = "0"                   ---角色A坐标y
    self.picIdB = "0"                       ---角色B
    self.dialogueB = "0"                    ---角色B对话
    self.positionBx = "0"                   ---角色B坐标x
    self.positionBy = "0"                   ---角色B标y
    self.music = "0"                        ---背景音乐
    self.awards = nil
    local configDia = SummerlogdialogueLocalData.tab[config.dialogueid]
    if configDia ~= nil then
        self.picIdA = configDia.picida
        self.dialogueA = configDia.dialoguea
        self.positionAx = configDia.positionax
        self.positionAy = configDia.positionay
        self.picIdB = configDia.picidb
        self.dialogueB = configDia.dialogueb
        self.positionBx = configDia.positionbx
        self.positionBy = configDia.positionby
        self.music = configDia.bgm
    end
end

function SummerPreheaData:PushData(_data)
    self.awards = _data
end

return SummerPreheaData