# Set the properties of a particle.
# It generates a random direction from 0 to 360 degrees.
mutable struct Activator360 <: AbstractParticleActivator
    function Activator360()
        o = new()
        o
    end
end

function activate!(activator::Activator360, particle::AbstractParticle, x::Float64, y::Float64)
    # Create a new direction
    degrees = Float64(round(rand(1)[1] * 360.0))
    speed = rand(1)[1] * 10.0

    Math.set_direction!(particle.velocity, degrees)
    Math.increase_speed!(particle.velocity, speed)
    
    set_position!(particle, x, y)

    lifespan = rand(1)[1] * (3.0 * 1000.0)
    # println("activating :", particle.id, ", lifespan: ", lifespan, ", speed: ", speed, ", velocity: ", particle.velocity)

    particle.lifespan = lifespan
    particle.elapsed = 0.0

    activate!(particle)
end
