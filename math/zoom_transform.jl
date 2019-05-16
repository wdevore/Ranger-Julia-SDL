mutable struct ZoomTransform{T <: AbstractFloat}
    # An optional (occasionally used) translation.
    position::Vector2D{T}

    # The zoom factor generally incremented in small steps.
    # For example, 0.1
    scale::Vector2D{T}

    # The focal point where zooming occurs
    zoom_at::Vector2D{T}

    # A "running" accumulating transform
    acc_transform::AffineTransform

    # A transform that includes position translation.
    transform::AffineTransform

    function ZoomTransform{T}() where {T <: AbstractFloat}
        o = new()
        
        o.position = Vector2D{Float64}()
        o.scale = Vector2D{Float64}(1.0, 1.0)
        o.zoom_at = Vector2D{Float64}()

        o.acc_transform = AffineTransform{Float64}()

        o.transform = AffineTransform{Float64}()
        o
    end
end

function get_transform(zoom::ZoomTransform)
    update!(zoom)
    zoom.transform
end

function update!(zoom::ZoomTransform)
    # Accumulate zoom transformations.
    # acc_transform is an intermediate accumulative matrix used for tracking the current zoom target.
    translate!(zoom.acc_transform, zoom.zoom_at.x, zoom.zoom_at.y)
    scale!(zoom.acc_transform, zoom.scale.x, zoom.scale.y)
    translate!(zoom.acc_transform, -zoom.zoom_at.x, -zoom.zoom_at.y)

    # We reset Scale because acc_transform is accumulative and has "captured" the information.
    set!(zoom.scale, 1.0, 1.0)

    # We want to leave acc_transform solely responsible for zooming.
    # "transform" is the final matrix.
    set!(zoom.transform, zoom.acc_transform)

    # Tack on translation. Note: we don't append it, but concat it into a separate matrix.
    translate!(zoom.transform, zoom.position.x, zoom.position.y)
end

# Use this if you want to manually set the positional value.
# You would typically use translateBy() instead.
function set_position!(zoom::ZoomTransform, x::T, y::T) where {T <: AbstractFloat}
    set!(zoom.position, x, y)
end

# A relative zoom.
# [delta] is relative to the current scale/zoom.
function zoom_by!(zoom::ZoomTransform, delta_x::T, delta_y::T) where {T <: AbstractFloat}
    set!(zoom.scale, zoom.scale.x + delta_x, zoom.scale.y + delta_y)
end

function translate_by!(zoom::ZoomTransform, delta_x::T, delta_y::T) where {T <: AbstractFloat}
    set!(zoom.position, zoom.position.x + delta_x, zoom.position.y + delta_y)
end

function set_scale!(zoom::ZoomTransform, scale::T) where {T <: AbstractFloat}
    update!(zoom)

    # We use dimensional analysis to set the scale. Remember we can't
    # just set the scale absolutely because acc_transform is an accumulating matrix.
    # We have to take its current value and compute a new value based
    # on the passed in value.

    # Also, I can use acc_transform.a because I don't allow rotations for zooms,
    # so the diagonal components correctly represent the matrix's current scale.
    # And because I only perform uniform scaling I can safely use just the "a" element.
    scale_factor = scale / zoom.acc_transform.a

    set!(zoom.scaleX, scale_factor, scale_factor)
end

function set_zoom_at!(zoom::ZoomTransform, x::T, y::T) where {T <: AbstractFloat}
    set!(zoom.zoom_at, x, y)
end