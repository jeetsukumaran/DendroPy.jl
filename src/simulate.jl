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
    value_type::Type = TreeNode,
    n_replicates = 1,
    ;
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
        # (num_extant_tips, kwargs) = pop_key(kwargs, :n_leaves, 10)
        # kwargs[:num_extant_tips] = num_extant_tips
        tree = bd.birth_death_tree(
                birth_rate,
                death_rate,
                ;
                kwargs...
        )
        if (value_type === WrappedPythonType)
            # do not convert
        elseif (value_type === AbstractTree || value_type === TreeNode)
            tree = abstract_tree(tree)
        else
            throw(ArgumentError("Unsupported 'value_type': $(value_type)"))
        end
        push!(trees, tree)
    end
    return trees
end

function birth_death_coalescent_tree_suites(
    rng,
    structuring_sampling_params,
    structured_sampling_params,
    n_replicates = 1;
    convert_fn = abstract_tree,
)
    # dp_treesim = PythonCall.pyimport("dendropy.simulate.treesim")
    dp_coalescent = PythonCall.pyimport("dendropy.model.coalescent")
    # structuring_trees = [wt.data for wt in birth_death_trees(
    #     rng,
    #     structuring_sampling_params,
    #     WrappedPythonType,
    #     n_replicates,
    # )]
    structuring_trees = birth_death_trees(
        rng,
        structuring_sampling_params,
        WrappedPythonType,
        n_replicates,
    )
    structured_trees = []
    for (st_tree_idx, structuring_tree) in enumerate(structuring_trees)
        kwargs = Dict{Symbol, Any}(rand(rng, structured_sampling_params))
        results = []
        structured_tree_samples = []
        for coal_tree_idx in 1:pop!(kwargs, :n_trees_per_gene, 1)
            (coal_tree, pop_tree) = dp_coalescent.constrained_kingman_tree(
                    structuring_tree;
                    kwargs...
            )
            if (convert_fn !== nothing)
                coal_tree = convert_fn(coal_tree)
            end
            push!(structured_tree_samples, coal_tree)
        end
        push!(structured_trees, structured_tree_samples)
    end
    if convert_fn !== nothing
        structuring_trees = [convert_fn(st) for st in structuring_trees]
    end
    return [
        structuring_trees,
        structured_trees,
    ]
end
