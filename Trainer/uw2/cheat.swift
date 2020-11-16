
import Foundation

// MARK: - 数据
typealias Address = UInt64

enum Cheat: Address {
    /// 现金
    case money = 1672

    /// 位置
    case port = 38
    case port2 = 41

    /// 当前显示海域的屏幕坐标
    case screenCoordinate = 1152

    /// 声望
    static func reputation(_ roleIdx: Int) -> Address {
        Address(1588 + roleIdx * 14)
    }

    /// 六国贡献
    static func contribution(_ roleIdx: Int) -> Address {
        Address(1594 + roleIdx * 14)
    }

    /// 爵位
    static func title(_ roleIdx: Int) -> Address {
        Address(1600 + roleIdx * 14)
    }
    static let titleList = ["平民", "士爵", "准勋爵士", "勋爵士", "准男爵", "男爵", "子爵", "伯爵", "侯爵", "公爵"]

    case characterBase = 1683

    static let characterList = [
        "约翰·法雷尔",       // 0
        "卡特琳娜·艾兰茨",   // 1
        "奥托·斯宾诺拉",     // 2
        "恩斯特·洛佩斯",     // 3
        "皮耶德·康迪",       // 4
        "阿兰·维萨斯",       // 5
        "西蒙·斯卡隆",       // 06
        "路易·科斯塔",       // 07
        "劳伦索·皮特",       // 08
        "洛波·菲雷拉",       // 09
        "莱佛尔·塞尔朗",     // 0A
        "迪艾哥·索萨",       // 0B
        "阿方索·安德拉德",   // 0C
        "卡洛西亚·阿尔瓦雷斯",  // 0D
        "冈罗萨·西尔维拉",   // 0E
        "艾斯图帕·阿尔特加", // 0F
        "斯蒂凡·佩龙",       // 10
        "佩拉罗松·阿基雷",   // 11
        "巴尔伯·奥利德",     // 12
        "雅各布·波佟文",     // 13
        "乌果·蒙塔古",       // 14
        "皮耶德·耐普尔",     // 15
        "布律内尔·罗耀拉",   // 16
        "埃鲁南·贝利欧",     // 17
        "乌宗·卡夫",         // 18
        "伊萨克尔·雅萨尔",   // 19
        "卡拉·罗姆",         // 1A
        "杜雷·希恩",         // 1B
        "塞南·帕夏",         // 1C
        "盖茨·凯莫尔",       // 1D
        "阿弗梅特·穆西丁",   // 1E
        "萨利姆·哥宝德",     // 1F
        "丹尼尔·米罗莎",     // 20
        "约瑟夫·伊斯特曼",   // 21
        "托马斯·格拉姆",     // 22
        "阿尔弗来德·罗",     // 23
        "埃德蒙·哈维",       // 24
        "罗伯特·怀尔德",     // 25
        "文克特·拉赛尔",     // 26
        "威廉·克来伯",       // 27
        "沃尔塔·劳伦斯",     // 28
        "查理·格拉夫登",     // 29
        "格廷·本森",         // 2A
        "约瑟夫·罗德维",     // 2B
        "卡米勒·萨伯罗拉",   // 2C
        "约翰尼·维萨里",     // 2D
        "安德鲁·纪尧姆",     // 2E
        "卡比尔·卡鲁其",     // 2F
        "奥克斯·巴里巴格",   // 30
        "安德鲁·多利亚",     // 31
        "胡安·巴斯克塞",     // 32
        "雨果·奥尔扎克",     // 33
        "克里斯蒂·格罗提兹", // 34
        "乌泽·休根",         // 35
        "莫里斯·里迪尔",     // 36
        "皮耶德·威尔斯",     // 37
        "威廉姆·海因",       // 38
        "朱里安·费卢米",     // 39
        "康耐尔斯·亨德利克", // 3A
        "杰克逊·勃卢姆",     // 3B
        "安东尼奥·卡恩",     // 3C
        "皮埃尔·卢格兰",     // 3D
        "路易斯·斯科特",     // 3E
        "约翰·戴维斯",       // 3F
        "希尔顿·雷斯",       // 40
        "艾登·雷斯",         // 41
        "穆哈默德·夏洛克",   // 42
        "沃尔格·阿里",       // 43
        "杰克·拉康姆",       // 44
        "洛克·阿尔姆克",     // 45
        "恩里克·马洛尼",     // 46
        "多明戈·马耐斯",     // 47
        "弗兰克·桑多",       // 48
        "安德鲁·纪德",       // 49
        "艾德蒙·吉尔巴特",   // 4A
        "马休·路易",         // 4B
        "凯麦隆·斯蒂芬",     // 4C
        "路德·斯塔特",       // 4D
        "加汉·萨利姆",       // 4E
        "彼利·雷斯",         // 4F
        "阿弗美特·古拉尼",   // 50
        "阿兰·法西",         // 51
        "萨加诺斯·贝尔",     // 52
        "法鲁南·冯特",       // 53
        "约翰·卡斯特罗",     // 54
        "米开罗·莱尔",       // 55
        "迪戈·法格迪斯",     // 56
        "格尔蒂·佩雷拉",     // 57
        "马诺尔·佩斯特罗",   // 58
        "弗朗西斯科·阿尔瓦莱斯",  // 59
        "路易·法雷",         // 5A
        "凡·克萨",           // 5B
        "马鲁汀·帕尔博",     // 5C
        "贝尔南特·戈麦斯",   // 5D
        "迪艾哥·百兰斯",     // 5E
        "欧马·奥力德",       // 5F
        "阿伦索·门特萨",     // 60
        "安东尼·金索",       // 61
        "劳伦斯·艾德瓦斯",   // 62
        "劳尔·费奇",         // 63
        "安东尼·夏利",       // 64
        "阿洛基·约翰尼",     // 65
        "佛朗斯·郎姆",       // 66
        "尼克·斯蒂芬",       // 67
        "阿尔桑德·班卓",     // 68
        "阿尔白·斯基拉奇",   // 69
        "克耐特·肖特",       // 6A
        "安普洛斯·艾因卡",   // 6B
        "盖勒克·修帕",       // 6C
        "汉斯·休塔特",       // 6D
        "雅各布·威尔维克",   // 6E
        "伊凡·阿尔冯斯",     // 6F
        "安东尼奥·品塔特",   // 70
        "卡扎莱·费德罗",     // 71
        "弗兰克·罗罗诺阿",   // 72
        "亨利·蒙斯法尔",     // 73
        "加里·费夏",         // 74
        "艾德凡·但比",       // 75
        "洛帕特·罗",         // 76
        "理查德·哈克斯",     // 77
    ]

