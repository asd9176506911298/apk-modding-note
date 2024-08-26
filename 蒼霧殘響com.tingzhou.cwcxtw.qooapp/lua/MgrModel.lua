MgrModel = {}
--------数据模型初始化---------
function MgrModel.Init()
    MgrModel.Install()
    MgrModel.LoginInit()
end

function MgrModel.Install()
    ---数据模型
    require("Model/Player/PlayerControl")           ---玩家控制器
    require("Model/Item/ItemControl")               ---物品控制器
    require("Model/Core/CoreControl")               ---核心控制器
    require("Model/Equip/EquipControl")             ---共鸣装备控制器
    require("Model/Hero/HeroControl")               ---角色控制器
    require("Model/Storm/StormControl")             ---关卡控制器
    require("Model/Monster/MonsterControl")         ---怪物控制器
    require("Model/Mail/MailControl")               ---邮件控制器
    require("Model/Team/TeamControl")               ---阵容控制器
    require("Model/Task/TaskControl")               ---任务控制器
    require("Model/Shop/ShopControl")               ---商店控制器
    require("Model/RedDot/RedDotControl")           ---红点控制器
    require("Model/SysLock/SysLockControl")         ---系统解锁控制器
    require("Model/PosterGirl/PosterGirlControl")   ---看板娘控制器
    require("Model/Novice/NoviceControl")           ---引导控制器
    require("Model/Passport/PassportControl")       ---通行证控制器
    require("Model/Activity/ActivityControl")       ---活动控制器
    require("Model/Activity/EventRaidControl")       ---活动事件控制器
    require("Model/Ark/ArkControl")       ---活动事件控制器
    require("Model/SysNotice/SysNoticeControl")       ---活动事件控制器
    require("Model/Skill/SkillDetailControl")       ---活动事件控制器
    require("Model/Illustration/IllustrationControl")       ---图鉴控制器
    require("Model/Notice/NoticeControl")           ---公告控制器
    require("Model/Banner/BannerControl")           ---公告控制器
    require("Model/CardDraw/CardDrawControl")       ---抽卡控制器
    require("Model/Summer/SummerControl")           ---夏日活动
    require("Model/Summer/SummerMapControl")           ---夏日地图
    require("Model/Activity/ActiveChapterControl")    ---活动章节
    require("Model/Novice/ActiveTutorialControl")   ---活动引导控制器
    require("Model/Guild/GuildControl")             ---工会控制器
    require("Model/Illustration/SkillAtlasControl")   ---技能图鉴控制器
    require("Model/Illustration/TeamAtlasControl")   ---队伍图鉴控制器
    require("Model/Illustration/OriginalControl")   ---原罪图鉴控制器
    require("Model/Illustration/ArtAtlasControl")   ---原罪图鉴控制器
    require("Model/Fund/FundControl")               ---基金控制器
    require("Model/Skill/SkillUpControl")               ---技能升级消耗控制器
    require("Model/HaiYue/HaiYueControl")               ---海月活动控制器
    ---主界面根节点
    RedDotControl.RegisterBaseDot("Home")
--[[    ---新手任务
    RedDotControl.RegisterChildDot("NoviceTask","Home")]]
    ---通行证任务
    RedDotControl.RegisterChildDot("Passes","Home")
    RedDotControl.RegisterChildDot("ActivityTask","Passes")
    RedDotControl.RegisterChildDot("ActivityDayTask","ActivityTask")
    RedDotControl.RegisterChildDot("ActivityWeekTask","ActivityTask")
    RedDotControl.RegisterChildDot("ActivityPhaseTask","ActivityTask")
    RedDotControl.RegisterChildDot("ActivityTaskReward","Passes")
--[[    ---活动任务红点
    RedDotControl.RegisterChildDot("EventRaidTask","Home")
    RedDotControl.RegisterChildDot("EventRaidTaskDaily","EventRaidTask")
    RedDotControl.RegisterChildDot("EventRaidTaskTotal","EventRaidTask")]]
    ---任务根节点
    RedDotControl.RegisterChildDot("Task","Home")
    ---邮件根节点
    RedDotControl.RegisterChildDot("Mail","Home")
    ---图鉴根节点
    RedDotControl.RegisterChildDot("Dex","Home")
    ---驾驶员根节点
    RedDotControl.RegisterChildDot("Role","Home")
    ---背包根节点
    RedDotControl.RegisterChildDot("Bag","Home")
