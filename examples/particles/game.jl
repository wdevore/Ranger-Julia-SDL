
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
yellow = Rendering.Yellow()
blue = Rendering.Blue()
lightblue = Rendering.LightNavyBlue()
red = Rendering.Red()
lime = Rendering.Lime()
olive = Rendering.Olive()
lightpurple = Rendering.LightPurple()
peach = Rendering.Peach()

include("drag_state.jl")
include("host_node.jl")
include("game_layer.jl")
include("game_scene.jl")

export go

function build(world::Ranger.World)
    println("Building: ", world.title)
    
    game = GameScene(world, "GameScene")
    build(game, world)
    
    Ranger.Engine.push(game)
    
    Nodes.print_tree(game)
    
    println("Built");
end

function go()
    world = Ranger.Engine.initialize("Template Particles", build)

    if world ≠ nothing
        Ranger.Engine.run(world);
    end
end

end # Module ----------------------------------------------------------
