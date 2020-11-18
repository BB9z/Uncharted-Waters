
import Foundation

// MARK: - 命令

class Command {
    private let file: FileHandle
    init() {
        guard let saveFilePath = CommandLine.arguments.element(at: 1) as NSString? else {
            print("请传入文件路径")
            Self.printUsage()
            exit(EXIT_FAILURE)
        }
        let saveFileURL = URL(fileURLWithPath: saveFilePath.expandingTildeInPath, isDirectory: false)
        do {
            file = try FileHandle(forUpdating: saveFileURL)
        } catch {
            print("FileHandle 创建失败: " + error.localizedDescription)
            exit(EXIT_FAILURE)
        }
        loadCurrentCharacter()
    }

    deinit {
        file.closeFile()
    }

    // MARK: - 状态

    private func loadCurrentCharacter() {
        let roleIDs = [0, 1, 2, 3, 4, 5, 125]
        for idx in roleIDs {
            let cInfo = characterList[idx]
            if cInfo.role == 1 {
                characterIndex = idx
                currentCharacter = cInfo
                break
            }
        }
    }
    var characterIndex = -1
    var currentCharacter: CharacterInfo?

    lazy var characterList: [CharacterInfo] = {
        let address = Cheat.characterBase.rawValue
        var items = [CharacterInfo]()
        Cheat.characterList.enumerateElements { cName, idx, _ in
            var cInfo = CharacterInfo(index: idx, address: address + UInt64(CharacterInfo.dataLength) * UInt64(idx), file: file)
            cInfo.name = cName
            items.append(cInfo)
        }
        return items
    }()

    lazy var employeeIDs: [Int] = {
        var employeeIDs = file.readBytes(offset: Cheat.employees.rawValue, length: 30)!
        employeeIDs.exchangeHighLowBits()
        return employeeIDs.map { Int($0) }
    }()

    lazy var fleetList: [Fleet] = {
        let address = Cheat.fleetListBase.rawValue
        // 同时存在 70 +10 +3 支舰队
        return (0..<83).compactMap { i -> Fleet? in
            return Fleet(address: address + UInt64(Fleet.dataLength) * UInt64(i), file: file)
        }
    }()
    var fleet: Fleet? {
        fleetList.first(where: { $0.belong == characterIndex })
    }
    func character(of fleet: Fleet) -> CharacterInfo? {
        characterList.element(at: fleet.belong)
    }

    var portID: Int {
        get {
            Int(file.readInt8(offset: Cheat.port.rawValue)!.uint8)
        }
        set {
            let data = Data([UInt8(truncatingIfNeeded: newValue)])
            file.write(data, address: Cheat.port.rawValue)
            file.write(data, address: Cheat.port2.rawValue)
        }
    }

    lazy var port: Port = {
        Port(address: Cheat.portListBase.rawValue + UInt64(Port.dataLength) * UInt64(portID), file: file)
    }()

    // MARK: -


    func log() {
        if let value = file.readInt32(offset: Cheat.money.rawValue) { print("💵\t\(value)") }
        logStatus()
        if portID == 0xFF {
            print("当前位置: 海上")
        } else if let name = Cheat.portList.element(at: portID) {
            let port = Port(address: Cheat.portListBase.rawValue + UInt64(Port.dataLength) * UInt64(portID), file: file)
            print("当前位置: \(name) \(port.supportDescription)")
        } else {
            print("某补给港 \(portID)")
        }
        logMyFleet()
        logEmployees()
        logItems()
    }

    func logStatus() {
        guard let cInfo = currentCharacter else {
            print("初始剧情未完成，角色信息暂不可用")
            return
        }
        print(cInfo.description)

        let reputationBase = Cheat.reputation(characterIndex)
        if let reputation1 = file.readInt16(offset: reputationBase)?.uint16,
           let reputation2 = file.readInt16(offset: reputationBase + 2)?.uint16,
           let reputation3 = file.readInt16(offset: reputationBase + 4)?.uint16 {
            print("声望: 经商 \(reputation1), 海盗 \(reputation2), 冒险 \(reputation3)")
        }
        if var contribution = file.readBytes(offset: Cheat.contribution(characterIndex), length: 6) {
            contribution.exchangeHighLowBits()
            print("贡献: 🇵🇹 \(Int(contribution[0]) - 100) 🇪🇸 \(Int(contribution[1]) - 100) 🇹🇷 \(Int(contribution[2]) - 100) 🇬🇧 \(Int(contribution[3]) - 100) 🇮🇹 \(Int(contribution[4]) - 100) 🇳🇱 \(Int(contribution[5]) - 100)")
        }
        if let titleIdx = file.readInt8(offset: Cheat.title(characterIndex)),
           let title = Cheat.titleList.element(at: Int(titleIdx)) {
            print("爵位: \(title)")
        }
    }

