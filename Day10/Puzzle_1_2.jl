# Part-1

function get_incorrect_closing_char(input_file::String)

    lines = readlines(input_file)

    # c1 -> (, c2 -> [, c3 -> {, c4 -> <
    index_dict = Dict(")" => 1, "]" => 2, "}" => 3, ">" => 4)
    closing_chars = [')', ']', '}', '>']

    for (line_num, line) in enumerate(lines)
        
        all_chars = collect(line)
        incomplete = false

        for closing_char in closing_chars            
            if length(filter(x -> x == closing_char, all_chars)) == 0
                incomplete = true
                break
            end
        end

        if ~incomplete

            start_index = 2
            found_chunk = false

            while start_index ≤ length(line)

                for i = start_index:length(line)

                    num_c = Int.(zeros(4))

                    # Chunk always starts with an opening character
                    if line[start_index-1] in ['(', '[', '{', '<']

                        # Scan chunk
                        for j = start_index-1:i 
                            
                            if line[j]     == '('
                                num_c[1] += 1
                            elseif line[j] == '['
                                num_c[2] += 1
                            elseif line[j] == '{'
                                num_c[3] += 1
                            elseif line[j] == '<'
                                num_c[4] += 1
                            elseif line[j] == ')'
                                num_c[1] -= 1
                            elseif line[j] == ']'
                                num_c[2] -= 1
                            elseif line[j] == '}'
                                num_c[3] -= 1
                            elseif line[j] == '>'
                                num_c[4] -= 1
                            end

                        end

                        # Find incomplete chunk
                        if length(filter(x -> x == 0, num_c)) == 2 && -1 ∈ num_c && 
                            1 ∈ num_c && ~found_chunk

                            closing_index = findfirst(isequal(-1), num_c)

                            found = ""

                            for (key, value) in index_dict
                                if value == closing_index
                                    found = key
                                end
                            end

                            @info "Found first incorrect closing character $(found) in line $(line_num)"
                            found_chunk = true 
                            break               
                        end

                    end

                    if found_chunk
                        break
                    end 
                end

                if found_chunk
                    break
                end

                start_index += 1
            end
        end
    end
end