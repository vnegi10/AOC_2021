# Part-1

function get_all_output_values(input_file::String)

    lines = readlines(input_file)

    all_outputs = Vector{SubString{String}}[]

    for line in lines
        output = split(line, " ")[12:end]
        push!(all_outputs, output)
    end

    return vcat(all_outputs...)

end

function get_unique_count(input_file)

    all_outputs = get_all_output_values(input_file)

    # 1 -> cf (2 char), 4 -> bcdf (4 char)
    # 7 -> acf (3 char), 8 -> abcdefg (7 char)

    unique_lengths = [2, 4, 3, 7]
    unique_counter = 0

    for output in all_outputs
        if length(output) in unique_lengths
            unique_counter += 1
        end
    end

    return unique_counter

end


