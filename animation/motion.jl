export 
  AngularMotion,
  set!, interpolate!, update!

using ..Math

mutable struct AngularMotion{T <: AbstractFloat}
    # Range is [from:to]
    from::T
    to::T
    angle::T
  
    # It is enabled by default.
    auto_wrap::Bool

    function AngularMotion{T}() where {T <: AbstractFloat}
        new(0.0, 0.0, 0.0, true)
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

function interpolate!(angMo::AngularMotion{T}, t::T) where {T <: AbstractFloat}
    angle = Math.lerp(angMo.from, angMo.to, t)

    # Adjust angle if exited the range
    if angMo.auto_wrap
        if angMo.angle > 0.0
            if angle >= 360.0
                # Wrap range back around
                angMo.from = 0.0
                angMo.to = 360.0 - angle
                # Calc new angle from the adjusted range
                angle = lerp(angMo.from, angMo.to, t)
            end
        else
            if angle <= 0.0
                angMo.from = 359.0
                angMo.to = 359.0 - angle
                angle = lerp(angMo.from, angMo.to, t)
            end
        end
    end

    angle
end

# dt = milliseconds
function update!(angMo::AngularMotion{T}, dt::T) where {T <: AbstractFloat}
    angMo.from = angMo.to
    # divide by 1000 to get seconds
    angMo.to += angMo.angle * (dt / 1000.0);
end