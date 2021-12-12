# Part-1

# Parse horizontal/vertical (hv) lines from input text file
function get_hv_lines(input_file::String)

    lines = readlines(input_file)

    hv_lines = Any[]

    for line in lines
        middle_split = split(line, "->")
        x1, y1 = split(middle_split[1], ",")[1], split(middle_split[1], ",")[2]
        x2, y2 = split(middle_split[2], ",")[1], split(middle_split[2], ",")[2]

        x1, y1 = parse(Int64, x1), parse(Int64, y1)
        x2, y2 = parse(Int64, x2), parse(Int64, y2)

        if x1 == x2 || y1 == y2
            push!(hv_lines, [(x1, y1), (x2, y2)])
        end
    end

    return hv_lines
end

# Get all points for horizontal/vertical (hv) lines
function get_hv_points(input_file::String)

    hv_lines  = get_hv_lines(input_file)
    hv_points = Any[]

    line_counter = 1
    x_range, y_range = [StepRange{Int64, Int64}[] for i = 1:2]

    for hv_line in hv_lines
        x1, y1 = hv_line[1][1], hv_line[1][2]
        x2, y2 = hv_line[2][1], hv_line[2][2]

        if y1 == y2 

            if x2 > x1
                x_range = range(start = x1, step = 1, stop = x2)
            else
                x_range = range(start = x1, step = -1, stop = x2)
            end

            for x in x_range
                push!(hv_points, [x, y1, line_counter])
            end        

        elseif x1 == x2 

            if y2 > y1
                y_range = range(start = y1, step = 1, stop = y2)
            else
                y_range = range(start = y1, step = -1, stop = y2)
            end

            for y in y_range
                push!(hv_points, [x1, y, line_counter])
            end        
        end

        line_counter += 1
    end

    return sort!(hv_points)
end

# Calculate overlap for both part-1 and part-2
function get_overlap(input_file::String, line_type::String)

    points = Any[]
    if line_type == "hv"
        points = get_hv_points(input_file)
    elseif line_type == "hvd"
        points = get_all_points(input_file)
    end
    
    overlap = 0
    i = 1
    
    while i < length(points)

        overlap_found = false

        x, y, l    = points[i][1], points[i][2], points[i][3]
        
        for j = i+1:length(points)
            xn, yn, ln = points[j][1], points[j][2], points[j][3]

            # Overlap region starts + record overlap
            if xn == x && yn == y && ln != l && ~overlap_found                
                overlap_found = true
                overlap += 1
            end

            # Overlap region stops
            if (xn != x || yn != y) && overlap_found
                i = j
                break
            end

            # Break out when overlap region is not found
            if ~overlap_found
                i = j
                break
            end
        end        
    end

    return overlap
end

# Part-2

# Parse all lines from input text file
function get_all_lines(input_file::String)

    lines = readlines(input_file)

    all_lines = Any[]

    for line in lines
        middle_split = split(line, "->")
        x1, y1 = split(middle_split[1], ",")[1], split(middle_split[1], ",")[2]
        x2, y2 = split(middle_split[2], ",")[1], split(middle_split[2], ",")[2]

        x1, y1 = parse(Int64, x1), parse(Int64, y1)
        x2, y2 = parse(Int64, x2), parse(Int64, y2)

        push!(all_lines, [(x1, y1), (x2, y2)])        
    end

    return all_lines
end

# Get all points for all lines
function get_all_points(input_file::String)

    all_lines  = get_all_lines(input_file)
    all_points = Any[]

    line_counter = 1
    x_range, y_range = [StepRange{Int64, Int64}[] for i = 1:2]

    # Account for hvd (horizontal, vertical and diagonal lines)
    for hvd_line in all_lines
        x1, y1 = hvd_line[1][1], hvd_line[1][2]
        x2, y2 = hvd_line[2][1], hvd_line[2][2]

        if y1 == y2 

            if x2 > x1
                x_range = range(start = x1, step = 1, stop = x2)
            else
                x_range = range(start = x1, step = -1, stop = x2)
            end

            for x in x_range
                push!(all_points, [x, y1, line_counter])
            end

        elseif x1 == x2 

            if y2 > y1
                y_range = range(start = y1, step = 1, stop = y2)
            else
                y_range = range(start = y1, step = -1, stop = y2)
            end
                
            for y in y_range
                push!(all_points, [x1, y, line_counter])
            end

        # Diagonal lines        
        elseif x1 == y1 && x2 == y2

            if x2 > x1
                x_range = range(start = x1, step = 1, stop = x2)
            else
                x_range = range(start = x1, step = -1, stop = x2)
            end

            for x in x_range
                push!(all_points, [x, x, line_counter])
            end

        elseif x1 == y2 && y1 == x2

            if x1 > x2
                x_range = range(start = x1, step = -1, stop = x2)
                y_range = range(start = y1, step = 1, stop = y2)
            else
                x_range = range(start = x1, step = 1, stop = x2)
                y_range = range(start = y1, step = -1, stop = y2)
            end

            for i = 1:length(x_range)
                push!(all_points, [x_range[i], y_range[i], line_counter])
            end

        else # all other lines

            if x1 > x2 && y1 > y2
                x_range = range(start = x1, step = -1, stop = x2)
                y_range = range(start = y1, step = -1, stop = y2)
            elseif x1 > x2 && y1 < y2
                x_range = range(start = x1, step = -1, stop = x2)
                y_range = range(start = y1, step = 1, stop = y2)
            elseif x1 < x2 && y1 > y2
                x_range = range(start = x1, step = 1, stop = x2)
                y_range = range(start = y1, step = -1, stop = y2)
            elseif x1 < x2 && y1 < y2
                x_range = range(start = x1, step = 1, stop = x2)
                y_range = range(start = y1, step = 1, stop = y2)
            end

            for i = 1:length(x_range)
                push!(all_points, [x_range[i], y_range[i], line_counter])
            end

        end

        line_counter += 1
    end

    return sort!(all_points)
end