# Part-1

using Combinatorics

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

                for comb in combs

                    perms = collect(permutations(comb))

                    for perm in perms

                        all_perms_combs = vcat(start_path, perm..., end_path)
                        push!(all_paths, all_perms_combs)

                    end
                end
            end

        end
    end

    return unique(all_paths)
end

function get_valid_paths(input_file::String)

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
end

function get_final_paths(input_file::String)

    valid_paths = get_valid_paths(input_file)

    final_paths = Any[]

    for path in valid_paths

        small_caves = String[]

        for i in range(start = 1, step = 2, stop = length(path) - 3)

            common = intersect(path[i:i + 1], path[i + 2:i + 3])
            if islowercase(common[1][1])
                push!(small_caves, common[1])                
            end

        end

        if length(small_caves) == length(unique(small_caves))
            push!(final_paths, path)
        end
    end

    return @info "Number of valid paths that visit small caves at most once = $(length(final_paths))"
end