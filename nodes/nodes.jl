# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
# Node API interface
# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
module Nodes

export
    Nodes,
    enter_node

export 
    AbstractNode,
    AbstractScene,
    visit, enter_node, exit_node

abstract type AbstractNode end
abstract type AbstractScene <: AbstractNode end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter_node(node::AbstractScene)
    println("AbstractScene::enter nodes ", node);
end

function exit_node(node::AbstractScene)
    println("AbstractScene::exit nodes ", node);
end
function transition end
function get_replacement end
function take_replacement end

# -----------------------------------------------------------
# Abstract Nodes
# -----------------------------------------------------------
function has_parent(node::AbstractNode)
    !(node.parent === node)
end

using ..Rendering:
    RenderContext

function visit(node::AbstractNode, context::RenderContext, interpolation::Float64)
    println("AbstractNode::visit nodes ", node);
end


# -----------------------------------------------------------
# Abstract Scenes
# -----------------------------------------------------------
function is_nil(node::AbstractScene)
    node.base.id == 0
end

function has_replacement(node::AbstractScene)
    !is_nil(node.replacement)
end

function has_parent(node::AbstractScene)
    !is_nil(node.base.parent)
end

# ---------- INCLUDES --------------------------------------------------
include("transition_properties.jl")
include("timing_properties.jl")
include("transform_properties.jl")

include("node.jl")
include("node_nil.jl")
include("node_stack.jl")

include("scenes/scenes.jl")
include("scenes/scene_nil.jl")

include("node_manager.jl")


end # End Module --------------------------------------------------------