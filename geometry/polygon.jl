using Base: min, max

export 
    Polygon,
    add_vertex!, build!

import .Geometry.add_vertex!
import .Geometry.build!

mutable struct Polygon{T <: AbstractFloat}
    mesh::Mesh

    function Polygon{T}() where {T <: AbstractFloat}
        new(Mesh())
    end
end

function add_vertex!(poly::Polygon{T}, x::T, y::T) where {T <: AbstractFloat}
    add_vertex!(poly.mesh, x, y)
end

function build!(poly::Polygon)
    build!(poly.mesh)
end

function is_point_inside(poly::Polygon{T}, p::Point{T}) where {T <: AbstractFloat}
    i = 1
    c = false
    vertices = poly.mesh.vertices
    nvert = length(vertices)
    j = nvert - 2 # Julia is 1-based indexing
    
    while i < nvert
        if ((vertices[i].y > p.y) ≠ (vertices[j].y > p.y)) &&
            (p.x < (vertices[j].x - vertices[i].x) * (p.y - vertices[i].y) /
              (vertices[j].y - vertices[i].y) + vertices[i].x)
            c = !c
        end
        j += 1
        i += 1
    end

    c
end
