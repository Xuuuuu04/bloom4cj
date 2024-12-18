package bloom4cj
import std.math

// 实现Bloom的基本操作接口
interface Bloom {
    
    // 添加一个元素到Bloom过滤器
    mut func Add(item : Array<Byte>) : Unit
    
    // 检查一个元素是否可能存在于Bloom过滤器中，若可能返回 true，否则返回 false
    mut func Check(item : Array<Byte>) : Bool
    
    // 返回已添加的元素数量
    func Count() : UInt64
    
    // 打印Bloom过滤器的统计信息
    func PrintStats() : Unit
    
    // 设置Bloom过滤器使用的Hash函数
    mut func SetHasher(h: (Array<Byte>) -> UInt64) : Unit
    
    // 重置Bloom过滤器到初始状态
    mut func Reset() : Unit
    
    // 返回Bloom过滤器的实际填充率，即已设置位的比例
    func FillRatio() : Float64
    
    // 返回Bloom过滤器的预计填充率（根据数学公式估算）
    func EstimatedFillRatio() : Float64
    
    // 设置Bloom过滤器的错误率参数
    mut func SetErrorProbability(e : Float64) : Unit
}

// K(e float64) 根据错误率 e 计算哈希次数 k = ceil(log2(1/e))。
// 当错误率越低时 1/e 越大，对数值越高，从而 k 值越大。
func K(e : Float64) : UInt64 {
	return UInt64(math.ceil(math.log2(1.0 / e)))
}

// M(n uint, p, e float64) 根据元素数量 n、填充率 p 和错误率 e 来计算需要的位数 m。
// 公式：m ≈ n / ((log(p)*log(1-p))/abs(log e))
// 该公式根据相关论文和文献推导而来，用于确定位数组的最佳大小。
func M(n : UInt64, p : Float64 , e : Float64) : UInt64 {
	return UInt64(math.ceil(Float64(n) / ((math.log(p) * math.log(1.0-p)) / math.abs(math.log(e)))))
}

// S(m, k uint) 计算每个分片的大小 s，即 s = ceil(m/k)。
// 如果使用分区式Bloom过滤器（partitioned bloom filter），每个分片都会有 s 个位。
func S(m : UInt64 , k : UInt64) : UInt64 {
	return UInt64(math.ceil(Float64(m) / Float64(k)))
}