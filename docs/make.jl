using Sandboxes
using Documenter

DocMeta.setdocmeta!(Sandboxes, :DocTestSetup, :(using Sandboxes); recursive=true)

makedocs(;
    modules=[Sandboxes],
    authors="Colin Caine <cmcaine@gmail.com> and contributors",
    repo="https://github.com/cmcaine/Sandboxes.jl/blob/{commit}{path}#{line}",
    sitename="Sandboxes.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cmcaine.github.io/Sandboxes.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/cmcaine/Sandboxes.jl",
    devbranch="main",
)
