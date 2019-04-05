# ranger_path = joinpath(@__DIR__,"../../")
# include(ranger_path * "ranger.jl")

include("../../ranger.jl")

const REngine = Ranger.Engine

include("build.jl")

println("Running Template 0")

function go()
    world = REngine.initialize("Template 0", build)

    REngine.run(world);
end

# using Debugger
go()
