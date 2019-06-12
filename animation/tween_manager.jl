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

function add!(man::TweenManager, tween::AbstractTween)
    idx = findfirst(isequal(tween), man.targets)
    if idx == nothing
        push!(man, tween)
        start!(tween)
    end
end

function remove!(man::TweenManager, tween::AbstractTween)
    idx = findfirst(isequal(tween), man.targets)
    if idx ≠ nothing
        println("Removing idx:(", idx, ") tween target");
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
    if idx ≠ nothing
        println("Killing idx:(", idx, ") tween target");
        kill!(man.targets, idx)
    else
        println("Unable to find and kill tween target");
    end
end

function pause!(man::TweenManager)
    man.paused = true
end

function resume!(man::TweenManager)
    man.paused = false
end

function update!(man::TweenManager, delta::Float64)
    items_to_remove = Array{AbstractTween,1}()

    for target in man.targets
        if target.finished && target.auto_remove
            free!(target)
            push!(items_to_remove, target)
        end
    end

    for item in items_to_remove
        idx = findfirst(isequal(item), man.targets)
        deleteat!(man.targets, idx)
    end

    if !man.paused
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