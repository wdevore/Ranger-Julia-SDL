
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

    # Note: If you apply a scale that is the size of the view-space
    # then the rest of your code will need to define all mesh data
    # in unit-space.
    # set_nonuniform_scale!(scene, world.view_width, world.view_height)
    # # Bake in the transform rather repeatedly perform in draw()
    # calc_transform!(scene.transform)

    # # This node/scene is never dirtied at the scene level
    set_dirty!(scene, false);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(scene::GameScene, dt::Float64)
    # println("SplashScene::update : ", scene)
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
