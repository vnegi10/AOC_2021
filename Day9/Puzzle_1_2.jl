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

h = get_height_matrix("Test_input_P1_P2.txt")








