
function _default_tween_creator()
    # println("Pool: used default tween creator")
    Tween()
end

mutable struct TweenPool
    tweens::Array{AbstractTween,1}
    creator::Function # f() -> AbstractTween

    function TweenPool(creator::Function = _default_tween_creator)
        o = new()
        o.tweens = Array{AbstractTween,1}()
        o.creator = creator
        o
    end
end

function count(pool::TweenPool)
    length(pool.tweens)
end

function get_from!(pool::TweenPool)
    tween = if count(pool) == 0
        pool.creator()
    else
        pop!(pool.tweens)
    end

    reset!(tween)

    tween
end

function put_to!(pool::TweenPool, tween::AbstractTween)
    push!(pool.tweens, tween)
end