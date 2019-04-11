export 
  AngularMotion,
  set!, interpolate!, update!

using ..Math

mutable struct AngularMotion{T <: AbstractFloat}
    from::T
    to::T
    # value is in "degrees/second"
    step_value::T
  
  # Caution:
  # Interpolation can sometimes be a tiny bit off at the wrap boundary
  # which renders as a small jitter at the boundary. This can be
  # most noticable for orbit type nodes where the error is
  # magnified.
  # It is disabled by default.
    auto_wrap::Bool

    function AngularMotion{T}() where {T <: AbstractFloat}
        new(0.0, 0.0, 0.0, false)
    end
end

function set!(angMo::AngularMotion{T}, from::T, to::T) where {T <: AbstractFloat}
    angMo.from = from
    angMo.to = to;
end

function set!(angMo::AngularMotion{T}, from::T, to::T, step::T) where {T <: AbstractFloat}
    set!(angMo, from, to)
    angMo.step_value = step;
end

function interpolate!(angMo::AngularMotion{T}, t::T) where {T <: AbstractFloat}
    value = Math.lerp(angMo.from, angMo.to, t)

    # Adjust value if wrapped
    if angMo.auto_wrap
        if angMo.step_value > 0.0
            if value >= 360.0
                # Wrap range back around
                angMo.from = 0.0
                angMo.to = angMo.step_value
                # Calc new value from the adjusted range
                value = lerp(angMo.from, angMo.to, t) #value - 360.0;
            end
        else
            if value <= 0.0
                angMo.from = 359.0
                angMo.to = 359.0 + self.step_value
                value = lerp(angMo.from, angMo.to, t) #360.0 + value;
            end
        end
    end

    value
end

# dt = milliseconds
function update!(angMo::AngularMotion{T}, dt::T) where {T <: AbstractFloat}
    angMo.from = angMo.to
    # divide by 1000 to get milliseconds
    angMo.to += angMo.step_value * (dt / 1000.0);
end