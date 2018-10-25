#=------------------------------------------------------------------------------
------------------------------------------------------------------------------=#
module SSST
using Combinatorics

mutable struct SSSTensor
    edges::Dict{Array{Int,1},Number}
    cubical_dimension::Int
    SSSTensor(e,n) =
       SSSTensor_verifier(e,n) ? new(reduce_edges(e),n) : error("invalid indices")
    function SSSTensor(e)
        indices_valid, n = SSSTensor_verifier(e)
        if indices_valid
            new(reduce_edges(e),n)
        else
            error("invalid indices")
        end
    end
end

"""-----------------------------------------------------------------------------
    order(A)

This function returns the order of the tensor passed in.

Input
-----
* A -(SSSTensor):
    the tensor in question

Outputs
-------
* order - (Int)
    the order of the tensor
-----------------------------------------------------------------------------"""
function order(A::SSSTensor)
    for (indices,_) in A.edges
        return length(indices)
    end
end

"""-----------------------------------------------------------------------------
    reduce_edges(edges)

This function takes in the edges to passed to create a new SSSTensor and reduces
the list into a dictionary where the edges that have the same edges are added
together.

Inputs:
-------
* edges -(Array{{Array{Int,1},Number},1}):
  2 Tuples which contain the sorted indices and an edge weight associated with
  it.

Outputs:
--------
* edge_dict - (Dict{Array{Int,1},Number}):
  The resulting dictionary which has the edges aggregated together.
-----------------------------------------------------------------------------"""
function reduce_edges(edges::Array{Tuple{Array{Int,1},N},1}) where N <: Number
    edge_dict = Dict()

    for (indices, weight) in edges
        if haskey(edge_dict,indices)
            edge_dict[indices] += weight
        else
            edge_dict[indices] = weight
        end
    end
    return edge_dict
end

function reduce_edges!(edge_dict::Dict{Array{Int,1},N},
                       edges::Array{Tuple{Array{Int,1},N},1}) where N <: Number
    for (indices, weight) in edges
        if haskey(edge_dict,indices)
            edge_dict[indices] += weight
        else
            edge_dict[indices] = weight
        end
    end
    return edge_dict
end


#=
"""-----------------------------------------------------------------------------
   This function is syntactically similar to reduce_edges, but adds the reduced
edges into a prexisting dictionary.
-----------------------------------------------------------------------------"""
function reduce_edges!(edge_dict::Dict{Array{Int,1},N},
                       edges::Array{Tuple{Array{Int,1},N},1}) where N <: Number
   for (indices, weight) in edges
       if haskey(edge_dict,indices)
           edge_dict[indices] += weight
       else
           edge_dict[indices] = weight
       end
   end
end
=#

"""-----------------------------------------------------------------------------
    SSSTensor_verifier(edges,n)

This function takes a list of edges and a cubical dimension and checks whether
or not the edges are appropriate for a a super symmetric cubical tensor of n
dimensions.

Inputs:
-------
* edges - (Array{Tuple{Array{Int,1},Float}}):
  An array which contains Tuples of index arrays and Tupleed edge values
  associated. The indices must be sorted
* n  - (Int):
  An iteger indicating the desired dimension of the cubical tensor.

Outputs:
--------
is_valid - (Bool)
  An integer indicating whether or not the edges are appropriate for the tensor
  specified.
-----------------------------------------------------------------------------"""
function SSSTensor_verifier(edges::Array{Tuple{Array{Int,1},N},1},n::Int) where N <: Number

    indices_are_valid, max_index = SSSTensor_verifier(edges)

    @show indices_are_valid, max_index
    return indices_are_valid && max_index <= n
end

#UNTESTED
"""-----------------------------------------------------------------------------
    SSSTensor_verifier(edges)

This function takes in a list of edges and a cubical dimension and checks
whether or not the edges are appropriate for a super symmetric tensor with
dimension n. Used as a helper function for the SSSTensor constructors.

Inputs
------
* edges - (Array{Tuple{Array{Int,1},Float}}):
  An array which contains Tuples of index arrays and paired edge values
  associated. The indices must be sorted

Outputs
-------
* are_valid - (Bool):
    a bool indicating whether or not the edges all have positive indices and
    the indices are sorted, and have same number of indices.
* max_index - (Int):
    an integer indicating the maximum index, returns 0 if an edge is found not
    to be sorted.
-----------------------------------------------------------------------------"""
function SSSTensor_verifier(edges::Array{Tuple{Array{Int,1},N},1}) where N <: Number
    max_index = -Inf
    order = -1
    for (edge,_) in edges
        if order == -1
            order = length(edge)
        else
            if length(edge) != order
                error("edge is wrong order")
            end
        end

        if !issorted(edge) || any(x -> x < 1,edge)
            return false, 0
        end
        if edge[end] > max_index
            max_index = edge[end]
        end
    end

    return true, max_index
end

#UNTESTED
"""-----------------------------------------------------------------------------
    add_edges!(A,edges)

This function takes in a list of edges and adds them into the SSSTensor. If an
edge is already present in the tensor, and the value is added in at that index.

Inputs:
-------
* A - (SSSTensor)
* edges - (Array{Tuple{Array{Int,1},Float},1})
  an array of pairs which contain the indices in the first element, and the
  value in the second element. Note each edge's indices must be in range
-----------------------------------------------------------------------------"""
function add_edges!(A::SSSTensor,edges::Array{Tuple{Array{Int,1},N},1}) where N <: Number
    #check edges' validity
    for (indices,_) in edges
        sort!(indices)
        @assert indices[1] > 0
        @assert indices[end] <= A.cubical_dimension
    end

    for (indices,v) in edges
        if haskey(A.edges, indices)
            A.edges[indices] += v
        else
            A.edges[indices] = v
        end
    end
