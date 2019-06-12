mutable struct Expo <: AbstractTweenEquation
    name::String
    # A function that accepts a time argument and returns a float
    compute::Function # f(t::Float64) -> Float64
    type::Int64

    function Expo_EaseIn(type::Int64)
        o = new()

        if type == EASE_IN
            o.type = EASE_IN
            o.name = "Expo.easeIn"
            o.compute = _exp_ease_in
        elseif type == EASE_OUT
            o.type = EASE_OUT
            o.name = "Expo.easeOut"
            o.compute = _exp_ease_out
        else
            o.type = EASE_INOUT
            o.name = "Expo.easeInOut"
            o.compute = _exp_ease_inout
        end

        o
    end
end

function _exp_ease_in(t::Float64)
    if t == 0.0
        0.0
    else
        2^(10.0 * (t - 1.0))
    end
end

function _exp_ease_out(t::Float64)
    if t == 1.0
        1.0
    else
        -(2.0^(-10.0 * t)) + 1.0
    end
end

function _exp_ease_inout(t::Float64)
    if t == 0.0
        return 0.0
    end

    if t == 1.0
        return 1.0
    end

    a = t * 2.0
    if a < 1.0
        return 0.5 * (2.0^(10.0 * (a - 1.0)))
    end

    0.5 * (-(2.0^(-10.0 * (t - 1.0))) + 2.0)
end