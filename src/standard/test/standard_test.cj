package bloom4cj.standard.test

import std.unittest.*
import std.unittest.testmacro.*
import bloom4cj.standard.*
import bloom4cj.*

@Test
class BloomFilterTest {
    private let web2: Array<String> = ["apple","banana","cherry"]
    private let web2a: Array<String> = ["orange","pear","peach"]

    @TestCase
    public func testBloomFilterWithFNV(){
        let bf = StandardBloom(1000)

        var fn = 0
        var fp = 0
        
        // 检查web2中的元素
        for (word in web2) {
            bf.add(word);
            if (!bf.contains(word)) {
                fn++; // false negative
            }
        }

        // 检查web2a中的元素
        for (word in web2a) {
            if (bf.contains(word)) {
                fp++; // false positive
            }
        }

        // 误报率
        @Expect(fn/web2.size < 1, 1)
        // 错报率
        @Expect(fp/web2.size < 1, 1)
    }
}