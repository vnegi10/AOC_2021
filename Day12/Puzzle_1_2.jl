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

function get_all_paths(input_file::String, num_caves::Int64)

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
                        if islowercase(key[1]) && value > num_caves
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

function do_cave_check(paths, num_caves::Int64)

    valid_paths = Any[]

    for path in paths

        small_cave_check = true

        map_dict = countmap(path)

        for (key, value) in map_dict
            if islowercase(key[1]) && value > num_caves
                small_cave_check = false
            end
        end

        if small_cave_check
            push!(valid_paths, path)
        end
        
    end       

    return valid_paths
end

function get_final_paths(input_file::String)

    valid_paths = do_cave_check(get_all_paths(input_file, 2), 2)

    # Generate unique path based on overlapping caves
    unique_paths = Any[]

    for path in valid_paths

        unique_all = Any[]

        for i in range(start = 1, step = 2, stop = length(path) - 3)

            common = intersect(path[i:i + 1], path[i + 2:i + 3])

            if isempty(unique_all) || common[1] != unique_all[end]
                push!(unique_all, common)
            end

            f = filter(x -> x != common[1], path[i + 2:i + 3]) 
            if f[1] != unique_all[end]
                push!(unique_all, f)   
            end   

        end

        push!(unique_paths, vcat("start", unique_all...))

    end

    # Remove duplicate caves appearing in succession
    single_paths = Any[]
    
    for path in unique_paths

        single_path = Any[]
        i = 1
        push!(single_path, path[i])

        while i < length(path)
            if path[i+1] != single_path[end]
                push!(single_path, path[i+1])
            end
            i += 1
        end

        push!(single_paths, vcat(single_path...))

    end
    
    unique!(single_paths)

    # Remove paths where number of small caves > 1
    final_paths = do_cave_check(single_paths, 1)

    return @info "Number of valid paths that visit small caves at most once = $(length(final_paths))"

    #return final_paths
end

# Part-2

function do_cave_check_2(paths, num_caves::Int64)

    valid_paths = Any[] 

    # Case when every small cave is visited at most once    
    for path in paths

        small_cave_check = true

        map_dict = countmap(path)

        for (key, value) in map_dict
            if islowercase(key[1]) && value > 2
                small_cave_check = false
            end
        end

        if small_cave_check
            push!(valid_paths, path)
        end
        
    end
    
    # Case when it's allowed to visit a single small cave twice
    for path in paths
        
        small_cave_check = true
        found_twice_cave = false

        map_dict = countmap(path)

        for (key, value) in map_dict
            if ~found_twice_cave && islowercase(key[1]) && value > num_caves

                found_twice_cave = true
                delete!(map_dict, key)
            end
        end

        for (key, value) in map_dict
            if found_twice_cave && islowercase(key[1]) && value > 2
                small_cave_check = false
            end 
        end

        if small_cave_check && found_twice_cave
            push!(valid_paths, path)
        end
        
    end       

    return valid_paths
end

function get_final_paths_2(input_file::String)

    #valid_paths = do_cave_check_2(get_all_paths(input_file, 4), 2)
    all_paths = get_all_paths(input_file, 4)

    # Generate unique path based on overlapping caves
    unique_paths = Any[]

    for path in all_paths

        unique_all = Any[]

        for i in range(start = 1, step = 2, stop = length(path) - 3)

            common = intersect(path[i:i + 1], path[i + 2:i + 3])

            if isempty(unique_all) || common[1] != unique_all[end]
                push!(unique_all, common)
            end

            f = filter(x -> x != common[1], path[i + 2:i + 3]) 
            if f[1] != unique_all[end]
                push!(unique_all, f)   
            end   

        end

        push!(unique_paths, vcat("start", unique_all...))

    end

    # Remove duplicate caves appearing in succession
    single_paths = Any[]
    
    for path in unique_paths

        single_path = Any[]
        i = 1
        push!(single_path, path[i])

        while i < length(path)
            if path[i+1] != single_path[end]
                push!(single_path, path[i+1])
            end
            i += 1
        end

        push!(single_paths, vcat(single_path...))

    end
    
    unique!(single_paths)

    # Remove paths where number of small caves > 1
    final_paths = do_cave_check_2(single_paths, 2, 2)

    @info "Number of valid paths that visit small caves at most once = $(length(final_paths))"

    return final_paths
end