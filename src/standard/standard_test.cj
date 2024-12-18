package bloom4cj.standard
import std.unittest.*
import std.unittest.testmacro.*
import bloom4cj.*
import std.core.Exception
import std.math

@Test
public class Bloom4cjTest{
    
    // 测试用的第一个单词表
    var web1: Array<Array<Byte>> = [
        StandardBloom.valToBinaryFromPudge<String>("我爱国家"),
        "天高地厚".toArray(),
        "春风得意".toArray(),
        "海阔天空".toArray(),
        "心花怒放".toArray(),
        "雪中送炭".toArray(),
        "风花雪月".toArray(),
        "大展宏图".toArray(),
        "心领神会".toArray(),
        "不拘一格".toArray(),
        "与时俱进".toArray(),
        "四海为家".toArray(),
        "举世闻名".toArray(),
        "任重道远".toArray(),
        "功成名就".toArray(),
        "无懈可击".toArray(),
        "才高八斗".toArray(),
        "一马当先".toArray(),
        "事半功倍".toArray(),
        "心有余而力不足".toArray()
    ]

    // 测试用的第二个单词表
    var web2: Array<Array<Byte>> = [
        "天命所归".toArray(),
        "天生我材".toArray(),
        "安居乐业".toArray(),
        "鸡飞狗跳".toArray(),
        "举世瞩目".toArray(),
        "金玉满堂".toArray(),
        "指日可待".toArray(),
        "心安理得".toArray(),
        "一帆风顺".toArray(),
        "与众不同".toArray(),
        "见义勇为".toArray(),
        "如鱼得水".toArray(),
        "众望所归".toArray(),
        "耳目一新".toArray(),
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