-- Cache Component Type 缓存组件类型
CCTypeEnum = {
    Obj = 1,                -- GameObject 游戏对象
    Img = 2,                -- UGUI Image 图片组件
    Txt = 3,                -- UGUI Text 文字组件
    Btn = 4,                -- UGUI Button 按钮组件
    Slide = 5,              -- UGUI Slide进度条组件
    RayEmpty = 8,           -- 空图片事件接收器，不会产出overdraw
    InputField = 9,         -- 输入框
    Template = 10,          -- 模板
    ScrAdapter = 11,        -- 水平/垂直 滑动适配器
    ScrGridAdapter = 12,    -- Grid 滑动适配器
    Tog = 13,               -- Toggle 组件
    Dropdown = 14,          -- Dropdown 组件
    RawImage = 15,          -- RawImage 组件
    DisplayUGUI = 16,       -- DisplayUGUI 组件
    TextCd = 17,            -- TextCd 组件
    LoopScrollRect = 18,    -- LoopScrollRect
    VideoContral = 19,      -- VideoContral 视频控制器
    TMP = 20,               -- TextMeshProUGUI 组件
    TMPInputField = 21,     -- TMP_InputField 组件
    TMPDropdown = 22,       -- TMP_Dropdown 组件
}

CCType = {
    [CCTypeEnum.Obj] =              {Name = 'GameObject'},
    [CCTypeEnum.Img] =              {Name = 'Image'},
    [CCTypeEnum.Txt] =              {Name = 'Text'},
    [CCTypeEnum.Btn] =              {Name = 'Button'},
    [CCTypeEnum.Slide] =            {Name = 'Slider'},
    [CCTypeEnum.RayEmpty] =         {Name = 'RaycastEx'},
    [CCTypeEnum.InputField] =       {Name = 'InputField'},
    [CCTypeEnum.Template] =         {Name = 'UITemplate'},
    [CCTypeEnum.ScrAdapter] =       {Name = 'ScrollAdapterHolder'},
    [CCTypeEnum.ScrGridAdapter] =   {Name = 'ScrollAdapterGridHolder'},
    [CCTypeEnum.Tog] =              {Name = 'Toggle'},
    [CCTypeEnum.Dropdown] =         {Name = 'Dropdown'},
    [CCTypeEnum.RawImage] =         {Name = 'RawImage'},
    [CCTypeEnum.DisplayUGUI] =      {Name = 'DisplayUGUI'},
    [CCTypeEnum.TextCd] =           {Name = 'TextCd'},
    [CCTypeEnum.LoopScrollRect] =   {Name = 'LoopScrollRect'},
    [CCTypeEnum.VideoContral] =     {Name = 'VideoContral'},
    [CCTypeEnum.TMP] =              {Name = 'TextMeshProUGUI'},
    [CCTypeEnum.TMPInputField] =    {Name = 'TMP_InputField'},
    [CCTypeEnum.TMPDropdown] =    {Name = 'TMP_Dropdown'},
}

-- 界面状态
UIState = {
    LoadLua = 1,
    Show    = 2,
    BackShow = 3,
    Stay    = 4,
    Hide    = 5,
    Close   = 6,
}
-- 界面状态字典
UIStateName = {
    [UIState.LoadLua]   = "LoadLua",
    [UIState.Show]      = "Show",
    [UIState.BackShow]  = "BackShow",
    [UIState.Stay]      = "Stay",
    [UIState.Hide]      = "Hide",
    [UIState.Close]     = "Close",
}
-- 界面层级
UILayerLv = {
    Background  = 1,
    Normal      = 2,
    Pop         = 3,
    Guide       = 4,
    Lock        = 5,
}