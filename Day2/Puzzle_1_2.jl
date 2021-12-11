# Composite type to store position data
mutable struct position
    h::Number
    d::Number
end

function get_final_position(input_file::String)

    start = position(0,0)

    lines = readlines(input_file)

    for line in lines

        direction = split(line, " ")[1]
        move      = parse(Int64, split(line, " ")[2])

        if direction == "forward"
            start.h += move
        elseif direction == "down"
            start.d += move
        else
            start.d -= move
        end
    end

    return start.h * start.d
end

function get_new_final_position(input_file::String)

    start = position(0,0)
    aim = 0

    lines = readlines(input_file)

    for line in lines

        direction = split(line, " ")[1]
        move      = parse(Int64, split(line, " ")[2])

        if direction == "forward"
            start.h += move
            start.d = start.d + (aim * move)
        elseif direction == "down"
            aim += move
        else
            aim -= move
        end

    end

    return start.h * start.d
end

