--[[    ---签到根节点
    RedDotControl.RegisterChildDot("WeekSign","Home")]]
    ---好友根节点
    RedDotControl.RegisterChildDot("Friend","Home")
    ---指挥室根节点
    RedDotControl.RegisterChildDot("Ark","Home")
    ---公告根节点
    RedDotControl.RegisterChildDot("Notice","Home")
    ---活动入口根节点
    RedDotControl.RegisterChildDot("Activity","Home")
    ---七日签到
    RedDotControl.RegisterChildDot("WeekSign","Activity")
    ---首充
    RedDotControl.RegisterChildDot("FirstCharge","Activity")
    ---签到
    RedDotControl.RegisterChildDot("Sign","Activity")
    ---基金
    RedDotControl.RegisterChildDot("Fund","Activity")
    RedDotControl.RegisterChildDot("FundPoint","Fund")
    RedDotControl.RegisterChildDot("FundTask","Fund")
    ---剧情活动任务红点
    RedDotControl.RegisterChildDot("EventRaidTask","Activity")
    RedDotControl.RegisterChildDot("EventRaidTaskDaily","EventRaidTask")
    RedDotControl.RegisterChildDot("EventRaidTaskTotal","EventRaidTask")
    ---成就根节点
    RedDotControl.RegisterChildDot("AchieveTask","Dex")
    RedDotControl.RegisterChildDot("AchieveTask1","AchieveTask")
    RedDotControl.RegisterChildDot("AchieveTask2","AchieveTask")
    RedDotControl.RegisterChildDot("AchieveTask3","AchieveTask")
    RedDotControl.RegisterChildDot("AchieveTask4","AchieveTask")
    ---新手任务
    RedDotControl.RegisterChildDot("NoviceTask","Activity")
    ---战术指导
    RedDotControl.RegisterChildDot("TacticalGuidance","Activity")
    ---联合讨伐
    RedDotControl.RegisterChildDot("WorldBoss","Activity")
    ---虚与梦
    RedDotControl.RegisterChildDot("ActivityPlot","Activity")
    ---核心碎片节点
    RedDotControl.RegisterChildDot("CorePz","Bag")
    ---共鸣背包节点
    RedDotControl.RegisterChildDot("GearBag","Bag")
    ---背包道具节点
    RedDotControl.RegisterChildDot("BagItem","Bag")
    ---机甲核心节点
    RedDotControl.RegisterChildDot("MechaCore","Bag")
    ---队伍图鉴节点
    RedDotControl.RegisterChildDot("TeamDex","Dex")
    ---每日任务节点
    RedDotControl.RegisterChildDot("DayTask","Task")
    ---每周任务节点
    RedDotControl.RegisterChildDot("WeekTask","Task")
    ---每月任务节点
    RedDotControl.RegisterChildDot("MonthTask","Task")
    ---每日积分任务节点
    RedDotControl.RegisterChildDot("DayIntegralTask","DayTask")
    ---每周积分任务节点
    RedDotControl.RegisterChildDot("WeekIntegralTask","WeekTask")
    ---每月积分任务节点
    RedDotControl.RegisterChildDot("MonthIntegralTask","MonthTask")
    ---章节宝箱节点
    RedDotControl.RegisterChildDot("ScrollBox","Home")
    ---主界面演习节点
    RedDotControl.RegisterChildDot("YanXiHome","Home")
    ---夏活
    RedDotControl.RegisterChildDot("Summer","Activity")
    ---夏活任务
    RedDotControl.RegisterChildDot("SummerTask","Summer")
    RedDotControl.RegisterChildDot("SummerDailyTask","SummerTask")
    RedDotControl.RegisterChildDot("SummerAchievement","SummerTask")
    ---月冕
    RedDotControl.RegisterChildDot("HaiYue","Activity")
    RedDotControl.RegisterChildDot("HaiYueDailyTask","HaiYue")
    RedDotControl.RegisterChildDot("HaiYueAchievement","HaiYue")
end

