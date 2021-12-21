function get_path_connections(input_file::String)

    lines = readlines(input_file)
    connections = Any[]

    for line in lines
        parts = split(line, "-")
        push!(connections, (parts[1], parts[2]))
    end

    return connections
end

connections = get_path_connections("Test_input_P1_P2.txt")

start_paths = filter(x -> "start" in x, connections)
end_paths = filter(x -> "end" in x, connections)