    lazy var myShips: [MyShip] = {
        guard let mFleet = fleet else { return [] }
        let shipSpecs = (0..<40).map { idx -> ShipSpecs in
            let address = Cheat.shipStore.rawValue + UInt64(idx) * UInt64(ShipSpecs.dataLength)
            let spec = ShipSpecs(data: file.readBytes(offset: address, length: ShipSpecs.dataLength)!)
            return spec
        }
        let shipStatus = (0..<10).compactMap { idx -> ShipStatus? in
            let address = Cheat.fleet.rawValue + UInt64(idx) * UInt64(ShipStatus.dataLength)
            let status = ShipStatus(address: address, file: file)
            return status.captainID == 0xFF ? nil : status
        }
        return zip(mFleet.ships, shipStatus).map { (ship, status) in
            MyShip(ship: ship, status: status, spec: shipSpecs[Int(ship.storeIndex)], captain: characterList.element(at: status.captainID)!)
        }
    }()

    func logMyFleet() {
        guard let mFleet = fleet else {
            print("我的舰队还未组建")
            return
        }
        let coordinateString = "\(mFleet.coordinate) [\(mFleet.coordinate.x), \(mFleet.coordinate.y)]"
        print("舰队情况 \(coordinateString):\n")
        myShips.forEach { print($0.description) }
        print("")
    }

    func logEmployees() {
        let salaries: [Int] = {
            var data = file.readBytes(offset: Cheat.salaries.rawValue, length: 30)
            data?.exchangeHighLowBits()
            return data?.map { Int($0) * 100 } ?? []
        }()
        print("雇员:\n")
        for (eid, salary) in zip(employeeIDs, salaries) {
            if eid == 0xFF { continue }
            let info = characterList.element(at: Int(eid))
            print("\(info!) \(salary)金币")
        }
        print("")
    }

    func dumpAll() {
        print("全角色信息")
        characterList.forEach { print($0.description) }
        print("")

        print("全舰队状态")
        fleetList.forEach { print($0.description) }
        print("")
    }

    // MARK: 其他

    func logItems() {
        guard var items = file.readBytes(offset: Cheat.items.rawValue, length: 80) else {
            print("❌ 物品读取失败")
            return
        }
        items.exchangeHighLowBits()
        let list = Cheat.itemList
        let names = items.compactMap { bit -> String? in
            if bit == 0xFF {
                return nil
            }
            return list.element(at: Int(bit)) ?? "未知 \(bit)"
        }
        print("物品:\n\t\(names.joined(separator: ", "))")
    }

    func test() {
        var fList = fleetList
        characterList.forEach { cInfo in
            print(cInfo.description)
            if let fIdx = fList.firstIndex(where: { $0.belong == cInfo.idx }) {
                let fleet = fList.remove(at: fIdx)
                print(fleet.description)
            }
        }
        if !fList.isEmpty {
            print("归属异常的舰队")
            print(fList)
        }
    }

    static func printUsage() {
        let commandName = (CommandLine.arguments.first as NSString?)?.lastPathComponent ?? ""
        print("\(commandName) file 命令 [参数]\n")
        print("""
命令:

  info
    查看存档信息

  money [金币数]
    修改金钱，例:
    money
    money 20000

  luck [数值]
    修改幸运度, 例:
    luck 100

  level [航海等级,战斗等级]
    查看/修改主角航海、战斗等级，例:
    level
    level 10,10

  dismiss 人物全名
    通过降忠诚降薪方式解雇，例:
    dismiss 路易·法雷

  development [经济发展度,工业发展度]
    查看/修改所处港口经济、工业发展度，例:
    development
    development 700,700

  ports
    查看全部港口状态

  teleport 港口ID或港口名
    瞬移到其他港口，供快速完成剧情，出港舰队还在原来的位置，例:
    teleport 2
    teleport 伊斯坦布尔

  cd 坐标
    修改舰队海上位置，例:
    cd 123,456

  cdx 坐标
    同 cd 命令，用我提供的地图上的像素坐标就行，不用转换

  repair
    维修全部船只

  freshSailor
    船队水手补满，并回复健康状态

  supply
    补充水粮，装火炮的船补充弹药

来自:
  https://github.com/BB9z/Uncharted-Waters
""")
    }

