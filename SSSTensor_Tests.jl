using SSST
using Test
"""------------------------------------#----------------------------------------
                               SSSTensor Test Suite
-----------------------------------------------------------------------------"""
                                Constructor Tests
#------------------------------------------------------------------------------#

"""-----------------------------------------------------------------------------
                                Add Edges Tests
-----------------------------------------------------------------------------"""


"""-----------------------------------------------------------------------------
                             Vector Contraction Tests
-----------------------------------------------------------------------------"""


"""-----------------------------------------------------------------------------
                                Multiplicity Tests
-----------------------------------------------------------------------------"""
@testset "multiplicity_tests" begin
    @Test multiplicity_factor([1,1,1,1,1]) = 1
    @Test multiplicity_factor([1,2,1,1,1]) = 5
    @Test multiplicity_factor([2,2,1,1,1]) = 10
end
