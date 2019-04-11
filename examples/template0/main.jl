# ranger_path = joinpath(@__DIR__,"../../")
# include(ranger_path * "ranger.jl")

# Run this template as:
#  julia --depwarn=error -- main.jl

include("../../ranger.jl")

include("build.jl")

using .RangerGame

println("Running Template 0")

# using Debugger
RangerGame.go()
