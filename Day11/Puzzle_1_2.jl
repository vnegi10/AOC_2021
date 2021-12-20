# Part-1

function get_energy_matrix(input_file::String)

    lines = readlines(input_file)

    nrows = length(lines)
    ncols = length(lines[1])

    energy_matrix = zeros(Int64, nrows, ncols)
    
    for (i, line) in enumerate(lines)
        row = map(x -> parse(Int64,x), collect(line))
        energy_matrix[i, :] = row
    end

    return energy_matrix
end

function get_adjacent_locations(r::Int64, c::Int64, nrows::Int64, ncols::Int64)

    # Diagonal positions are also included here
    loc = Any[]

    # Top left corner
    if r == 1 && c == 1
        loc = [(r, c + 1), (r + 1, c), (r + 1, c + 1)]
    end

    # Top row
    if r == 1 && ncols > c > 1
        loc = [(r, c - 1), (r + 1, c), (r, c + 1), (r + 1, c - 1), (r + 1, c + 1)]
    end

    # Top right corner
    if r == 1 && c == ncols
        loc = [(r, c - 1), (r + 1, c), (r + 1, c - 1)]
    end

    # Left side
    if nrows > r > 1 && c == 1 
        loc = [(r - 1, c), (r, c + 1), (r + 1, c), (r - 1, c + 1), (r + 1, c + 1)]
    end

    # Middle
    if r ∈ collect(2:nrows-1) && c ∈ collect(2:ncols-1)
        loc = [(r, c - 1), (r - 1, c), (r, c + 1), (r + 1, c), (r - 1, c - 1), (r - 1, c + 1), 
               (r + 1, c + 1), (r + 1, c - 1)]
    end

    # Right side
    if nrows > r > 1 && c == ncols
        loc = [(r - 1, c), (r, c - 1), (r + 1, c), (r - 1, c - 1), (r + 1, c - 1)]
    end

    # Bottom left corner
    if r == nrows && c == 1
        loc = [(r - 1, c), (r, c + 1), (r - 1, c + 1)]
    end

    # Bottom row
    if r == nrows && ncols > c > 1
        loc = [(r, c - 1), (r - 1, c), (r, c + 1), (r - 1, c - 1), (r - 1, c + 1)]
    end

    # Bottom right
    if r == nrows && c == ncols
        loc = [(r - 1, c), (r, c - 1), (r - 1, c - 1)]
    end

    return loc
end

function get_total_flashes(input_file::String, steps::Int64)

    e = get_energy_matrix(input_file)

    nrows, ncols = size(e)
    all_flashes = Int64[]

    for step = 1:steps

        e = e .+ 1
        flash_search = true
        
        while flash_search

            flash_locs = findall(x -> x > 9, e)

            if ~isempty(flash_locs)

                for loc in flash_locs
                    r, c = loc[1], loc[2]
                    e[r, c] = 0

                    adj_loc = get_adjacent_locations(r, c, nrows, ncols)

                    for pos in adj_loc                         
                        i, j = pos[1], pos[2]

                        # Flashed positions should remain at 0, so update only non-0 positions
                        if e[i, j] != 0
                            e[i, j] += 1
                        end                       
                    end
                end

            else
                @info "No flashes found, moving on to next step!"
                break
            end

        end

        # Number of flashes = Number of O's
        num_flashes = length(findall(x -> x == 0, e))
        push!(all_flashes, num_flashes)
    end

    return sum(all_flashes)
end