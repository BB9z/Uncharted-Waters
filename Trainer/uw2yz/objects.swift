
import Foundation

protocol DataLoad {
    static var dataLength: Int { get }
    init(address: Address, file: FileHandle)
}

struct Port: DataLoad, CustomDebugStringConvertible {
    var raw: Data
    let address: Address
    init(address: Address, file: FileHandle) {
        self.address = address
        let data = file.readBytes(offset: address, length: Self.dataLength)!
        raw = data
        commerceLv = UInt16(data[25]) << 8 + UInt16(data[24])
        commerceInvestment = UInt16(data[27]) << 8 + UInt16(data[26])
        industryLv = UInt16(data[29]) << 8 + UInt16(data[28])
        industryInvestment = UInt16(data[31]) << 8 + UInt16(data[30])
        var supports = data.subdata(in: Range(NSRange(location: 32, length: 6))!)
        supports.exchangeHighLowBits()
        supportInfo = [String: UInt8](uniqueKeysWithValues: zip(["🇵🇹", "🇪🇸", "🇹🇷", "🇬🇧", "🇮🇹", "🇳🇱"], supports))
    }
    static let dataLength = 38

    var commerceLv: UInt16 {
        didSet {
            raw[24] = UInt8(truncatingIfNeeded: commerceLv)
            raw[25] = UInt8(truncatingIfNeeded: commerceLv >> 8)
        }
    }
    let commerceInvestment: UInt16
    var industryLv: UInt16 {
        didSet {
            raw[28] = UInt8(truncatingIfNeeded: industryLv)
            raw[29] = UInt8(truncatingIfNeeded: industryLv >> 8)
        }
    }
    let industryInvestment: UInt16
    /// 六国支持度
    let supportInfo: [String: UInt8]
    var supportDescription: String {
        let supports = supportInfo.sorted { $0.value > $1.value }.filter { $0.value > 0 }
        var result = ""
        supports.forEach { result += "\($0.key) \($0.value)% " }
        return result
    }

    var debugDescription: String {
        raw.subdata(in: Range(NSRange(location: 0, length: 22))!).hexString()
    }
}

/// 角色信息
struct CharacterInfo: CustomStringConvertible, CustomDebugStringConvertible {
    var idx: Int
    var name: String?
    var abilities: Data
    var luck: UInt8 {
        didSet {
            raw[16] = luck
        }
    }
    var navigationLv: UInt8 {
        didSet {
            raw[19] = navigationLv
        }
    }
    var combatLv: UInt8 {
        didSet {
            raw[18] = combatLv
        }
    }
    let navigationExp: UInt16
    let combatExp: UInt16
    var abilitiyDescription: String {
        "航海Lv: \(navigationLv)/\(navigationExp)  战斗Lv: \(combatLv)/\(combatExp)  统御: \(abilities[1])  航海术: \(abilities[0])  知识: \(abilities[3])  直觉: \(abilities[2])  勇气: \(abilities[5])  剑术: \(abilities[4])  魅力: \(abilities[7])  运气: \(luck)"
    }

    /// 年龄
    let age: UInt8
    /// 忠诚
    var loyalty: UInt8 {
        didSet {
            raw[24] = loyalty
        }
    }
    /// 身份
    let role: UInt8
    var roleDescription: String {
        CharacterInfo.roleList.element(at: Int(role)) ?? "??"
    }
    /// 国籍
    let nationality: UInt8
    var nationalityDescription: String {
        switch nationality {
        case 0:
            return "🇵🇹"
        case 1:
            return "🇪🇸"
        case 2:
            return "🇹🇷"
        case 3:
            return "🇬🇧"
        case 4:
            return "🇮🇹"
        case 5:
            return "🇳🇱"
        case 6:
            return "🏴‍☠️"
        case 7:
            return "🇨🇳"
        default:
            return "未知\(nationality)"
        }
    }
    /// 技能
    let skill: Skill

    let address: Address
    var raw: Data
    static let dataLength = 32
    static let roleOffset = 29

    init(index: Int, address: Address, file: FileHandle) {
        let data = file.readBytes(offset: address, length: Self.dataLength)!
        self.address = address
        idx = index
        raw = data
        abilities = data.subdata(in: Range(NSRange(location: 10, length: 8))!)
        luck = data[16]
        navigationLv = data[19]
        combatLv = data[18]
        navigationExp = UInt16(data[21]) << 8 + UInt16(data[20])
        combatExp = UInt16(data[23]) << 8 + UInt16(data[22])
        loyalty = data[23]
        age = data[25]
        role = data[Self.roleOffset]
        // 后四位是国籍，前四位作用未知
        nationality = data[30] & 0b00001111
        skill = Skill(rawValue: data[31])
    }

