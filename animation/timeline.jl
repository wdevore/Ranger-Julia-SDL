# A Timeline is a container for many tweens, which can be played either sequentially,
# or in parallel. A timeline can contain other timelines as well.
mutable struct TimeLine <: AbstractTween
    base::BaseTween

    children::Array{AbstractTween,1}

    current::TimeLine
    parent::TimeLine

    mode::Int64
    built::Bool

    function TimeLine_AsSequence()
        o = new()
        o.base = BaseTween()
        o.mode = TIMELINE_SEQUENCE
        o.built = false
        o
    end

    function TimeLine_AsParallel()
        o = new()
        o.base = BaseTween()
        o.mode = TIMELINE_PARALLEL
        o.built = false
        o
    end
end

function build!(tween::TimeLine)
    if tween.built
        return
    end

    tween.base.duration = 0

    for child in tween.children
        if child.base.repeat_cnt < 0
            throw("You can't push an object with infinite repetitions in a TimeLine")
        end

        build!(child)

        if tween.mode == TIMELINE_SEQUENCE
            t_delay = tween.base.duration
            tween.base.duration += full_duration(child.base)
            child.base.delay += t_delay
        elseif tween.mode == TIMELINE_PARALLEL
            tween.base.duration = max(tween.base.duration, full_duration(child.base))
        end
    end

    tween.built = true;
end

function start!(tween::TimeLine, man::TweenManager = nothing)
    if man == nothing
        build!(tween)

        tween.base.current_time = 0
        tween.base.started = true

        for child in tween.children
            start!(child, man)
        end
    else
        add!(man, tween)
    end
end

function free!(tween::TimeLine)
    for child in tween.children
        free!(child)
    end

    empty!(tween.children)

    push!(tween_pool, tween)
end

function update_override!(tween::TimeLine, step::Int64, lastStep::Int64, isIterationStep::Bool, delta::Float64)
    if !isIterationStep && step > lastStep
        dt = if is_reverse(lastStep)
            -delta - 1.0
        else
            delta + 1.0
        end

        for child in tween.children
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
        for child in reverse!(tween.children)
            update!(child, dt)
        end

        return
    end

    @assert(isIterationStep, "isIterationStep was false")

    if step > lastStep
        if is_reverse(step)
            force_end_values!(tween)
            for child in reverse!(tween.children)
                update!(child, delta)
            end
        else
            force_start_values!(tween)
            for child in tween.children
                update!(child, delta)
            end
        end
    elseif step < lastStep
        if is_reverse(step)
            force_start_values!(tween)
            for child in reverse!(tween.children)
                update!(child, delta)
            end
        else
            force_end_values!(tween)
            for child in reverse!(tween.children)
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
            for child in tween.children
                update!(child, dt)
            end
        else
            for child in reverse!(tween.children)
                update!(child, dt)
            end
        end
    end
end

function force_start_values!(tween::TimeLine)
    for child in tween.children
        force_to_start!(child.base, tween)
    end
end

function force_end_values!(tween::TimeLine)
    for child in tween.children
        force_to_end!(child.base, tween)
    end
end
