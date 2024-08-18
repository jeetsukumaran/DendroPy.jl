



using PythonCall

function birth_death_coalescence_ages(
    args... ; kwargs...
)
    return coalescence_ages(birth_death_tree(args...; kwargs...))
end

function birth_death_divergence_times(
    args... ; kwargs...
)
    return divergence_times(birth_death_tree(args...; kwargs...))
end

function birth_death_tree(
    birth_rate::Real=1,
    death_rate::Real=0,
    args... ;
    kwargs...
)
    bd = PythonCall.pyimport("dendropy.model.birthdeath")
    tree = bd.birth_death_tree(birth_rate, death_rate, args...;kwargs...)
    return abstract_tree(tree)
end
