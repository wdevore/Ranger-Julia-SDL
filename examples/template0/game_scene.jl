
mutable struct GameScene <: AbstractScene
    base::NodeData

    replacement::AbstractScene

    # Collection of layers. The first is always a background layer
    children::Array{AbstractNode,1}

    function GameScene(world::World, name::String)
        obj = new()

        obj.base = NodeData(gen_id(world), name, NodeNil())
        obj.replacement = SceneNil()
        obj.children = Array{AbstractNode,1}[]
        
        obj
    end
end

function build(scene::GameScene, world::World)
    layer = GameLayer(world, "GameLayer", scene)
    push!(scene.children, layer)
    build(layer, world);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(scene::GameScene, dt::Float64)
    # println("SplashScene::update : ", scene)
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function Ranger.Nodes.visit(scene::GameScene, context::RenderContext, interpolation::Float64)
    # println("GameScene visit ", node);
    set_draw_color(context, white)
    draw_text(context, 10, 10, scene.base.name, 3, 2, false)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Ranger.Nodes.enter_node(scene::GameScene, man::NodeManager)
    println("enter ", scene);
    # Register node as a timing target in order to receive updates
    # register_target(man, scene);
end

function Ranger.Nodes.exit_node(scene::GameScene, man::NodeManager)
    println("exit ", scene);
    # unregister_target(man, scene);
end

function Ranger.Nodes.transition(scene::GameScene)
    NO_ACTION
end

function Ranger.Nodes.get_replacement(scene::GameScene)
    scene.replacement
end

function Ranger.Nodes.get_children(node::GameScene)
    node.children
end