    var description: String {
        var result = String()
        let nameFormated = (name ?? "").padding(toLength: 13, withPad: " ", startingAt: 0)
        result += nameFormated
        result += "\t\(nationalityDescription) \(roleDescription)"
        result += "  \(abilitiyDescription) 技能: \(skill) 忠诚: \(loyalty) 年龄: \(age)"
//        let u1 = raw.subdata(in: Range(NSRange(location: 0, length: 7))!)
//        let u2 = raw.subdata(in: Range(NSRange(location: 23, length: 5))!)
//        result += "\n未识别 前\(u1.hexString()) 后\(u2.hexString())"
        return result
    }

    var debugDescription: String {
        let nameFormated = (name ?? "").padding(toLength: 13, withPad: " ", startingAt: 0)
        return String(format: "%@\t%@", nameFormated, String(raw[27], radix: 2))
    }

    static let roleList = ["受限", "独立", "舰长", "副官", "会计", "主席航海士", "下属航海士"]

    /// 技能
    struct Skill: OptionSet, CustomStringConvertible {
        let rawValue: UInt8
        var description: String {
            var options = [String]()
            if ((rawValue & (1 << 4)) != 0) { options.append("测量") }
            if ((rawValue & (1 << 3)) != 0) { options.append("地图") }
            if ((rawValue & (1 << 2)) != 0) { options.append("炮术") }
            if ((rawValue & (1 << 1)) != 0) { options.append("会计") }
            if ((rawValue & (1 << 0)) != 0) { options.append("交涉") }
            return options.joined(separator: ", ")
        }
    }
}

/// 坐标
struct Coordinate: CustomStringConvertible, Equatable {
    var x: Int
    var y: Int

    var description: String {
        Self.transform(x: x, y: y)
    }
    static func transform(x: Int, y: Int) -> String {
        var weStr = ""
        var nsStr = ""
        switch x {
        case 0...178:
            weStr = "W\(29 - x/6)"
        case 179...1259:
            weStr = "E\((x - 179)/6)"
        case 1260...2160:
            weStr = "W\(179 - (x - 1260)/6)"
        default:
            weStr = "Err"
        }
        switch y {
        case 0...5:
            nsStr = "N89"
        case 6...640:
            nsStr = "N\(Int((Float(640 - y) / 7.2)))"
        case 641...1076:
            nsStr = "S\(Int(Float(y - 640) / 7.11))"
        default:
            nsStr = "Err"
        }
        return nsStr + weStr
    }
}

/// 舰队
struct Fleet: CustomStringConvertible, DataLoad {
    let coordinate: Coordinate
    /// 航向
    let direction: UInt8
    static let directionList = ["⚓️", "↗️", "➡️", "↘️", "⬇️", "↙️", "⬅️", "↖️", "⬆️"]
    /// 归属
    let belong: Int

    var raw: Data
    let address: Address
    init(address: Address, file: FileHandle) {
        self.address = address
        let data = file.readBytes(offset: address, length: Self.dataLength)!
        raw = data
        coordinate = Coordinate(x: Int(data[0]) + Int(data[1]) << 8, y: Int(data[2]) + Int(data[3]) << 8)
        direction = data[27]
        belong = Int(data[43])
        ships = (0..<10).compactMap { idx -> Ship in
            Ship(address: address + 44 + UInt64(Ship.dataLength) * UInt64(idx), file: file)
        }
    }
    static let dataLength = 144

    var description: String {
        let directionString = Self.directionList.element(at: Int(direction)) ?? "航向未知"
        var coordinateString = String(format: "%4d, %4d", coordinate.x, coordinate.y)
        if let portInfo = Cheat.portCoordinate.first(where: { $1 == coordinate }) {
            coordinateString += " \(portInfo.key)"
        }
        let captain = Cheat.characterList.element(at: belong) ?? "\(belong)?"
        var result = "\(directionString) \(coordinate)[\(coordinateString)] \(captain):\n"
        result += ships.filter { $0.isVaild }.map { "  耐久: \($0.hpCurrent)/\($0.hpMax) 水手: \($0.sailorCount) 炮数: \($0.cannonCount)" }.joined(separator: "\n")
        return result
    }
    var ships: [Ship]
}

/// 舰队中的船信息
struct Ship: DataLoad {
    var raw: Data
    let address: Address
    init(address: Address, file: FileHandle) {
        self.address = address
        let data = file.readBytes(offset: address, length: Self.dataLength)!
        raw = data
        sailorCount = UInt16(data[0]) + UInt16(data[1]) << 8
        hpCurrent = data[3]
        hpMax = data[2]
        propulsion = data[4]
        steering = data[5]
        storeIndex = data[6]
        cannonCount = data[7]
        cannonType = data[9] & 0b00001111
    }
    static let dataLength = 10