end

#UNTESTED
"""-----------------------------------------------------------------------------
    dense(A)

This function returns a dense representation of the SSSTensor passed in.
-----------------------------------------------------------------------------"""
function dense(A::SSSTensor)
    B = zeros(Tuple(repeat([A.cubical_dimension],order(A))))

    for (indices,_) in A.edges
        for p in permutations(indices)
            B[CartesianIndex(Tuple(p))] = A.edges[indices]
        end
    end

    return B
end

"""-----------------------------------------------------------------------------
    contract_edge(e,x,k)

This function takes in an edge of a super symmetric tensor and computes the
resulting edges which result from contracting the the edge along k modes with
the vector x.

Inputs:
-------
* e -(Tuple(Array{Int,1},Float)):
    a list of indices paired with an edge value. Note that the list of indices
    corresponds to multiple sets of indices because we consider all
    permutations.
* x -(Array{Float,1})
    The vector to contract with.
* k - (Int):
    a positive integer which corresponds to the number of modes to contract
    along, must be greater than 0, and less than or equal to the cardinality
    of the edge.
-----------------------------------------------------------------------------"""
function contract_edge(e::Tuple{Array{Int,1},Float},x,k::Int)
    order = length(e)
    @assert 0 < k <= order
    error("unfinished")
end


"""-----------------------------------------------------------------------------
    contract_edge_k_1(e,x)

This function takes in an edge of a super symmetric tensor and computes the
resulting edges which result from contracting the the edge along k-1 modes with
the vector x, where k is the order of the hyper edge.

Inputs:
-------
* e -(Tuple(Array{Int,1},Number)):
    a list of sorted indices paired with an edge value. Note that the list of
    indices corresponds to multiple sets of indices because we consider all
    permutations.
* x -(Array{Number,1})
    The vector of the same dimenionality of the tensor, to contract with.
-----------------------------------------------------------------------------"""
function contract_edge_k_1(e::Tuple{Array{Int,1},N},x::Array{N,1}) where N <: Number
    (indices,val) = e
    order = length(indices)

#    scaling_factors = Dict()
    visited_sub_indices = Set{Array{Int,1}}()
    contraction_vals = Array{Tuple{Array{Int,1},N}}(undef,0)

    for i in 1:order
        sub_edge = deleteat!(copy(indices),i)
        if !in(sub_edge,visited_sub_indices)#haskey(scaling_factors,sub_edge)
            scaling = multiplicity_factor(sub_edge)
            push!(visited_sub_indices,sub_edge)
            push!(contraction_vals,([indices[i]],scaling*val*prod(x[sub_edge])))
        end
    end
    return contraction_vals
end

"""-----------------------------------------------------------------------------
    contract_k_1(A,x)

This function contracts the tensor with the vector all the way until the result
is a vector (the generalization of the matvec).

Inputs
------
* A -(SSSTensor):
  the tensor to contract.
* x - (Array{Number,1}):
  a vector of numbers to contract with.

Outputs
-------
* y - (Array{Number,1}):
  the output vector of Ax^{k-1}.
-----------------------------------------------------------------------------"""
function contract_k_1(A::SSSTensor, x::Array{N,1}) where N <: Number
    @assert length(x) == A.cubical_dimension

    order = SSST.order(A)
    new_edges = Array{Tuple{Array{Int,1},N}}(undef,0)
    y = zeros(A.cubical_dimension)

    #compute contractions
    for edge in A.edges
        contracted_edges = contract_edge_k_1(Tuple(edge),x)
        push!(new_edges,contracted_edges...)
    end
    #reduce edges and copy into new vector
    edge_dict = reduce_edges(new_edges)

    for (i,v) in edge_dict
        y[i[1]] = v
    end
    return y
end

"""-----------------------------------------------------------------------------
    multiplicity_factor(indices)

This function takes in a list of indices and returns the multinomial coefficient
computed by the frequency of the values in the indices. Works as a helper
function for computing the number of non-zeros the edge represents in the
vector contraction routines.

Inputs
------
* indices -(Array{Int,1}):
  the indices associated with the hyper edge

Output
------
* multinomial_factor - (Int)
   the number of non-zeros this edge represents in the original tensor.
-----------------------------------------------------------------------------"""
function multiplicity_factor(indices::Array{Int,1})
    multiplicities = Dict()

    for index in indices
        @show index
        if haskey(multiplicities,index)
            multiplicities[index] += 1
        else
            multiplicities[index] = 1
        end
    end

    #copy into format that can be passed to multinomial
    final_counts = zeros(Int,length(indices))
    i = 1
    for (_,val) in multiplicities
        final_counts[i] = Int(val)
        i += 1
    end

    @show final_counts
    return multinomial(final_counts...)
end

"""-----------------------------------------------------------------------------
    dense_contraction(A,x)

This function computes a k-1 mode contraction for a dense kth order cubical
tensor representation, with a vector of the appropriate dimension.

Inputs
------
* A - (Array{Float64,k}):
  a kth order cubical tensor stored as a multidimensional array.
* x - (Array{Float,1}):
  an array corresponding to the vector to contract A with.

Outputs
-------
* y - (Array{Float64,1}):
  the result of the k-1 mode contraction.
-----------------------------------------------------------------------------"""
@generated function dense_contraction(A::Array{T,k},x::Array{Float64,1}) where {T,k}
    quote
        y = zeros(size(x))

        @nloops $k i A begin
            xs = prod(x[collect(@ntuple $(k -1) j-> i_{j+1})])
            y[i_1] += xs*(@nref $k A i)
        end
        return y
    end
end

end #module end
