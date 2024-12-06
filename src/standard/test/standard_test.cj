package bloom4cj.standard.test

import std.unittest.*
import std.unittest.testmacro.*
import bloom4cj.standard.*
import bloom4cj.*

@Test
class BloomFilterTest {
    private let web2: Array<String> = ["apple","banana","cherry"]
    private let web2a: Array<String> = ["orange","pear","peach"]

    private func calculateCRC32(data: String){
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

    @TestCase
    public func testBloomFilterWithFNV(){
        let bf = StandardBloom(1000)

        var fn = 0
        var fp = 0
        
        // 检查web2中的元素
        for (word in web2) {
            bf.add(word);
            if (!bf.check(word)) {
                fn++; // false negative
            }
        }

        // 检查web2a中的元素
        for (word in web2a) {
            if (bf.check(word)) {
                fp++; // false positive
            }
        }

        // 误报率
        @Expect(fn/web2.size < 1, true)
        // 错报率
        @Expect(fp/web2.size < 1, true)
    }

    @TestCase
    public func testBloomFilterWithCRC(){
        let bf = StandardBloom(1000)
        bf.setHashFunction(calculateCRC32)

        var fn = 0
        var fp = 0
        
        // 检查web2中的元素
        for (word in web2) {
            bf.add(word);
            if (!bf.check(word)) {
                fn++; // false negative
            }
        }

        // 检查web2a中的元素
        for (word in web2a) {
            if (bf.check(word)) {
                fp++; // false positive
            }
        }

        // 误报率
        @Expect(fn/web2.size < 1, true)
        // 错报率
        @Expect(fp/web2.size < 1, true)
    }
}