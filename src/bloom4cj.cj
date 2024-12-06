package bloom4cj

import std.math.*

interface Bloom {
    func add(key : String) : Unit
    func check(key : String) : Bool
    func count() : Int64
    func printStats() : Unit
    func reset() : Bool
}

// K(e)的计算公式不变
public func K(e: Float64) : Int64 {
    return Int64(ceil(log(1.0 / e) / log(2.0)))
}

// M(n,p,e)的计算公式不变
public func M(n: Int64, p: Float64, e: Float64) : Int64 {
    let numerator = Float64(n)
    let denominator = (log(p) * log(1.0 - p)) / abs(log(e))
    return Int64(ceil(numerator / denominator))
}

// S(m,k)的计算公式不变
public func S(m: Int64, k: Int64) : Int64 {
    return Int64(ceil(Float64(m) / Float64(k)))
}