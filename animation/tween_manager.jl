# A TweenManager updates all your tweens and timelines at once.
# Its main interest is that it handles the tween/timeline life-cycles for you,
# as well as the pooling constraints.
#
# Just give it a bunch of tweens or timelines and call [update] periodically,
# you don't need to care for anything else! Relax and enjoy your animations.

mutable struct TweenManager
    paused::Bool
    
    targets::Array{AbstractTween,1}

    function TweenManager(paused::Bool = true)
        o = new()
        o.paused = paused
        o.targets = Array{AbstractTween,1}()
        o
    end
end

# Adds a tween or timeline to the manager and starts or restarts it.
function add!(man::TweenManager, tween::AbstractTween)
    idx = findfirst(isequal(tween), man.targets)
    if isnothing(idx)
        println("TweenManager: adding target tween")
        push!(man.targets, tween)
    end

    start!(tween)
end

function contains(man::TweenManager, tween::AbstractTween)
    idx = findfirst(isequal(tween), man.targets)
    idx
end

function remove!(man::TweenManager, tween::AbstractTween)
    idx = contains(man, tween)
    if !isnothing(idx)
        println("Removing tween target")
        deleteat!(man.targets, idx)
    else
        println("Unable to find and remove tween target");
    end
end

function kill_all!(man::TweenManager)
    for target in man.targets
        kill!(target)
    end
end

function kill_target!(man::TweenManager, tween::AbstractTween)
    idx = findfirst(isequal(tween), man.targets)
    if !isnothing(idx)
        println("Killing idx:(", idx, ") tween target")
        kill!(man.targets, idx)
    else
        println("Unable to find and kill tween target")
    end
end

function pause!(man::TweenManager)
    man.paused = true
end

function resume!(man::TweenManager)
    man.paused = false
end

function start!(man::TweenManager, tween::AbstractTween)
    add!(man, tween)
end

function update!(man::TweenManager, delta::Float64)
    items_to_remove = Array{AbstractTween,1}()

    for target in man.targets
        if target.base.finished && target.base.auto_remove
            println("TweenManager: finished and auto removing")
            free!(target)
            push!(items_to_remove, target)
        end
    end

    for item in items_to_remove
        idx = findfirst(isequal(item), man.targets)
        deleteat!(man.targets, idx)
    end

    if !man.paused
        println("TweenManager: updating: ", delta)
        if delta >= 0.0
            for target in man.targets
                update!(target, delta)
            end
        else
            for i in length(man.targets):1
                update!(man.targets[i], delta)
            end
        end
    end
end

function count(man::TweenManager)
    length(man.targets)
end