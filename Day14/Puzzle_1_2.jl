# Part-1

using StatsBase

function get_template(input_file::String)

    lines = readlines(input_file)
    template = collect(lines[1])

    return template
end

function get_insertion_rules(input_file::String)

    lines = readlines(input_file)
    pairs = SubString{String}[]
    inserts = Char[]

    for line in lines[3:end]
        parts = split(line, " ")

        push!(pairs, parts[1])
        push!(inserts, only(parts[3]))

    end

    rules_dict = Dict(pairs .=> inserts)

    return rules_dict
end

function grow_polymer(input_file::String, steps::Int64)

    template = get_template(input_file)
    rules_dict = get_insertion_rules(input_file)

    for step = 1:steps

        i = 1
        pol_inserts = Char[]

        while i < length(template)
            pol_pair = template[i] * template[i+1]
            push!(pol_inserts, rules_dict[pol_pair])
            i += 1
        end

        for j in eachindex(pol_inserts)
            insert!(template, 2*j, pol_inserts[j])
        end

    end

    return template
end

function get_final_result(input_file::String, steps::Int64)

    template = grow_polymer(input_file, steps)

    count_dict = countmap(template)
    all_counts = collect(values(count_dict))

    max_count, min_count = maximum(all_counts), minimum(all_counts)

    return max_count - min_count
end















