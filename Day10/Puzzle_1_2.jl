# Part-1

function get_incorrect_closing_char(input_file::String)

    lines = readlines(input_file)
    
    # c1 -> (, c2 -> [, c3 -> {, c4 -> <
    index_dict = Dict(")" => 1, "]" => 2, "}" => 3, ">" => 4)
    matching_dict = Dict(")" => "(", "]" => "[", "}" => "{", ">" => "<")

    closing_chars = [')', ']', '}', '>']
    opening_chars = ['(', '[', '{', '<']
    incorrect_chars = Any[]

    for (line_num, line) in enumerate(lines)
            
        start_index = 2
        found_chunk = false

        while start_index < length(line)

            for i = start_index:length(line)

                num_c = Int.(zeros(4))

                # Chunk always starts with an opening character
                if line[start_index-1] in opening_chars

                    chunk = ""

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

                        chunk *= line[j]
                    end

                    # Move start index ahead when a valid chunk is found
                    if length(filter(x -> x == 0, num_c)) == 4 &&
                        chunk[end] in closing_chars &&
                        string(chunk[1]) == matching_dict[string(chunk[end])]

                        start_index += length(chunk)
                        # @info "Found valid chunk $(chunk) in line $(line_num)"
                        
                    end

                    # Find incomplete chunk
                    if length(filter(x -> x == 0, num_c)) == 2 && -1 ??? num_c && 
                        1 ??? num_c && ~found_chunk && chunk[end] in closing_chars

                        closing_index = findfirst(isequal(-1), num_c)

                        found = ""

                        for (key, value) in index_dict
                            if value == closing_index
                                found = key
                            end
                        end

                        # Line is corrupted only when incorrect closing character appears at the end
                        # of the chunk and does not match with the start of the chunk
                        if found == string(chunk[end]) && 
                           string(chunk[1]) != matching_dict[string(chunk[end])]

                            @info "Found first incorrect closing character $(found) in line $(line_num) within $(chunk)"
                            found_chunk = true
                            push!(incorrect_chars, found) 
                            break
                        end               
                    end

                end

                #=if found_chunk
                    break
                end=# 
            end

            if found_chunk
                break
            end

            start_index += 1
        end
        
    end

    return incorrect_chars
end

function get_error_score(input_file::String)

    incorrect_chars = get_incorrect_closing_char(input_file)

    score_dict = Dict(")" => 3, "]" => 57, "}" => 1197, ">" => 25137)

    score = 0

    for incorrect_char in incorrect_chars
        score += score_dict[incorrect_char]
    end

    return score
end    