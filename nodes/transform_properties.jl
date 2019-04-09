export TransformProperties

mutable struct TransformProperties{T <: AbstractFloat}
    position::Point{T}
    rotation::T       # radians
    scale::Point{T}

    aft::AffineTransform{T}
    inverse::AffineTransform{T}

    function TransformProperties{T}() where {T <: AbstractFloat}
        new(Point{T}(),
            0.0,
            Point{T}(1.0, 1.0),
            AffineTransform{T}(),
            AffineTransform{T}())
    end
end

function set_position!(prop::TransformProperties{T}, x::T, y::T) where {T <: AbstractFloat}
    Geometry.Point.set!(prop.position, x, y);
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
    Geometry.Point.set!(prop.scale, s, s);
end

function set_nonuniform_scale!(prop::TransformProperties{T}, sx::T, sy::T) where {T <: AbstractFloat}
    Geometry.Point.set!(prop.scale, sx, sy);
end

function calc_filtered_transform!(prop::TransformProperties{T},
    exclude_translation::Bool, exclude_rotation::Bool, exclude_scale::Bool,
    aft::AffineTransform{T},
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

using ..Math

function calc_transform!(prop::TransformProperties{T}) where {T <: AbstractFloat}

    make_translate!(prop.aft, prop.position.x, prop.position.y)

    if prop.rotation ≠ 0.0
        rotate!(prop.aft, prop.rotation)
    end

    if prop.scale.x ≠ 1.0 || prop.scale.y ≠ 1.0
        scale!(prop.aft, prop.scale.x, prop.scale.y)
    end

    Math.set!(prop.inverse, prop.aft)
    invert!(prop.inverse)

    prop.aft
end
