ranger_path = joinpath(@__DIR__,"../../")
# include(ranger_path * "ranger.jl")

include("../../ranger.jl")

using .Ranger.Game:
    World

using Debugger

const RGeo = Ranger.Geometry
const RMath = Ranger.Math
const RAnim = Ranger.Animation
const RGame = Ranger.Game

println("Running Template 0")

function build(world::World)
    println("Building...")
    println(world.title)
    println("Built")
end

function go()
    # try
        world = RGame.initialize("Template 0", build)
    
        RGame.run(world)
    
        RGame.exit()
    # catch e
    #     println("OOOPS... -------------------------------")
    #     println(e)
    #     println("----------------------------------------")
    # end
end

go()

# p = RGeo.Point{Float64}()
# println("p: $p")


