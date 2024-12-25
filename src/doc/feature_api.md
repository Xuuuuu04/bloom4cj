```cangjie
/*
* 构造函数，初始化布隆过滤器
* @param n - 预计添加的元素数量
*/
public init(n: UInt64)
```

```cangjie
/*
* 构造函数，初始化布隆过滤器
* @param n - 预计添加的元素数量
*/
public init(n: UInt64)
```

```cangjie
/*
* 设置布隆过滤器使用的哈希函数
* @param h - 自定义的哈希函数，接收字节数组并返回一个64位无符号整数
*/
public func setHasher(h: (Array<Byte>) -> UInt64): Unit
```

```cangjie
/*
* 重置布隆过滤器并重新计算参数
*/
public func reset(): Unit
```

```cangjie
/*
* 设置新的误报率并重置过滤器
* @param e - 期望的误报率，必须在0和1之间
*/
public func setErrorProbability(e: Float64): Unit
```

```cangjie
/*
* 估算布隆过滤器的理论填充率
* @return Float64 - 理论上的填充率
*/
public func estimatedFillRatio(): Float64
```

```cangjie
/*
* 获取布隆过滤器的实际填充率
* @return Float64 - 实际上的填充率
*/
public func fillRatio(): Float64

```cangjie
/*
* 添加元素到布隆过滤器
* @param item - 要添加的元素，作为字节数组
*/
public func add(item: Array<Byte>): Unit
```

```cangjie
/*
* 检查元素是否可能存在于布隆过滤器中
* @param item - 要检查的元素，作为字节数组
* @return Bool - 如果元素可能存在返回true，否则返回false
*/
public func check(item: Array<Byte>): Bool
```

```cangjie
/*
* 获取当前已添加的元素数量
* @return UInt64 - 已添加的元素数量
*/
public func count(): UInt64
```

```cangjie
/*
* 打印布隆过滤器的统计信息
*/
public func printStats(): Unit
```

```cangjie
/*
* 将可序列化对象转换为字节数组
* @param value - 要转换的可序列化对象
* @return Array<Byte> - 转换后的字节数组
*/
public static func valToBinaryFromPudge<T>(value: T) where T <: Serializable<T>
```