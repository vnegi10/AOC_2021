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

function get_hv_points(input_file::String)

    hv_lines  = get_hv_lines(input_file)
    hv_points = Any[]

    line_counter = 1

    for hv_line in hv_lines
        x1, y1 = hv_line[1][1], hv_line[1][2]
        x2, y2 = hv_line[2][1], hv_line[2][2]

        if y1 == y2 && x2 > x1
            x_range = range(start = x1, step = 1, stop = x2)
            for x in x_range
                push!(hv_points, [x, y1, line_counter])
            end

        elseif y1 == y2 && x1 > x2
            x_range = range(start = x1, step = -1, stop = x2)
            for x in x_range
                push!(hv_points, [x, y1, line_counter])
            end

        elseif x1 == x2 && y2 > y1
            y_range = range(start = y1, step = 1, stop = y2)
            for y in y_range
                push!(hv_points, [x1, y, line_counter])
            end

        elseif x1 == x2 && y1 > y2
            y_range = range(start = y1, step = -1, stop = y2)
            for y in y_range
                push!(hv_points, [x1, y, line_counter])
            end
        end
        line_counter += 1
    end

    return sort!(hv_points)
end

function get_hv_overlap(input_file::String)

    hv_points = get_hv_points(input_file)
    overlap = 0
    i = 1
    
    while i < length(hv_points)

        overlap_found = false

        x, y, l    = hv_points[i][1], hv_points[i][2], hv_points[i][3]
        
        for j = i+1:length(hv_points)
            xn, yn, ln = hv_points[j][1], hv_points[j][2], hv_points[j][3]

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