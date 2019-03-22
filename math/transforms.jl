module Transforms

using ..Geometry:
    Point

export AffineTransform
export copy
export to_identity, set, transform_vector, set_translate

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

# setters/getters
function set!(aft::AffineTransform, a::T, b::T, c::T, d::T, tx::T, ty::T) where {T <: AbstractFloat}
    aft.a = a;
    aft.b = b;
    aft.c = c;
    aft.d = d;
    aft.tx = tx;
    aft.ty = ty;
end

# transforms
function transform_vector!(aft::AffineTransform{T}, v::Point{T}) where {T <: AbstractFloat}
    v.x = (aft.a * v.x) + (aft.c * v.y) + aft.tx;
    v.y = (aft.b * v.x) + (aft.d * v.y) + aft.ty;
end

function set_translate!(aft::AffineTransform, tx::T, ty::T) where {T <: AbstractFloat}
    aft.tx = tx;
    aft.ty = ty;
end

end