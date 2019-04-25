export Math

module Math

const EPSILON = 0.0000001192092896

include("transforms.jl")
include("interpolation.jl")
include("vector_2d.jl")

# Scratch vectors
v1 = Vector2D{Float64}()
v2 = Vector2D{Float64}()
v3 = Vector2D{Float64}()

include("velocity.jl")

end