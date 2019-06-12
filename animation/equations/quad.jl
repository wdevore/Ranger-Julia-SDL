mutable struct Quad <: AbstractTweenEquation
    name::String
    # A function that accepts a time argument and returns a float
    compute::Function # f(t::Float64) -> Float64
    type::Int64

    function Quad(type::Int64)
        o = new()

        if type == EASE_IN
            o.type = EASE_IN
            o.name = "Quad.easeIn"
            o.compute = _quad_ease_in
        elseif type == EASE_OUT
            o.type = EASE_OUT
            o.name = "Quad.easeOut"
            o.compute = _quad_ease_out
        else
            o.type = EASE_INOUT
            o.name = "Quad.easeInOut"
            o.compute = _quad_ease_inout
        end

        o
    end
end

function _quad_ease_in(t::Float64)
    t * t
end

function _quad_ease_out(t::Float64)
    -t * (t - 2.0)
end

function _quad_ease_inout(t::Float64)
    a = t * 2.0
    if a < 1.0
        return 0.5 * a * a
    end

    -0.5 * ((t - 1.0) * (t - 2.0) - 1.0)
end