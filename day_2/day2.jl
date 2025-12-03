#!/usr/bin/env julia

using Pipe: @pipe

function invalid₂(id::String)::Integer
    l = length(id)
    for d in 1:l-1
        if l % d != 0
            continue
        end

        if allequal([id[((i-1)*d+1):(i*d)] for i in 1:Int(l / d)])
            return parse(Int, id)
        end
    end

    0
end

function invalid(id::String)::Integer
    l = length(id)
    if l % 2 != 0
        return 0
    end
    h = Int(l / 2)
    # if subsequences are equal, id is invalid
    id[1:h] == id[h+1:end] ? parse(Int, id) : 0
end

p(s) = parse(Int, s)
proc(r) = @pipe(
    r
    |> split(_, '-')
    |> map(p, _)
    |> range(_...)
    |> map(invalid₂ ∘ string, _)
    |> reduce(+, _; init=0)
)

@pipe(
    (length(ARGS) >= 1 ? ARGS[1] : "input.txt")
    |> readline
    |> split(_, ',')
    |> map(proc, _)
    |> sum
    |> println
)