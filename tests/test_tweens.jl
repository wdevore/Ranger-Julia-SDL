include("../ranger.jl")

using .Ranger

const RGeo = Ranger.Geometry
const RAni = Ranger.Animation
const RNodes = Ranger.Nodes

function test_basic_create_tween()
    println("Testing basic create tween")

    node = Nodes.NodeNil()

    tween = Animation.create_tween_to(node, 1, 10.0)

    println("Passed")
end

function test_tween_pool()
    println("Testing tween pool")

    node = Nodes.NodeNil()

    tween = Animation.create_tween_to(node, 1, 10.0)
    @assert Animation.pool_size() == 0 "Expected 0 item(s) in pool"

    Animation.free!(tween)
    @assert Animation.pool_size() == 1 "Expected 1 item(s) in pool"

    tween2 = Animation.create_tween_to(node, 1, 10.0)

    Animation.free!(tween2)
    @assert Animation.pool_size() == 1 "Expected 1 item(s) in pool"

    tween3 = Animation.create_tween_to(node, 1, 10.0)
    @assert Animation.pool_size() == 0 "Expected 0 item(s) in pool"

    tween4 = Animation.create_tween_to(node, 1, 10.0)
    @assert Animation.pool_size() == 0 "Expected 0 item(s) in pool"

    Animation.free!(tween3)
    Animation.free!(tween4)
    @assert Animation.pool_size() == 2 "Expected 2 item(s) in pool"

    tween5 = Animation.create_tween_to(node, 1, 10.0)
    @assert Animation.pool_size() == 1 "Expected 1 item(s) in pool"

    tween6 = Animation.create_tween_to(node, 1, 10.0)
    @assert Animation.pool_size() == 0 "Expected 0 item(s) in pool"

    println("Passed")
end

function test_tween_manager()
    println("Testing tween manager")

    man = Animation.TweenManager(false)

    node = Nodes.NodeNil()

    seq_timeline_tween = Animation.TimeLine(Animation.TIMELINE_SEQUENCE)

    Animation.add!(man, seq_timeline_tween)

    @assert seq_timeline_tween.base.started == true "Expected a started timeline"

    Animation.update!(man, 1.0)

    println("Passed")
end

# A test fixture to testing the test_tweens
mutable struct TestAccessor <: RAni.AbstractTweenAccessor
    FIELD_POSITION::Int64

    function TestAccessor()
        o = new()
        o.FIELD_POSITION = 1
        o
    end
end

function get_values!(accessor::TestAccessor, tween::RAni.Tween, return_buffer::Array{Float64})
    if tween.value_type == accessor.FIELD_POSITION
        println("getting FIELD_POSITION")
        return_buffer[1] = tween.target.transform.position.x
        return_buffer[2] = tween.target.transform.position.y
        return 2 # specify how many values are to be changed.
    end
end

function set_values!(accessor::TestAccessor, tween::RAni.Tween, values::Array{Float64})
    if tween.value_type == accessor.FIELD_POSITION
        println("setting FIELD_POSITION")
        tween.target.transform.position.x = values[1]
        tween.target.transform.position.y = values[2]
        # Mark node dirty. etc...
    end
end

function test_tweens()
    println("Testing tweens")

    accessor = TestAccessor()

    RAni.register_accessor(RAni.CLASS_NODE, accessor)

    node = Nodes.TrivialNode()
    man = Animation.TweenManager(false)

    tween = RAni.create_tween_to(node, accessor.FIELD_POSITION, 10.0)
    RAni.set_target_values!(tween, [20.0, 0.0])
    RAni.start!(man, tween)

    println("Passed")
end

test_tweens()