    /// 手下列表
    case employees = 6022
    /// 薪水列表
    case salaries = 6052

    /// 物品
    case items = 6082

    /// 物品列表，0xFF 无物品
    static let itemList = [
        "匕首",    //
        "短剑",    //
        "长剑",    //
        "刺剑",    //
        "重剑",    //
        "长刺剑",    //
        "短佩剑",    //
        "土耳其弯刀",    //
        "日本刀",    //
        "短弯刀",    //
        "阔剑",    //
        "青龙偃月刀",    //
        "蛇形剑",    //
        "长柄剑",    //
        "双刃宽刀",    //
        "佩剑",    //
        "硬锴",    //
        "锁子甲",    //
        "短甲",    //
        "连环甲",    //
        "四分仪",    //
        "六分仪",    //
        "经纬仪",    //
        "怀表",    //
        "望远镜",    //
        "猫",    //
        "？",    //
        "？",    //
        "白虎半月刀",    //
        "私掠许可证(葡)",    //
        "私掠许可证(西)",    //
        "私掠许可证(土)",    //
        "私掠许可证(英)",    //
        "私掠许可证(意)",    //
        "私掠许可证(荷)",    //
        "免税证(葡)",    //
        "免税证(西)",    //
        "免税证(土)",    //
        "免税证(英)",    //
        "免税证(意)",    //
        "免税证(荷)",    //
        "老鼠药",    //
        "神圣香油",    //
        "坏血病药",    //
        "王冠",    //
        "？",    //
        "免罪苻",    //
        "？",    //
        "？",    //
        "？",    //
        "真丝披肩",    //
        "华服",    //
        "纯银头饰",    //
        "银梳",    //
        "貂皮大衣",    //
        "珠冠",    //
        "孔雀羽扇",    //
        "丝带",    //
        "天鹅绒大衣",    //
        "钻石王冠",    //
        "珍珠手镯",    //
        "红宝石发钗",    //
        "银烛台",    //
        "翡翠百宝箱",    //
        "宝冠",    //
        "金手镯",    //
        "蓝宝石戒指",    //
        "孔雀石小箱",    //
        "白银胸针",    //
        "红宝石戒指",    //
        "106(秘宝)",    //
        "班达尔(秘宝)",    //
        "查克斯(秘宝)",    //
        "妖刀村正",    //
        "神剑",    //
        "圣骑士甲",    //
        "圣骑士剑",    //
        "魔刀",    //
        "艾罗尔宝甲",    //
        "假面地图",    //
        "祭坛地图",    //
        "雕像地图",    //
        "石板地图",    //
        "水晶玉地图",    //
        "火焰之壶地图",    //
        "魔剑地图",    //
        "藏金图",    //
        "圣人宝杖地图",    //
        "古地图",    //
        "纯金假面",    //
        "翡翠祭坛",    //
        "古神雕像",    //
        "黑曜石石板",    //
        "黑暗神水晶玉",    //
        "火焰之壶",    //
        "破坏神宝剑",    //
        "黄金藏宝图",    //
        "圣人宝杖",    //
        "最后的财宝"    //
    ]

