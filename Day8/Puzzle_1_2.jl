# Part-1

function get_all_values(input_file::String, value_type::String)

    lines = readlines(input_file)

    all_outputs = Vector{SubString{String}}[]

    for line in lines

        value_type == "output" ? output = split(line, " ")[12:end] : 
                                 output = split(line, " ")[1:10]

        push!(all_outputs, output)
    end

    if value_type == "output"
        all_outputs = vcat(all_outputs...)
    end

    return all_outputs

end

function get_unique_count(input_file)

    all_outputs = get_all_values(input_file, "output")

    # 1 -> cf (2 char), 4 -> bcdf (4 char)
    # 7 -> acf (3 char), 8 -> abcdefg (7 char)

    unique_dict = [2, 4, 3, 7]
    unique_counter = 0

    for output in all_outputs
        if length(output) in unique_dict
            unique_counter += 1
        end
    end

    return unique_counter

end

# Part-2

function get_digit_mapping(input_file::String)

    all_signals = get_all_values(input_file, "signal")

    # 1 -> cf (2 char), 4 -> bcdf (4 char)
    # 7 -> acf (3 char), 8 -> abcdefg (7 char)

    unique_dict = [2, 4, 3, 7]
    
end

unique_dict = Dict{Any,Any}("1" => 2, "4" => 4, "7" => 3, "8" => 7)

all_signals = get_all_values("Test_input_P1_p2.txt", "signal")

mapping_dict = Dict()

for signal in all_signals[1]

    for (key,value) in unique_dict
        if length(signal) == value
            mapping_dict[key] = signal
        end
    end
    
    # Pattern for 3
    if length(signal) == 5 && issubset(mapping_dict["1"], signal)
        mapping_dict["3"] = signal
    end
end

for signal in all_signals[1]
    
    # Pattern for 9
    if length(signal) == 6 && issubset(mapping_dict["3"], signal)
        mapping_dict["9"] = signal
    end

end

for signal in all_signals[1]

    # Pattern for 0
    if length(signal) == 6 && issubset(mapping_dict["7"], signal) && 
                              ~(signal in collect(values(mapping_dict)))

        mapping_dict["0"] = signal
    end

end

for signal in all_signals[1]

    # Pattern for 6
    if length(signal) == 6 && ~(signal in collect(values(mapping_dict)))

        mapping_dict["6"] = signal
    end

end

for signal in all_signals[1]

    # Pattern for 5
    if length(signal) == 5 && issubset(signal, mapping_dict["6"])

        mapping_dict["5"] =  signal
    end
end

for signal in all_signals[1]

    # Pattern for 2
    if length(signal) == 5 && ~(signal in collect(values(mapping_dict)))

        mapping_dict["2"] = signal
    end
end

