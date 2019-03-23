include("ranger.jl")

using Base.Math: deg2rad

using .Ranger

const RGeo = Ranger.Geometry
const RMath = Ranger.Math

println("Basic Ranger test")

p = RGeo.Point{Float64}()
println("p: $p")

aft = RMath.AffineTransform{Float64}()
println("aft: $aft")

RMath.set!(aft, 1.1,2.2,3.3,4.4,5.5,6.6)
println("aft: $aft")

RMath.to_identity!(aft)
println("aft: $aft")

RMath.translate!(aft, 5.0, 10.0)
println("aft: $aft")

v = RGeo.Point{Float64}(1.0, 2.0)
println("v: $v")
RMath.transform!(aft, v)

println("v: $v")

println("transform by components")
cv = RMath.transform!(aft, 5.0, 5.0)

println("cv: $cv")

println("rotate +x vector")
v = RGeo.Point{Float64}(1.0, 0.0)
println("new v: $v")
rott = RMath.AffineTransform{Float64}()
radians = deg2rad(45.0);

RMath.make_rotate!(rott, radians)
RMath.transform!(rott, v)
println("v rotated: $v")

rv = RMath.transform!(rott, 1.0, 0.0)
println("rv rotated: $rv")