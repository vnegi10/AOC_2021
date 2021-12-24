# Part-1

using Combinatorics, StatsBase

function get_path_connections(input_file::String)

    lines = readlines(input_file)
    connections = Any[]

    for line in lines
        parts = split(line, "-")

        if isuppercase(parts[1][1])
            parts[1], parts[2] = parts[2], parts[1]
        end

        if parts[2] == "start" || parts[1] == "end"
            parts[1], parts[2] = parts[2], parts[1]
        end

        push!(connections, [parts[1], parts[2]])
    end

    return connections
end

function get_all_paths(input_file::String)

    connections = get_path_connections(input_file)

    start_paths = filter(x -> "start" in x, connections)
    end_paths = filter(x -> "end" in x, connections)

    rest_paths = Any[]

    for path in connections
        if ~("start" in path) && ~("end" in path)
            push!(rest_paths, path)
        end
    end

    all_paths = Any[]

    for start_path in start_paths
        for end_path in end_paths

            for i in eachindex(rest_paths)

                combs = collect(combinations(rest_paths, i))

                @inbounds for j in eachindex(combs)

                    # Find how many small caves will be visited for this combination
                    path = vcat(combs[j]...)
                    small_cave_check = true

                    map_dict = countmap(path)

                    for (key, value) in map_dict
                        if islowercase(key[1]) && value > 2
                            small_cave_check = false
                        end
                    end

                    # Permutations only for valid paths (small caves visited only once)
                    if small_cave_check
                        
                        # Optimize memory usage by permuting only a selected range every loop
                        if length(combs[j]) > 10
                            num_perms = factorial(length(combs[j]))
                            
                            @info "Optimizing for num_perms = $(num_perms)"
                            perm_range = range(start = 1, stop = num_perms, length = 25)                            

                            i = 1
                            while i < length(perm_range)
                                start_i = round(Int, perm_range[i])
                                end_i   = round(Int, perm_range[i+1])
                                perms = collect(permutations(combs[j]))[start_i:end_i]

                                # Check overlap for every permutation
                                @inbounds for k in eachindex(perms)
                                    
                                    path = vcat(start_path, perms[k]..., end_path)
                                    overlap = true

                                    for i in range(start = 1, step = 2, stop = length(path) - 3)

                                        if isempty(intersect(path[i:i + 1], path[i + 2:i + 3]))
                                            overlap = false
                                            break
                                        end

                                    end

                                    if overlap
                                        push!(all_paths, path)
                                    end        
                                end
                                i += 1
                            end
                        else
                            perms = collect(permutations(combs[j]))

                            # Check overlap for every permutation
                            @inbounds for k in eachindex(perms)

                                path = vcat(start_path, perms[k]..., end_path)
                                overlap = true

                                for i in range(start = 1, step = 2, stop = length(path) - 3)

                                    if isempty(intersect(path[i:i + 1], path[i + 2:i + 3]))
                                        overlap = false
                                        break
                                    end

                                end

                                if overlap
                                    push!(all_paths, path)
                                end    
                            end   
                        end                                     

                    end
                    
                end
            end

            # There can also be direct paths from start to end
            if ~isempty(intersect(start_path, end_path))

                push!(all_paths, vcat(start_path, end_path))

            end

        end
    end

    return unique(all_paths)
end

#=function get_valid_paths(input_file::String)

    all_paths = get_all_paths(input_file)

    connected_paths = Any[]

    # Filter for connected paths based on overlap
    for path in all_paths

        overlap = true

        for i in range(start = 1, step = 2, stop = length(path) - 3)

            if isempty(intersect(path[i:i + 1], path[i + 2:i + 3]))
                overlap = false
                break
            end

        end

        if overlap
            push!(connected_paths, path)
        end
    end

    # Rearrange for common caves and remove consecutive duplicates
    #=for path in connected_paths

        for i in range(start = 2, step = 2, stop = length(path) - 2)

            if path[i] != path[i + 1] && path[i] == path[i + 2]
                
                path[i + 1], path[i + 2] = path[i + 2], path[i + 1]

            end
        end
        
    end=#

    return unique(connected_paths)
end=#

function get_final_paths(input_file::String)

    valid_paths = get_all_paths(input_file)

    final_paths = Any[]

    for path in valid_paths

        small_cave_check = true

        map_dict = countmap(path)

        for (key, value) in map_dict
            if islowercase(key[1]) && value > 2
                small_cave_check = false
            end
        end

        if small_cave_check
            push!(final_paths, path)
        end
        
    end   

    @info "Number of valid paths that visit small caves at most once = $(length(final_paths))"

    return final_paths
end