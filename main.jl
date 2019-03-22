include("ranger.jl")

using .Ranger

const RGeo = Ranger.Geometry
const RTrans = Ranger.Transforms

println("Basic Ranger test")

p = RGeo.Point{Float64}()
println("p: $p")

aft = RTrans.AffineTransform{Float64}()
println("aft: $aft")

RTrans.set!(aft, 1.1,2.2,3.3,4.4,5.5,6.6)
println("aft: $aft")

RTrans.to_identity!(aft)
println("aft: $aft")

RTrans.set_translate!(aft, 5.0, 10.0)
println("aft: $aft")

v = RGeo.Point{Float64}(1.0, 2.0)
println("v: $v")
RTrans.transform_vector!(aft, v)

println("v: $v")