const TIMELINE_SEQUENCE = 1
const TIMELINE_PARALLEL = 2

# Used as parameter in [repeat] and [repeatYoyo] methods.
const INFINITY = -1

tween_pool = TweenPool()

mutable struct Tween <: AbstractTween
    base::BaseTween

    easing::AbstractTweenEquation

    function Tween()
        o = new()
        o.base = BaseTween()
        o
    end
end

function pool_size()
    count(tween_pool)
end

# Factories -------------------------------------------------------------
# field_id = tween_type
function create_tween_to(node::Ranger.AbstractNode, field_id::Int64, duration::Float64)
    tween = get_from!(tween_pool)

    tween.easing = Quad(EASE_INOUT) # A default equation

    setup!(tween, node, field_id, duration)

    tween
end
# ------------------------------------------------------------------------

function reset!(tween::AbstractTween)
    reset!(tween.base)
end

# Stops and resets the tween or timeline, and sends it to its pool, for
# later reuse. Note that if you use a [TweenManager], this method
# is automatically called once the animation is finished.
function free!(tween::AbstractTween)
    put_to!(tween_pool, tween)
end

function force_start_values!(tween::AbstractTween)
end

function force_end_values!(tween::AbstractTween)
end

# field_id = tween_type
function contains_target(target::AbstractTween, field_id::Int64)
end

function setup!(tween::AbstractTween, node::Ranger.AbstractNode, field_id::Int64, duration::Float64)
    if duration < 0.0
        throw("Duration can't be negative")
    end

    tween.base.target = node
    tween.base.field_id = field_id
    tween.base.duration = duration
end