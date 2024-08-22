using PythonCall

function pop_key(d, key, default)
    value = get(d, key, default)
    popped_d = Dict(k => v for (k, v) in d if k != key)
    return value, popped_d
end

function birth_death_coalescence_ages(
    rng,
    n_leaves_fn,
    n_replicates,
    ;
    kwargs...
)
    return DendroPy.coalescence_ages.(birth_death_trees(rng, n_leaves_fn, n_replicates; kwargs...))
end

function birth_death_divergence_times(
    rng,
    n_leaves_fn,
    n_replicates,
    ;
    kwargs...
)
    return DendroPy.divergence_times.(birth_death_trees(rng, n_leaves_fn, n_replicates; kwargs...))
end

function birth_death_trees(
    rng,
    n_leaves_fn,
    n_replicates,
    ;
    kwargs...
)
    dp = PythonCall.pyimport("dendropy")
    bd = PythonCall.pyimport("dendropy.model.birthdeath")
    tns = dp.TaxonNamespace()
    (birth_rate, kwargs) = pop_key(kwargs, :birth_rate, 1.0)
    (death_rate, kwargs) = pop_key(kwargs, :death_rate, 0.0)
    n_leaves_per_tree = [ n_leaves_fn() for _ in 1:n_replicates ]
    trees = []
    for n_leaves in n_leaves_per_tree
        dp_kwargs = copy(kwargs)
        dp_kwargs[:num_extant_tips] = n_leaves
        tree = bd.birth_death_tree(
                birth_rate,
                death_rate,
                ;
                dp_kwargs...
        )
        tree = abstract_tree(tree)
        push!(trees, tree)
    end
    return trees
end