    func run() {
        let subCommand = CommandLine.arguments.element(at: 2)
        let subArgument = CommandLine.arguments.element(at: 3)
        switch subCommand {
        case "info":
            log()

        case "money":
            giveMoney(argument: subArgument)

        case "luck":
            luck(argument: subArgument)

        case "level":
            level(argument: subArgument)

        case "dismiss":
            dismiss(argument: subArgument)

        case "development":
            development(argument: subArgument)

        case "ports":
            ports(argument: nil)

        case "repair":
            repairFleet()

        case "freshSailor":
            freshSailor()

        case "teleport":
            teleport(argument: subArgument)

        case "cd":
            updateFleetLocation(argument: subArgument)

        case "cdx":
            cdx(argument: subArgument)

        case "supply":
            supply(argument: nil)

        case "hire":
            hire(argument: subArgument)

        case "dump":
            dumpAll()

        case "test":
            test()

        default:
            Self.printUsage()
        }
    }

    func badArguments(_ text: String, printUsage: Bool = true) -> Never {
        print("\(text)\n")
        if printUsage {
            Self.printUsage()
        }
        exit(EXIT_FAILURE)
    }
}

// MARK: - Interface

extension Command {

    func giveMoney(argument: String?) {
        var count: UInt32?
        if let input = argument {
            guard let countIn = Int(input), countIn > 0 else {
                badArguments("金币数量非法")
            }
            count = UInt32(clamping: countIn)
        } else {
            count = nil
        }
        let current = UInt32(clamping: file.readInt32(offset: Cheat.money.rawValue)!)
        let toCount: UInt32 = count != nil ? count! : (current < 3000) ? 10000 : current * 2
        print("金币修改 \(current) => \(toCount)")
        file.write(Data(uint32: toCount), address: Cheat.money.rawValue)
    }

    func luck(argument: String?) {
        guard let input = argument else {
            logStatus()
            return
        }
        guard let value = UInt8(input), value <= 100 else {
            badArguments("参数错误")
        }
        guard var cInfo = currentCharacter else {
            print("角色未准备好，请先完成初始剧情")
            exit(EXIT_FAILURE)
        }
        print("主角运气修改 \(cInfo.luck) => \(value)")
        cInfo.luck = value
        file.write(cInfo.raw, address: cInfo.address)
    }

    func level(argument: String?) {
        guard var cInfo = currentCharacter else {
            print("角色未准备好，请先完成初始剧情")
            exit(EXIT_FAILURE)
        }
        guard let input = argument else {
            print(cInfo)
            return
        }
        let cdStrings = input.split(separator: ",")
        guard cdStrings.count == 2,
              let cd1 = UInt8(cdStrings[0]),
              let cd2 = UInt8(cdStrings[1]) else {
            badArguments("格式错误，如；10,10")
        }
        print("修改等级，\(cInfo.navigationLv) => \(cd1), \(cInfo.combatLv) => \(cd2)")
        cInfo.navigationLv = cd1
        cInfo.combatLv = cd2
        file.write(cInfo.raw, address: cInfo.address)
    }

    func dismiss(argument: String?) {
        guard let input = argument else {
            print("雇员信息未传入")
            logEmployees()
            exit(EXIT_FAILURE)
        }
        guard let characterIdx = Cheat.characterList.firstIndex(where: { $0 == input }) else {
            badArguments("雇员参数错误")
        }
        guard let employeeIdx = employeeIDs.firstIndex(of: characterIdx) else {
            print("未雇用 \(input)")
            logEmployees()
            exit(EXIT_FAILURE)
        }
        var cInfo = characterList.element(at: characterIdx)!
        cInfo.loyalty = 0
        file.write(cInfo.raw, address: cInfo.address)
        let salaryIdx = Data.bitOffset(at: employeeIdx)
        file.write(Data([1]), address: Cheat.salaries.rawValue + salaryIdx)
    }

