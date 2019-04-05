export Scenes

module Scenes

export
    SceneActions

@enum SceneActions NO_ACTION REPLACE REPLACE_TAKE REPLACE_TAKE_UNREGISTER

using ...Nodes:
    NodeData,
    is_nil, AbstractScene

import Base.show

function Base.show(io::IO, node::AbstractScene)
    # repl = nothing
    # if  !is_nil(node.replacement)
    #     repl = node.replacement.base.name
    # else
    #     repl = "Nil"
    # end

    # parent = nothing
    # if is_nil(node.base.parent)
    #     parent = "Nil"
    # else
    #     parent = node.base.parent
    # end
    # print(io,
    #     "'", node.base.name, "' ",
    #     "(", node.base.id, ") ",
    #     "repl:{", repl, "}");
    show(io, node.base)
end

end # Module -------------------------------------------------------

