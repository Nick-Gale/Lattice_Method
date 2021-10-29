module LatticeMethod

using QHull
using StatsBase

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

function select_projection_points(coordinates, intial_points, spacing_upper_bound, spacing_lower_bound, minimum_spacing_fraction, spacing_reduction_factor)
    area = chull(coordinates)
    mean_spacing = 0;
    n_points = intial_points
    points_selected = []
    # While the spacing is not in bounds we target a minimum spacing and then randomly select n_points which are good candidates for the desired target spacing. We could allow some number of trials to get to the desired number

    while (mean_spacing < spacing_lower_bound) || (mean_spacing > spacing_upper_bound)        
        # set the spacing
        min_spacing = minimum_spacing_fraction * sqrt(area / n_points)
        while length(points_selected) < n_points
            # if a good trial set was not found reset the selected points and potential points and try again after reducing the spacing
            potential_points = collect(1:size(coordinates)[1])
            points_selected = []

            # if the required number of points have not yet been chosen and there are still some points to be chosen from then choose a new point
            while (length(points_selected) < n_points) && (length(potential_points)>0)
                # chose a candidate point, add it to the selected points list and remove it from potential further selections
                candidate = rand(1:length(potential_points))
                selected_index = potential_points[candidate_point_index]
                append!(points_selected, selected_index)
                deleteat!(potential_points, candidate)

                # now remove all potential points within the mininum spacing of this chosen point and remove them
                unacceptable_indexes = findall(x -> sqrt((coordinates[x, 1] - coordinates[selected_index, 1])^2 + (coordinates[x, 2] - coordinates[selected_index, 2])^2) < min_spacing, 1:length(coordinates))
                potential_points = setdiff(potential_points, unacceptable_indexes)
            end

            # reduce the spacing
            min_spacing *= spacing_reduction_factor
        end

        #compute the spacings to check if within bounds and reduce the number of points if necessary to continue the loop
        distances = sqrt.((coordinates[points_selected, 1] .- coordinates[points_selected, 1]') .^ 2 .+ (coordinates[points_selected, 2] .- coordinates[points_selected, 2]') .^ 2)
        mean_spacing = mean(distances .+ maximum(distances))
        n_points -= 1
    end

    return points_selected
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