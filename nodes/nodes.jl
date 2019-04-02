module Nodes

export AbstractNode

abstract type AbstractNode end

include("transition_properties.jl")
include("timing_properties.jl")
include("transform_properties.jl")
include("node.jl")
include("node_stack.jl")
include("scenes/scenes.jl")
include("node_manager.jl")

using .Scenes
    AbstractScene

# -----------------------------------------------------------
# Nodes
# -----------------------------------------------------------
function has_parent(node::AbstractNode)
    !(node.parent === node)
end

# -----------------------------------------------------------
# Scenes
# -----------------------------------------------------------
function has_replacement(node::AbstractScene)
    !(node.replacement === node)
end

function has_parent(node::AbstractScene)
    !(node.base.parent === node)
end


end # End Module --------------------------------------------------------