    func development(argument: String?) {
        if portID == 0xFF {
            print("不在港口中")
            exit(EXIT_FAILURE)
        }
        let portName = Cheat.portList[portID]
        guard let cdInput = argument else {
            var line = "\(portName)\n经济: \(port.commerceLv)\t工业: \(port.industryLv)\t\(port.supportDescription)"
            if port.commerceInvestment > 0 || port.industryInvestment > 0 {
               line += " 投资: \(port.commerceInvestment), \(port.industryInvestment)"
            }
            exit(EXIT_FAILURE)
        }
        let cdStrings = cdInput.split(separator: ",")
        guard cdStrings.count == 2,
              let cdx = UInt16(cdStrings[0]),
              let cdy = UInt16(cdStrings[1]) else {
            badArguments("发展度格式错误，如；700,700")
        }
        guard cdx <= 1000, cdy <= 10000 else {
            badArguments("发展度范围 0~1000", printUsage: false)
        }
        print("修改 \(portName) 发展度 => \(cdx), \(cdy)")
        port.commerceLv = cdx
        port.industryLv = cdy
        file.write(port.raw, address: port.address)
    }

    func ports(argument: String?) {
        func logPort(_ port: Port, name: String) {
            let nameFormated = name.padding(toLength: 8, withPad: " ", startingAt: 0)
            var line = "  \(nameFormated)\t经济: \(port.commerceLv)\t工业: \(port.industryLv)\t\(port.supportDescription)"
            if port.commerceInvestment > 0 || port.industryInvestment > 0 {
               line += " 投资: \(UInt32(port.commerceInvestment) * 100), \(UInt32(port.industryInvestment) * 100)"
            }
            print(line)
        }
        let sectionKeys = ["欧洲", "美洲", "西非", "东非", "中东", "印度", "东南亚", "东亚"]
        let sectionValue = [
            [Int](0x00...0x29),
            [Int](0x2A...0x38),
            [Int](0x39...0x41),
            [Int](0x42...0x47),
            [Int](0x48...0x50),
            [0x51, 0x52, 0x53, 0x55, 0x5C, 0x6A, 0x6B],
            [0x54, 0x56, 0x57, 0x58, 0x59, 0x5B, 0x5D, 0x60],
            [0x5E, 0x5F, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6C, 0x6D]
        ]
        let address = Cheat.portListBase.rawValue
        for (key, ids) in zip(sectionKeys, sectionValue) {
            print(key + ":\n")
            for id in ids {
                let port = Port(address: address + UInt64(Port.dataLength) * UInt64(id), file: file)
                logPort(port, name: Cheat.portList[id])
            }
            print("")
        }
    }

    func teleport(argument: String?) {
        if portID == 0xFF {
            print("先进港才能传送")
            exit(EXIT_FAILURE)
        }
        func usage() -> String {
            var result = "\n港口列表:\n"
            Cheat.portList.enumerateElements { name, idx, _ in
                result += String(format: "%2d  %@\n", idx, name)
            }
            return result
        }
        guard let input = argument else {
            badArguments("港口未指定\n" + usage(), printUsage: false)
        }
        if let idx = Int(input), idx < Cheat.portList.count {
            print("执行传送到 \(Cheat.portList[idx])")
            portID = idx
        } else if let idx = Cheat.portList.firstIndex(where: { $0 == input }) {
            print("执行传送到 \(Cheat.portList[idx])")
            portID = idx
        } else {
            badArguments("港口参数不对\n" + usage(), printUsage: false)
        }
    }

    func updateFleetLocation(argument: String?) {
        guard let cdInput = argument else {
            badArguments("请输入坐标")
        }
        let cdStrings = cdInput.split(separator: ",")
        guard cdStrings.count == 2,
              let cdx = Int(cdStrings[0]),
              let cdy = Int(cdStrings[1]) else {
            badArguments("坐标格式错误")
        }
        updateFleetLocation(x: cdx, y: cdy, updateScreenLocation: true)
    }

    func cdx(argument: String?) {
        guard let cdStrings = argument?.split(separator: ","),
              let cdx = Int(cdStrings[0]),
              let cdy = Int(cdStrings[1]) else {
            badArguments("坐标错误")
        }
        updateFleetLocation(x: cdx / 4, y: cdy / 4, updateScreenLocation: true)
    }

