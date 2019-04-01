# ranger_path = joinpath(@__DIR__,"../../")
# include(ranger_path * "ranger.jl")

include("../../ranger.jl")
include("build.jl")

using .Ranger.Game:
    World

const RGame = Ranger.Game

println("Running Template 0")

function go()
    world = RGame.initialize("Template 0", build)

    RGame.run(world);
end

# using Debugger
go()