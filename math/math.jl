export Math

module Math

const EPSILON = 0.0000001192092896

include("transforms.jl")
include("interpolation.jl")
include("vector_2d.jl")

end