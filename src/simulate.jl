using PythonCall

function pop_key(d, key, default)
    value = get(d, key, default)
    popped_d = Dict(k => v for (k, v) in d if k != key)
    return value, popped_d
end

function birth_death_coalescence_ages(
    rng,
    sampling_params,
    n_replicates,
)
    return DendroPy.coalescence_ages.(birth_death_trees(rng, sampling_params, n_replicates))
end

function birth_death_divergence_times(
    rng,
    sampling_params,
    n_replicates,
    ;
    kwargs...
)
    return DendroPy.divergence_times.(birth_death_trees(rng, sampling_params, n_replicates))
end

function birth_death_trees(
    rng,
    sampling_params,
    n_replicates,
)
    dp = PythonCall.pyimport("dendropy")
    bd = PythonCall.pyimport("dendropy.model.birthdeath")
    tns = dp.TaxonNamespace()
    trees = []
    for rep_idx in 1:n_replicates
        kwargs = Dict{Symbol, Any}(sampling_params)
        (birth_rate, kwargs) = pop_key(kwargs, :birth_rate, 1.0)
        if isa(birth_rate, Function) || isa(birth_rate, Type)
            birth_rate = birth_rate(rng)
        end
        (death_rate, kwargs) = pop_key(kwargs, :death_rate, 0.0)
        if isa(death_rate, Function) || isa(death_rate, Type)
            death_rate = death_rate(rng)
        end
        (num_extant_tips, kwargs) = pop_key(kwargs, :n_leaves, 10)
        kwargs[:num_extant_tips] = num_extant_tips
        tree = bd.birth_death_tree(
                birth_rate,
                death_rate,
                ;
                kwargs...
        )
        tree = abstract_tree(tree)
        push!(trees, tree)
    end
    return trees
end

function birth_death_coalescent_trees(
    rng,
    n_replicates,
    ;
    kwargs...
)
end
