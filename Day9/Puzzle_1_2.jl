# Part-1

function get_height_matrix(input_file::String)

    lines = readlines(input_file)

    nrows = length(lines)
    ncols = length(lines[1])

    height_matrix = zeros(Int64, nrows, ncols)
    
    for (i, line) in enumerate(lines)
        row = map(x -> parse(Int64,x), collect(line))
        height_matrix[i, :] = row
    end

    return height_matrix
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

function get_sum_of_risks(input_file::String)

    h = get_height_matrix(input_file)

    nrows, ncols = size(h)
    found_mins = Any[]

    for r = 1:nrows
        for c = 1:ncols
            loc = get_adjacent_locations(r, c, nrows, ncols)
            mins = 0

            for pos in loc
                i, j = pos[1], pos[2]
                if h[r, c] < h[i, j]
                    mins += 1
                end
            end

            # Low points should be lower than all adjacent points
            if mins == length(loc)
                push!(found_mins, [r, c])
            end
        end
    end

    risks = Int64[]

    # Find elements at the low (minima) locations
    for loc in found_mins
        risk = h[loc[1], loc[2]] + 1
        push!(risks, risk)
    end

    return sum(risks), found_mins
end

# Part-2

function get_basin_size(points, h::Matrix{Int64}, basin_size::Int64, covered_locations)

    nrows, ncols = size(h)
    basin_size_i = basin_size

    valid_locations = Any[]
    
    for start_point in points        

        locations = get_adjacent_locations(start_point[1], start_point[2], nrows, ncols)

        for loc in locations

            if h[loc[1], loc[2]] != 9 && h[loc[1], loc[2]] > h[start_point[1], start_point[2]] 
                                         
                if ~(loc in covered_locations)
                    basin_size += 1
                    push!(valid_locations, loc)
                end
                
                # Update counter for all covered locations                
                push!(covered_locations, loc)

            end            
        end
    end

    if basin_size == basin_size_i
        return basin_size
    else
        return get_basin_size(valid_locations, h, basin_size, covered_locations)
    end
end

function get_largest_basins(input_file::String)

    h = get_height_matrix(input_file)
    found_mins = get_sum_of_risks(input_file)[2]

    basin_sizes = Int64[]

    for low_point in found_mins

        basin_size = get_basin_size([(low_point[1], low_point[2])], h, 1, 
                                    [(low_point[1], low_point[2])])
        push!(basin_sizes, basin_size)

    end

    sort!(basin_sizes, rev = true)

    final_size = 1

    for i = 1:3
        final_size *= basin_sizes[i]
    end
    
    return final_size
end