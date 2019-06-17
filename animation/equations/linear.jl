mutable struct Linear <: AbstractTweenEquation
    name::String
    # A function that accepts a time argument and returns a float
    compute::Function # f(t::Float64) -> Float64
    type::Int64

    function Linear(type::Int64)
        o = new()

        o.type = EASE_INOUT
        o.name = "Linear.easeInOut"
        o.compute = _linear_ease_inout

        o
    end
end

function _linear_ease_inout(t::Float64)
    t
end