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

- 分区结构：将位数组分为多个分区，提高内存和查找效率。
- 灵活的哈希函数：支持自定义哈希函数，未定义时使用默认哈希函数。
- 高效的存储与查找：使用位数组和多个哈希函数实现高效的查找操作。
- 本项目迁移自[zentures](https://github.com/zentures/bloom)

### 项目计划

- 2024/12/6 v0.57.3发布

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
| `public init(n: Int64)` | 构造函数，`n` 为预计存储的元素数量，使用默认填充比率 (`p=0.5`) 和默认误报率 (`e=0.001`) 初始化bloom过滤器。 |
| `public init(n: Int64, e: Float64)` | 重载构造函数，`n` 为预计存储的元素数量，`e` 为自定义误报率，使用默认填充比率 (`p=0.5`) 初始化bloom过滤器。 |
| `public init(n: Int64, e: Float64, p: Float64)` | 重载构造函数，`n` 为预计存储的元素数量，`e` 为自定义误报率，`p` 为自定义填充比率，初始化bloom过滤器。 |
| `public func reset() : Bool` | 重置bloom过滤器，清空所有内容并保持原有大小。返回 `true` 表示重置成功。 |
| `public func count() : Int64` | 返回已插入的元素数量。 |
| `public func printStats() : Unit` | 打印当前bloom过滤器的统计信息，包括位数组大小 (`m`)、预计元素数 (`n`)、哈希函数数量 (`k`)、分片大小 (`s`)、填充比率 (`p`)、误报率 (`e`) 以及已设置的位数和其比例。 |
| `public func setHashFunction(function: (String) -> Int64)` | 设置用户自定义的哈希函数，用于生成位数组的位置。 |
| `public func add(key: String) : Unit` | 向bloom过滤器中添加一个元素 `key`。 |
| `public func check(key: String) : Bool` | 检查元素 `key` 是否可能存在于bloom过滤器中。返回 `true` 表示可能存在，`false` 表示肯定不存在。 |


## 使用说明

### 编译构建

```shell
cjpm build
```

### 功能示例

#### 初始化bloom过滤器并添加、检查元素
示例代码如下：
```cangjie
main() {
		let bf = StandardBloom(1000)
        bf.add("Hello")
        bf.check("Hello")
}
```
#### 自定义哈希函数
示例代码如下：
```cangjie
// CRC32哈希函数
func calculateCRC32(data: String){
    let CRC32_POLYNOMIAL = 0xEDB88320
    let CRC32_TABLE= Array<Int64>(256,repeat:0)

    for(i in 0..256){
        var crc = i
        for(j in 0..8){
            if((crc & 1) == 1){
                crc = (crc >> 1) ^ CRC32_POLYNOMIAL
            }else {
                crc >>= 1
            }
        }
        CRC32_TABLE[i] = crc
    }

    var crc = 0xFFFFFFFF    // CRC32初始值
    for(b in data){
        let tableIndex = ((crc) & 0xFF) ^ (Int64(b & 0xFF))
        crc = (CRC32_TABLE[tableIndex] ^ (crc >> 8)) & 0xFFFFFFFF
    }

    return crc ^ 0xFFFFFFFF
}

main() {
		let bf = StandardBloom(1000)
        bf.setHashFunction(calculateCRC32)
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

