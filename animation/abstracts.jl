abstract type AbstractTween end

# ----------------------------------------------------------------------------
# The tween engine cannot directly change your objects attributes, since it doesn't
# about know them. Therefore, you need to let it know how to get and set the different
# attributes of your objects:
# **you need to implement the [AbstractTweenAccessor] interface for each object you will animate**. 
abstract type AbstractTweenAccessor end
# Gets one or many values from the target object associated to the
# given tween type. It is used by the Tween Engine to determine starting
# values.
#
# [target] The target object of the tween.
# [tween] The tween interpolating on the target
# [returnValues] An array which should be modified by the tween.
# Returns a count of how many values are to be modified.
# getValues!(target::AbstractNode, tween::Tween, buffer::Array{Float64});

# This method is called by the Tween Engine each time a running tween
# associated with the current target object has been updated.
#
# [target] The target object of the tween.
# [tween] The tween interpolating on the target
# [tweenType] An integer representing the property index.
# [newValues] The new values determined by the Tween Engine.

# setValues!(target::AbstractNode, tween::Tween, Array{Float64} newValues)
