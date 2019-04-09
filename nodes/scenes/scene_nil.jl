export SceneNil, is_nil

struct SceneNil <: Ranger.AbstractScene
    base::NodeData

    function SceneNil()
        new(NodeData(UInt32(0), "_Nil_"))
    end
end

function is_nil(node::Ranger.AbstractScene)
    node.base.id == 0
end
