mutable struct BaseTween
    target::Ranger.AbstractNode

    auto_start::Bool
    auto_remove::Bool

    # General
    step::Int64
    repeat_cnt::Int64
    is_iterationStep::Bool
    is_yoyo::Bool
  
    # Timings
    # the delay of the tween or timeline. Nothing will happen before
    delay::Int64
  
    # the duration of a single iteration.
    duration::Int64
    repeat_delay::Int64
    current_time::Int64 #elapsed time, relative to current iteration
    delta_time::Int64
    started::Bool # true when the object is started
    initialized::Bool # true after the delay
    finished::Bool # true when all repetitions are done
    killed::Bool # true if kill() was called
    paused::Bool # true if pause() was called

    state_callback::Function
    callback_triggers::UInt64 # Bit flags

    function BaseTween()
        o = new()
        reset!(o)
        o
    end
end

function start!(base::BaseTween)
    base.current_time = 0
    base.started = true
end

function reset!(base::BaseTween)
    base.step = -2
    base.repeat_cnt = 0
    base.is_iterationStep = false
    base.is_yoyo = false

    base.delay = 0

    base.duration = 0
    base.repeat_delay = 0
    base.current_time = 0
    base.delta_time = 0
    base.started = false
    base.initialized = false
    base.finished = false
    base.killed = false
    base.paused = false

    # base.state_callback = nothing
    base.callback_triggers = TWEEN_CALLBACK_COMPLETE

    base.auto_start = true
    base.auto_remove = true
end

# Kills the tween or timeline. If you are using a [TweenManager],
# this object will be removed automatically.
function kill(base::BaseTween)
    base.killed = true
end

# Returns the complete duration, including initial delay and repetitions.
function full_duration(base::BaseTween)
    if base.repeat_cnt < 0
        return -1
    else
        return base.delay + base.duration + (base.repeat_delay + base.duration) * base.repeat_cnt
    end
end

function force_to_start!(base::BaseTween, tween::AbstractTween)
    base.current_time = -base.delay
    base.step = -1
    base.is_iterationStep = false

    if is_reverse(base, 0)
        force_end_values!(tween)
    else
        force_start_values!(tween)
    end
end

function force_to_end!(base::BaseTween, tween::AbstractTween)
    base.current_time = tween.base.duration - full_duration(base)
    base.step = base.repeat_cnt * 2 + 1
    base.is_iterationStep = false

    if is_reverse(base, base.repeat_cnt * 2)
        force_start_values!(tween)
    else
        force_end_values!(tween)
    end
end

function is_reverse(base::BaseTween, step::Int64)
    base.is_yoyo && abs(base.step % 4) == 2
end

function is_valid(base::BaseTween, step::Int64)
    (step >= 0 && step <= base.repeat_cnt * 2) || base.repeat_cnt < 0
end

function kill_target()
    
end

# Updates the tween or timeline state. **You may want to use a
# TweenManager to update objects for you.**
#
# Slow motion, fast motion and backward play can be easily achieved by
# tweaking this delta time. Multiply it by -1 to play the animation
# backward, or by 0.5 to play it twice slower than its normal speed.
#
# [delta] The time between now and the last call, in seconds.
function update!(base::BaseTween, delta::Float64)
    println("BaseTween updating")

    if (!base.started || base.paused || base.killed)
        return
    end
    
    base.delta_time = delta

    if !base.initialized
        initialize!(base)
    end
end
