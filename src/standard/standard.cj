package bloom4cj.standard
import std.math.*
import std.format.*
import std.binary.*
import serialization.serialization.*
import bloom4cj.*
import pudge4cj.*
import std.core.Exception

// 标准Bloom过滤器实现
struct StandardBloom <: Bloom {
    
    // 用于生成Hash值的Hash模块
    private var h : HashModule = HashModule()
    
    // Bloom过滤器的总位数
    private var m : UInt64 = 0
    
    // Hash函数的数量
    private var k : UInt64 = 0
    
    // 分片大小
    private var s : UInt64 = 0
    
    // 填充率参数
    private var p : Float64 = 0.5
    
    // 期望的误报率
    private var e : Float64 = 0.01
    
    // 预计添加的元素数量
    private var n : UInt64 = 0
    
    // 位数组
    private var b : BitSet = BitSet(0)
    
    // 当前添加的元素数量
    private var c : UInt64 = 0
    
    // 临时存储k个位索引的数组
    private var bs : Array<UInt64> = Array<UInt64>(0, repeat: 0)
    
    // 初始化Bloom过滤器
    public init(n : UInt64) {
        this.n = n
        this.c = 0
        this.e = 0.01
        this.p = 0.5
        this.m = M(n, p, e)
        this.k = K(e)
        this.s = S(m, k)
        this.bs = Array<UInt64>(Int64(k), repeat: 0)
        this.b = BitSet(m)
    }

    // 通过自定义参数初始化Bloom过滤器
    public init(n : UInt64 , e : Float64 , p : Float64) {
        this.n = n
        this.c = 0
        this.e = e
        this.p = p
        this.m = M(n, p, e)
        this.k = K(e)
        this.s = S(m, k)
        this.bs = Array<UInt64>(Int64(k), repeat: 0)
        this.b = BitSet(m)
    }
    
    // 设置Bloom过滤器使用的Hash函数
    public mut func setHasher(h : (Array<Byte>)->UInt64) : Unit {
        this.h.setHashFunction(h)
    }
    
    // 重置Bloom过滤器并重新计算参数
    public mut func reset() : Unit {
        this.k = K(this.e)
        this.m = M(this.n, this.p, this.e)
        this.s = S(m, k)
        this.b = BitSet(m)
        this.bs = Array<UInt64>(Int64(k), repeat: 0)
        this.h.reset()
    }
    
    // 设置新的误报率并重置过滤器
    public mut func setErrorProbability(e : Float64) : Unit {
        if (e <= 0.0 || e >= 1.0) {
            throw IllegalArgumentException("Error probability (e) must be between 0 and 1.")
        }
        this.e = e
        this.reset()
    }
    
    // 估算Bloom过滤器的理论填充率
    public func estimatedFillRatio() : Float64 {
        return 1.0 - exp((-Float64(this.c) * Float64(this.k)) / Float64(this.m))
    }
    
    // 获取Bloom过滤器的实际填充率
    public func fillRatio() : Float64 {
        return Float64(this.b.count()) / Float64(this.m)
    }
    
    // 添加元素到Bloom过滤器
    public mut func add(item : Array<Byte>) : Unit {
        this.bits(item)
        
        // 设置对应的位
        for (i in 0..this.k) {
            let index = this.bs[Int64(i)]
            if (index >= this.m) {
                throw IllegalArgumentException("Bit index $index is out of bounds (m = $m).")
            }
            this.b.funcSet(index)
        }
        
        this.c += 1
    }
    
    // 检查元素是否可能存在于Bloom过滤器中
    public mut func check(item : Array<Byte>) : Bool {
        this.bits(item)
        
        // 检查所有对应的位是否都被设置
        for (i in 0..this.k) {
            let index = this.bs[Int64(i)]
            if (index >= this.m) {
                throw IllegalArgumentException("Bit index $index is out of bounds (m = $m).")
            }
            if (!this.b.test(index)) {
                return false
            }
        }
        return true
    }
    
    // 获取已添加的元素数量
    public func count() : UInt64 {
        return this.c
    }
    
    // 打印Bloom过滤器的统计信息
    public func printStats() : Unit {
        print("m = ${this.m}, n = ${this.n}, k = ${this.k}, s = ${this.s}, p = ${this.p.format(".2")}, e = ${this.e.format(".4")}\n")
        print("Total items: ${this.c}\n")
        var cSet = this.b.count()
        print("Total bits set: ${cSet} (${(Float64(cSet) / Float64(this.m) * 100.0).format(".2")})\n")
    }
    
    // 根据元素计算k个位索引
    private mut func bits(item : Array<Byte>) : Unit {
        this.h.reset()
        this.h.Write(item)
        var s = this.h.sum()
        
        // 确保Hash结果长度足够
        if (s.size < 8) {
            throw IllegalArgumentException("Hash result size is $s.size, expected at least 8 bytes.")
        }
        
        // 从Hash结果中提取两个32位整数a和b
        var aBytes : Array<Byte> = Array<Byte>(4, repeat: 0)
        for (i in 0..3) {
            aBytes[i] = s[4 + i]
        }
        let aUInt32 : UInt32 = (UInt32(aBytes[0]) << 24) | (UInt32(aBytes[1]) << 16) | (UInt32(aBytes[2]) << 8) | UInt32(aBytes[3])

        var bBytes : Array<Byte> = Array<Byte>(4, repeat: 0)
        for (i in 0..3) {
            bBytes[i] = s[i]
        }
        let bUInt32 : UInt32 = (UInt32(bBytes[0]) << 24) | (UInt32(bBytes[1]) << 16) | (UInt32(bBytes[2]) << 8) | UInt32(bBytes[3])

        // 生成k个位索引
        for (i in 0..this.k) {
            let index_i : UInt64 = (UInt64(aUInt32) + (UInt64(bUInt32) * UInt64(i))) % UInt64(this.m)
            this.bs[Int64(i)] = index_i
        }
    }

