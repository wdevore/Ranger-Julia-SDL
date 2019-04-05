# We `import` methods from Nodes so we can extend them.
# The import must occur *before* the extensions/methods defined
# in splash and game scenes.
# import .Ranger.Nodes:
#     transition, get_replacement, visit

include("scene_boot.jl")
include("splash_scene.jl")
include("game_scene.jl")

using .Ranger.Engine:
    World

const RGeo = Ranger.Geometry
const RMath = Ranger.Math
const RAnim = Ranger.Animation
const RRendering = Ranger.Rendering
const RNodes = Ranger.Nodes
const RScenes = Ranger.Nodes.Scenes
const REngine = Ranger.Engine

function build(world::World)
    println("Building: ", world.title)

    game = GameScene(world, "GameScene")
    println(game)
    # enter(game)
    # exit(game)

    splash = SplashScene(world, "SplashScene", game)
    println(splash)
    # println("splash scene has parent: ", RNodes.has_parent(splash))
    # enter(splash)
    # exit(splash)

    boot = SceneBoot(world, "SceneBoot", splash)
    println(boot)
    # println("boot scene has parent: ", RNodes.has_parent(boot))
    # enter(scene)
    # exit(scene)

    # TODO should we auto add SceneBoot on behalf of user?????
    REngine.push(boot)
    # println(RNodes.has_replacement(scene))

    println("Built");
end
