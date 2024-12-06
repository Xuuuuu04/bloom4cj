package bloom4cj.standard

import bloom4cj.*
import std.collection.*

public class StandardBloom <: Bloom {
    // 配置的六大参数部分
    private var m: Int64   // bit总位数
    private var k: Int64   // 哈希函数的数量
    private var s: Int64   // 分片大小
    private var p: Float64 // 填充比率
    private var e: Float64 // 误报率
    private var n: Int64   // 预计存放的元素数 只有这个是需要传入的
    // 主要数据结构部分
    private var b: Array<Bool> // 位数组（bitset）
    // 其他辅助功能部分
    private var c: Int64   // 已插入元素计数
    private var bs: Array<Int64> // 存储一次哈希函数计算得到的k个位置
    private var HashFunction : (String) -> Int64 = { x => 0}  //哈希函数

    // 构造函数，默认p=0.5，e=0.001 初始化所有参数
    public init(n: Int64) {
        let defaultP: Float64 = 0.5
        let defaultE: Float64 = 0.001
        let defaultK: Int64 = K(defaultE)
        let defaultM: Int64 = M(n, defaultP, defaultE)

        this.n = n
        this.p = defaultP
        this.e = defaultE
        this.k = defaultK
        this.m = defaultM
        this.s = S(this.m, this.k)
        this.b = Array<Bool>(this.m, repeat: false)
        this.bs = Array<Int64>(this.k, repeat: 0)
        this.c = 0
        this.HashFunction = computeBitPositions
    }

    // 构造函数，默认p=0.5，初始化所有参数
    public init(n: Int64,e:Float64) {
        let defaultP: Float64 = 0.5
        let defaultE: Float64 = e
        let defaultK: Int64 = K(defaultE)
        let defaultM: Int64 = M(n, defaultP, defaultE)

        this.n = n
        this.p = defaultP
        this.e = defaultE
        this.k = defaultK
        this.m = defaultM
        this.s = S(this.m, this.k)
        this.b = Array<Bool>(this.m, repeat: false)
        this.bs = Array<Int64>(this.k, repeat: 0)
        this.c = 0
        this.HashFunction = computeBitPositions
    }

    // 构造函数，默认初始化所有参数
    public init(n: Int64,e:Float64,p:Float64) {
        let defaultP: Float64 = p
        let defaultE: Float64 = e
        let defaultK: Int64 = K(defaultE)
        let defaultM: Int64 = M(n, defaultP, defaultE)

        this.n = n
        this.p = defaultP
        this.e = defaultE
        this.k = defaultK
        this.m = defaultM
        this.s = S(this.m, this.k)
        this.b = Array<Bool>(this.m, repeat: false)
        this.bs = Array<Int64>(this.k, repeat: 0)
        this.c = 0
        this.HashFunction = computeBitPositions
    }

    // 重置布隆过滤器，清空所有内容保持原本大小，根据结果返回Bool
    public func reset() : Bool {
        this.k = K(this.e)
        this.m = M(this.n, this.p, this.e)
        this.s = S(this.m, this.k)
        this.b = Array<Bool>(this.m, repeat:false)
        this.bs = Array<Int64>(this.k, repeat : 0)
        this.c = 0
        return true
    }

    // 返回已插入元素数
    public func count() : Int64 {
        return this.c
    }

    // 打印这个数据结构的相关当前统计信息
    public func printStats(): Unit{
        println("m = ${this.m},n = ${this.n}, k = ${this.k}, s = ${this.s}, p = ${this.p}, e = ${this.e}")
        println("Total items: ${this.c}")
        let c = this.countBitsSet()
        let ratio = (Float64(c)/Float64(this.m))*100.0
        println("Total bits set: ${c} ( ${ratio}% )")
    }

    // 设置用户自定义的哈希函数
    public func setHashFunction(function:(String) -> Int64){
        this.HashFunction = function
    }

    // 默认哈希函数
    private func computeBitPositions(key: String): Int64{
        // FNV-1a 32位哈希的初始值和常数
        let FNV_OFFSET_BASIS:Int64 = 0x811C9DC5
        let FNV_32_PRIME:Int64 = 0x01000193

        // 计算 FNV-1a 32位哈希值
        var hash = FNV_OFFSET_BASIS
        for(b in key){
            hash = hash ^ Int64(b)
            // hash = hash * FNV_32_PRIME
        }
        return hash;
    }

    // 使用偏移量来生成不同的哈希值
    private func dealHashResult(baseHash: Int64, offset:Int64): Int64{
        return baseHash ^ (offset * 0x9E3779B9); // 0x9E3779B9 是黄金分割数常数
    }
    
    // 通过偏移量模拟多个哈希函数的计算结果，记录到bs中
    private func hashCalculate(key: String) {
        let baseHash = this.HashFunction(key)
        for (i in 0..this.k) {
            let partition = i
            let position = ((dealHashResult(baseHash, i) % this.s) + (partition * this.s)) % this.m
            bs[i] = position
        }
    }
    
    public func add(key: String): Unit{
        this.hashCalculate(key)
        for (i in 0..this.k) {
            this.setBit(this.bs[i])
        }
        this.c += 1
    }

    public func check(key: String) : Bool {
        this.hashCalculate(key)
        for (i in 0..this.k) {
            if(!this.testBit(this.bs[i])) {
                return false
            }
        }
        return true
    }

    // 设置一个位为true
    private func setBit(index: Int64){
        this.b[index] = true
    }

    // 看看这个位设置成功没有
    private func testBit(index: Int64) : Bool {
        return this.b[index]
    }

    // 统计是否设置成功了多少位数
    private func countBitsSet() : Int64 {
        var count: Int64 = 0
        for (bitVal in this.b) {
            if(bitVal) {
                count += 1
            }
        }
        return count
    }
}
