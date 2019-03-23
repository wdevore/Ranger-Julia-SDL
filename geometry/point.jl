import Base.copy

export Point

mutable struct Point{T <: AbstractFloat}
    x::T
    y::T

    function Point{T}() where {T <: AbstractFloat}
        new(0.0, 0.0)
    end

    function Point{T}(x::T, y::T) where {T <: AbstractFloat}
        new(x, y)
    end
end

# copy specializations
copy(p::Point) = Point{Float64}(p.x, p.y)
