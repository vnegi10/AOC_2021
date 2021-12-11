function get_drawn_numbers(input_file::String)

    lines = readlines(input_file)

    # Assuming first line always has the list of drawn numbers
    numbers_list = split(lines[1], ",")
    drawn_numbers = map(x -> parse(Int64, x), numbers_list)

    return drawn_numbers
end

function get_row(lines::Vector{String}, start_line::Int64)

    line = split(lines[start_line], " ")

    # Correct for double spacing due to single digit numbers
    line_correct = line[map(x -> ~isempty(x), line)]

    row = map(x -> parse(Int64, x), line_correct)

    return row
end

function get_boards(input_file::String)

    lines = readlines(input_file)

    # Assuming boards start at line 3
    start_line = 3
    first_row = get_row(lines, start_line)    

    dim = length(first_row)

    # Determine how many boards are present
    board_index = range(start = start_line, step = dim + 1, stop = length(lines))
    num_boards = length(board_index)

    # Initialize with zeros
    all_boards = Any[]
    for i = 1:num_boards
        push!(all_boards, zeros(Int64, dim, dim))
    end

    # Store results when drawn numbers match
    result_boards = deepcopy(all_boards)

    board_counter = 1

    for i in board_index
        row_counter = 1
        for j = i:i+dim-1
            row = get_row(lines, j)
            all_boards[board_counter][row_counter,:] = row
            row_counter += 1
        end
        board_counter += 1
    end

    return all_boards, result_boards, dim
end

function find_winning_board(input_file::String)

    drawn_numbers = get_drawn_numbers(input_file)

    results = get_boards(input_file)

    all_boards    = results[1]
    result_boards = results[2]
    dim = results[3]

    win = false
    num_draws = 0
    stop_playing = false

    for number in drawn_numbers
        board_counter = 1
        for board in all_boards
            rows, cols = size(board)
            for i = 1:rows
                for j = 1:cols
                    if board[i,j] == number
                        result_boards[board_counter][i,j] = 1
                    end
                end
            end
            board_counter += 1
        end

        num_draws += 1

        if num_draws ≥ dim

            global current_draw = drawn_numbers[num_draws]

            global rboard_counter = 1

            for board in result_boards

                rows, cols = size(board)
                # Check if we have a square matrix
                @assert rows == cols

                for i = 1:rows
                    # Check all rows
                    if sum(board[i,:]) == rows
                        win = true
                    end

                    # Check all columns
                    if sum(board[:,i]) == rows
                        win = true
                    end
                end

                if win
                    @info "Board # $(rboard_counter) has won!"
                    stop_playing = true
                    break
                end

                rboard_counter += 1
            end
        end

        if stop_playing
            break
        end

    end

    return result_boards[rboard_counter], all_boards[rboard_counter], current_draw

end

function get_winning_score(input_file::String, win_type::String)

    if win_type == "first"
        results = find_winning_board(input_file)
    else
        results = find_last_winning_board(input_file)
    end

    winning_rboard  = results[1]
    winning_board   = results[2]
    winning_draw    = results[3]

    unmarked = Int64[]
    rows, cols = size(winning_rboard)    
    for i = 1:rows
        for j = 1:cols
            if winning_rboard[i,j] == 0
                push!(unmarked, winning_board[i,j])
            end
        end
    end

    return sum(unmarked) * winning_draw
end

function find_last_winning_board(input_file::String)

    drawn_numbers = get_drawn_numbers(input_file)

    results = get_boards(input_file)

    all_boards    = results[1]
    result_boards = results[2]
    dim           = results[3]

    win = false
    stop_playing = false
    num_draws = 0
    win_counter = Int64[]

    for number in drawn_numbers
        board_counter = 1
        for board in all_boards
            rows, cols = size(board)
            for i = 1:rows
                for j = 1:cols
                    if board[i,j] == number
                        result_boards[board_counter][i,j] = 1
                    end
                end
            end
            board_counter += 1
        end

        num_draws += 1

        if num_draws ≥ dim

            global current_draw = drawn_numbers[num_draws]

            global rboard_counter = 1

            for board in result_boards

                rows, cols = size(board)
                # Check if we have a square matrix
                @assert rows == cols

                for i = 1:rows
                    # Check all rows
                    if sum(board[i,:]) == rows
                        win = true
                    end

                    # Check all columns
                    if sum(board[:,i]) == rows
                        win = true
                    end
                end

                if win
                    @info "Board # $(rboard_counter) has won!"
                    win = false
                    push!(win_counter, rboard_counter)
                end

                if length(unique!(win_counter)) == length(all_boards)
                    stop_playing = true
                    break
                end                    

                rboard_counter += 1
            end
        end 
        
        if stop_playing
            break
        end

    end

    return result_boards[win_counter[end]], all_boards[win_counter[end]], 
           current_draw, win_counter
end











