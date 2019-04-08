# We `import` methods from Nodes so we can extend them.
# The import must occur *before* the extensions/methods defined
# in splash and game scenes.
# import .Ranger.Nodes:
#     transition, get_replacement, visit
using .Ranger.Engine:
    World

using .Ranger.Nodes:
    NodeData, SceneNil, NodeNil, NodeManager,
    AbstractScene, AbstractNode,
    update,
    register_target, unregister_target,
    register_event_target, unregister_event_target,
    has_parent

using .Ranger.Nodes.Scenes:
    NO_ACTION

using .Ranger:
    gen_id

using .Ranger.Engine:
    World

using .Ranger.Rendering:
    RenderContext,
    White,
    set_draw_color, draw_text

using .Ranger.Events:
    KeyboardEvent
    
include("scene_boot.jl")
include("splash_scene.jl")
include("game_layer.jl")
include("game_scene.jl")

# const RGeo = Ranger.Geometry
# const RMath = Ranger.Math
# const RAnim = Ranger.Animation
# const RRendering = Ranger.Rendering
# const RNodes = Ranger.Nodes
# const RScenes = Ranger.Nodes.Scenes
const REngine = Ranger.Engine

function build(world::World)
    println("Building: ", world.title)

    game = GameScene(world, "GameScene")
    build(game, world)
    println(game)

    splash = SplashScene(world, "SplashScene", game)
    splash.transitioning.pause_for = 0.1 * 1000.0

    println(splash)
    # println("splash scene has parent: ", RNodes.has_parent(splash))

    boot = SceneBoot(world, "SceneBoot", splash)
    println(boot)
    # println("boot scene has parent: ", RNodes.has_parent(boot))

    REngine.push(boot)
    # println(RNodes.has_replacement(scene))

    println("Built");
end
