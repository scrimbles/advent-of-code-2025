#!/usr/bin/env julia

using Pipe: @pipe

function main(filename)
    𝕸 = readlines(filename)
    splits = 0

    l₀ = 𝕸[1] |> collect
    t₀ = [c == 'S' ? 1 : 0 for c in l₀]
    println(String(l₀))

    for line ∈ 𝕸[2:end]
        t₁ = [0 for _ in 1:length(𝕸[1])]
        l₁ = collect(line)
        for i ∈ eachindex(l₁)
            if l₁[i] == '^'
                splits += 1
                t₁[i-1] += t₀[i]
                t₁[i+1] += t₀[i]
                l₁[i-1] = '|'
                l₁[i+1] = '|'
            else
                t₁[i] += t₀[i]
            end
            if (l₀[i] == '|' || l₀[i] == 'S') && l₁[i] == '.'
                l₁[i] = '|'
            end

        end

        println(String(l₁))
        l₀ = l₁
        t₀ = t₁
    end

    println("Timelines: ", sum(t₀))
    println("Splits: ", splits)
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
main(filename)