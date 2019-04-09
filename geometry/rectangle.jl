using Base: min, max

export Rectangle
export set!, intersect!, intersects
export bounds!, contains_point

# A two-dimensional axis-aligned rectangle.
#
# X-axis directed towards the right
#
# Y-Axis directed downward.
#
# left(X)/Top(Y)
#       *------------.  --> X
#       |            |  |
#       |            |  v Y
#       |            |
#       |            |
#       .------------*
#              Right(X)/Bottom(Y)
#
mutable struct Rectangle{T <: AbstractFloat}
  # Top-left corner
    min::Point{T}
  # Bottom-right corner
    max::Point{T}
  
    width::T
    height::T

    function Rectangle{T}() where {T <: AbstractFloat}
        new(Point{T}(), Point{T}(1.0, 1.0), 1.0, 1.0)
    end

    function Rectangle{T}(minx::T, miny::T, maxx::T, maxy::T) where {T <: AbstractFloat}
        new(Point{T}(minx, miny), Point{T}(maxx, maxy), maxx - minx, maxy - miny)
    end
  
    function Rectangle{T}(min::Point{T}, max::Point{T}) where {T <: AbstractFloat}
        new(min, max, max.x - min.x, max.y - min.y)
    end
  
end

# setters/getters
function set!(rect::Rectangle{T}, minx::T, miny::T, maxx::T, maxy::T) where {T <: AbstractFloat}
    set!(rect.min, minx, miny);
    set!(rect.max, maxx, maxy);
    rect.width = maxx - minx;
    rect.height = maxy - miny;
end

# algorithms
function intersect!(intersect::Rectangle{T}, rectA::Rectangle{T}, rectB::Rectangle{T}) where {T <: AbstractFloat}
    x0 = max(rectA.min.x, rectB.min.x);
    x1 = min(rectA.max.x, rectB.max.x);
  
    if x0 <= x1
        y0 = max(rectA.min.y, rectB.min.y);
        y1 = min(rectA.max.y, rectB.max.y);
    
        if y0 <= y1
            set!(intersect, x0, y0, x1, y1);
        end
    end
end

function intersects(rectA::Rectangle{T}, rectB::Rectangle{T}) where {T <: AbstractFloat}
    rectA.min.x <= rectB.min.x + rectB.width &&
  rectB.min.x <= rectA.min.x + rectA.width &&
  rectA.max.y <= rectB.max.y + rectB.height &&
  rectB.max.y <= rectA.max.y + rectA.height
end

# Returns a new rectangle which completely contains `rectA` and `rectB`.
function bounds!(bounds::Rectangle{T}, rectA::Rectangle{T}, rectB::Rectangle{T}) where {T <: AbstractFloat}
    right = max(rectA.max.x, rectB.max.x);
    bottom = max(rectA.max.y, rectB.max.y);
    left = min(rectA.min.x, rectB.min.x);
    top = min(rectA.min.y, rectB.min.y);

    set!(bounds.min, left, top);
    set!(bounds.max, right, bottom);
    bounds.width = right - left;
    bounds.height = bottom - top;
end

function contains_point(rect::Rectangle{T}, p::Point{T}) where {T <: AbstractFloat}
    p.x >= rect.min.x &&
  p.x <= rect.max.x &&
  p.y >= rect.min.y &&
  p.y <= rect.max.y
end