    /// 全舰队地址
    case fleetListBase = 6114
    /// 当前舰队
    case fleet = 16194
    /// 名下所有船只
    case shipStore = 17694

    case portListBase = 19750

    /// 港口列表
    static let portList = [
        "里斯本",      // 00
        "塞维利亚",    // 01
        "伊斯坦布尔",  // 02
        "巴塞罗纳",    // 03
        "阿尔及尔",    // 04
        "突尼斯",      // 05
        "巴伦西亚",    // 06
        "马赛",        // 07
        "热那亚",      // 08
        "比萨",        // 09
        "那不勒斯",    // 0A
        "锡腊库扎",    // 0B
        "帕尔马",      // 0C
        "威尼斯",      // 0D
        "拉古扎",      // 0E
        "干地亚",      // 0F
        "雅典",        // 10
        "萨洛尼卡",    // 11
        "亚力山卓",    // 12
        "雅法",        // 13
        "贝鲁特",      // 14
        "尼科西亚",    // 15
        "的黎波里",    // 16
        "卡法",        // 17
        "特纳",        // 18
        "特拉比松",    // 19
        "休达",        // 1A
        "波尔多",      // 1B
        "南特",        // 1C
        "伦敦",        // 1D
        "布里斯托尔",  // 1E
        "都柏林",      // 1F
        "安特卫普",    // 20
        "阿姆斯特丹",  // 21
        "哥本哈根",    // 22
        "汉堡",        // 23
        "奥斯陆",      // 24
        "斯德哥尔摩",  // 25
        "卢卑克",      // 26
        "但泽",        // 27
        "里加",        // 28
        "卑尔根",      // 29
        "加拉加斯",    // 2A
        "喀他基那",    // 2B
        "哈瓦那",      // 2C
        "马加里塔",    // 2D
        "巴拿马城",    // 2E
        "波鲁特内罗",  // 2F
        "圣多明哥",    // 30
        "委拉克鲁斯",  // 31
        "牙买加",      // 32
        "危地马拉",    // 33
        "伯南布哥",    // 34
        "里约热内卢",  // 35
        "马拉开波",    // 36
        "圣地亚哥",    // 37
        "卡宴",        // 38
        "马德拉维",    // 39
        "桑塔库鲁兹",  // 3A
        "圣约鲁吉",    // 3B
        "比绍",        // 3C
        "罗安达",      // 3D
        "阿尔金岛",    // 3E
        "巴瑟斯特",    // 3F
        "廷巴克图",    // 40
        "阿比让",      // 41
        "索法拉",      // 42
        "马林迪",      // 43
        "摩加迪沙",    // 44
        "蒙巴萨岛",    // 45
        "莫桑比克",    // 46
        "克利马内",    // 47
        "亚丁",        // 48
        "根布龙",      // 49
        "马沙华",      // 4A
        "开罗",        // 4B
        "巴斯拉",      // 4C
        "麦加",        // 4D
        "卡塔尔",      // 4E
        "社拉夫",      // 4F
        "马斯喀特",    // 50
        "第乌",        // 51
        "柯钦",        // 52
        "锡兰",        // 53
        "安波那",      // 54
        "果阿",        // 55
        "马六甲",      // 56
        "德那第",      // 57
        "班达",        // 58
        "帝汶",        // 59
        "帕塞",        // 5A
        "巽他",        // 5B
        "卡利卡特",    // 5C
        "邦加",        // 5D
        "泉州",        // 5E
        "澳门",        // 5F
        "河内",        // 60
        "长安",        // 61
        "界",          // 62
        "长崎",        // 63
    ]

