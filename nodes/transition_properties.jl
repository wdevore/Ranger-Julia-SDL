export TransitionProperties

mutable struct TransitionProperties
    pause_for::Float64
    pause_for_cnt::Float64
    transition::Bool # true = transition completed.

    function TransitionProperties()
        new(
            0.0,
            0.0,
            false
        )
    end
end