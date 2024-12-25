# bloomcj库设计介绍

## 描述
本文档旨在详细介绍一个名为 `bloom4cj.standard` 的布隆过滤器库，该库使用 Cangjie 编程语言编写。这个库提供了一套高效且功能完备的 API，用于在应用程序中实现布隆过滤器功能，包括添加元素、检查元素是否存在、设置哈希函数等操作。此外，它还能够自动计算和调整过滤器参数以优化性能和误报率。

## class StandardBloom design API

### 类描述
`StandardBloom` 类是 `bloom4cj.standard` 库的核心组件，负责管理所有与布隆过滤器相关的操作。它支持自定义哈希函数、动态调整误报率，并提供详细的统计信息。`StandardBloom` 类通过高效的位数组管理和哈希模块实现了布隆过滤器的高性能特性。

### 类API
```cangjie
// class API
public class StandardBloom <: Bloom {
    public init(n: UInt64)
    public func setHasher(h: (Array<Byte>) -> UInt64): Unit
    public func reset(): Unit
    public func setErrorProbability(e: Float64): Unit
    public func estimatedFillRatio(): Float64
    public func fillRatio(): Float64
    public func add(item: Array<Byte>): Unit
    public func check(item: Array<Byte>): Bool
    public func count(): UInt64
    public func printStats(): Unit
    public static func valToBinaryFromPudge<T>(value: T) where T <: Serializable<T>
}
```

## 展示示例

### 示例1：将可序列化对象转化为字节数组
```cangjie
main() {
	let a : Array<Byte> = StandardBloom.valToBinaryFromPudge<String>("我爱cangjie"),
    let b : Array<Byte> = StandardBloom.valToBinaryFromPudge<Int64>(1234567890),
    let c : Array<Byte> = StandardBloom.valToBinaryFromPudge<Int32>(123456),
    let d : Array<Byte> = StandardBloom.valToBinaryFromPudge<Int16>(1234),
    let e : Array<Byte> = StandardBloom.valToBinaryFromPudge<Float64>(3.1415926535),
    let f : Array<Byte> = StandardBloom.valToBinaryFromPudge<Float32>(2.0001234),
    let g : Array<Byte> = StandardBloom.valToBinaryFromPudge<Float16>(1.618),
    let h : Array<Byte> = StandardBloom.valToBinaryFromPudge<String>("🌟🌍🚀")
}
```

### 示例2：初始化Bloom过滤器并添加、检查元素
```cangjie
main() {
    // 初始化Bloom过滤器，预计添加100个元素，误报率0.01
    var bloom : StandardBloom = StandardBloom(100)
    
    // 将字符串 "我“，“爱”，“CangJie" 转换为字节数组，逐个添加到 Bloom 过滤器中
    var wordList: Array<Array<Byte>> = [
        "我".toArray(),
        "爱".toArray(),
        "CangJie".toArray()
    ]

    // 将wordList中的每个单词添加到Bloom过滤器中
    for (word in wordList) {
        bloom.add(word)
    }
    
    // 检查 "CangJie" 是否存在于 Bloom 过滤器中
    let exists : Bool = bloom.check("CangJie".toArray())
    print(exists) // 输出: true
}
```

### 示例3：重置Bloom过滤器
```cangjie
main() {
    var bloom : StandardBloom = StandardBloom(1000)
    // 重置 Bloom 过滤器
    bloom.reset()
}
```

### 示例4：置新误报率并重置过滤器
```cangjie
main() {
    var bloom : StandardBloom = StandardBloom(1000)
    // 设置新的误报率并自动重置过滤器
    bloom.setErrorProbability(0.001)
}
```