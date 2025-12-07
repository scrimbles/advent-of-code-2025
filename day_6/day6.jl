#!/usr/bin/env julia

using Pipe: @pipe

ϕ(str) = str == "+" ? Base.:+ : Base.:*
solve(prob) = reduce(ϕ(prob[end]), map(n -> parse(Int, n), prob[1:end-1]))

function chunk(vec)
    chunked = []
    current = []
    for value in vec
        if ismissing(value)
            push!(chunked, current)
            current = []
        else
            append!(current, value)
        end
    end

    push!(chunked, current)
    chunked
end

part1(filename) = @pipe(
    readlines(filename)
    |> map(split, _)
    |> zip(_...)
    |> map(solve, _)
    |> sum
)

function part2(filename)
    lines = readlines(filename)
    nums = @pipe(
        lines[1:end-1]
        |> map(collect, _)
        |> zip(_...)
        |> map(s -> string(s...), _)
        |> map(s -> all(isspace, s) ? missing : parse(Int, s), _)
        |> chunk
    )

    ops = lines[end] |> split |> s -> map(ϕ, s)

    problems = [[nums[i]..., ops[i]] for i in eachindex(ops)]

    map(p -> reduce(p[end], p[1:end-1]), problems) |> sum
end



filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
println("Part I: ", part1(filename))
println("Part II: ", part2(filename))