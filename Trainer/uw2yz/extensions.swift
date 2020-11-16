
import Foundation

extension FileHandle {
    func readBytes(offset: UInt64, length: Int) -> Data? {
        do {
            try seek(toOffset: offset)
            return try read(upToCount: length)
        } catch {
            print(error)
            return nil
        }
    }
    func readInt32(offset: UInt64) -> Int32? {
        guard let part = readBytes(offset: offset, length: 4), part.count == 4 else { return nil }
        return Int32(truncatingIfNeeded: part.toInt32())
    }
    func readInt16(offset: UInt64) -> Int16? {
        guard let part = readBytes(offset: offset, length: 2), part.count == 2 else { return nil }
        return Int16(truncatingIfNeeded: part.toInt16())
    }
    func readInt8(offset: UInt64) -> Int8? {
        guard let part = readBytes(offset: offset, length: 1), part.count == 1 else { return nil }
        return part[0].int8
    }
    func write(_ data: Data, address: Address) {
        try! seek(toOffset: address)
        write(data)
    }
}

extension Collection {
    /// 安全的获取元素，index 超出范围返回 nil
    func element(at index: Index) -> Element? {
        if startIndex..<endIndex ~= index {
            return self[index]
        }
        return nil
    }

    /**
     遍历集合，同时访问元素和序号，并可随时终止遍历
     */
    func enumerateElements(_ block: (Element, Index, _ stoped: inout Bool) -> Void) {
        var stop = false
        var i = startIndex
        while i != endIndex {
            block(self[i], i, &stop)
            if stop { return }
            i = index(after: i)
        }
    }
}

extension Data {
    func hexString() -> String {
        map { String(format: "%02hhX", $0) }.joined(separator: " ")
    }

    /// 修正高低位的 32 位整形
    func toInt32() -> UInt32 {
        precondition(count >= 4)
        return UInt32(self[0]) << 16 + UInt32(self[1]) << 24 + UInt32(self[2]) + UInt32(self[3]) << 8
    }

    /// 修正高低位的 16 位整形
    func toInt16() -> UInt16 {
        precondition(count >= 2)
        return UInt16(self[1]) << 8 + UInt16(self[0])
    }

    /// 交换高低位数据
    mutating func exchangeHighLowBits() {
        for i in 0 ..< count/2 {
            swapAt(i * 2, i * 2 + 1)
        }
    }

    /// 正常的数组序号转为高低交换的原始数据序号
    static func bitOffset(at index: Int) -> UInt64 {
        return UInt64(index % 2 == 0 ? index : index + 2)
    }

    init(uint32: UInt32) {
        self.init([UInt8(truncatingIfNeeded: uint32 >> 16), UInt8(truncatingIfNeeded: uint32 >> 24), UInt8(truncatingIfNeeded: uint32 >> 0), UInt8(truncatingIfNeeded: uint32 >> 8)])
    }
}

extension UInt8 {
    var int8: Int8 {
        Int8(truncatingIfNeeded: self)
    }
    var int: Int {
        Int(self)
    }
}
extension Int8 {
    var uint8: UInt8 {
        UInt8(truncatingIfNeeded: self)
    }
}
extension Int16 {
    var uint16: UInt16 {
        UInt16(truncatingIfNeeded: self)
    }
}
