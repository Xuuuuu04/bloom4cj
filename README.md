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
| `public func SetHasher(h: (Array<Byte>) -> UInt64) : Unit` | 设置用户自定义的哈希函数，用于生成位数组的位置。 |
| `public func Reset() : Unit` | 重置 Bloom 过滤器，清空所有内容并重新计算参数。 |
| `public func SetErrorProbability(e: Float64) : Unit` | 设置新的误报率，并重置过滤器。 |
| `public func EstimatedFillRatio() : Float64` | 估算 Bloom 过滤器的理论填充率。 |
| `public func FillRatio() : Float64` | 获取 Bloom 过滤器的实际填充率。 |
| `public func Add(item: Array<Byte>) : Unit` | 向 Bloom 过滤器中添加一个元素 `item`。 |
| `public func Check(item: Array<Byte>) : Bool` | 检查元素 `item` 是否可能存在于 Bloom 过滤器中。返回 `true` 表示可能存在，`false` 表示肯定不存在。 |
| `public func Count() : UInt64` | 返回已插入的元素数量。 |
| `public func PrintStats() : Unit` | 打印当前 Bloom 过滤器的统计信息，包括位数组大小 (`m`)、预计元素数 (`n`)、哈希函数数量 (`k`)、分片大小 (`s`)、填充比率 (`p`)、误报率 (`e`) 以及已设置的位数和其比例。 |



## 使用说明

### 编译构建

```shell
cjpm build
```

### 功能示例

#### 初始化Bloom过滤器并添加、检查元素
示例代码如下：
```cangjie
main() {
    // 初始化 Bloom 过滤器，预计存储 1000 个元素
    let bf = StandardBloom(n: 1000)
    
    // 将字符串 "Hello" 转换为字节数组并添加到 Bloom 过滤器中
    let item: Array<Byte> = [72, 101, 108, 108, 111] // ASCII 码对应 'H', 'e', 'l', 'l', 'o'
    bf.Add(item)
    
    // 检查 "Hello" 是否存在于 Bloom 过滤器中
    let exists = bf.Check(item)
    print(exists) // 输出: true
}
```
#### 自定义哈希函数
示例代码如下：
```cangjie
// CRC64 Hash函数
func CRC64Hash(data: Array<Byte>) : UInt64 {
    // CRC64多项式
    const poly: UInt64 = 0xC96C5795D7870F42
    // 初始化CRC值
    var crc: UInt64 = 0xFFFFFFFFFFFFFFFF  

    // 逐字节计算CRC
    for (b in data) {
        crc ^= UInt64(b)  
        // 处理每个字节的8位
        for (i in 0..7) {
            if ((crc & 1) != 0) {
                crc = (crc >> 1) ^ poly  
            } else {
                crc = crc >> 1  
            }
        }
    }
    // 返回无符号的CRC值
    return crc
}

main() {
    // 初始化 Bloom 过滤器，预计存储 1000 个元素
    let bf = StandardBloom(n: 1000)
    
    // 设置自定义的 CRC32 哈希函数
    bf.SetHasher(calculateCRC32)
    
    // 添加元素到 Bloom 过滤器
    let item: Array<Byte> = [72, 101, 108, 108, 111] // "Hello"
    bf.Add(item)
    
    // 检查元素是否存在
    let exists = bf.Check(item)
    print(exists) // 输出: true
}
```
#### 自定义初始化参数
示例代码如下：
```cangjie
main() {
    // 初始化 Bloom 过滤器，预计存储 5000 个元素，误报率为 0.005，填充率为 0.6
    let bf = StandardBloom(n: 5000, e: 0.005, p: 0.6)
    
    // 添加和检查元素的操作同上
    let item: Array<Byte> = [97, 98, 99] // ASCII 'a', 'b', 'c'
    bf.Add(item)
    
    let exists = bf.Check(item)
    print(exists) // 输出: true
}
```
#### 重置Bloom过滤器
示例代码如下：
```cangjie
main() {
    let bf = StandardBloom(n: 1000)
    
    // 添加元素
    let item1: Array<Byte> = [100, 101, 102] // "def"
    bf.Add(item1)
    
    // 检查元素
    let exists1 = bf.Check(item1)
    print(exists1) // 输出: true
    
    // 重置 Bloom 过滤器
    bf.Reset()
    
    // 检查元素是否仍然存在
    let exists2 = bf.Check(item1)
    print(exists2) // 输出: false
}
```
#### 设置新误报率并重置过滤器
示例代码如下：
```cangjie
main() {
    let bf = StandardBloom(n: 1000)
    
    // 添加元素
    let item: Array<Byte> = [103, 104, 105] // "ghi"
    bf.Add(item)
    
    // 检查元素
    let exists1 = bf.Check(item)
    print(exists1) // 输出: true
    
    // 设置新的误报率
    bf.SetErrorProbability(0.001)
    
    // 检查元素是否仍然存在
    let exists2 = bf.Check(item)
    print(exists2) // 输出: true
}
```
#### 性能优化方法
示例代码如下：
```cangjie
main() {
    let bf = StandardBloom(n: 1000)
    
    // 添加元素
    let item: Array<Byte> = [103, 104, 105] // "ghi"
    bf.Add(item)
    
    // 检查元素
    let exists1 = bf.Check(item)
    print(exists1) // 输出: true
    
    // 设置新的误报率
    bf.SetErrorProbability(0.001)
    
    // 检查元素是否仍然存在
    let exists2 = bf.Check(item)
    print(exists2) // 输出: true
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

