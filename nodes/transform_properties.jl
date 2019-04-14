export
    TransformProperties, calc_transform!

using ..Math

mutable struct TransformProperties{T <: AbstractFloat}
    position::Point{T}
    rotation::T       # radians
    scale::Point{T}

    aft::Math.AffineTransform{T}
    inverse::Math.AffineTransform{T}

    function TransformProperties{T}() where {T <: AbstractFloat}
        new(Point{T}(),
            0.0,
            Point{T}(1.0, 1.0),
            Math.AffineTransform{T}(),
            Math.AffineTransform{T}())
    end
end

function set_position!(prop::TransformProperties{T}, x::T, y::T) where {T <: AbstractFloat}
    Geometry.set!(prop.position, x, y);
end

function rotation_in_degrees!(prop::TransformProperties{T}) where {T <: AbstractFloat}
    rad2deg(prop.rotation)
end

function set_rotation_in_degrees!(prop::TransformProperties{T}, rotation::T) where {T <: AbstractFloat}
    prop.rotation = deg2rad(rotation);
end

function uniform_scale(prop::TransformProperties{T}) where {T <: AbstractFloat}
    @assert(prop.scale.x == prop.scale.y)

    prop.scale.x
end

function set_scale!(prop::TransformProperties{T}, s::T) where {T <: AbstractFloat}
    Geometry.set!(prop.scale, s, s);
end

function set_nonuniform_scale!(prop::TransformProperties{T}, sx::T, sy::T) where {T <: AbstractFloat}
    Geometry.set!(prop.scale, sx, sy);
end

function calc_filtered_transform!(prop::TransformProperties{T},
        exclude_translation::Bool, exclude_rotation::Bool, exclude_scale::Bool,
        aft::Math.AffineTransform{T},
    ) where {T <: AbstractFloat}
    to_identity!(aft)

    if !exclude_translation 
        make_translate!(aft, prop.position.x, prop.position.y)
    end

    if !exclude_rotation && prop.rotation ≠ 0.0
        rotate!(aft, prop.rotation)
    end

    if !exclude_scale && (prop.scale.x ≠ 1.0 || prop.scale.y ≠ 1.0)
        scale!(aft, prop.scale.x, prop.scale.y)
    end

    nothing
end

function calc_transform!(prop::TransformProperties{T}) where {T <: AbstractFloat}
    make_translate!(prop.aft, prop.position.x, prop.position.y)

    if prop.rotation ≠ 0.0
        rotate!(prop.aft, prop.rotation)
    end

    if prop.scale.x ≠ 1.0 || prop.scale.y ≠ 1.0
        scale!(prop.aft, prop.scale.x, prop.scale.y)
    end

    Math.invert!(prop.aft, prop.inverse)

    prop.aft
end
