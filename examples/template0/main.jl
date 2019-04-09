# ranger_path = joinpath(@__DIR__,"../../")
# include(ranger_path * "ranger.jl")

# Run this template as:
#  julia --depwarn=error -- main.jl

include("../../ranger.jl")

include("build.jl")

println("Running Template 0")

function go()
    world = Ranger.Engine.initialize("Template 0", build)

    Ranger.Engine.run(world);
end

# using Debugger
go()
