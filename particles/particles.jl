export Particles

module Particles

using ..Ranger

const MAX_PARTICLE_SPEED = 20.0
const MAX_PARTICLE_LIFETIME = 1.0
const MAX_PARTICLES = 50
const MAX_PARTICE_SIZE = 10.0

include("abstracts.jl")
include("activator_360.jl")
include("particle.jl")
include("particle_system.jl")

end