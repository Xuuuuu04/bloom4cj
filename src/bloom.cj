package bloom4cj
import std.math.*

// 实现Bloom的基本操作接口
public interface Bloom {
    
    // 添加一个元素到Bloom过滤器
    mut func add(item : Array<Byte>) : Unit
    
    // 检查一个元素是否可能存在于Bloom过滤器中，若可能返回 true，否则返回 false
    mut func check(item : Array<Byte>) : Bool
    
    // 返回已添加的元素数量
    func count() : UInt64
    
    // 打印Bloom过滤器的统计信息
    func printStats() : Unit
    
    // 设置Bloom过滤器使用的Hash函数
    mut func setHasher(h: (Array<Byte>) -> UInt64) : Unit
    
    // 重置Bloom过滤器到初始状态
    mut func reset() : Unit
    
    // 返回Bloom过滤器的实际填充率，即已设置位的比例
    func fillRatio() : Float64
    
    // 返回Bloom过滤器的预计填充率（根据数学公式估算）
    func estimatedFillRatio() : Float64
    
    // 设置Bloom过滤器的错误率参数
    mut func setErrorProbability(e : Float64) : Unit
}

// 根据错误率 e 计算哈希次数 k
func K(e : Float64) : UInt64 {
	return UInt64(ceil(log2(1.0 / e)))
}

// 根据元素数量 n、填充率 p 和错误率 e 来计算需要的位数 m。
func M(n : UInt64, p : Float64 , e : Float64) : UInt64 {
	return UInt64(ceil(Float64(n) / ((log(p) * log(1.0-p)) / abs(log(e)))))
}

// 计算每个分片的大小 s
func S(m : UInt64 , k : UInt64) : UInt64 {
	return UInt64(ceil(Float64(m) / Float64(k)))
}