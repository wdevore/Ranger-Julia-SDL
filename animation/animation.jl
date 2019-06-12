export Animation

module Animation

using ..Ranger

include("motion.jl")

include("abstracts.jl")
include("tween_pool.jl")
include("equations/equations.jl")
include("base_tween.jl")
include("tween.jl")

include("tween_manager.jl")
include("timeline.jl")

end