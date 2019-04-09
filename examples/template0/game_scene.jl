
using .Ranger.Custom:
    CrossNode

mutable struct GameScene <: Ranger.AbstractScene
    base::NodeData
    transform::TransformProperties{Float64}

    replacement::Ranger.AbstractScene

    # Collection of layers. The first is always a background layer
    children::Array{Ranger.AbstractNode,1}

    function GameScene(world::Ranger.World, name::String)
        obj = new()

        obj.base = NodeData(gen_id(world), name, NodeNil())
        obj.replacement = SceneNil()
        obj.transform = TransformProperties{Float64}()
        obj.children = Array{Ranger.AbstractNode,1}[]

        obj
    end
end

function build(scene::GameScene, world::Ranger.World)
    layer = GameLayer(world, "GameLayer", scene)
    push!(scene.children, layer)
    build(layer, world);

    cross = CrossNode(gen_id(world), "CrossNode", scene)
    push!(scene.children, cross)
    
    set_nonuniform_scale!(scene, world.view_width, world.view_height);
    # Bake in the transform rather repeatedly perform in draw()
    calc_transform!(scene.transform)
    # This node is never dirtied
    set_dirty!(scene, false);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(scene::GameScene, dt::Float64)
    # println("SplashScene::update : ", scene)
end

# --------------------------------------------------------
# Visits and rendering
# --------------------------------------------------------
# function Ranger.Nodes.visit(scene::GameScene, context::Rendering.RenderContext, interpolation::Float64)
#     # println("GameScene visit ", node);
# end

# function Ranger.Nodes.draw(scene::GameScene, context::Rendering.RenderContext)
#     # println("GameScene::draw ", node);
#     set_draw_color(context, white)
#     draw_text(context, 10, 10, scene.base.name, 3, 2, false)
# end

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