    /// 更新舰队位置
    func updateFleetLocation(x: Int, y: Int, updateScreenLocation: Bool = false) {
        guard characterIndex >= 0 else {
            print("初始剧情未完成，不能修改舰队位置")
            return
        }
        if file.readInt8(offset: Cheat.port.rawValue)?.uint8 != 0xFF {
            print("未出海，不能修改舰队位置")
            return
        }
        print("修改舰队位置 => \(x), \(y)")
        if let fleetNo = fleetList.firstIndex(where: { $0.belong == characterIndex }) {
            try! file.seek(toOffset: Cheat.fleetListBase.rawValue + UInt64(fleetNo) * UInt64(Fleet.dataLength) + 0)
            let d0 = UInt8(truncatingIfNeeded: x >> 0)
            let d1 = UInt8(truncatingIfNeeded: x >> 8)
            let d2 = UInt8(truncatingIfNeeded: y >> 0)
            let d3 = UInt8(truncatingIfNeeded: y >> 8)
            file.write(Data([d0, d1, d2, d3]))
        }
        if updateScreenLocation {
            let screenX = max(x - 15, 0)
//            let screenY = max(y - 14, 0)
            let screenY = y             // 不移动到最终位置，让屏幕移动以刷新，避免花屏
            try! file.seek(toOffset: Cheat.screenCoordinate.rawValue)
            let d0 = UInt8(truncatingIfNeeded: screenX >> 0)
            let d1 = UInt8(truncatingIfNeeded: screenX >> 8)
            let d2 = UInt8(truncatingIfNeeded: screenY >> 0)
            let d3 = UInt8(truncatingIfNeeded: screenY >> 8)
            file.write(Data([d0, d1, d2, d3]))
        }
    }

    func repairFleet() {
        var countRepaired = 0
        myShips.forEach { info in
            var ship = info.ship
            if ship.hpCurrent < ship.hpMax {
                print("\(info.type) 已维修 \(ship.hpCurrent) => \(ship.hpMax)")
                ship.hpCurrent = ship.hpMax
                file.write(ship.raw, address: ship.address)
                countRepaired += 1
            }
        }
        if countRepaired == 0 {
            print("没有船只需要维修")
        }
    }

    func freshSailor() {
        var count = 0
        myShips.forEach { info in
            var ship = info.ship
            if ship.sailorCount < info.spec.sailorCount {
                print("\(info.type) 补充水手 \(info.ship.sailorCount) => \(info.spec.sailorCount)")
                ship.sailorCount = info.spec.sailorCount
                file.write(ship.raw, address: ship.address)
                count += 1
            }
            var status = info.status
            if status.health < 100 {
                print("\(info.type) 水手状态刷新")
                status.health = 100
                file.write(status.raw, address: status.address)
            }
        }
        if count == 0 {
            print("没有船只需要补充水手")
        }
    }

    func supply(argument: String?) {
        var count = 0
        myShips.forEach { info in
            let spec = info.spec
            var status = info.status
            let cannonballTarget = UInt16(spec.cannonCount / 10)
            let foodCount = (spec.volume - cannonballTarget) / 2 * 10
            if status.cannonball >= cannonballTarget,
               status.food >= foodCount,
               status.water >= foodCount {
                return
            }
            print("\(info.type):")
            if status.water < foodCount {
                print("  补充水分 \(status.food / 10) => \(foodCount / 10)")
                status.water = foodCount
            }
            if status.food < foodCount {
                print("  补充粮食 \(status.food / 10) => \(foodCount / 10)")
                status.food = foodCount
            }
            if status.cannonball < cannonballTarget {
                print("  补充弹药 \(status.cannonball) => \(cannonballTarget)")
                status.cannonball = cannonballTarget
            }
            print("")
            file.write(status.raw, address: status.address)
            count += 1
        }
        if count == 0 {
            print("目前补给充分")
        }
    }

    func hire(argument: String?) {
        guard let input = argument else {
            badArguments("人员未指定")
        }
        if let idx = Int(input) {
            forceHire(id: idx)
        } else if let idx = Cheat.characterList.firstIndex(where: { $0 == input }) {
            forceHire(id: idx)
        } else {
            badArguments("人员参数不对")
        }
    }

    private func forceHire(id: Int) {
        print("⚠️ 该功能仅供测试用")
        print("强制雇佣 \(Cheat.characterList.element(at: id) ?? "?") [\(id)]")
        var employeeIDs = file.readBytes(offset: Cheat.employees.rawValue, length: 30 + 2)!
        var forSpace = employeeIDs
        forSpace.exchangeHighLowBits()
        _ = forSpace.popFirst()
        _ = forSpace.popLast()
        forSpace = Data(forSpace)
        if forSpace.contains(UInt8(id)) {
            print("已雇佣")
            return
        }
        guard var spaceIdx = forSpace.firstIndex(where: { $0 == 0xFF }) else {
            print("人雇满了")
            return
        }
        spaceIdx = spaceIdx % 2 == 0 ? spaceIdx : spaceIdx + 2
        employeeIDs[spaceIdx] = UInt8(id)
        file.write(employeeIDs, address: Cheat.employees.rawValue)
//        if let cInfo = characterList[id] {
//
//        }
    }
}

Command().run()
