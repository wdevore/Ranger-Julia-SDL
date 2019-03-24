using Base: sin, cos

using ..Geometry:
    Point

export AffineTransform
export copy
export to_identity!, set!, transform!
export translate!, make_translate!
export scale!, make_scale!
export rotate!, set_rotate!, make_rotate!
export multiply!, invert!
export transpose!

# A minified affine transform.
# Column major
#     x'   |a c tx|   |x|
#     y' = |b d ty| x |y|                  <=== Post multiply
#     1    |0 0  1|   |1|
# or
# Row major
#                           |a  b   0|
#     |x' y' 1| = |x y 1| x |c  d   0|     <=== Pre multiply
#                           |tx ty  1|
#
mutable struct AffineTransform{T <: AbstractFloat}
    a::T
    b::T
    c::T
    d::T
    tx::T
    ty::T

    function AffineTransform{T}() where {T <: AbstractFloat}
        new(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
    end

    function AffineTransform{T}(a::T, b::T, c::T, d::T, tx::T, ty::T) where {T <: AbstractFloat}
        new(a, b, c, d, tx, ty)
    end
end

# copy specializations
copy(t::AffineTransform) = AffineTransform{Float64}(t.a, t.b, t.c, t.d, t.tx, t.ty)

# initializations
function to_identity!(aft::AffineTransform)
    aft.a = aft.d = 1.0;
    aft.b = aft.c = aft.tx = aft.ty = 0.0;
end

# transforms
function transform!(aft::AffineTransform{T}, v::Point{T}) where {T <: AbstractFloat}
    x = (aft.a * v.x) + (aft.c * v.y) + aft.tx;
    y = (aft.b * v.x) + (aft.d * v.y) + aft.ty;
    v.x = x;
    v.y = y;
end

function transform!(aft::AffineTransform{T}, vx::T, vy::T) where {T <: AbstractFloat}
  (
    (aft.a * vx) + (aft.c * vy) + aft.tx,
    (aft.b * vx) + (aft.d * vy) + aft.ty
  )
end

# setters/getters
function set!(aft::AffineTransform{T}, a::T, b::T, c::T, d::T, tx::T, ty::T) where {T <: AbstractFloat}
    aft.a = a;
    aft.b = b;
    aft.c = c;
    aft.d = d;
    aft.tx = tx;
    aft.ty = ty;
end

function translate!(aft::AffineTransform{T}, tx::T, ty::T) where {T <: AbstractFloat}
    aft.tx = tx;
    aft.ty = ty;
end

function make_translate!(aft::AffineTransform{T}, tx::T, ty::T) where {T <: AbstractFloat}
    aft.a = aft.d = 1.0;
    aft.b = aft.c = 0.0;
    aft.tx = tx;
    aft.ty = ty;
end

function scale!(aft::AffineTransform{T}, sx::T, sy::T) where {T <: AbstractFloat}
    aft.a *= sx;
    aft.b *= sx;
    aft.c *= sy;
    aft.d *= sy;
end

function make_scale!(aft::AffineTransform{T}, sx::T, sy::T) where {T <: AbstractFloat}
  aft.a = sx
  aft.d = sy;
  aft.b = aft.c = aft.tx = aft.ty = 0.0;
end

# Concatinate a rotation (radians) onto this transform.
#
# Rotation is just a matter of perspective. A CW rotation can be seen as
# CCW depending on what you are talking about rotating. For example,
# if the coordinate system is thought as rotating CCW then objects are
# seen as rotating CW, and that is what the 2x2 matrix below represents.
#
# It is also the frame of reference we use. In this library +Y axis is downward
#     |cos  -sin|   object appears to rotate CW.
#     |sin   cos|
#
# In the matrix below the object appears to rotate CCW.
#     |cos  sin|
#     |-sin cos|
#
#     |a  c|    |cos  -sin|
#     |b  d|  x |sin   cos|
#
function rotate!(aft::AffineTransform{T}, radians::T) where {T <: AbstractFloat}
  rsin = sin(radians);
  rcos = cos(radians);
  a = aft.a;
  b = aft.b;
  c = aft.c;
  d = aft.d;
  
  aft.a = a * rcos + c * rsin;
  aft.b = b * rcos + d * rsin;
  aft.c = c * rcos - a * rsin;
  aft.d = d * rcos - b * rsin;
end

function set_rotate!(aft::AffineTransform{T}, radians::T) where {T <: AbstractFloat}
  rsin = sin(radians);
  rcos = cos(radians);
  aft.a = rcos;
  aft.b = rsin;
  aft.c = -rsin;
  aft.d = rcos;
end

function make_rotate!(aft::AffineTransform{T}, radians::T) where {T <: AbstractFloat}
  set_rotate!(aft, radians);
  aft.tx = 0.0;
  aft.ty = 0.0;
end

# aft = aft * at
function multiply!(aft::AffineTransform{T}, at::AffineTransform{T}) where {T <: AbstractFloat}
  a = aft.a;
  b = aft.b;
  c = aft.c;
  d = aft.d;
  tx =aft.tx;
  ty =aft.ty;
  aft.a = a * at.a + b * at.c;
  aft.b = a * at.b + b * at.d;
  aft.c = c * at.a + d * at.c;
  aft.d = c * at.b + d * at.d;
  aft.tx = (tx * at.a) + (ty * at.c) + at.tx;
  aft.ty = (tx * at.b) + (ty * at.d) + at.ty;
end

function invert!(aft::AffineTransform{T}) where {T <: AbstractFloat}
  determinant = 1.0 / (aft.a * aft.d - aft.b * aft.c);
  a = aft.a;
  b = aft.b;
  c = aft.c;
  d = aft.d;
  tx =aft.tx;
  ty =aft.ty;
  aft.a = determinant * d;
  aft.b = -determinant * b;
  aft.c = -determinant * c;
  aft.d = determinant * a;
  aft.tx = determinant * (c * ty - d * tx);
  aft.ty = determinant * (b * tx - a * ty);
end

# Converts either from or to pre or post multiplication.
#     a c
#     b d
# to
#     a b
#     c d
function transpose!(aft::AffineTransform{T}) where {T <: AbstractFloat}
  c = aft.c;
  aft.c = aft.b;
  aft.b = c;
end

