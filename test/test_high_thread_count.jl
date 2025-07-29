using Test
using PolyesterWeave

@testset "High thread count compatibility" begin
    # Test worker_bits returns Int for all thread counts
    @test isa(PolyesterWeave.worker_bits(), Int)
    
    # Test worker_mask_count returns Int
    @test isa(PolyesterWeave.worker_mask_count(), Int)
    
    # Test that request_threads works with high thread counts
    # This simulates the case where worker_mask_count() > 1
    if Threads.nthreads() > 64
        # With > 64 threads, worker_mask_count() should be 2 or more
        @test PolyesterWeave.worker_mask_count() >= 2
        
        # Test that request_threads doesn't throw
        threads, torelease = PolyesterWeave.request_threads(10)
        @test length(threads) >= 0  # May get 0 if no threads available
        
        # Free the threads
        PolyesterWeave.free_threads!(torelease)
    else
        # With <= 64 threads, worker_mask_count() should be 1
        @test PolyesterWeave.worker_mask_count() == 1
    end
    
    # Test specific values
    @test PolyesterWeave.worker_bits() == max(64, nextpow2(Threads.nthreads()))
    @test PolyesterWeave.worker_mask_count() == cld(PolyesterWeave.worker_bits(), 64)
end

println("All tests passed!")