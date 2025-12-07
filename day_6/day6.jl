#!/usr/bin/env julia

using Pipe: @pipe

ϕ(s) = s == "+" || s == '+' ? Base.:+ : Base.:*

solve(prob) = @pipe(
    prob
    |> filter(s -> all(isnumeric, s), _)
    |> map(n -> parse(Int, n), _)
    |> reduce(ϕ(prob[end]), _)
)

solve₂(prob) = @pipe(
    prob
    |> map(p -> filter(isnumeric, p) |> collect |> String, _)
    |> map(n -> parse(Int, n), _)
    |> reduce(ϕ(prob[1][end]), _)
)

splitᵥ(λ, a::Vector) = @pipe(
    [firstindex(a) - 1; findall(λ, a); lastindex(a) + 1]
    |> tuple(@view(_[1:end-1]), @view(_[2:end]))
    |> zip(_...)
    |> map(x -> view(a, x[1]+1:x[2]-1), _)
)

part1(filename) = @pipe(
    readlines(filename)
    |> map(split, _)
    |> zip(_...)
    |> map(collect, _)
    |> map(solve, _)
    |> sum
)

part2(filename) = @pipe(
    readlines(filename)
    |> map(collect, _)
    |> zip(_...)
    |> collect
    |> splitᵥ(p -> all(isspace, p), _)
    |> map(solve₂, _)
    |> sum
)

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
println("Part I: ", part1(filename))
println("Part II: ", part2(filename))