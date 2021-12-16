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

    return sum(risks)
end