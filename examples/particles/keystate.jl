# Some key events are "one-shot" either triggered on the falling edge
# (i.e. key-down) or rising edge (i.e. key-up)
#
# Some key events are repeating (i.e. as long as a key is down the event occurs)
#
mutable struct KeyState
    thrusting::Bool
    firing::Bool
    turning::Int8
end

function firing(state::KeyState)
    s = state.firing
    state.firing = false
    s
end

function thrusting(state::KeyState)
    state.thrusting
end

function turning(state::KeyState)
    state.turning
end

function set_state!(state::KeyState, event::Events.KeyboardEvent)
    if (event.keycode == Events.KEY_A && event.state == Events.KEY_PRESSED)   # thrust
        state.thrusting = true
        return
    end

    if (event.keycode == Events.KEY_A && event.state == Events.KEY_RELEASED)   # thrust
        state.thrusting = false
        return
    end

    if (event.repeat != Events.KEY_REPEATING && event.keycode == Events.KEY_S && event.state == Events.KEY_PRESSED)   # fire
        state.firing = true
        return
    end

    # turn left
    if (event.keycode == Events.KEY_LEFT && event.state == Events.KEY_PRESSED)   # thrust
        state.turning = -1
        return
    end

    if (event.keycode == Events.KEY_LEFT && event.state == Events.KEY_RELEASED)   # thrust
        state.turning = 0
        return
    end
    
    # turn right
    if (event.keycode == Events.KEY_RIGHT && event.state == Events.KEY_PRESSED)   # thrust
        state.turning = 1
        return
    end

    if (event.keycode == Events.KEY_RIGHT && event.state == Events.KEY_RELEASED)   # thrust
        state.turning = 0
        return
    end
    
end
