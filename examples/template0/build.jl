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
    println("splash scene has parent: ", RNodes.has_parent(splash))
    # enter(splash)
    # exit(splash)

    scene = RScenes.SceneBoot(world, "SceneBoot", splash)
    println(scene)
    println("boot scene has parent: ", RNodes.has_parent(scene))
    # enter(scene)
    # exit(scene)

    # println(RNodes.has_replacement(scene))

    println("Node:")
    node = RNodes.Node()
    # println(RNodes.has_parent(node))

    println("Built");
end
