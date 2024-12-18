<div align="center">
<img alt="" src="doc" width="20%" />
<h1>bloom4cj</h1>
</div>


<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.57.3-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-0.0%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/state-孵化-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/domain-HOS/Cloud-brightgreen" style="display: inline-block;" />
</p>

## 介绍

### 项目特性

- 灵活的哈希函数：支持自定义哈希函数，未定义时使用默认哈希函数（FNV-1a）。
- 高效的存储与查找：利用位数组和哈希函数实现快速的插入和查询操作。
- 本项目迁移自 [zentures](https://github.com/zentures/bloom)

### 项目计划

- 2024/12/18 v0.57.3发布

##  项目架构

### 源码目录

```shell
.
├── README.md
├── LICENSE
├── cjpm.toml
|
└── src								# 源码目录
	└── standard
		└── test						# 测试代码目录
    		└── standard_test.cj
  	    └── standard.cj            
    └── bloom4cj.cj            
```

### 接口说明

| 名称 | 用途 |
| --- | --- |
| `public init(n: UInt64)` | 构造函数，`n` 为预计存储的元素数量，使用默认填充比率 (`p=0.5`) 和默认误报率 (`e=0.01`) 初始化 Bloom 过滤器。 |
| `public func setHasher(h: (Array<Byte>) -> UInt64) : Unit` | 设置用户自定义的哈希函数，用于生成位数组的位置。 |
| `public func reset() : Unit` | 重置 Bloom 过滤器，清空所有内容并重新计算参数。 |
| `public func setErrorProbability(e: Float64) : Unit` | 设置新的误报率，并重置过滤器。 |
| `public func estimatedFillRatio() : Float64` | 估算 Bloom 过滤器的理论填充率。 |
| `public func fillRatio() : Float64` | 获取 Bloom 过滤器的实际填充率。 |
| `public func add(item: Array<Byte>) : Unit` | 向 Bloom 过滤器中添加一个元素 `item`。 |
| `public func check(item: Array<Byte>) : Bool` | 检查元素 `item` 是否可能存在于 Bloom 过滤器中。返回 `true` 表示可能存在，`false` 表示肯定不存在。 |
| `public func count() : UInt64` | 返回已插入的元素数量。 |
| `public func printStats() : Unit` | 打印当前 Bloom 过滤器的统计信息，包括位数组大小 (`m`)、预计元素数 (`n`)、哈希函数数量 (`k`)、分片大小 (`s`)、填充比率 (`p`)、误报率 (`e`) 以及已设置的位数和其比例。 |
| `public static func valToBinaryFromPudge<T>(value: T) where T <: Serializable<T>` | 调用外部接口将对象通过序列化的方式，转化为字节数组。转化的对象必须要实现Serializable接口。 |



## 使用说明

### 编译构建

```shell
cjpm build
```

### 功能示例

#### 将可序列化对象转化为字节数组
示例代码如下：
```cangjie
main() {
	let a : Array<Byte> = StandardBloom.valToBinaryFromPudge<String>("我爱国家"),
    let b : Array<Byte> = StandardBloom.valToBinaryFromPudge<Int64>(1234567890),
    let c : Array<Byte> = StandardBloom.valToBinaryFromPudge<Int32>(123456),
    let d : Array<Byte> = StandardBloom.valToBinaryFromPudge<Int16>(1234),
    let e : Array<Byte> = StandardBloom.valToBinaryFromPudge<Float64>(3.1415926535),
    let f : Array<Byte> = StandardBloom.valToBinaryFromPudge<Float32>(2.0001234),
    let g : Array<Byte> = StandardBloom.valToBinaryFromPudge<Float16>(1.618),
    let h : Array<Byte> = StandardBloom.valToBinaryFromPudge<String>("🌟🌍🚀")
}
```

#### 初始化Bloom过滤器并添加、检查元素
示例代码如下：
```cangjie
main() {
    // 初始化 Bloom 过滤器，预计存储 1000 个元素
    let bf = StandardBloom(n: 1000)
    
    // 将字符串 "Hello" 转换为字节数组并添加到 Bloom 过滤器中
     // ASCII 码对应 'H', 'e', 'l', 'l', 'o'
    let item: Array<Byte> = [72, 101, 108, 108, 111]
    bf.add(item)
    
    // 检查 "Hello" 是否存在于 Bloom 过滤器中
    let exists = bf.check(item)
    print(exists) // 输出: true
}
```

#### 初始化Bloom过滤器时，自定义初始化参数
示例代码如下：
```cangjie
main() {
    // 初始化 Bloom 过滤器，预计存储 5000 个元素，误报率为 0.005，填充率为 0.6
    let bf = StandardBloom(n: 5000, e: 0.005, p: 0.6)
}
```

#### 重置Bloom过滤器
示例代码如下：
```cangjie
main() {
    let bf = StandardBloom(n: 1000)
    // 重置 Bloom 过滤器
    bf.reset()
}
```

#### 设置新误报率并重置过滤器
示例代码如下：
```cangjie
main() {
    let bf = StandardBloom(n: 1000)
    // 设置新的误报率
    bf.setErrorProbability(0.001)
}
```

## 约束与限制
环境限制：无

版本限制：无

依赖版本：无

## 开源协议
本项目基于 MIT License

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。

本项目committer：[@mumu_xsy](https://gitcode.com/mumu_xsy)/[@leaveWhite088](https://gitcode.com/leaveWhite9088)

