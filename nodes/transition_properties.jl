export TransitionProperties

mutable struct TransitionProperties
    pause_for::Float64
    pause_for_cnt::Float64
    can_transition::Bool # true = transition completed.

    function TransitionProperties()
        new(0.0,
            0.0,
            false)
    end
end

function reset_pause(prop::TransitionProperties) 
    prop.pause_for_cnt = 0.0
    prop.can_transition = false;
end

function inc_pause_cnt(prop::TransitionProperties, dt::Float64) 
    prop.pause_for_cnt += dt;
end

function update(prop::TransitionProperties, dt::Float64) 
    inc_pause_cnt(prop, dt)
    if prop.pause_for_cnt >= prop.pause_for 
        prop.can_transition = true
    end
end

function ready(prop::TransitionProperties)
    prop.can_transition
end
