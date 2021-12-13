# Part-1

function get_initial_fish(input_file::String)

    lines = readlines(input_file)
    line = split(lines[1], ",")

    # Initial number of fish
    fish_num = map(x -> parse(Int128, x), line)

    return fish_num
end

function get_final_fish(input_file::String, days::Int64)

    fish_num = get_initial_fish(input_file)

    for day = 1:days

        # Check if there is a fish with timer 0
        indices_0 = findall(x -> x == 0, fish_num)
        indices_not0 = findall(x -> x != 0, fish_num)

        # Reduce all by 1 when no 0's are found
        if isempty(indices_0)
            fish_num = fish_num .- 1
        else
            # Reduce non-0's by 1
            fish_num[indices_not0] = fish_num[indices_not0] .- 1

            # Split 0 into a 6 and 8
            fish_num[indices_0] .= 6

            for i = 1:length(indices_0)
                push!(fish_num, 8)
            end
        end

    end


    return @info "After $(days) days, we will have $(length(fish_num)) fish"
end




