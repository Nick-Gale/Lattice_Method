module LatticeMethod

struct Lattice
    # the raw pre_synaptic and post_synaptic co-ordinate locations
    pre_synaptic::Array{Float64, 2}
    post_synaptic::Array{Float64, 2}

    # the data defined topographic map under some measurement
    topographic_map::Array{Float64, 2}

    # the forward projection 
    forward_projection::Array{Int, 2}
    forward_triangulation::Array{Int, 2}
    forward_links_removed::Array{Int, 2}
    forward_links_retained::Array{Int, 2}

    # the reverse projection 
    reverse_projection::Array{Int, 2}
    reverse_triangulation::Array{Int, 2}
    reverse_links_removed::Array{Int, 2}
    reverse_links_retained::Array{Int, 2}

    # the construction method 
    function Lattice(pre_x::Array{Float64, 1}, pre_y::Array{Float64, 1}, post_x::Array{Float64, 1}, post_y::Array{Float64, 1}, params_linking::Any, params_lattice::Any)
        
        # construct the topographic map by some linking function 
        topographic_map = topographic_linking(pre_synaptic, post_synaptic, params_linking...)
        pre_synaptic = vcat(pre_x, pre_y)
        post_synaptic = vcat(post_x, post_y)

        # define the projections pre_image on a restricted number of points
        forward_preimage_points = select_projection_points(pre_synaptic, params.lattice_forward_preimage...)
        reverse_preimage_points = select_projection_points(post_synaptic, params.lattice_reverse_preimage...)

        # create the images 
        forward_image_points = create_projection(forward_preimage_points, pre_synaptic, post_synaptic, params.lattice_forward_image...)
        reverse_image_points = create_projection(reverse_preimage_points, post_synaptic, pre_synaptic, params.lattice_reverse_image...)

        # create the functional map on the indexes
        forward_projection = vcat(forward_preimage_points, forward_image_points)
        reverse_projection = vcat(reverse_preimage_points, reverse_image_points)

        # create the triangulations; graph adjacencies indexed on 1:length(projection)
        forward_triangulation_abstract = triangulate(pre_synaptic[forward_preimage_points,:], params_lattice.forward_triangle_tolerance)
        reverse_triangulation_abstract = triangulate(post_synaptic[reverse_preimage_points,:], params_lattice.reverse_triangle_tolerance)

        # remove any overlapping links when the functional map is applied to the graph, the links remaining define the lattice object
        forward_links_retained, forward_links_removed = link_crossings(post_synaptic, forward_triangulation_abstract, forward_projection)
        reverse_links_retained, reverse_links_removed = link_crossings(pre_synaptic, reverse_triangulation_abstract, reverse_projection)
    end
end

function select_projection_points(coordinates, intial_points, spacing, spacing_multiplier, spacing_upper_bound, spacing_lower_bound)

    return indexes
end

function create_projection(preimage_points, preimage_coordinates, image_coordinates, radius)

    return indexes 
end

function topograph_linking(pre_synaptic, post_synaptic, params_linking)
    linking_key = params_linking[1]
    if linking_key == "phase_linking"
        return topographic_phase_linking(pre_synaptic, post_synaptic, params_linking[2:end]...)
    end
end

function topographic_phase_linking(pre_synaptic, post_synaptic, p1=1, p2=2)
    array = zeros(Float64, 2, size(pre_synaptic)[2])
    return array
end

# end module
end