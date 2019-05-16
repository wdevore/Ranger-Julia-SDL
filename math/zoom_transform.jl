mutable struct ZoomTransform{T <: AbstractFloat}
    position::Vector2D{T}
    scale::Vector2D{T}
    zoom_at::Vector2D{T}

    atSCTransform::AffineTransform
    zoomCenter::AffineTransform
    scaleTransform::AffineTransform
    negScaleCenter::AffineTransform

    transform::AffineTransform
    out::AffineTransform

    function ZoomTransform{T}() where {T <: AbstractFloat}
        o = new()
        
        o.position = Vector2D{Float64}()
        o.scale = Vector2D{Float64}(1.0, 1.0)
        o.zoom_at = Vector2D{Float64}()

        o.atSCTransform = AffineTransform{Float64}()
        o.zoomCenter = AffineTransform{Float64}()
        o.scaleTransform = AffineTransform{Float64}()
        o.negScaleCenter = AffineTransform{Float64}()

        o.transform = AffineTransform{Float64}()
        o.out = AffineTransform{Float64}()
        o
    end
end

function get_transform(zoom::ZoomTransform)
    update!(zoom)
    zoom.transform
end

function update!(zoom::ZoomTransform)
    # println("up: zoom_at: ", zoom.zoom_at)
    make_translate!(zoom.zoomCenter, zoom.zoom_at.x, zoom.zoom_at.y)
    make_scale!(zoom.scaleTransform, zoom.scale.x, zoom.scale.y)
    make_translate!(zoom.negScaleCenter, -zoom.zoom_at.x, -zoom.zoom_at.y)

    # Accumulate zoom transformations.
    # atSCTransform is an intermediate accumulative matrix used for tracking the current zoom target.
    # multiply_pre!(zoom.atSCTransform, zoom.zoomCenter)
    # multiply_pre!(zoom.atSCTransform, zoom.scaleTransform)
    # multiply_pre!(zoom.atSCTransform, zoom.negScaleCenter)
    multiply!(zoom.zoomCenter, zoom.atSCTransform, zoom.out)
    set!(zoom.atSCTransform, zoom.out)
    multiply!(zoom.scaleTransform, zoom.atSCTransform, zoom.out)
    set!(zoom.atSCTransform, zoom.out)
    multiply!(zoom.negScaleCenter, zoom.atSCTransform, zoom.out)
    set!(zoom.atSCTransform, zoom.out)

    # println("up: atSCTransform: ", zoom.atSCTransform)

    # We reset Scale because atSCTransform is accumulative and has "captured" the information.
    set!(zoom.scale, 1.0, 1.0)

    # Tack on translation. Note: we don't append it, but concat it into a separate matrix.
    # We want to leave atSCTransform solely responsible for zooming.
    # "transform" is the final matrix.
    set!(zoom.transform, zoom.atSCTransform)

    translate!(zoom.transform, zoom.position.x, zoom.position.y)
    # println("up: transform: ", zoom.transform)
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
    # just set the scale absolutely because atSCTransform is an accumulating matrix.
    # We have to take its current value and compute a new value based
    # on the passed in value.

    # Also, I can use atSCTransform.a because I don't allow rotations for zooms,
    # so the diagonal components correctly represent the matrix's current scale.
    # And because I only perform uniform scaling I can safely use just the "a" element.
    scale_factor = scale / zoom.atSCTransform.a

    set!(zoom.scaleX, scale_factor, scale_factor)
end

function set_zoom_at!(zoom::ZoomTransform, x::T, y::T) where {T <: AbstractFloat}
    set!(zoom.zoom_at, x, y)
end