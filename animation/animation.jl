export Animation

module Animation

using ..Ranger

include("motion.jl")

include("abstracts.jl")

const CLASS_NODE = 1
const CLASS_VECTOR = 2
const CLASS_COLOR = 3

include("tween_pool.jl")
include("equations/equations.jl")
include("tween_callback.jl")
include("base_tween.jl")
include("tween.jl")

include("tween_manager.jl")
include("timeline.jl")

end