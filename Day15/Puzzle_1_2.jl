# Part-1

using DelimitedFiles

function get_risk_matrix(input_file::String)

    lines = readlines(input_file)

    nrows = length(lines)
    ncols = length(lines[1])

    risk_matrix = zeros(Int64, nrows, ncols)
    
    for (i, line) in enumerate(lines)
        row = map(x -> parse(Int64,x), collect(line))
        risk_matrix[i, :] = row
    end

    return risk_matrix
end

function get_adjacent_locations(r::Int64, c::Int64, nrows::Int64, ncols::Int64)

    loc = Any[]

    # Top left corner
    if r == 1 && c == 1
        loc = [(r, c + 1), (r + 1, c)]
    end

    # Top row
    if r == 1 && ncols > c > 1
        loc = [(r, c - 1), (r + 1, c), (r, c + 1)]
    end

    # Top right corner
    if r == 1 && c == ncols
        loc = [(r, c - 1), (r + 1, c)]
    end

    # Left side
    if nrows > r > 1 && c == 1 
        loc = [(r - 1, c), (r, c + 1), (r + 1, c)]
    end

    # Middle
    if r ∈ collect(2:nrows-1) && c ∈ collect(2:ncols-1)
        loc = [(r, c - 1), (r - 1, c), (r, c + 1), (r + 1, c)]
    end

    # Right side
    if nrows > r > 1 && c == ncols
        loc = [(r - 1, c), (r, c - 1), (r + 1, c)]
    end

    # Bottom left corner
    if r == nrows && c == 1
        loc = [(r - 1, c), (r, c + 1)]
    end

    # Bottom row
    if r == nrows && ncols > c > 1
        loc = [(r, c - 1), (r - 1, c), (r, c + 1)]
    end

    # Bottom right
    if r == nrows && c == ncols
        loc = [(r - 1, c), (r, c - 1)]
    end

    return loc
end

function get_all_risks(r::Matrix{Int64}, output_file::String, source, 
                       target, visited_locations, path_locations)

    nrows, ncols = size(r)

    # Terminate search when target is reached and print path
    if source == target

        path = Int64[]

        for pos in path_locations[2:end]
            push!(path, r[pos[1], pos[2]])
        end

        open(output_file, "a") do file
            writedlm(file, sum(path))
        end

        #println(sum(path))
        return 
    end
    
    # Depth-first search with set of visited locations
    # Adapted from: https://coderedirect.com/questions/713581/finding-all-paths-between-2-points-on-a-square-matrix 

    locations = get_adjacent_locations(source[1], source[2], nrows, ncols)
        
    for loc in locations
        if loc in visited_locations
            continue
        end

        push!(path_locations, loc)
        push!(visited_locations, loc)

        get_all_risks(r, output_file, loc, target, visited_locations, path_locations)

        filter!(x -> x != loc, visited_locations)
        popat!(path_locations, length(path_locations))
    end
end

function get_lowest_risk(input_file::String, output_file::String)

    # Start at top left
    source = (1, 1)

    # Stop at bottom right
    r = get_risk_matrix(input_file)
    nrows, ncols = size(r)
    target = (nrows, ncols)

    # Start defaults
    visited_locations = [(1,1)]
    path_locations    = [(1,1)]

    get_all_risks(r, output_file, source, target, visited_locations, path_locations)

    lines = readlines(output_file)
    lines = map(x -> parse(Int64, x), lines)

    # Delete file
    rm(output_file)

    return @info "Lowest total risk is $(minimum(lines))"
end