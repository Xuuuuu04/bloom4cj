package bloom4cj.standard.test
import std.unittest.*
import std.unittest.testmacro.*
import bloom4cj.standard.*
import std.core.Exception

@Test
public class Bloom4cjTest{
    
    // 测试用的第一个单词表
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
        "功成名就".toArray(),
        "无懈可击".toArray(),
        "才高八斗".toArray(),
        "一马当先".toArray(),
        "事半功倍".toArray(),
        "心有余而力不足".toArray()
    ]

    // 测试用的第二个单词表
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
        "如雷贯耳".toArray(),
        "青出于蓝".toArray(),
        "身心俱疲".toArray(),
        "百折不挠".toArray(),
        "忍辱负重".toArray(),
        "不求甚解".toArray()
    ]
    
    // 测试Bloom过滤器的准确性
    @TestCase
    public func testBloomFilter(){
        // 假阴性计数器
        var fn = 0
        // 假阳性计数器
        var fp = 0

        // 初始化Bloom过滤器，预计添加100个元素，误报率0.01
        var bloom : StandardBloom = StandardBloom(100)

        // 将web1中的每个单词添加到Bloom过滤器中
        for (word in web1) {
            bloom.Add(word)
        }

        // 检查web1中的每个单词是否存在于Bloom过滤器中
        for (word in web1) {
            if (!bloom.Check(word)) { 
                fn++
            }
        }

        // 检查web2中的每个单词是否错误地存在于Bloom过滤器中
        for (word in web2) {
            if (bloom.Check(word)) { 
                fp++
            }
        }

        // 断言假阴性为0
        @Expect(fn, 0)  
        // 断言假阳性不超过1
        @Expect(fp <= 1, true)  
    }

    // 使用CRC64 Hash的Benchmark测试
    @TestCase
    public func BenchmarkBloomCRC64(){
        // 假阴性计数器
        var fn = 0
        // 假阳性计数器
        var fp = 0

        // 初始化Bloom过滤器，m=100，使用CRC64 Hash
        var bloom : StandardBloom = StandardBloom(100)
        bloom.SetHasher(CRC64Hash)

        // 将web1中的每个单词添加到Bloom过滤器中
        for (word in web1) {
            bloom.Add(word)
        }

        // 检查web1中的每个单词是否存在于Bloom过滤器中
        for (word in web1) {
            if (!bloom.Check(word)) { 
                fn++
            }
        }

        // 检查web2中的每个单词是否错误地存在于Bloom过滤器中
        for (word in web2) {
            if (bloom.Check(word)) { 
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
}