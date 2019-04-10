# We `import` methods from Nodes so we can extend them.
# The import must occur *before* the extensions/methods defined
# in splash and game scenes.
# import .Ranger.Nodes:
#     transition, get_replacement, visit

using .Ranger.Nodes
using .Ranger.Nodes.Scenes
using .Ranger.Nodes.Custom

using .Ranger
using .Ranger.Rendering
using .Ranger.Events
using .Ranger.Geometry

module GameData
    using ..Ranger.Rendering

    orange = Rendering.Orange()
    white = Rendering.White()
    darkgray = Rendering.DarkGray()
    lightgray = Rendering.LightGray()
    red = Rendering.Red()
    yellow = Rendering.Yellow()

    vector_font = Rendering.VectorFont()
    Rendering.build_font!(vector_font)
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
    splash.transitioning.pause_for = 0.25 * 1000.0

    # println(splash)

    boot = SceneBoot(world, "SceneBoot", splash)
    # println(boot)

    Ranger.Engine.push(boot)

    Nodes.print_tree(game)

    println("Built");
end