    // 将4字节数组转换为大端序
    private func bigEndianSort32(input : Array<Byte>) : Array<Byte> {
        if (input.size != 4) {
            throw IllegalArgumentException("Size of Array is $input.size, expected 4.")
        }
        
        var bytes : Array<Byte> = Array<Byte>(4, repeat : 0)
        for (i in 0..3) {
            bytes[i] = input[3 - i]
        }
        return bytes
    }

    // 将对象转化为 Array<Byte>
    public static func valToBinaryFromPudge<T>(value: T) where T <: Serializable<T>{
        return Db.valToBinary<T>(value)
    }
}

// BitSet 是一个位集
struct BitSet {
    
    // 位集的总位数
    private var length : UInt64 = 0
    
    // 存储位信息的数组，每个UInt64存储64位
    private var set : Array<UInt64> = Array<UInt64>(0, repeat : 0)
    
    // 初始化BitSet
    public init(length : UInt64) {
        this.length = length
        let numWords = (length + 63) / 64
        this.set = Array<UInt64>(Int64(numWords), repeat : 0)
    }
    
    // 检查第i位是否被设置
    public func test(i : UInt64) : Bool {
        if (i >= this.length) {
            return false
        }
        let wordIndex = i >> 6
        let bitIndex = i & 63
        if (wordIndex >= UInt64(this.set.size)) {
            return false
        }
        let mask : UInt64 = 1 << bitIndex
        return (this.set[Int64(wordIndex)] & mask) != 0
    }
    
    // 计算设置为1的位数
    public func count() : UInt64 {
        var count : UInt64 = 0
        for (word in this.set) {
            count += popcount(word)
        }
        return count
    }
    
    // 计算UInt64中设置位的数量
    public func popcount(x : UInt64) : UInt64 {
        var y = x
        y = y - ((y >> 1) & 0x5555555555555555)
        y = (y & 0x3333333333333333) + ((y >> 2) & 0x3333333333333333)
        y = (y + (y >> 4)) & 0x0F0F0F0F0F0F0F0F
        y = (y * 0x0101010101010101) >> 56
        return y
    }
    
    // 设置第i位为1
    public mut func funcSet(i : UInt64) : Unit {
        if (i >= this.length) {
            throw IllegalArgumentException("Index $i is out of bounds. Current BitSet length is $length.")
        }
        let wordIndex = i >> 6
        let bitIndex = i & 63
        if (wordIndex >= UInt64(this.set.size)) {
            throw IllegalArgumentException("Word index $wordIndex is out of bounds.")
        }
        this.set[Int64(wordIndex)] |= (1 << bitIndex)
    }
}

// Hash模块，包含Hash函数的实现
struct HashModule {
    
    // 存储要Hash的数据
    private var buffer : Array<Byte> = Array<Byte>(0, repeat : 0)
    
    // 当前的Hash值
    private var hashValue : UInt64 = 0
    
    // 当前使用的Hash函数，默认为SetcalFNV1aHash
    private var hashFunc : (Array<Byte>)->UInt64 = {x => 0}

    // 初始化Hash模块
    public init() {
        buffer = Array<Byte>(0, repeat : 0)
        hashValue = 0
        hashFunc = calSetcalFNV1aHash
    }
    
    // 重置Hash模块状态
    public mut func reset() : Unit {
        this.buffer = Array<Byte>(0, repeat : 0)
        this.hashValue = 0
    }
    
    // 写入数据到Hash模块
    public mut func Write(data : Array<Byte>) : Unit {
        this.buffer = data
    }
    
    // 计算Hash值并返回大端序字节数组
    public mut func sum() : Array<Byte> {
        if (this.buffer.size == 0) {
            throw IllegalArgumentException("Buffer is empty. Cannot compute hash.")
        }
        
        this.hashValue = this.hashFunc(this.buffer)
        
        var sumBytes : Array<Byte> = Array<Byte>(8, repeat: 0)
        for (i in 0..7) {
            sumBytes[7 - i] = UInt8((this.hashValue >> (i * 8)) & 0xFF)
        }
        return sumBytes
    }
    
    // 将8字节数组转换为大端序
    public func bigEndianSort64(input : Array<Byte>) : Array<Byte> {
        if (input.size != 8) {
            throw IllegalArgumentException("Size of Array is $input.size, expected 8.")
        }
        
        var bytes : Array<Byte> = Array<Byte>(8, repeat: 0)
        for (i in 0..7) {
            bytes[i] = input[7 - i]
        }
        return bytes
    }
    
    // 计算FNV-1a 64位Hash值
    public func calSetcalFNV1aHash(data: Array<Byte>) : UInt64 {
        const offset64: UInt64 = 14695981039346656037
        const prime64: UInt64 = 1099511628211
        let seed: UInt64 = offset64

        var hash = seed

        for (b in data) {
            hash ^= UInt64(b)
            // 模拟64位乘法溢出
            let high = (hash >> 32) * (prime64 >> 32)
            let low = (hash & 0xFFFFFFFF) * (prime64 & 0xFFFFFFFF)
            hash = ((low & 0xFFFFFFFF) + ((low >> 32) + high)) & 0xFFFFFFFFFFFFFFFF
        }

        return hash
    }
    
    // 设置新的Hash函数
    public mut func setHashFunction(newHashFunc : (Array<Byte>)->UInt64) : Unit {
        this.hashFunc = newHashFunc
    }
}