package bloom4cj.standard.test
import std.unittest.*
import std.unittest.testmacro.*
import bloom4cj.standard.*
import std.core.Exception
import pudge4cj.*

@Test
public class Bloom4cjTest{
    
    // 采用pudge4cj中自定义的方法导入的多种类型的数据
    var web1: Array<Array<Byte>> = [
        StandardBloom.valToBinaryFromPudge<String>("我爱国家"),
        StandardBloom.valToBinaryFromPudge<Int64>(1234567890),
        StandardBloom.valToBinaryFromPudge<Int32>(123456),
        StandardBloom.valToBinaryFromPudge<Int16>(1234),
        StandardBloom.valToBinaryFromPudge<Float64>(3.1415926535),
        StandardBloom.valToBinaryFromPudge<Float32>(2.0001234),
        StandardBloom.valToBinaryFromPudge<Float16>(1.618),
        StandardBloom.valToBinaryFromPudge<String>("你好，世界！"),
        StandardBloom.valToBinaryFromPudge<String>("Special@Character#123"),
        StandardBloom.valToBinaryFromPudge<Int64>(-9876543210),
        StandardBloom.valToBinaryFromPudge<String>("12345测试"),
        StandardBloom.valToBinaryFromPudge<Int32>(-67890),
        StandardBloom.valToBinaryFromPudge<Float32>(0.1234),
        StandardBloom.valToBinaryFromPudge<String>("🌟🌍🚀"),
        StandardBloom.valToBinaryFromPudge<String>("Python编程"),
        StandardBloom.valToBinaryFromPudge<Float64>(6.02214076),
        StandardBloom.valToBinaryFromPudge<Int16>(4321),
        StandardBloom.valToBinaryFromPudge<Int32>(54321),
        StandardBloom.valToBinaryFromPudge<String>("C++开发者的世界"),
        StandardBloom.valToBinaryFromPudge<Float64>(1.414213562)
    ]

    // 采用pudge4cj中自定义的方法导入的多种类型的数据
    var web2: Array<Array<Byte>> = [
        StandardBloom.valToBinaryFromPudge<String>("欢迎来到编程世界"),
        StandardBloom.valToBinaryFromPudge<Int64>(987654321098765432),
        StandardBloom.valToBinaryFromPudge<Int32>(2147483647),
        StandardBloom.valToBinaryFromPudge<Int16>(32000),
        StandardBloom.valToBinaryFromPudge<Float64>(9.876543210987654),
        StandardBloom.valToBinaryFromPudge<Float32>(0.0001234),
        StandardBloom.valToBinaryFromPudge<Float16>(42.42),
        StandardBloom.valToBinaryFromPudge<String>("编程真有趣！"),
        StandardBloom.valToBinaryFromPudge<String>("特殊字符：~!@#%^&*()_+{}|:\"<>?"),
        StandardBloom.valToBinaryFromPudge<Int64>(-123456789012345678),
        StandardBloom.valToBinaryFromPudge<String>("Data#1234🔢"),
        StandardBloom.valToBinaryFromPudge<Int32>(-2147483648),
        StandardBloom.valToBinaryFromPudge<Float32>(3.14159),
        StandardBloom.valToBinaryFromPudge<String>("💡💻🔧技术"),
        StandardBloom.valToBinaryFromPudge<String>("Java开发者的荣耀"),
        StandardBloom.valToBinaryFromPudge<Float64>(2.718281828),
        StandardBloom.valToBinaryFromPudge<Int16>(5000),
        StandardBloom.valToBinaryFromPudge<Int32>(-99999),
        StandardBloom.valToBinaryFromPudge<String>("欢迎使用Go语言！"),
        StandardBloom.valToBinaryFromPudge<Float64>(1.6180339887)
    ] 

    // 采用CangJie自带的toArray方法导入的多种类型的数据
    var web3: Array<Array<Byte>> = [
        "创新科技".toArray(),
        "智能算法".toArray(),
        "数据分析".toArray(),
        "云计算平台".toArray(),
        "人工智能".toArray(),
        "区块链技术".toArray(),
        "物联网".toArray(),
        "大数据".toArray(),
        "机器学习".toArray(),
        "深度学习".toArray(),
        "自然语言处理".toArray(),
        "计算机视觉".toArray(),
        "虚拟🌟🌍🚀现实".toArray(),
        "增强现实".toArray(),
        "自动驾驶".toArray(),
        "量子计算".toArray(),
        "边缘计算".toArray(),
        "1".toArray(),
        "e".toArray(),
        "2.1".toArray()
    ]

