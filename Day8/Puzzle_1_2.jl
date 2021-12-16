# Part-1

function get_all_values(input_file::String, value_type::String)

    lines = readlines(input_file)

    all_outputs = Vector{SubString{String}}[]

    for line in lines

        value_type == "output" ? output = split(line, " ")[12:end] : 
                                 output = split(line, " ")[1:10]

        push!(all_outputs, output)
    end 

    return all_outputs

end

function get_unique_count(input_file)

    all_outputs = get_all_values(input_file, "output")
    all_outputs = vcat(all_outputs...)    

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

function get_digit_mapping(signals::Vector{SubString{String}})

    unique_dict = Dict{Any,Any}("1" => 2, "4" => 4, "7" => 3, "8" => 7)

    mapping_dict = Dict()    

    for signal in signals
        for (key,value) in unique_dict

            if length(signal) == value
                mapping_dict[key] = signal
            end
        end
    end

    for signal in signals
        # Pattern for 3
        if length(signal) == 5 && issubset(mapping_dict["1"], signal)
            mapping_dict["3"] = signal
        end
    end

    for signal in signals        
        # Pattern for 9
        if length(signal) == 6 && issubset(mapping_dict["3"], signal)
            mapping_dict["9"] = signal
        end
    end

    for signal in signals
        # Pattern for 0
        if length(signal) == 6 && issubset(mapping_dict["7"], signal) && 
                                ~(signal in collect(values(mapping_dict)))

            mapping_dict["0"] = signal
        end
    end

    for signal in signals
        # Pattern for 6
        if length(signal) == 6 && ~(signal in collect(values(mapping_dict)))

            mapping_dict["6"] = signal
        end
    end

    for signal in signals
        # Pattern for 5
        if length(signal) == 5 && issubset(signal, mapping_dict["6"])

            mapping_dict["5"] =  signal
        end
    end

    for signal in signals
        # Pattern for 2, last remaining digit
        if length(signal) == 5 && ~(signal in collect(values(mapping_dict)))

            mapping_dict["2"] = signal
        end
    end    

    return mapping_dict
end

function get_output_sum(input_file::String)

    all_signals = get_all_values(input_file, "signals")
    all_outputs = get_all_values(input_file, "output")

    all_output_values = Int64[]

    for i = 1:length(all_signals)

        mapping_dict = get_digit_mapping(all_signals[i])

        outputs = all_outputs[i]

        output_string = ""

        for output in outputs
            for (key, value) in mapping_dict
                if length(output) == length(value) && issubset(output, value)
                    output_string = output_string * key
                end
            end
        end

        output_value = parse(Int64, output_string)

        push!(all_output_values, output_value)

    end

    return sum(all_output_values)
end