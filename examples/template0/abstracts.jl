# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter_node(node::AbstractScene)
    println("AbstractScene::enter ", node);
end

function exit_node(node::AbstractScene)
    println("AbstractScene::exit ", node);
end

function visit(node::AbstractNode, context::RenderContext, interpolation::Float64)
    println("AbstractNode::visit ", node);
end

