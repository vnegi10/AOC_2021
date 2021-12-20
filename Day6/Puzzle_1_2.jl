# Part-1

function get_initial_fish(input_file::String)

    lines = readlines(input_file)
    line = split(lines[1], ",")

    # Initial number of fish
    fish_num = map(x -> parse(Int8, x), line)

    return fish_num
end

function get_final_fish(input_file::String, days::Int64)

    fish_num = get_initial_fish(input_file)

    for day = 1:days

        # Check if there is a fish with timer 0
        indices_0    = BigInt.(findall(x -> x == 0, fish_num))
        indices_not0 = BigInt.(findall(x -> x != 0, fish_num))

        # Reduce all by 1 when no 0's are found
        if isempty(indices_0)
            fish_num = fish_num .- Int8(1)
        else
            # Reduce non-0's by 1
            fish_num[indices_not0] = fish_num[indices_not0] .- Int8(1)

            # Split 0 into a 6 and 8
            fish_num[indices_0] .= Int8(6)

            for i = 1:length(indices_0)
                push!(fish_num, Int8(8))
            end
        end

        # Free memory
        indices_0    = 0
        indices_not0 = 0

    end

    fish_total = length(BigInt.(fish_num))    

    return @info "After $(days) days, we will have $(fish_total) fish"
end

# Part-2

function get_final_big_fish(input_file::String, days::Int64, day_split::Int64)

    fish_num_all = get_initial_fish(input_file)
    fish_total_all = Int128[]

    # Initial calculation for full array up to day_split
    for day = 1:day_split

        @inbounds for i in eachindex(fish_num_all)

            if fish_num_all[i] != Int8(0)
                fish_num_all[i] = fish_num_all[i] - Int8(1)
            else
                fish_num_all[i] = Int8(6)
                push!(fish_num_all, Int8(8))
            end

        end

    end

    @info "Calculation up to $(day_split) is done, will split and continue with $(length(fish_num_all)) fish"

    @inbounds for fish in fish_num_all

        fish_num = Int8[]
        push!(fish_num, fish)

        for day = day_split+1:days

            @inbounds for i in eachindex(fish_num)

                if fish_num[i] != Int8(0)
                    fish_num[i] = fish_num[i] - Int8(1)
                else
                    fish_num[i] = Int8(6)
                    push!(fish_num, Int8(8))
                end

            end            
        end

        fish_total = length(Int128.(fish_num))
        push!(fish_total_all, fish_total)
    end

    return @info "After $(days) days, we will have $(sum(fish_total_all)) fish"
end