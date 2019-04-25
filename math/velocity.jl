# Velocity's direction is alway defined relative to the +X axis.
# Default direction is +X axis.

mutable struct Velocity{T <: AbstractFloat}
    magnitude::T
    min_magnitude::T
    max_magnitude::T
    
    direction::Vector2D{T}
    
    limit_magnitude::Bool

    function Velocity{T}() where {T <: AbstractFloat}
        o = new()
        o.magnitude = 0.0
        o.min_magnitude = 0.0
        o.max_magnitude = 0.0
        o.direction = Vector2D{T}()
        o.limit_magnitude = true
        o
    end

    function Velocity{T}(velocity::Velocity{T}) where {T <: AbstractFloat}
        o = new()
        o.magnitude = velocity.magnitude
        o.min_magnitude = velocity.min_magnitude
        o.max_magnitude = velocity.max_magnitude
        Math.set!(o.direction, velocity.direction)
        o
    end

    function Velocity{T}(x::T, y::T, speed::T) where {T <: AbstractFloat}
        o = new()
        o.magnitude = speed
        Math.set!(o.direction, x, y)
        o
    end

end

function set!(v::Velocity{T}, from::Velocity{T}) where {T <: AbstractFloat}
    v.magnitude = from.magnitude
    v.min_magnitude = from.min_magnitude
    v.max_magnitude = from.max_magnitude
    Math.set!(v.direction, from.direction);
end

function set_magnitude_range!(v::Velocity{T}, min::T, max::T) where {T <: AbstractFloat}
    v.min_magnitude = min
    v.max_magnitude = max;
end

function set_magnitude!(v::Velocity{T}, magnitude::T) where {T <: AbstractFloat}
    if v.limit_magnitude
        # Push magnitude into the range
        v.magnitude = min(magnitude, v.max_magnitude)
        v.magnitude = max(magnitude, v.min_magnitude)
    else
        v.magnitude = magnitude
    end
end

function get_magnitude(v::Velocity{T}) where {T <: AbstractFloat}
    v.magnitude
end

function accelerate!(v::Velocity{T}, acceleration::T) where {T <: AbstractFloat}
    v.magnitude += acceleration
    set_magnitude!(v, v.magnitude);
end

function increase_speed!(v::Velocity{T}, acceleration::T) where {T <: AbstractFloat}
    v.magnitude += acceleration
    if v.limit_magnitude
        v.magnitude = min(v.magnitude, v.max_magnitude)
    end
end

function decrease_speed!(v::Velocity{T}, acceleration::T) where {T <: AbstractFloat}
    v.magnitude -= acceleration
    if v.limit_magnitude
        v.magnitude = max(v.magnitude, v.min_magnitude)
    end
end

function set_direction!(v::Velocity{T}, degrees::T) where {T <: AbstractFloat}
    set_direction!(v.direction, degrees);
end

function set_direction!(v::Velocity{T}, direction::Vector2D{T}) where {T <: AbstractFloat}
    set_direction!(v.direction, direction);
end

function get_velocity!(v::Velocity{T}, velocity::Vector2D{T}) where {T <: AbstractFloat}
    set!(velocity, v.direction.x * v.magnitude, v.direction.y * v.magnitude);
end

# Relative to +X axis in radians
function get_angle(v::Velocity{T}) where {T <: AbstractFloat}
    atan(v.direction.x, v.direction.y)
end

# vA = vA + vB
function add!(vA::Velocity{T}, vB::Velocity{T}) where {T <: AbstractFloat}
    # Convert to vectors first
    get_velocity!(vA, v1)
    get_velocity!(vB, v2)

    add!(v1, v2, v3)
    len = length(v3)

    # limit/clamp
    vA.magnitude = min(len, vA.max_magnitude)

    set!(vA.direction, v3)
    Math.normalize!(vA.direction)
end

# vA = vB - vA
function sub!(vA::Velocity{T}, vB::Velocity{T}) where {T <: AbstractFloat}
    # Convert to vectors first
    get_velocity!(vA, v1)
    get_velocity!(vB, v2)

    sub!(v2, v1, v3)
    len = length(v3)

    # limit/clamp
    vA.magnitude = min(len, vA.max_magnitude)

    set!(vA.direction, v3)
    Math.normalize!(vA.direction)
end

# Apply velocity to vector
function apply!(velocity::Velocity{T}, vec::Vector2D{T}) where {T <: AbstractFloat}
    get_velocity!(velocity, v1)
    add!(vec, v1, vec);
end

function apply!(velocity::Velocity{T}, point_mass::Point{T}) where {T <: AbstractFloat}
    get_velocity!(velocity, v1)

    set!(v2, point_mass.x, point_mass.y)
    add!(v2, v1, v3);

    Geometry.set!(point_mass, v3.x, v3.y)
end