    var sailorCount: UInt16 {
        didSet {
            raw[0] = UInt8(truncatingIfNeeded: sailorCount)
            raw[1] = UInt8(truncatingIfNeeded: sailorCount >> 8)
        }
    }
    var hpCurrent: UInt8 {
        didSet {
            raw[3] = hpCurrent
        }
    }
    let hpMax: UInt8
    /// 推进
    let propulsion: UInt8
    /// 转向
    let steering: UInt8
    /// 归属船序号
    let storeIndex: UInt8
    let cannonCount: UInt8
    let cannonType: UInt8
    var isVaild: Bool {
        steering != 0xFF
    }
}

/// 舰船规格
struct ShipSpecs {
    private var raw: Data
    init(data: Data) {
        raw = data
        flage = data[4]
        type = Int(data[5])
        cannonCount = data[7]
        sailorCount = UInt16(data[8]) + UInt16(data[9]) << 8
        volume = UInt16(data[10]) + UInt16(data[11]) << 8
    }
    static let dataLength = 12

    let flage: UInt8
    let type: Int
    let cannonCount: UInt8
    let sailorCount: UInt16
    let volume: UInt16

    static let types = [
        "单桅渔船",     // 00
        "汉萨柯克船",   // 01
        "单桅拉丁帆船", // 02
        "大型双桅渔船", // 03
        "泰里达帆船",   // 04
        "斜帆卡拉维尔", // 05
        "横帆卡拉维尔", // 06
        "双桅海盗船",   // 07
        "拿屋帆船",     // 08
        "卡拉克船",     // 09
        "盖伦军舰",     // 0A
        "阿拉伯战船",   // 0B
        "轻型舢板船",   // 0C
        "护卫舰",       // 0D
        "英式盖伦",     // 0E
        "英式战列舰",   // 0F
        "重装战列舰",   // 10
        "中国式帆船",   // 11
        "轻型排桨船",   // 12
        "佛兰德式加莱", // 13
        "加莱赛战舰",   // 14
        "加莱快船",     // 15
        "铁甲舰",       // 16
        "安宅船",       // 17
        "关船",         // 18
    ]

    static let statueTypes = ["无", "海兽", "提督", "独角兽", "狮子", "鹰", "伟人", "海神", "海龙", "天使", "女神"]
    static let cannonTypes = ["无", "散弹", "轻曲射", "曲射", "加农曲射", "轻加农", "加农", "臼炮"]
}

/// 舰船状态
struct ShipStatus: DataLoad {
    let address: Address
    var raw: Data
    init(address: Address, file: FileHandle) {
        let data = file.readBytes(offset: address, length: Self.dataLength)!
        self.address = address
        raw = data
        food = UInt16(data[0]) + UInt16(data[1]) << 8
        water = UInt16(data[2]) + UInt16(data[3]) << 8
        material = UInt16(data[4]) + UInt16(data[5]) << 8
        cannonball = UInt16(data[6]) + UInt16(data[7]) << 8
        captainID = Int(data[26])
        statue = data[28]
        health = data[29]
    }
    static let dataLength = 30

    var food: UInt16 {
        didSet {
            raw[0] = UInt8(truncatingIfNeeded: food)
            raw[1] = UInt8(truncatingIfNeeded: food >> 8)
        }
    }
    var water: UInt16 {
        didSet {
            raw[2] = UInt8(truncatingIfNeeded: water)
            raw[3] = UInt8(truncatingIfNeeded: water >> 8)
        }
    }
    let material: UInt16
    var cannonball: UInt16 {
        didSet {
            raw[6] = UInt8(truncatingIfNeeded: cannonball)
            raw[7] = UInt8(truncatingIfNeeded: cannonball >> 8)
        }
    }
    let captainID: Int
    let statue: UInt8
    var health: UInt8 {
        didSet {
            raw[29] = health
        }
    }
}

struct MyShip: CustomStringConvertible {
    let ship: Ship
    let status: ShipStatus
    let spec: ShipSpecs
    let captain: CharacterInfo
    var type: String {
        if spec.type == 0xFF {
            return "空"
        } else {
            return ShipSpecs.types.element(at: spec.type) ?? "未知船"
        }
    }

    var description: String {
        var result = ""
        let statue = ShipSpecs.statueTypes.element(at: status.statue.int) ?? "?"
        let cannon = ShipSpecs.cannonTypes.element(at: ship.cannonType.int) ?? "炮?"

        result += "\(type) \(captain.name ?? "?")\n"
        result += "  耐久: \(ship.hpCurrent)/\(ship.hpMax) 水手: \(ship.sailorCount)/\(spec.sailorCount) 健康: \(status.health) 船首像: \(statue) \(cannon): \(ship.cannonCount)/\(spec.cannonCount)\n"
        result += "  容积: \(spec.volume) 水: \(status.water / 10) 粮: \(status.food / 10) 资材: \(status.material) 炮弹: \(status.cannonball)"
        return result
    }
}
