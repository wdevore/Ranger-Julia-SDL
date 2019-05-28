# ranger_path = joinpath(@__DIR__,"../../")
# include(ranger_path * "ranger.jl")

# Run this template as:
#  julia --depwarn=error -- main.jl

include("../../ranger.jl")

include("game.jl")

using .RangerGame

println("Running Template Particles")

# using Debugger
RangerGame.go()
