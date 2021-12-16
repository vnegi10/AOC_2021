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

    unique_dict = Dict{Any,Any}("1" => 2, "4" => 4, "7" => 3, "8" => 7)

    all_signals = get_all_values(input_file, "signal")

    mapping_dict = Vector{Dict{Any,Any}}[]

    for i = 1:length(all_signals)

        for signal in all_signals[i]

            for (key,value) in unique_dict

                if length(signal) == value
                    mapping_dict[i][key] = signal
                end
            end
    
            # Pattern for 3
            if length(signal) == 5 && issubset(mapping_dict[i]["1"], signal)
                mapping_dict[i]["3"] = signal
            end

        end

    

        for signal in all_signals[i]
            
            # Pattern for 9
            if length(signal) == 6 && issubset(mapping_dict[i]["3"], signal)
                mapping_dict[i]["9"] = signal
            end

        end

        for signal in all_signals[i]

            # Pattern for 0
            if length(signal) == 6 && issubset(mapping_dict[i]["7"], signal) && 
                                    ~(signal in collect(values(mapping_dict[i])))

                mapping_dict[i]["0"] = signal
            end

        end

        for signal in all_signals[i]

            # Pattern for 6
            if length(signal) == 6 && ~(signal in collect(values(mapping_dict[i])))

                mapping_dict[i]["6"] = signal
            end

        end

        for signal in all_signals[i]

            # Pattern for 5
            if length(signal) == 5 && issubset(signal, mapping_dict[i]["6"])

                mapping_dict[i]["5"] =  signal
            end
        end

        for signal in all_signals[i]

            # Pattern for 2
            if length(signal) == 5 && ~(signal in collect(values(mapping_dict[i])))

                mapping_dict[i]["2"] = signal
            end
        end
    end

    return mapping_dict
end
