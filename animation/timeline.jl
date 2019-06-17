# A Timeline is a container for many tweens, which can be played either sequentially,
# or in parallel. A timeline can contain other timelines as well.
mutable struct TimeLine <: AbstractTween
    tween::Tween

    children::Array{AbstractTween,1}

    current::TimeLine
    parent::TimeLine

    mode::Int64
    built::Bool

    function TimeLine(type::Int64)
        o = new()
        o.tween = Tween()
        o.children = Array{AbstractTween,1}()
        o.mode = type
        o.built = false
        o
    end
end

# Called if the TimeLine is managing itself.
function build!(timeline::TimeLine)
    if timeline.built
        return
    end

    timeline.tween.base.duration = 0

    for child in timeline.children
        if child.tween.base.repeat_cnt < 0
            throw("You can't push an object with infinite repetitions in a TimeLine")
        end

        build!(child)

        if timeline.mode == TIMELINE_SEQUENCE
            t_delay = timeline.tween.base.duration
            timeline.tween.base.duration += full_duration(child.base)
            child.base.delay += t_delay
        elseif timeline.mode == TIMELINE_PARALLEL
            timeline.tween.base.duration = max(timeline.tween.base.duration, full_duration(child.tween.base))
        end
    end

    timeline.built = true;
end

function start!(timeline::TimeLine, man::TweenManager)
    build!(timeline)

    timeline.tween.base.current_time = 0
    timeline.tween.base.started = true

    for child in timeline.children
        start!(child, man)
    end
end

function free!(timeline::TimeLine)
    for child in timeline.children
        free!(child)
    end

    empty!(timeline.children)

    free!(timeline)
end

function contains_target_field(timeline::TimeLine, field_id::Int64)
    for child in timeline.children
        if child.tween.base.field_id == field_id
            return true
        end
    end

    false
end

function update_override!(timeline::TimeLine, step::Int64, lastStep::Int64, isIterationStep::Bool, delta::Float64)
    if !isIterationStep && step > lastStep
        dt = if is_reverse(lastStep)
            -delta - 1.0
        else
            delta + 1.0
        end

        for child in timeline.children
            update!(child, dt)
        end

        return
    end

    if !isIterationStep && step < lastStep
        dt = if is_reverse(lastStep)
            delta + 1.0
        else
            -delta - 1.0
        end

        # Interate in reverse
        for child in reverse!(timeline.children)
            update!(child, dt)
        end

        return
    end

    @assert(isIterationStep, "isIterationStep was false")

    if step > lastStep
        if is_reverse(step)
            force_end_values!(timeline)
            for child in reverse!(timeline.children)
                update!(child, delta)
            end
        else
            force_start_values!(timeline)
            for child in timeline.children
                update!(child, delta)
            end
        end
    elseif step < lastStep
        if is_reverse(step)
            force_start_values!(timeline)
            for child in reverse!(timeline.children)
                update!(child, delta)
            end
        else
            force_end_values!(timeline)
            for child in reverse!(timeline.children)
                update!(child, delta)
            end
        end
    else
        dt = if is_reverse(lastStep)
            -delta
        else
            delta
        end

        if delta >= 0.0
            for child in timeline.children
                update!(child, dt)
            end
        else
            for child in reverse!(timeline.children)
                update!(child, dt)
            end
        end
    end
end

function force_start_values!(timeline::TimeLine)
    for child in timeline.children
        force_to_start!(child.base, timeline)
    end
end

function force_end_values!(timeline::TimeLine)
    for child in timeline.children
        force_to_end!(child.base, timeline)
    end
end
