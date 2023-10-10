if !isdefined(@__MODULE__, :testpackagesdir)
    const interfacetestsdir = abspath(joinpath(dirname(@__DIR__), "ThickNumbersInterfaceTests"))
    const testpackagesdir = joinpath(interfacetestsdir, "test", "testpackages")

    if testpackagesdir ∉ LOAD_PATH
        push!(LOAD_PATH, testpackagesdir)
    end

    function cleanup()
        filter!(LOAD_PATH) do path
            path != testpackagesdir && path != interfacetestsdir
        end
        return nothing
    end
end
