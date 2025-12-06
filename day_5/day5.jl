#!/usr/bin/env julia

using Pipe: @pipe


function parsefile(filename)

    txt = readlines(filename; keep=true)
    radix = findfirst(l -> l == "\n", txt)

    ranges = @pipe(
        txt
        |> _[1:radix-1]
        |> map(l -> strip(l), _)
        |> map(pstr -> split(pstr, "-"), _)
        |> map(pvec -> map(x -> parse(Int, x), pvec), _)
        |> map(pvec -> Pair(pvec...), _)
    )

    ingredients = @pipe(
        txt
        |> _[radix+1:end]
        |> map(x -> parse(Int, x), _)
    )

    ranges, ingredients
end

isfresh(ing, lst) = any(rec -> ing >= rec[1] && ing <= rec[2], lst)
freshingredients(ranges, ingredients) = map(ing -> isfresh(ing, ranges), ingredients) |> sum

function combine(R)
    R₁ = []
    a₁, b₁ = 0, 0
    for r ∈ R
        a₂, b₂ = r
        if a₂ > b₁
            # no overlap, store current range to R₁
            if a₁ != b₁ # ignore the starting 0,0
                push!(R₁, Pair(a₁, b₁))
            end
            a₁, b₁ = a₂, b₂
        else
            # overlap, replace our b with the maximum between b₁ and b₂
            b₁ = max(b₁, b₂)
        end
    end
    if a₁ != R₁[end][1]
        push!(R₁, Pair(a₁, b₁))
    end

    R₁
end

allfresh(ranges) = @pipe(
    ranges
    |> sort(_; by=r -> r[1])
    |> combine
    |> map(p -> (p[2] - p[1]) + 1, _)
    |> sum
)



function main(filename)
    ranges, ingredients = parsefile(filename)

    println("Available fresh ingredients: ", freshingredients(ranges, ingredients))
    println("Number of fresh ingredients possible: ", allfresh(ranges))
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
main(filename)