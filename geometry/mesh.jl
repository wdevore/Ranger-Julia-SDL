mutable struct Mesh
    # Original untransformed vertices
    vertices::Array{Point{Float64},1}
    # Transformed vertices
    bucket::Array{Point{Float64},1}

    function Mesh()
        obj = new()

        obj.vertices = Array{Point{Float64},1}[]
        obj.bucket = Array{Point{Float64},1}[]

        obj
    end
end

function add_vertex!(mesh::Mesh, x::T, y::T) where {T <: AbstractFloat}
    push!(mesh.vertices, Point{Float64}(x, y))
end

function build!(mesh::Mesh)
    for p in mesh.vertices
        push!(mesh.bucket, Point{Float64}())
    end
end