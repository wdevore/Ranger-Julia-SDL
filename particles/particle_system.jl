# An emitter emits particles when trigger by an external event.
# Once triggered properties must be set on a particle by an activator.
mutable struct ParticleSystem
    epi_center::Geometry.Point

    activator::AbstractParticleActivator

    particles::Array{AbstractParticle,1}

    active::Bool

    ids::Int64

    function ParticleSystem(activator::AbstractParticleActivator)
        o = new()

        o.activator = activator
        o.epi_center = Geometry.Point{Float64}()
        o.particles = Array{AbstractParticle,1}()
        o.active = false
        o.ids = 1
        o
    end
end

function add_particle!(ps::ParticleSystem, particle::AbstractParticle)
    particle.id = ps.ids
    push!(ps.particles, particle)
    ps.ids += 1
end

function update!(ps::ParticleSystem, dt::Float64)
    if ps.active
        for p in ps.particles
            if p.active
                update!(p, dt)

                if !is_alive(p)
                    # println("particle died: ", p.id)
                    de_activate!(p)
                end
            end
        end
    end
end

function set_position!(ps::ParticleSystem, x::Float64, y::Float64)
    Geometry.set!(ps.epi_center, x, y)
end

function trigger_oneshot!(ps::ParticleSystem)
    # Look for a dead particle to resurrect.
    for p in ps.particles
        if !is_alive(p)
            # Use the activator on a single particle.
            # println("activating particle: ", p.id)
            activate!(ps.activator, p, ps.epi_center.x, ps.epi_center.y)
            break
        end
    end
end

function trigger_at!(ps::ParticleSystem, x::Float64, y::Float64)
end