---登录推送数据
function MgrModel.PushData(data, isReconnet)
    PlayerControl.PushPlayerData(data)                          ---填充玩家数据
    ItemControl.PushGroupItemData(data.goods)                   ---填充物品数据
    --CoreControl.PushGroupCoreData(data.armors)                  ---填充核心数据
    EquipControl.CreateAllEquip()                               ---创建所有共鸣装备
    MonsterControl.CreateAllMonster()                           ---创建所有怪物信息
    TaskControl.CreateAllTask(data)                             ---创建所有任务
    TaskControl.RegisterClearTaskToC()
    EquipControl.PushGroupEquipData(data.equips)                ---填充共鸣装备数据
    HeroControl.CreateAllHeroData()                             ---创建角色数据
    HeroControl.CreateAllSkinData()                             ---创建皮肤数据
    HeroControl.CreateAllOriginalHeroData()
    HeroControl.PushGroupHeroData(data.heros)                   ---填充角色数据
    HeroControl.PushGroupHeroSkinsData(data.skin)               ---填充角色数据
    PosterGirlControl.CreateAllPosterGirl()                     ---创建所有看板娘数据
    StormControl.CreateAllStorm()                               ---创建关卡数据
    StormControl.PushGroupPointData(data.levels)                ---填充关卡数据
    StormControl.PushActivityPointData(data.activity)           ---填充活动关卡数据
    StormControl.PushScrollBox(data.scrollBox)                  ---更新章节宝箱
    StormControl.PushTowerData(data.tower)                      ---更新红色巨塔
    StormControl.PushGuideData(data.guide)                      ---更新战术指导
    MailControl.ReLoadMailData(data.newEmailNum)                ---邮件数据
    MailControl.ReLoadMailBirthdayData(data.unGetEmail)         ---生日邮件数据
    PostMailViewModel.MailBirthdayUnCaCheData = data.unGetEmail
    TeamControl.InitTeamData(data.TeamInfo)                     ---初始化阵容数据
    ShopControl.InitShopData()                                  ---初始化商店数据
    ShopControl.PushGroupShopItem(data.shops)                   ---更新商店商品信息
    SysLockControl.InitSysLock()
    IllustrationControl.InitIllustrationData(data)              ---初始化图鉴数据
    if not isReconnet then
        NoviceControl.Init()                                    ---初始化引导
        NoviceControl.PushNoviceData(data.tutorial)
    end
    ArkControl.Init(data.home,data.expeditionInfos)             ---初始化指挥室
    ActivityControl.InitActivity(data.events)                   ---获取活动数据
    SysNoticeControl.CheckNotice(data.marquee)                  ---获取跑马灯数据
    SkillDetailControl.InitSkillDetail()                        ---初始化技能信息
    PlayerControl.PushBuyNumber(data)                  ---更新体力、演习挑战券购买次数
    BannerControl.InitBannerData()                              ---初始化Banner配置数据
    PassportControl.PushPassport(data.bigMonthCardVersion,data.bigMonthCardBuyTime)   ---推送通行证版本和购买时间
    CardDrawControl.Init()                                      ---初始化卡池数据
    CardDrawControl.PushCardPoolData(data.lotterys)
    PlayerControl.PushFriendApplyCount(data.newFriendNum)       ---初始化待审批的好友数量
    PlayerControl.PushFriendSupport(data.supportNum)
    ActiveChapterControl.Init()                                 ---活动章节数据
    SummerMapControl.Init()                                     ---夏日地图数据
    SummerMapControl.SetMapPos(data.activityPos)                ---设置各地图,玩家所在位置
    ActiveTutorialControl.Init()                                ---初始化活动引导
    GuildControl.InitData(data.alliance)                                     ---初始化公会信息
    GuildControl.SetCalmTime(data.calmTime)                     ---申请公会冷静期时间戳
    ItemControl.RequireBagItem()                                ---初始化背包
    SummerControl.Init(data.summerAward)                        ---夏日活动数据
    MgrChatNet.Init(data.chatAddr)                              ---分配的聊天服务地址
    StormViewModel.SendStormBossData2()                         ---初始化联合讨伐
    FundControl.Init()                                          ---基金
    SkillUpControl.InitSkillUpData()                            ---技能升级消耗
    HaiYueControl.Init()                                        ---海月活动
end

function MgrModel.LoginInit()
    NoticeControl.InitNoticeData()                              ---初始化公告配置数据
end

function MgrModel.ClearAll()
    PlayerControl.Clear()
    ItemControl.Clear()
    CoreControl.Clear()
    EquipControl.Clear()
    MonsterControl.Clear()
    TaskControl.Clear()
    HeroControl.Clear()
    PosterGirlControl.Clear()
    StormControl.Clear()
    MailControl.Clear()
    TeamControl.Clear()
    ShopControl.Clear()
    SysLockControl.Clear()
    NoviceControl.Clear()
    ArkControl.Clear()
    ActivityControl.Clear()
    SysNoticeControl.Clear()
    SkillDetailControl.Clear()
    ArkViewModel.Clear()
    BagViewModel.Clear()
    EventRaidViewModel.Clear()
    FriendViewModel.Clear()
    IllustrationViewModel.Clear()
    NormalCardDrawViewModel.Clear()
    NoviceViewModel.Clear()
    PassportViewModel.Clear()
    PlayerAvatarViewModel.Clear()
    PlotViewModel.Clear()
    PosterGirlViewModel.Clear()
    PostMailViewModel.Clear()
    PVPViewModel.Clear()
    RoleCardViewModel.Clear()
    SignViewModel.Clear()
    StormViewModel.Clear()
    NoticeControl.Clear()
    BannerControl.Clear()
    CardDrawControl.Clear()
    SummerControl.Clear()
    FightVideoViewModel.Clear()
    SkillAtlasControl.Clear()
    TeamAtlasControl.Clear()
    OriginalControl.Clear()
    ArtAtlasControl.Clear()
    ActiveTutorialControl.Clear()
    GuildControl.Clear()
    SummerMapControl.Clear()
    HelpViewModel.Clear()
    FundControl.Clear()
    SkillUpControl.Clear()
    HaiYueControl.Clear()
end

return MgrModel
