const TIMELINE_SEQUENCE = 1
const TIMELINE_PARALLEL = 2

# Used as parameter in [repeat] and [repeatYoyo] methods.
const INFINITY = -1

# A typical max would be 4, for example a color would need an array size
# of [r, g, b, a] = 4.
# a position [x,y] or alpha [a] would certainly fit.
const DEFAULT_COMBINED_ATTRS_LIMIT = 4
const EPSILON = 0.00000000001

tween_pool = TweenPool()
accessors = Dict{Int64,AbstractTweenAccessor}()

mutable struct Tween <: AbstractTween
    base::BaseTween

    easing::AbstractTweenEquation

    # An object associated with this tween.
    # The target is what is read/write via the accessor
    target::Any

    # Class types could be: 1 = AbstractNode, 2 = Vector2D, 3 = Color etc...
    class_type::Int64 # (aka tween_type)

    # Each accessor handles a different property on the target.
    accessor::AbstractTweenAccessor

    # Indicates how many values are to be modified by the currrent update time step.
    combined_attrs_cnt::Int64
    combined_attrs_limit::Int64

    # Indicates which value we want the accessor to read or write.
    value_type::Int64

    start_values::Array{Float64,1}
    # These are the values the tween interpolates to (aka targets for).
    # It is set by the user while creating the tween. For example, to tween from
    # black (0,0,0) to red (255,0,0) the target values would be:
    # [255, 0, 0] array.
    # Code example:
    #   tween.target_values[1] = 255
    #   tween.target_values[2] = 0
    #   tween.target_values[3] = 0
    target_values::Array{Float64,1}
    accessor_buffer::Array{Float64,1}

    # General
    is_from::Bool
    is_relative::Bool

    function Tween()
        o = new()
        o.base = BaseTween()

        o.combined_attrs_limit = DEFAULT_COMBINED_ATTRS_LIMIT

        o.start_values = Array{Float64}(undef, DEFAULT_COMBINED_ATTRS_LIMIT)
        fill!(o.start_values, 0.0)

        o.target_values = Array{Float64}(undef, DEFAULT_COMBINED_ATTRS_LIMIT)
        fill!(o.target_values, 0.0)

        o.accessor_buffer = Array{Float64}(undef, DEFAULT_COMBINED_ATTRS_LIMIT)
        fill!(o.accessor_buffer, 0.0)

        o.target = nothing
        o
    end
end

function pool_size()
    count(tween_pool)
end

# Factories -------------------------------------------------------------
# value_type = tween_type
function create_tween_to(node::Ranger.AbstractNode, value_type::Int64, duration::Float64)
    tween = get_from!(tween_pool)

    # Be sure to change this default easing to match your requirements.
    tween.easing = Linear(EASE_INOUT) # A default equation

    setup!(tween, node, value_type, duration)

    tween
end
# ------------------------------------------------------------------------

function register_accessor(class_type::Int64, accessor::AbstractTweenAccessor)
    accessors[class_type] = accessor
end

# return a AbstractTweenAccessor
function get_registered_accessor(class_type::Int64)
    accessors[class_type]
end

# Changes the [limit] for combined attributes. Defaults to 3 to reduce memory footprint.
function set_combined_attrs_limit(tween::AbstractTween, limit::Int64)
    tween.combined_attrs_limit = limit
end

function start!(tween::AbstractTween)
    if tween.base.auto_start
        build!(tween)
        start!(tween.base)
    end
end

function reset!(tween::AbstractTween)
    reset!(tween.base)
    println("tween resetting")
    tween.target = nothing
    tween.class_type = -1
    tween.value_type = -1
    tween.easing = nothing
    tween.is_from = false
    tween.is_relative = false
    tween.combined_attrs_cnt = 0

    if length(tween.accessor_buffer) ≠ tween.combined_attrs_limit
        tween.accessor_buffer = Array{Float64}(undef, tween.combined_attrs_limit)
        fill!(tween.accessor_buffer, 0.0)
    end 
end

function update!(tween::AbstractTween, delta::Float64)
    update!(tween.base, delta)
end

function kill!(tween::AbstractTween)
    kill!(tween.base)
end

function reset!(tween::AbstractTween)
    reset!(tween.base)
end

# Sets the [TweenCallbackHandler]. By default, it will be fired at the completion of the tween or timeline (event COMPLETE).
# If you want to change this behavior and add more triggers, use the [setCallbackTriggers] method.
function set_callback!(tween::AbstractTween, callback::Function)
    tween.base.state_callback = callback
end

function set_target_values!(tween::AbstractTween, values::Array{Float64,1})
    idx = 1
    for value in values
        tween.target_values[idx] = value
        idx += 1
    end
end

function callCallback(tween::AbstractTween, type::UInt64)
    if !isnothing(tween.base.state_callback) && (tween.base.callback_triggers & type) > 0
        tween.base.state_callback(type, tween)
    end
end

