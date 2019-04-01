export TransformProperties

using ..Geometry
    Point

using ..Math
    AffineTransform

mutable struct TransformProperties{T <: AbstractFloat}
    position:: Point{T}
    rotation::T       # radians
    scale::Point{T}

    aft::AffineTransform{T}
    inverse::AffineTransform{T}

    function TransformProperties{T}() where {T <: AbstractFloat}
        new(
            Point{T}(),
            0.0,
            Point{T}(),
            AffineTransform{T}(),
            AffineTransform{T}()
        )
    end
end