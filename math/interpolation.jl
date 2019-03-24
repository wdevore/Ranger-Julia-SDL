export lerp, linear

# Lerp returns a the value between min and max given t = 0->1
function lerp(min::T, max::T, t::T) where {T <: AbstractFloat}
  min * (1.0 - t) + max * t
end

# TODO new to review for negative ranges.
# `linear` returns 0->1 for a "value" between min and max.
# Generally used to map from view-space to unit-space
function linear(min::T, max::T, value::T) where {T <: AbstractFloat}
  if min < 0.0
    (value - max) / (min - max)
  else
    (value - min) / (max - min)
  end
end