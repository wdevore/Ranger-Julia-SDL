using Base: min, max

export 
    Polygon,
    add_vertex!, build!

import .Geometry.add_vertex!
import .Geometry.build!

mutable struct Polygon{T <: AbstractFloat}
    mesh::Mesh

    function Polygon{T}() where {T <: AbstractFloat}
        new(
            Mesh()
        )
    end
end

function add_vertex!(poly::Polygon, x::T, y::T) where {T <: AbstractFloat}
    add_vertex!(poly.mesh, x, y)
end

function build!(poly::Polygon)
    build!(poly.mesh)
end