function build!(tween::AbstractTween)
    if isnothing(tween.target)
        return
    end
    
    tween.accessor = get_registered_accessor(tween.class_type)

    if isnothing(tween.accessor)
        tween.accessor = tween.target
    end

    if isnothing(tween.accessor)
        throw("No TweenAccessor was found for the target, and it is not Tweenable either.")
    end

    # Fetch the current range values from the target.
    tween.combined_attrs_cnt =
        get_values!(tween.accessor, tween, tween.accessor_buffer) # get_values will use 'tween.value_type' as a property selector

    if tween.combined_attrs_cnt < 0
        tween.combined_attrs_cnt = 0
    end

    if tween.combined_attrs_cnt > tween.combined_attrs_limit
        msg = """
        You cannot combine more than 'combined_attrs_limit' 
        attributes in a tween. You can raise this limit with 
        Tween.setCombinedAttributesLimit(), which should be called once 
        in application initialization code.
        """
        throw(msg)
    end
end

function initialize!(tween::AbstractTween)
    if tween.base.current_time + tween.base.delta_time >= tween.base.delay
        initialize_override!(tween)
        tween.base.initialized = true
        tween.base.is_iterationStep = true
        tween.base.step = 0
        tween.base.delta_time -= tween.base.delay - tween.base.current_time
        tween.base.current_time = 0
        tween.base.state_callback(TWEEN_CALLBACK_BEGIN, tween)
        tween.base.state_callback(TWEEN_CALLBACK_START, tween)
    end
end

function initialize_override!(tween::AbstractTween)
    if (tween.target == nothing)
        return
    end

    get_tweened_values!(tween, tween.start_values)

    for i in 1:tween.combined_attrs_cnt
        inc = if tween.is_relative
            tween.start_values[i]
        else
            0
        end
        tween.target_values[i] += inc

        if tween.is_from
            tmp = tween.start_values[i]
            tween.start_values[i] = tween.target_values[i]
            tween.target_values[i] = tmp
        end
    end

end

function update_override!(tween::AbstractTween, step::Int64, last_step::Int64, is_iteration_step::Bool, delta::Float64)
    if (tween.target == nothing || tween.easing == nothing)
        return
    end

    # in case iteration end has been reached
    if !is_iteration_step && step > last_step
        values = if is_reverse(tween, last_step)
            tween.start_values
        else
            tween.target_values
        end

        set_tweened_values!(values)
        return
    end

    if !is_iteration_step && step < last_step
        values = if is_reverse(tween, last_step)
            tween.target_values
        else
            tween.start_values
        end

        set_tweened_values!(values)
        return
    end

    # Validation
    @assert is_iteration_step "Expected an iteration step"
    @assert tween.base.current_time >= 0.0 "Expected current time > 0.0"
    @assert tween.base.current_time <= tween.base.duration "Expected an current time < duration"

    # Case duration equals zero
    if tween.base.duration < EPSILON && delta > -EPSILON
        values = if is_reverse(tween, step)
            tween.target_values
        else
            tween.start_values
        end

        set_tweened_values!(values)
        return
    end

    if tween.base.duration < EPSILON && delta < EPSILON
        values = if is_reverse(tween, step)
            tween.start_values
        else
            tween.target_values
        end

        set_tweened_values!(values)
        return
    end

    # Normal behavior
    time = if is_reverse(tween, step)
        tween.base.duration - tween.base.current_time
    else
        tween.base.current_time
    end

    # compute modifies "t" based on easing equations. This value
    # is then passed to the lerp loop below.
    t = tween.easing.compute(time / tween.base.duration)

    for i in 1:tween.combined_attrs_cnt
        tween.accessor_buffer[i] =
            tween.start_values[i] + t * (tween.target_values[i] - tween.start_values[i])
    end

    set_tweened_values!(tween, tween.accessor_buffer)
end

function force_start_values!(tween::AbstractTween)
    if tween.target == nothing
        return
    end
    set_tweened_values!(tween, tween.start_values)
end

function force_end_values!(tween::AbstractTween)
    if tween.target == nothing
        return
    end
    set_tweened_values!(tween, tween.target_values)
end

# class_type = tween_type
function contains_target(tween::AbstractTween, target::AbstractTween, class_type::Int64)
    tween.target == target && tween.class_type == class_type
end

# Stops and resets the tween or timeline, and sends it to its pool, for
# later reuse. Note that if you use a [TweenManager], this method
# is automatically called once the animation is finished.
function free!(tween::AbstractTween)
    put_to!(tween_pool, tween)
end

function setup!(tween::AbstractTween, node::Ranger.AbstractNode, value_type::Int64, duration::Float64)
    if duration < 0.0
        throw("Duration can't be negative")
    end

    tween.value_type = value_type
    tween.base.target = node
    tween.base.duration = duration
end

function get_tweened_values!(tween::AbstractTween, into_buffer::Array{Float64,1})
    value_count = if tween.accessor ≠ nothing
        get_values!(tween.accessor, tween, into_buffer)
    else
        0
    end

    value_count
end

function set_tweened_values!(tween::AbstractTween, values::Array{Float64,1})
    if tween.accessor ≠ nothing
        set_values!(tween.accessor, tween, values)
    end
end