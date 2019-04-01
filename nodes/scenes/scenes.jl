module Scenes

export AbstractScene
export SceneActions

using ..Nodes
    AbstractNode

abstract type AbstractScene <: AbstractNode end

@enum SceneActions NO_ACTION REPLACE REPLACE_TAKE REPLACE_TAKE_UNREGISTER

include("scene_boot.jl")

import Base.show

function Base.show(io::IO, node::AbstractScene)
    repl = nothing
    if !(node.replacement === node)
        repl = node.replacement
    else
        repl = "Nil"
    end

    parent = nothing
    if node === node.base.parent
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

