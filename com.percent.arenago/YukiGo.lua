function FindSoBase()
    local list = gg.getRangesList('libil2cpp.so')
    if list[1] then
        so_base=list[1]['start']
    end
end

function OP()
    -- local code_offset = 0x1D1CB00
    local code_code = 'F3 14 E0 E3r'

    local tb = {{}}
    --Gold
    tb[1].address = so_base + 0x4EC0DC
    tb[1].flags = gg.TYPE_DWORD
    tb[1].value = code_code
    gg.setValues(tb)
    --Diamond
    tb[1].address = so_base + 0x4EC268
    tb[1].flags = gg.TYPE_DWORD
    tb[1].value = code_code
    gg.setValues(tb)
    --NormalTokenBoost
    tb[1].address = so_base + 0x4EC3F4
    tb[1].flags = gg.TYPE_DWORD
    tb[1].value = code_code
    gg.setValues(tb)
    
    gg.toast('success')
end

function noAnimation()
    -- local code_offset = 0x1D1CB00
    local code_code = 'F3 14 E0 E3r'

    local tb = {{}}
    --射錢錢移除
    -- tb[1].address = so_base + 0x54C800
    -- tb[1].flags = gg.TYPE_DWORD
    -- tb[1].value = "1E FF 2F E1r"
    -- gg.setValues(tb)
    --無動畫
    tb[1].address = so_base + 0x49C848
    tb[1].flags = gg.TYPE_DWORD
    tb[1].value = '01 70 A0 E3r'
    gg.setValues(tb)

    
    gg.toast('success')
end

function Exit()
    gg.setVisible(true) 
    os.exit()
end

list = {
    OP,
    noAnimation,
    Exit
}

function Page()
    if not so_base then
        FindSoBase()
    end
    local menu = gg.choice({'ooooooofffff','noAnimation','Exit'})


    if menu then
        list[menu]()
    else
        nowPage = nil
    end
end

while true do
    if gg.isVisible() then
        gg.setVisible(false)
        nowPage = Page
    end
    if nowPage then
        nowPage()
    end
end
