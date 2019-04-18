using Base: min, max

using .Geometry

export
    set!, expand!

mutable struct AABB{T <: AbstractFloat}
    # Top-left corner
    min::Geometry.Point{T}
    # Bottom-right corner
    max::Geometry.Point{T}

    function AABB{T}() where {T <: AbstractFloat}
        new(Point{T}(), Point{T}())
    end

    function AABB{T}(min::Geometry.Point{T}, max::Geometry.Point{T}) where {T <: AbstractFloat}
        new(copy(min), copy(max))
    end

end

# Set and expand if needed. p0,p1,p2 typically represent a triangle
function set!(aabb::AABB{T}, p0::Geometry.Point{T}, p1::Geometry.Point{T}, p2::Geometry.Point{T}) where {T <: AbstractFloat}
    aabb.min.x = min(p0.x, min(p1.x, p2.x));
    aabb.min.y = min(p0.y, min(p1.y, p2.y));
  
    aabb.max.x = max(p0.x, max(p1.x, p2.x));
    aabb.max.y = max(p0.y, max(p1.y, p2.y));
end

function set!(aabb::AABB{T}, vertices::AbstractArray{Geometry.Point{T}}) where {T <: AbstractFloat}
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
  
    Geometry.set!(aabb.min, minx, miny);
    Geometry.set!(aabb.max, maxx, maxy);
end

function expand!(aabb::AABB{T}, vertices::AbstractArray{Geometry.Point{T}}) where {T <: AbstractFloat}
    minx = aabb.min.x;
    miny = aabb.min.y;
    maxx = aabb.max.x;
    maxy = aabb.max.y;
  
    for v in vertices
        minx = min(minx, v.x);
        maxx = max(maxx, v.x);
        miny = min(miny, v.y);
        maxy = max(maxy, v.y);
    end
  
    Geometry.set!(aabb.min, minx, miny);
    Geometry.set!(aabb.max, maxx, maxy);
end
