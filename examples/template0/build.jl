# We `import` methods from Nodes so we can extend them.
# The import must occur *before* the extensions/methods defined
# in splash and game scenes.
# import .Ranger.Nodes:
#     transition, get_replacement, visit

using .Ranger.Nodes:
    NodeData, SceneNil, NodeNil, NodeManager,
    update,
    register_target, unregister_target,
    register_event_target, unregister_event_target,
    has_parent, is_dirty, set_dirty!, ready,
    TransformProperties, TransitionProperties,
    set_nonuniform_scale!, set_position!,
    calc_transform!,
    print_tree

using .Ranger.Nodes.Scenes:
    NO_ACTION, REPLACE_TAKE

using .Ranger:
    gen_id

using .Ranger.Rendering
using .Ranger.Events
using .Ranger.Geometry

module GameData
    using ..Ranger.Rendering

    orange = Rendering.Orange()
    white = Rendering.White()
    darkgray = Rendering.DarkGray()
    lightgray = Rendering.LightGray()
end

using .GameData

include("scene_boot.jl")
include("splash_scene.jl")
include("game_layer.jl")
include("game_scene.jl")

function build(world::Ranger.World)
    println("Building: ", world.title)

    game = GameScene(world, "GameScene")
    build(game, world)
    # println(game)

    splash = SplashScene(world, "SplashScene", game)
    build(splash, world)
    splash.transitioning.pause_for = 1.25 * 1000.0

    # println(splash)

    boot = SceneBoot(world, "SceneBoot", splash)
    # println(boot)

    Ranger.Engine.push(boot)

    print_tree(game)

    println("Built");
end
