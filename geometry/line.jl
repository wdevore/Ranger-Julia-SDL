export
Line,
    set!

mutable struct Line{T <: AbstractFloat}
    p1::Point{T}
    p2::Point{T}
    # Transformed vertices
    bucket::Array{Point{Float64},1}

    function Line{T}() where {T <: AbstractFloat}
        new(Point{T}(), Point{T}(), [])
    end

    function Line{T}(x1::T, y1::T, x2::T, y2::T) where {T <: AbstractFloat}
        new(Point{T}(x1, y1), Point{T}(x2, y2))
    end
end

# copy specializations
copy(p::Line) = Line{Float64}(p.x1, p.y1, p.x2, p.y2)

# setters/getters set_point
function set!(l::Line{T}, x1::T, y1::T, x2::T, y2::T) where {T <: AbstractFloat}
    set!(l.p1, x1, y1)
    set!(l.p2, x2, y2);
end

function set!(l::Line{T}, from::Line{T}) where {T <: AbstractFloat}
    set!(l.p1, from.x1, from.y1)
    set!(l.p2, from.x2, from.y2);
end
