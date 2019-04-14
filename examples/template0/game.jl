# We `import` methods from Nodes so we can extend them.
# The import must occur *before* the extensions/methods defined
# in splash and game scenes.
# import .Ranger.Nodes:
#     transition, get_replacement, visit

using .Ranger

module RangerGame
using ..Ranger
using ..Ranger.Rendering
using ..Ranger.Events
using ..Ranger.Geometry
using ..Ranger.Nodes
using ..Ranger.Nodes.Scenes
using ..Ranger.Nodes.Custom
using ..Ranger.Animation
using ..Ranger.Nodes.Filters

orange = Rendering.Orange()
white = Rendering.White()
darkgray = Rendering.DarkGray()
lightgray = Rendering.LightGray()
red = Rendering.Red()
yellow = Rendering.Yellow()
blue = Rendering.Blue()
lightblue = Rendering.LightNavyBlue()
lime = Rendering.Lime()
olive = Rendering.Olive()

# vector_font = Rendering.VectorFont()
# Rendering.load_font!(vector_font)

include("orbit_system_node.jl")
include("scene_boot.jl")
include("splash_scene.jl")
include("game_layer.jl")
include("game_scene.jl")

export go

function build(world::Ranger.World)
    println("Building: ", world.title)
    
    game = GameScene(world, "GameScene")
    build(game, world)
    
    splash = SplashScene(world, "SplashScene", game)
    build(splash, world)
    splash.transitioning.pause_for = 0.25 * 1000.0
    
    boot = SceneBoot(world, "SceneBoot", splash)
    
    Ranger.Engine.push(boot)
    
    Nodes.print_tree(game)
    
    println("Built");
end

function go()
    world = Ranger.Engine.initialize("Template 0", build)

    if world ≠ nothing
        Ranger.Engine.run(world);
    end
end

end # Module ----------------------------------------------------------
