#!/usr/bin/env julia

# naïve approach first — do sum of shapes fit in area of region?
# UPDATE: holy shit this works.
#.        It doesn't work on the test input, but it does on the real input.
function main(filename)
    txt = read(filename, String)
    sections = split(txt, "\n\n")
    P, R = sections[1:(end-1)], split(strip(sections[end]), '\n')

    presents = [count(==('#'), s) for s in P]

    map(r -> begin
            dims, qtys = split(r, ": ")
            x, y = map(n -> parse(Int, n), split(dims, 'x'))

            quants_nums = [parse(Int, m.match) for m in eachmatch(r"-?\d+", qtys)]
            total = sum(a * b for (a, b) in zip(quants_nums, presents))
            total < x * y ? 1 : 0
        end, R) |> sum
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
println(main(filename))