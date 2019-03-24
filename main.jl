include("ranger.jl")

using Base.Math: deg2rad

using .Ranger

const RGeo = Ranger.Geometry
const RMath = Ranger.Math
const RAnim = Ranger.Animation

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

println("--------------------------")
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

println("--------------------------")
p0 = RGeo.Point{Float64}(5.0, 5.0)
p1 = RGeo.Point{Float64}(2.5, 10.0)
p2 = RGeo.Point{Float64}(7.5, 10.0)

aabb = RGeo.AABB{Float64}()
println("aabb: $aabb")
RGeo.expand!(aabb, p0, p1, p2)
println("aabb: $aabb")

println("--------------------------")
verts = [p0, p1, p2]
# println(verts)

aabb = RGeo.AABB{Float64}()
println("A Verts aabb: $aabb")
RGeo.expand!(aabb, verts)
println("B Verts aabb: $aabb")

println("intersection rectangle --------------------------")
intersect = RGeo.Rectangle{Float64}()
rectA = RGeo.Rectangle{Float64}(0.0, 0.0, 10.0, 10.0)
rectB = RGeo.Rectangle{Float64}(5.0, 5.0, 20.0, 20.0)

RGeo.intersect!(intersect, rectA, rectB)

println(intersect)

println("intersects True rectangle --------------------------")
intersects = RGeo.intersects(rectA, rectB)

println(intersects)

println("intersects False rectangle --------------------------")
rectC = RGeo.Rectangle{Float64}(0.0, 0.0, 10.0, 10.0)
rectD = RGeo.Rectangle{Float64}(15.0, 15.0, 25.0, 25.0)
intersects = RGeo.intersects(rectC, rectD)

println(intersects)

println("bounds rectangle --------------------------")
bounds = RGeo.Rectangle{Float64}()
RGeo.bounds!(bounds, rectA, rectB)

println(bounds)

println("contains True point --------------------------")
contains = RGeo.contains_point(rectA, p0)

println(contains)

println("contains False point --------------------------")
p4 = RGeo.Point{Float64}(25.0, 25.0)
contains = RGeo.contains_point(rectA, p4)

println(contains)

println("motion ----------------------------------------")
motion = RAnim.AngularMotion{Float64}()
RAnim.set!(motion, 1.0, 2.0, 0.0)

value = RAnim.interpolate!(motion, 0.0)
println(value)
value = RAnim.interpolate!(motion, 0.1)
println(value)
value = RAnim.interpolate!(motion, 0.5)
println(value)
value = RAnim.interpolate!(motion, 1.0)
println(value)