export 
  AngularMotion,
  set!, interpolate!, update!

using ..Math

mutable struct AngularMotion{T <: AbstractFloat}
    # Range is [from:to]
    from::T
    to::T
    angle::T
    time_scale::T  # typically 1000.0ms = 1sec

    # It is enabled by default.
    auto_wrap::Bool

    function AngularMotion{T}() where {T <: AbstractFloat}
        new(0.0, 0.0, 0.0, 1000.0,  true)
    end
end

function set!(angMo::AngularMotion{T}, from::T, to::T) where {T <: AbstractFloat}
    angMo.from = from
    angMo.to = to;
end

function set!(angMo::AngularMotion{T}, from::T, to::T, angle::T) where {T <: AbstractFloat}
    set!(angMo, from, to)
    angMo.angle = angle;
end

# Base on:
# https://gameprogrammingpatterns.com/game-loop.html

# interpolate is called during rendering (aka visits) which happens more often than updates
# For example, if rendering is 60fps and updates are 30ups then interpolate is
# called twice or more for updates.
function interpolate!(angMo::AngularMotion{T}, t::T) where {T <: AbstractFloat}
    angle = Math.lerp(angMo.from, angMo.to, t)

    # Adjust angle if exited the range
    if angMo.auto_wrap
        if angMo.angle > 0.0
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

# dt = milliseconds
# Each update sets a new time window that rendering passes will interpolate
# between.
function update!(angMo::AngularMotion{T}, dt::T) where {T <: AbstractFloat}
    # During each frame the "from" becomes the current "to"
    angMo.from = angMo.to

    # "to" is now moved to the next 
    # divide by 1000 to get seconds
    angMo.to += angMo.angle * (dt / angMo.time_scale);
end