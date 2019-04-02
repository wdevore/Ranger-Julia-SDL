include("splash_scene.jl")
include("game_scene.jl")
include("abstracts.jl")

const RGeo = Ranger.Geometry
const RMath = Ranger.Math
const RAnim = Ranger.Animation
const RRendering = Ranger.Rendering
const RNodes = Ranger.Nodes
const RScenes = Ranger.Nodes.Scenes

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

    boot = RScenes.SceneBoot(world, "SceneBoot", splash)
    println(boot)
    # println("boot scene has parent: ", RNodes.has_parent(boot))
    # enter(scene)
    # exit(scene)

    # TODO should we auto add SceneBoot on behalf of user?????
    RGame.push(boot)
    # println(RNodes.has_replacement(scene))

    println("Built");
end
