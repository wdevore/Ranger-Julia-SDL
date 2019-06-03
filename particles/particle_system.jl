# An emitter emits particles when trigger by an external event.
# Once triggered properties must be set on a particle by an activator.
mutable struct ParticleSystem
    epi_center::Geometry.Point

    activator::AbstractParticleActivator

    particles::Array{AbstractParticle,1}

    active::Bool
    auto_trigger::Bool

    ids::Int64

    function ParticleSystem(activator::AbstractParticleActivator)
        o = new()

        o.activator = activator
        o.epi_center = Geometry.Point{Float64}()
        o.particles = Array{AbstractParticle,1}()
        o.active = false
        o.auto_trigger = false
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

                if is_dead(p)
                    if ps.auto_trigger
                        trigger_oneshot!(ps)
                    else
                        de_activate!(p)
                    end
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
        if is_dead(p)
            activate!(ps.activator, p, ps.epi_center.x, ps.epi_center.y)
            break
        end
    end
end

function trigger_at!(ps::ParticleSystem, x::Float64, y::Float64)
    # Look for a dead particle to resurrect.
    for p in ps.particles
        if is_dead(p)
            activate!(ps.activator, p, x, y)
            break
        end
    end
end

function explode!(ps::ParticleSystem)
    for p in ps.particles
        activate!(ps.activator, p, ps.epi_center.x, ps.epi_center.y)
    end
end