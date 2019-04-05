export SceneNil, is_nil

struct SceneNil <: AbstractScene
    base::NodeData

    function SceneNil()
        new(NodeData(UInt32(0), "_Nil_"))
    end
end

function is_nil(node::AbstractScene)
    node.base.id == 0
end


