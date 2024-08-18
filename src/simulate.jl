



    using PythonCall

    function birth_death_divergence_times(
        args... ; kwargs...
    )
        return divergence_times(birth_death_tree(args...; kwargs...))
    end

    function birth_death_tree(
        args... ; kwargs...
    )
        bd = PythonCall.pyimport("dendropy.model.birthdeath")
        tree = bd.birth_death_tree(args...;kwargs...)
        return abstract_tree(tree)
    end
