# Part-1

function get_hpos(input_file::String)

    lines = readlines(input_file)
    line = split(lines[1], ",")

    hpos = map(x -> parse(Int64, x), line)

    return hpos
end

function get_least_fuel(input_file::String)

    hpos_all = get_hpos(input_file)

    hpos_min, hpos_max = minimum(hpos_all), maximum(hpos_all)

    hpos_range = range(hpos_min, step = 1, stop = hpos_max)

    fuel_total = Int64[]

    for target in hpos_range

        fuel_change = hpos_all .- target
        fuel_change_abs = abs.(fuel_change)
        push!(fuel_total, sum(fuel_change_abs))

    end

    min_fuel, min_target = findmin(fuel_total)[1], hpos_range[findmin(fuel_total)[2]]

    return @info "Minimum $(min_fuel) fuel used to align on $(min_target)"

end

# Part-2

function get_least_fuel_new(input_file::String)

    hpos_all = get_hpos(input_file)

    hpos_min, hpos_max = minimum(hpos_all), maximum(hpos_all)

    hpos_range = range(hpos_min, step = 1, stop = hpos_max)

    fuel_total = Int64[]

    for target in hpos_range

        fuel_change = hpos_all .- target
        fuel_change_abs = abs.(fuel_change)

        # Calculate fuel cost with new rate
        fuel_change_cost = map(x -> sum(collect(1:x)), fuel_change_abs)
        push!(fuel_total, sum(fuel_change_cost))

    end

    min_fuel, min_target = findmin(fuel_total)[1], hpos_range[findmin(fuel_total)[2]]

    return @info "Minimum $(min_fuel) fuel used to align on position $(min_target)"

end