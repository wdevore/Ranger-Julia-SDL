module Ranger

# Example:
# Ranger.print_trace(stacktrace(), "run")
function print_trace(trace, stop_at::String)
    println("------- trace ---------")
    for tr in trace
        if string(tr.func) == stop_at
            break
        end
        println(tr)
    end
    println("-----------------------")
end

include("geometry/geometry.jl")
include("math/math.jl")
include("world.jl")
include("nodes/abstracts.jl")
include("events/events.jl")
include("animation/animation.jl")
include("rendering/rendering.jl")
include("nodes/nodes.jl")
include("particles/particles.jl")

include("nodes/custom/custom.jl")

include("engine/engine.jl")

end