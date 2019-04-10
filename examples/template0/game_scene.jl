
using .Ranger.Custom

mutable struct GameScene <: Ranger.AbstractScene
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    replacement::Ranger.AbstractScene

    # Collection of layers. The first is always a background layer
    children::Array{Ranger.AbstractNode,1}

    function GameScene(world::Ranger.World, name::String)
        obj = new()

        obj.base = Nodes.NodeData(gen_id(world), name, Nodes.NodeNil())
        obj.replacement = Nodes.SceneNil()
        obj.transform = Nodes.TransformProperties{Float64}()
        obj.children = Array{Ranger.AbstractNode,1}[]

        obj
    end
end

function build(scene::GameScene, world::Ranger.World)
    layer = GameLayer(world, "GameLayer", scene)
    push!(scene.children, layer)
    build(layer, world);

    cross = Custom.CrossNode(world, "CrossNode", scene)
    push!(scene.children, cross)

    text = Custom.VectorTextNode(world, "VectorTextNode", scene)
    Nodes.set_scale!(text, 50.0)
    Nodes.set_rotation_in_degrees!(text, 45.0)
    text.color = GameData.orange
    Custom.set_text!(text, GameData.vector_font, "RANGER IS A GO!")
    push!(scene.children, text)

    # Note: If you apply a scale that is the size of the view-space
    # then the rest of your code will need to define all mesh data
    # in unit-space.
    # set_nonuniform_scale!(scene, world.view_width, world.view_height)
    # # Bake in the transform rather repeatedly perform in draw()
    # calc_transform!(scene.transform)

    # # This node/scene is never dirtied at the scene level
    Nodes.set_dirty!(scene, false);
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
    Scenes.NO_ACTION
end

function Ranger.Nodes.get_replacement(scene::GameScene)
    scene.replacement
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Ranger.Nodes.get_children(node::GameScene)
    node.children
end
