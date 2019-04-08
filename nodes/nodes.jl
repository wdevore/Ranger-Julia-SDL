# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
# Nodes API interface
# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
module Nodes

export
    Nodes,
    enter_node

export 
    visit, enter_node, exit_node

using ..Ranger:
    AbstractNode, AbstractScene, AbstractIOEvent

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter_node end
function exit_node end

function transition end
function get_replacement end
function take_replacement end
function visit end

function has_parent end
function is_nil end
function has_replacement end
function has_parent end

function update end

function get_children end

function io_event end

# ---------- INCLUDES --------------------------------------------------
include("transition_properties.jl")
include("timing_properties.jl")
include("transform_properties.jl")

include("node_data.jl")
include("node_nil.jl")
include("node_stack.jl")

include("scenes/scenes.jl")
include("scenes/scene_nil.jl")

include("node_manager.jl")

# -----------------------------------------------------------------------
# Base defaults
# -----------------------------------------------------------------------
# -----------------------------------------------------------
# Abstract Nodes
# -----------------------------------------------------------
function has_parent(node::AbstractNode)
    !is_nil(node.base.parent)
end

using ..Rendering:
    RenderContext

function visit(node::AbstractNode, context::RenderContext, interpolation::Float64)
    println("AbstractNode::visit ", node);
end

function get_children(node::AbstractNode)
    nothing
end

function io_event(node::AbstractNode, event::AbstractIOEvent)
    println("AbstractScene::io_event ", event)
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

function enter_node(node::AbstractScene, man::NodeManager)
    println("AbstractScene::enter ", node);
end

function exit_node(node::AbstractScene, man::NodeManager)
    println("AbstractScene::exit ", node);
end

function get_children(node::AbstractScene)
    nothing
end

# --------------------------------------------------------------------------
# Timing
# --------------------------------------------------------------------------
function update(node::AbstractNode, dt::Float64)
    println("AbstractNode::update : ", node)
end

import Base.show

function Base.show(io::IO, node::AbstractNode)
    print(io, "|'", node.base.name, "' (", node.base.id, ")|");
end

end # End Module --------------------------------------------------------