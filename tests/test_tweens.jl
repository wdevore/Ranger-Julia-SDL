include("../ranger.jl")

using .Ranger

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

test_tween_pool()