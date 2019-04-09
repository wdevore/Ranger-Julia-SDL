using Base: min, max

using .Geometry:
    Point, set!

export expand!

mutable struct AABB{T <: AbstractFloat}
    # Top-left corner
    min::Point{T}
    # Bottom-right corner
    max::Point{T}

    function AABB{T}() where {T <: AbstractFloat}
        new(Point{T}(), Point{T}())
    end

    function AABB{T}(min::Point{T}, max::Point{T}) where {T <: AbstractFloat}
        new(copy(min), copy(max))
    end

end

# Set and expand if needed. p0,p1,p2 typically represent a triangle
function expand!(aabb::AABB{T}, p0::Point{T}, p1::Point{T}, p2::Point{T}) where {T <: AbstractFloat}
    aabb.min.x = min(p0.x, min(p1.x, p2.x));
    aabb.min.y = min(p0.y, min(p1.y, p2.y));
  
    aabb.max.x = max(p0.x, max(p1.x, p2.x));
    aabb.max.y = max(p0.y, max(p1.y, p2.y));
end

function expand!(aabb::AABB{T}, vertices::AbstractArray{Point{T}}) where {T <: AbstractFloat}
    minx = typemax(T);
    miny = typemax(T);
    maxx = typemin(T);
    maxy = typemin(T);
  
    for v in vertices
        minx = min(minx, v.x);
        maxx = max(maxx, v.x);
        miny = min(miny, v.y);
        maxy = max(maxy, v.y);
    end
  
    set!(aabb.min, minx, miny);
    set!(aabb.max, maxx, maxy);
end
