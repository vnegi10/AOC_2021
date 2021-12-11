# Test data, answer is 7
A = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

function get_depth_increase(input_file::String)

    lines = readlines(input_file)

    input = map(x -> parse(Int64, x), lines)

    counter = 0
    for i = 2:length(input)    
        if input[i] > input[i-1]
            counter += 1
        end
    end

    return counter
end

