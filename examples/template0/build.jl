# We `import` methods from Nodes so we can extend them.
# The import must occur *before* the extensions/methods defined
# in splash and game scenes.
# import .Ranger.Nodes:
#     transition, get_replacement, visit
using .Ranger.Engine:
    World

using .Ranger:
    AbstractScene, AbstractNode

using .Ranger.Nodes:
    NodeData, SceneNil, NodeNil, NodeManager,
    update,
    register_target, unregister_target,
    register_event_target, unregister_event_target,
    has_parent, is_dirty, set_dirty!,
    TransformProperties,
    set_nonuniform_scale!, set_position!

using .Ranger.Nodes.Scenes:
    NO_ACTION

using .Ranger:
    gen_id

using .Ranger.Rendering:
    RenderContext,
    Orange, White, DarkGray,
    set_draw_color, draw_text, render_aa_rectangle,
    FILLED,
    transform!

using .Ranger.Events:
    KeyboardEvent

using .Ranger.Geometry:
    Point, Mesh,
    add_vertex!, build_it!

include("scene_boot.jl")
include("splash_scene.jl")
include("game_layer.jl")
include("game_scene.jl")

const REngine = Ranger.Engine

orange = Orange()
white = White()
darkgray = DarkGray()

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
