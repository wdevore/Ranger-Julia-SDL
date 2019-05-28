# An emitter emits particles when trigger by an external event.
# Once triggered properties must be set on a particle by an activator.
mutable struct ParticleSystem
    epi_center::Geometry.Point
    activator::AbstractActivator

    particles::Array{Particle,1}

    function ParticleSystem(activator::AbstractActivator)
        o = new()

        o.activator = activator
        o.epi_center = Geometry.Point{Float64}()

        o
    end
end

function add_particle(ps::ParticleSystem, particle::Particle)
end

function trigger(ps::ParticleSystem)
end

function trigger_at(ps::ParticleSystem, x::Float64, y::Float64)
end