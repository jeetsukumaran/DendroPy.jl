using DendroPy
using Documenter

DocMeta.setdocmeta!(DendroPy, :DocTestSetup, :(using DendroPy); recursive=true)

makedocs(;
    modules=[DendroPy],
    authors="Jeet Sukumaran <jeetsukumaran@gmail.com>",
    sitename="DendroPy.jl",
    format=Documenter.HTML(;
        canonical="https://jeetsukumaran.github.io/DendroPy.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jeetsukumaran/DendroPy.jl",
    devbranch="main",
)
