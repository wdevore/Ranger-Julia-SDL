# ----------------------------------------------------------
# Space mappings
# ----------------------------------------------------------

function map_device_to_view(context::Rendering.RenderContext, dx::Int32, dy::Int32, view_point::Geometry.Point{Float64})
    Math.transform!(context.inv_view_space, Float64(dx), Float64(dy), view_point);
end