    static let portCoordinate = [
        "里斯本": Coordinate(x: 120, y: 358),
        "塞维利亚": Coordinate(x: 142, y: 374),
        "热那亚": Coordinate(x: 230, y: 320),
        "伊斯坦布尔": Coordinate(x: 352, y: 344),
        "伦敦": Coordinate(x: 180, y: 262),
        "阿姆斯特丹": Coordinate(x: 216, y: 248),
        "那不勒斯": Coordinate(x: 260, y: 350),
        "那不勒斯2": Coordinate(x: 260, y: 348),
        "威尼斯": Coordinate(x: 258, y: 318),
        "马加里塔": Coordinate(x: 1922, y: 584),
        "波鲁特内罗": Coordinate(x: 1826, y: 596),
    ]

    static let cargoList = [
        "丁香",  // 00
        "桂皮",  // 01
        "胡椒",  // 02
        "肉豆蔻",  // 03
        "甘椒",  // 04
        "生姜",  // 05
        "烟草",  // 06
        "茶叶",  // 07
        "咖啡",  // 08
        "可可",  // 09
        "砂糖",  // 0A
        "乳制品",  // 0B
        "鱼肉",  // 0C
        "谷类",  // 0D
        "橄榄油",  // 0E
        "葡萄酒",  // 0F
        "岩盐",  // 10
        "丝绸",  // 11
        "木棉",  // 12
        "羊毛",  // 13
        "黄麻 ",  // 14
        "棉织品",  // 15
        "丝织品",  // 16
        "毛织品",  // 17
        "天鹅绒",  // 18
        "麻布",  // 19
        "珊瑚",  // 1A
        "琥珀",  // 1B
        "象牙",  // 1C
        "珍珠",  // 1D
        "玳瑁甲",  // 1E
        "黄金",  // 1F
        "白银",  // 20
        "铜矿石",  // 21
        "锡矿石",  // 22
        "铁矿石",  // 23
        "美术品",  // 24
        "绒毯",  // 25
        "麝香",  // 26
        "香水",  // 27
        "玻璃球",  // 28
        "染料",  // 29
        "陶瓷器",  // 2A
        "玻璃器皿",  // 2B
        "武器",  // 2C
        "木材",  // 2D
    ]
}

