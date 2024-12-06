package bloom4cj.standard

import bloom4cj.*

class StandardBloom <: Bloom {

/*------------------------------------------------类的属性部分-----------------------------------------------------*/

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

/*------------------------------------------------初始化参数部分（待拓展修改错误率和填充比率）-----------------------------------------------------*/

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
    }

/*------------------------------------------------基础功能部分-----------------------------------------------------*/

    //重置布隆过滤器，清空所有内容保持原本大小，根据结果返回Bool
    public func reset() : Bool {
        this.k = K(this.e)
        this.m = M(this.n, this.p, this.e)
        this.s = S(this.m, this.k)
        this.b = Array<Bool>(this.m, repeat:false)
        this.bs = Array<Int64>(this.k, repeat : 0)
        this.c = 0
        return true
    }

    // count(): 返回已插入元素数
    public func count() : Int64 {
        return this.c
    }

    // printStats(): 打印这个数据结构的相关当前统计信息，返回Bool
    public func printStats() : Bool {
        println("m = ${this.m},n = ${this.n}, k = ${this.k}, s = ${this.s}, p = ${this.p}, e = ${this.e}")
        println("Total items: ${this.c}")
        let c = this.countBitsSet()
        let ratio = (Float64(c)/Float64(this.m))*100.0
        println("Total bits set: ${this.c} ( + ${ratio} + %)")
        return true
    }

/*------------------------------------------------哈希函数部分-----------------------------------------------------*/

    // 这个函数负责计算添加进来的key：Array<Byte>的哈希结果，并将其通过处理函数计算得到多个位置存储到bs变量中
    private func computeBitPositions(key: Array<Byte>): Bool{
        // 缺少具体实现
        return true;
    }

    // 单次哈希结果的处理函数
    private func DealHashResult(hasCalculateResult: Array<Byte>): Bool{
        // 缺少具体实现
        return true;
    }

/*------------------------------------------------核心功能部分（哈希函数部分未实现）-----------------------------------------------------*/
    
    // add(key): 添加元素  等待Hash函数计算结果的部分
    public func add(key: Array<Byte>) : Bool {
        this.computeBitPositions(key)// 这个函数负责计算添加进来的key：Array<Byte>的哈希结果，并将其通过处理函数计算得到多个位置存储到bs变量中
        for (i in 0..this.k) {
            this.setBit(this.bs[i])
        }
        this.c += 1
        return true
    }

    // check(key): 检查元素是否可能存在  等待Hash函数计算结果的部分
    public func check(key: Array<Byte>) : Bool {
        this.computeBitPositions(key)
        for (i in 0..this.k) {
            if(!this.testBit(this.bs[i])) {
                return false
            }
        }
        return true
    }
    
/*------------------------------------------------内部功能部分（不向用户开放）-----------------------------------------------------*/

    // 设置一个位为true
    private func setBit(index: Int64) : Bool {
        this.b[index] = true
        return true
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
