# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter(node::AbstractScene)
    println("AbstractScene::enter ", node);
end

function exit(node::AbstractScene)
    println("AbstractScene::exit ", node);
end

function visit(node::AbstractNode, context::RenderContext, interpolation::Float64)
    println("AbstractNode::visit ", node);
end

