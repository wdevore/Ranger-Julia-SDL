# import Base.copy
import Base.-
import Base./

export
    Vector2D,
    set!

mutable struct Vector2D{T <: AbstractFloat}
    x::T
    y::T

    function Vector2D{T}() where {T <: AbstractFloat}
        new(0.0, 0.0)
    end

    function Vector2D{T}(x::T, y::T) where {T <: AbstractFloat}
        new(x, y)
    end
end

# copy specializations
copy(v::Vector2D) = Vector2D{Float64}(v.x, v.y)

# setters/getters set_point
function set!(v::Vector2D{T}, x::T, y::T) where {T <: AbstractFloat}
    v.x = x
    v.y = y;
end

function set!(v::Vector2D{T}, from::Vector2D{T}) where {T <: AbstractFloat}
    v.x = from.x
    v.y = from.y;
end

function length(x::T, y::T) where {T <: AbstractFloat}
    sqrt(x * x + y * y)
end

function length(v::Vector2D{T}) where {T <: AbstractFloat}
    sqrt(v.x * v.x + v.y * v.y)
end

function length_sq(x::T, y::T) where {T <: AbstractFloat}
    x * x + y * y
end

# Scratch vectors
scv = Vector2D{Float64}()
scv2 = Vector2D{Float64}()

function add!(v1::Vector2D{T}, v2::Vector2D{T}, out::Vector2D{T}) where {T <: AbstractFloat}
    set!(out, v1.x + v2.x, v1.y + v2.y)
end

function sub!(v1::Vector2D{T}, v2::Vector2D{T}, out::Vector2D{T}) where {T <: AbstractFloat}
    set!(out, v1.x - v2.x, v1.y - v2.y)
end

function scale!(v::Vector2D{T}, s::T) where {T <: AbstractFloat}
    set!(v, v.x * s, v.y * s)
end

function scale!(v::Vector2D{T}, s::T, out::Vector2D{T}) where {T <: AbstractFloat}
    set!(out, v.x * s, v.y * s)
end

function div!(v::Vector2D{T}, value::T) where {T <: AbstractFloat}
    set!(v, v.x / value, v.y / value)
end

# distance between two vectors
function distance(v1::Vector2D{T}, v2::Vector2D{T}) where {T <: AbstractFloat}
    sub!(v1, v2, scv)
    length(scv)
end

# returns the angle in radians between this vector and the x axis
function angle(v::Vector2D{T}) where {T <: AbstractFloat}
    atan(v.y, v.x)
end

# Returns  multiplied to a length of 1.
# If the point is 0, it returns (1, 0)
function normalize!(v::Vector2D{T}) where {T <: AbstractFloat}
    len = length(v)
    if length(v) == 0.0
        set!(scv, 1.0, 0.0)
        return scv
    end

    div!(v, len);
end

# Calculates dot product of two points.
function dot(v1::Vector2D{T}, v2::Vector2D{T}) where {T <: AbstractFloat}
    v1.x * v2.x + v1.y * v2.y
end

# Calculates cross product of two points.
function cross(v1::Vector2D{T}, v2::Vector2D{T}) where {T <: AbstractFloat}
    v1.x * v2.y - v1.y * v2.x
end

# returns the angle in radians between two vector directions
function angle_between(v1::Vector2D{T}, v2::Vector2D{T}) where {T <: AbstractFloat}
    set!(scv, v1)
    set!(scv2, v2)
    
    normalize!(scv) #a2
    normalize!(scv2) #b2

    angle = atan(cross(scv, scv2), dot(scv, scv2))

    if abs(angle) < EPSILON 
        return 0.0
    else
        return angle
    end
end

# Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
function perpindicular(x::T, y::T) where {T <: AbstractFloat}
    Vector2D(-y, x)
end

function ccw_perpindicular!(v::Vector2D{T}) where {T <: AbstractFloat}
    set!(v, -v.y, v.x);
end

# Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
function cw_perpindicular!(v::Vector2D{T}) where {T <: AbstractFloat}
    set!(v, v.y, -v.x);
end

function set_direction!(v::Vector2D{T}, degrees::T) where {T <: AbstractFloat}
    set!(v, cos(deg2rad(degrees)), sin(deg2rad(degrees)));
end