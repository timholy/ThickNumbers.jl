using ThickNumbers
using Documenter

DocMeta.setdocmeta!(ThickNumbers, :DocTestSetup, :(using ThickNumbers); recursive=true)

makedocs(;
    modules=[ThickNumbers],
    authors="Tim Holy <tim.holy@gmail.com> and contributors",
    repo="https://github.com/timholy/ThickNumbers.jl/blob/{commit}{path}#{line}",
    sitename="ThickNumbers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://timholy.github.io/ThickNumbers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "required.md",
        "optional.md",
        "user_api.md",
    ],
)

deploydocs(;
    repo="github.com/timholy/ThickNumbers.jl",
    devbranch="main",
    push_preview=true,
)
