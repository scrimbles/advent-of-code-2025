#!/usr/bin/env julia

function invalid(id::String)::Integer
    l = length(id)
    if l % 2 != 0 # invalid ids are a repetition of two subsequences, so MUST have an even number of digits
        return 0
    end
    h = Int(l / 2)
    # if subsequences are equal, id is invalid
    id[1:h] == id[h+1:end] ? parse(Int, id) : 0
end

rs = split(readline(ARGS[1]), ',')
Σ = 0
for r in rs
    s, e = map(i -> parse(Int, i), split(r, '-'))
    ι = map(n -> string(n) |> invalid, s:e)
    Σᵣ = reduce(+, ι; init=0)
    global Σ += Σᵣ
    # println("")
    # println(r)
    # println("ι: ", ι)
    # println("Σᵣ: ", Σᵣ)
    # println("Σ: ", Σ)
end

println("Σ: ", Σ)