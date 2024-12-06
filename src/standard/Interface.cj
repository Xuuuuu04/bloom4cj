package bloom4cj.standard

interface bloomInterface {
    static func K(e : Float64) : Int64
    static func M(n : Int64, p : Float64, e : Float64) : Int64
    static func S(m : Int64, k : Int64) : Int64
    func add(key : Array<Byte>) : Bool
    func check(key : Array<Byte>) : Bool
    func count() : Int64
    func printStats() : Bool
    func reset() : Bool
}