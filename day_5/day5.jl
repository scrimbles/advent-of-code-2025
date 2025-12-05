#!/usr/bin/env julia

using Pipe: @pipe

isfresh(ing, lst) = any(rec -> ing >= rec[1] && ing <= rec[2], lst)

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

freshingredients(ranges, ingredients) = map(ing -> isfresh(ing, ranges), ingredients) |> sum
allfresh(ranges) = 0


filename = length(ARGS) > 1 ? ARGS[1] : "input.txt"
ranges, ingredients = parsefile(filename)

println("Available fresh ingredients: ", freshingredients(ranges, ingredients))
println("Number of fresh ingredients possible: ", allfresh(filename))