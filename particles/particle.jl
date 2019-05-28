using ..Geometry
using ..Math

# Basic particle properties and functionality
mutable struct Particle{T} <: AbstractParticle{T}
    elapsed::T
    lifespan::T
    position::Geometry.Point{T}
    velocity::Math.Velocity{T}
    
    active::Bool
     
    function Particle{T}() where {T <: AbstractFloat}
        o = new()

        o.elapsed = 0.0
        o.lifespan = 0.0
        o.velocity = Math.Velocity{Float64}()
        o.position = Geometry.Point{Float64}()

        o
    end
end

function is_alive(particle::AbstractParticle{T}) where {T <: AbstractFloat}
    particle.active
end

function activate!(particle::AbstractParticle{T}, 
    x::T, y::T, velocity::Math.Velocity{T}, lifespan::T) where {T <: AbstractFloat}
    Math.set!(particle.velocity, velocity)
    Geometry.set!(particle.position, x, y)

    particle.lifespan = lifespan
    particle.elapsed = 0.0
    particle.active = true;
end

function de_activate(particle::AbstractParticle{T}) where {T <: AbstractFloat}
    particle.active = false;
end

function step!(particle::AbstractParticle{T}) where {T <: AbstractFloat}
end

function update(particle::AbstractParticle{T}, dt::Float64) where {T <: AbstractFloat}
    particle.elapsed += dt

    t = particle.elapsed / particle.lifespan

    clamp(t, 0.0, 1.0)

    step!(particle, t);
end