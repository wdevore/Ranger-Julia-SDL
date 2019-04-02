module Scenes

export AbstractScene, SceneNil, is_nil
export visit, 
    enter_node, exit_node
export SceneActions

@enum SceneActions NO_ACTION REPLACE REPLACE_TAKE REPLACE_TAKE_UNREGISTER

using ..Nodes:
    AbstractNode, NodeData

import ..Nodes:
    is_nil

using ...Rendering:
    RenderContext

abstract type AbstractScene <: AbstractNode end

struct SceneNil <: AbstractScene
    base::NodeData

    function SceneNil()
        new(
            NodeData(UInt32(0), "_Nil_")
        )
    end
end

function is_nil(node::AbstractScene)
    node.base.id == 0
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter_node(node::AbstractScene)
    println("AbstractScene::enter scenes ", node);
end

function exit_node(node::AbstractScene)
    println("AbstractScene::exit scenes ", node);
end

function visit(node::AbstractNode, context::RenderContext, interpolation::Float64)
    println("AbstractNode::visit scenes ", node);
end

include("scene_boot.jl")

import Base.show

function Base.show(io::IO, node::AbstractScene)
    repl = nothing
    if  !is_nil(node.replacement)
        repl = node.replacement
    else
        repl = "Nil"
    end

    parent = nothing
    if !is_nil(node.base.parent)
        parent = "Nil"
    else
        parent = node.base.parent
    end
    print(io,
        "'", node.base.name, "' ",
        "(", node.base.id, ") ",
        "repl:{", repl, "}, ",
        "parent:[", parent, "]"
        );
    # show(io, node.base)
end

end