    // 采用CangJie自带的toArray方法导入的多张类型的数据
    var web4: Array<Array<Byte>> = [
        "生物信息学".toArray(),
        "纳米技术".toArray(),
        "可再生能源".toArray(),
        "基因编辑".toArray(),
        "智慧城市".toArray(),
        "无人商店".toArray(),
        "自动化生产".toArray(),
        "智能医疗".toArray(),
        "机器人技术".toArray(),
        "可穿戴设备".toArray(),
        "智能交通".toArray(),
        "🌟🌍".toArray(),
        "智能物流".toArray(),
        "智能农业".toArray(),
        "虚拟助手".toArray(),
        "智能教育".toArray(),
        "智能金融".toArray(),
        "3".toArray(),
        "Ar".toArray(),
        "3.4".toArray()
    ]

    // 自定义方法导入数据，并测试Bloom过滤器的准确性
    @TestCase
    public func testBloomFilterByPudge(){
        // 假阴性计数器
        var fn = 0
        // 假阳性计数器
        var fp = 0

        // 初始化Bloom过滤器，预计添加100个元素，误报率0.01
        var bloom : StandardBloom = StandardBloom(100)

        // 将web1中的每个单词添加到Bloom过滤器中
        for (word in web1) {
            bloom.add(word)
        }

        // 检查web1中的每个单词是否存在于Bloom过滤器中
        for (word in web1) {
            if (!bloom.check(word)) { 
                fn++
            }
        }

        // 检查web2中的每个单词是否错误地存在于Bloom过滤器中
        for (word in web2) {
            if (bloom.check(word)) { 
                fp++
            }
        }

        // 断言假阴性为0
        @Expect(fn, 0)  
        // 断言假阳性不超过1
        @Expect(fp <= 1, true)  
    }

    // 自定义方法导入数据，并自定义CRC64哈希函数测试Bloom过滤器的准确性
    @TestCase
    public func testBloomFilterCRC64ByPudge(){
        // 假阴性计数器
        var fn = 0
        // 假阳性计数器
        var fp = 0

        // 初始化Bloom过滤器，m=100，使用CRC64 Hash
        var bloom : StandardBloom = StandardBloom(100)
        bloom.setHasher(CRC64Hash)

        // 将web1中的每个单词添加到Bloom过滤器中
        for (word in web1) {
            bloom.add(word)
        }

        // 检查web1中的每个单词是否存在于Bloom过滤器中
        for (word in web1) {
            if (!bloom.check(word)) { 
                fn++
            }
        }

        // 检查web2中的每个单词是否错误地存在于Bloom过滤器中
        for (word in web2) {
            if (bloom.check(word)) { 
                fp++
            }
        }

        // 断言假阴性为0
        @Expect(fn, 0)  
        // 断言假阳性不超过1
        @Expect(fp <= 1, true)  
    }

    // toArray方法导入数据，并测试Bloom过滤器的准确性
    @TestCase
    public func testBloomFilter(){
        // 假阴性计数器
        var fn = 0
        // 假阳性计数器
        var fp = 0

        // 初始化Bloom过滤器，预计添加100个元素，误报率0.01
        var bloom : StandardBloom = StandardBloom(100)

        // 将web1中的每个单词添加到Bloom过滤器中
        for (word in web3) {
            bloom.add(word)
        }

        // 检查web1中的每个单词是否存在于Bloom过滤器中
        for (word in web3) {
            if (!bloom.check(word)) { 
                fn++
            }
        }

        // 检查web2中的每个单词是否错误地存在于Bloom过滤器中
        for (word in web4) {
            if (bloom.check(word)) { 
                fp++
            }
        }

        // 断言假阴性为0
        @Expect(fn, 0)  
        // 断言假阳性不超过1
        @Expect(fp <= 1, true)  
    }

    // toArray方法导入数据，并自定义CRC64哈希函数测试Bloom过滤器的准确性
    @TestCase
    public func testBloomFilterCRC64(){
        // 假阴性计数器
        var fn = 0
        // 假阳性计数器
        var fp = 0

        // 初始化Bloom过滤器，m=100，使用CRC64 Hash
        var bloom : StandardBloom = StandardBloom(100)
        bloom.setHasher(CRC64Hash)

        // 将web1中的每个单词添加到Bloom过滤器中
        for (word in web3) {
            bloom.add(word)
        }

        // 检查web1中的每个单词是否存在于Bloom过滤器中
        for (word in web3) {
            if (!bloom.check(word)) { 
                fn++
            }
        }

        // 检查web2中的每个单词是否错误地存在于Bloom过滤器中
        for (word in web4) {
            if (bloom.check(word)) { 
                fp++
            }
        }

        // 断言假阴性为0
        @Expect(fn, 0)  
        // 断言假阳性不超过1
        @Expect(fp <= 1, true)  
    }

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
            for (_ in 0..7) {
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
}