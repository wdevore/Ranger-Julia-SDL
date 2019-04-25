mutable struct VectorMotion
    # force to be applied to momentum
    vector_force::Math.Velocity{Float64}

    # Momentum applied to mass
    momentum::Math.Velocity{Float64}

    function VectorMotion()
        o = new()
        o.vector_force = Math.Velocity{Float64}()
        o.vector_force.max_magnitude = MAX_THRUST_MAGNITUDE
        o.momentum = Math.Velocity{Float64}()
        o.momentum.max_magnitude = MAX_MAGNITUDE
        o
    end
end

function apply_force!(motion::VectorMotion)
    if Math.get_magnitude(motion.vector_force) > 0.0
        Math.add!(motion.momentum, motion.vector_force)
    end
end

function increase_force!(motion::VectorMotion, mag::Float64)
    Math.accelerate!(motion.vector_force, mag);
end

function decrease_force!(motion::VectorMotion, mag::Float64)
    Math.accelerate!(motion.vector_force, -mag);
end

function increase_momentum!(motion::VectorMotion, mag::Float64)
    Math.accelerate!(motion.momentum, mag);
end

function decrease_momentum!(motion::VectorMotion, mag::Float64)
    Math.accelerate!(motion.momentum, -mag);
end
