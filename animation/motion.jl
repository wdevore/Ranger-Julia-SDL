export 
  AngularMotion,
  set!, interpolate!, update!

using ..Math
using ..Ranger

# ----------------------------------------------------------------------
# Angular motion
# ----------------------------------------------------------------------
mutable struct AngularMotion{T <: AbstractFloat} <: Ranger.AbstractMotion
    # Range is [from:to]
    from::T
    to::T
    rate::T
    time_scale::T  # typically 1000.0ms = 1sec

    # It is enabled by default.
    auto_wrap::Bool

    function AngularMotion{T}() where {T <: AbstractFloat}
        new(0.0, 0.0, 0.0, 1000.0,  true)
    end
end

# Inferred from:
# https://gameprogrammingpatterns.com/game-loop.html

# interpolate is called during rendering (aka visits) which happens more often than updates
# For example, if rendering is 60fps and updates are 30ups then interpolate is
# called twice or more for updates.
function interpolate!(angMo::AngularMotion{T}, t::T) where {T <: AbstractFloat}
    angle = Math.lerp(angMo.from, angMo.to, t)

    # Adjust angle if exited the range
    if angMo.auto_wrap
        if angMo.rate > 0.0
            if angle >= 360.0
                # Wrap range back around
                angMo.from = 0.0
                angMo.to = 361.0 - angle
                # Calc new angle from the adjusted range
                angle = lerp(angMo.from, angMo.to, t)
            end
        else
            if angle <= 0.0
                angMo.from = 360.0
                angMo.to = 358.0 - angle
                angle = lerp(angMo.from, angMo.to, t)
            end
        end
    end

    angle
end

# ----------------------------------------------------------------------
# Linear motion
# ----------------------------------------------------------------------
mutable struct LinearMotion{T <: AbstractFloat} <: Ranger.AbstractMotion
    # Range is [from:to]
    from::T
    to::T
    rate::T
    time_scale::T  # typically 1000.0ms = 1sec

    function LinearMotion{T}() where {T <: AbstractFloat}
        new(0.0, 0.0, 0.0, 1000.0)
    end
end

function interpolate!(angMo::LinearMotion{T}, t::T) where {T <: AbstractFloat}
    Math.lerp(angMo.from, angMo.to, t)
end

# ----------------------------------------------------------------------
# Linear 2D motion
# ----------------------------------------------------------------------
mutable struct Linear2DMotion{T <: AbstractFloat} <: Ranger.AbstractMotion
    # Range is [from:to]
    from::Math.Vector2D{T}
    to::Math.Vector2D{T}
    p::Math.Vector2D{T}
    rate::T
    time_scale::T  # typically 1000.0ms = 1sec

    function Linear2DMotion{T}() where {T <: AbstractFloat}
        new(Math.Vector2D{Float64}(),
            Math.Vector2D{Float64}(),
            Math.Vector2D{Float64}(),
            0.0, 
            1000.0)
    end
end

function interpolate!(angMo::Linear2DMotion{T}, t::T) where {T <: AbstractFloat}
    Math.lerp(angMo.from, angMo.to, t, angMo.p)
    angMo.p
end

# ----------------------------------------------------------------------
# Abstract motion
# ----------------------------------------------------------------------
function set!(angMo::Ranger.AbstractMotion, from::T, to::T) where {T <: AbstractFloat}
    angMo.from = from
    angMo.to = to;
end

function set!(angMo::Ranger.AbstractMotion, from::T, to::T, rate::T) where {T <: AbstractFloat}
    set!(angMo, from, to)
    angMo.rate = rate;
end

# dt = milliseconds
# Each update sets a new time window that rendering passes will interpolate
# between.
# Only used for non-2D motion
function update!(angMo::Ranger.AbstractMotion, dt::T) where {T <: AbstractFloat}
    # During each frame the "from" becomes the current "to"
    angMo.from = angMo.to

    # "to" is now moved to the next value
    # divide by time_scale
    angMo.to += angMo.rate * (dt / angMo.time_scale);
end

