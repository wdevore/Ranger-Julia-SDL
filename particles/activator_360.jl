# Set the properties of a particle.
# It generates a random direction from 0 to 360 degrees.
mutable struct Activator360 <: AbstractParticleActivator
    max_life::Float64
    max_speed::Float64

    function Activator360()
        o = new()
        o.max_life = MAX_PARTICLE_LIFETIME
        o.max_speed = MAX_PARTICLE_SPEED
        o
    end
end

function activate!(activator::Activator360, particle::AbstractParticle, x::Float64, y::Float64)
    # Create new velocity components
    direction = Float64(round(rand(1)[1] * 360.0))
    speed = rand(1)[1] * activator.max_speed

    Math.set_velocity!(particle.velocity, direction, speed)
    
    # The location of where the particle is emitted
    set_position!(particle, x, y)

    # A random lifetime ranging from 0.0 to max_life
    lifespan = rand(1)[1] * (activator.max_life * 1000.0)
    particle.lifespan = lifespan

    shade = clamp(Int64(round(rand(1)[1] * 32.0 * speed)), 0, 255)

    particle.visual.color.r = shade

    # Reset counter for this lifespan.
    particle.elapsed = 0.0

    activate!(particle)
end
