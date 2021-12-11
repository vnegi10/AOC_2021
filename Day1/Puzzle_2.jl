# Test input, answer is 5
A = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

function get_window_increase(input_file::String, window::Int64)

    lines = readlines(input_file)

    input = map(x -> parse(Int64, x), lines)

    counter = 0
    end_index = length(input) - (window - 1)

    for i = 2:end_index

        i_start = i
        i_end   = i + (window - 1)

        if sum(input[i_start:i_end]) > sum(input[i_start-1:i_end-1])
            counter += 1
        end
    end

    return counter
end


