# Basic particle properties and functionality
# A visual representation is provided by a Node.
mutable struct Particle{T} <: AbstractParticle{T}
    id::Int64
    elapsed::T
    lifespan::T
    position::Geometry.Point{T}
    velocity::Math.Velocity{T}
    
    active::Bool
    
    # visual
    visual::Ranger.AbstractNode

    function Particle{T}() where {T <: AbstractFloat}
        o = new()

        o.elapsed = 0.0
        o.lifespan = 0.0
        o.velocity = Math.Velocity{Float64}()
        Math.set_magnitude_range!(o.velocity, 0.0, 10.0)
        Math.set_magnitude!(o.velocity, 5.0)
        o.position = Geometry.Point{Float64}()

        o
    end
end

function set_visual!(particle::AbstractParticle{T}, visual::Ranger.AbstractNode) where {T <: AbstractFloat}
    particle.visual = visual
end

function set_position!(particle::AbstractParticle{T}, x::T, y::T) where {T <: AbstractFloat}
    Geometry.set!(particle.position, x, y)
    Nodes.set_position!(particle.visual, x, y)
end

function is_alive(particle::AbstractParticle{T}) where {T <: AbstractFloat}
    particle.active
end

function is_dead(particle::AbstractParticle{T}) where {T <: AbstractFloat}
    !particle.active
end

function activate!(particle::AbstractParticle{T}) where {T <: AbstractFloat}
    particle.active = true;
    particle.visual.base.visible = true;
end

function de_activate!(particle::AbstractParticle{T}) where {T <: AbstractFloat}
    particle.active = false;
    particle.visual.base.visible = false;
end

function step!(particle::AbstractParticle{T}, t::Float64) where {T <: AbstractFloat}
    particle.active = particle.elapsed < particle.lifespan

    # Adjust position based on the recent update.
    pos = particle.visual.transform.position
    Math.apply!(particle.velocity, pos)
    Nodes.set_position!(particle.visual, pos.x, pos.y)
end

function update!(particle::AbstractParticle{T}, dt::Float64) where {T <: AbstractFloat}
    particle.elapsed += dt

    t = particle.elapsed / particle.lifespan

    t = clamp(t, 0.0, 1.0)
    # println("updating particle: ", particle.id, ", elapsed: ", particle.elapsed, ", t: ", t)

    step!(particle, t);
end