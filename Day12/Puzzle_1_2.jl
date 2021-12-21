function get_path_connections(input_file::String)

    lines = readlines(input_file)
    connections = Any[]

    for line in lines
        parts = split(line, "-")
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
            for rest_path in rest_paths

                if ~isempty(intersect(start_path, rest_path)) &&
                ~isempty(intersect(rest_path, end_path))

                push!(all_paths, vcat(start_path, rest_path, end_path))

                end

                if ~isempty(intersect(start_path, end_path))

                    push!(all_paths, vcat(start_path, end_path))

                end

            end
        end
    end

    return unique(all_paths)
end

#=all_rest_paths = Any[]

for i in eachindex(rest_paths)

    if ~isempty(intersect(rest_paths[i:i+1]...)) && i < length(rest_paths)

        push!(vcat(rest_paths[i:i+1]...))

    end=#