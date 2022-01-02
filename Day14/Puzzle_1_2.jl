# Part-1

using Pkg
Pkg.activate(pwd())

using StatsBase

function get_template(input_file::String)

    lines = readlines(input_file)
    template = collect(lines[1])

    return template
end

function get_insertion_rules(input_file::String)

    lines = readlines(input_file)
    pairs = SubString{String}[]
    inserts = Char[]

    for line in lines[3:end]
        parts = split(line, " ")

        push!(pairs, parts[1])
        push!(inserts, only(parts[3]))

    end

    rules_dict = Dict(pairs .=> inserts)

    return rules_dict
end

function grow_polymer(input_file::String, steps::Int64)

    template = get_template(input_file)
    rules_dict = get_insertion_rules(input_file)

    for step = 1:steps

        @info "Calculating polymer growth for step $(step)"

        #i = 1
        pol_inserts = Char[]
        pol_range = range(start = 1, stop = length(template) - 1, step = 1)

        #while i < length(template)
        @inbounds for i in pol_range
            pol_pair = template[i] * template[i+1]
            push!(pol_inserts, rules_dict[pol_pair])
            #i += 1
        end

        @inbounds for j in eachindex(pol_inserts)
            insert!(template, 2*j, pol_inserts[j])
        end

    end

    return template
end

function get_final_result(input_file::String, steps::Int64)

    template = grow_polymer(input_file, steps)

    count_dict = countmap(template)
    all_counts = collect(values(count_dict))

    max_count, min_count = maximum(all_counts), minimum(all_counts)

    return max_count - min_count
end

# Part-2

using Mmap

function grow_polymer_2(template::Vector{Char}, rules_dict::Dict{SubString{String}, Char},
                           steps::Int64)

    for step = 1:steps

        #@info "Calculating polymer growth for step $(step)"

        # Create new template by using old one + inserting new elements
        template_new = Array{Char}(undef, 2*length(template) - 1)
        k = 1

        @inbounds for j in eachindex(template_new)

            if iseven(j)
                template_new[j] = rules_dict[template[Int(j/2)] * template[Int(j/2) + 1]]

            else
                template_new[j] = template[k]
                k += 1 
            end
                                   
        end

        template = template_new
        template_new = nothing        
    end

    return template
end

function grow_polymer_2_mmap(template::Vector{Char}, rules_dict::Dict{SubString{String}, Char},
                           steps::Int64, mmap_filename::String)

    mmap_dir = "/mnt/sabrent/home/vikas/Desktop/Julia_mmap"
    template_length = 0

    for step = 1:steps

        #@info "Calculating polymer growth for step $(step)"
        
        template_io = open(joinpath(mmap_dir, mmap_filename), "w+")

        # Create new template by using old one + inserting new elements
        template_length = 2*length(template) - 1
        template_new = Mmap.mmap(template_io, Vector{Char}, template_length)
        k = 1

        @inbounds for j in eachindex(template_new)

            if iseven(j)
                template_new[j] = rules_dict[template[Int(j/2)] * template[Int(j/2) + 1]]
            else
                template_new[j] = template[k]
                k += 1 
            end
                                   
        end

        template = template_new
        template_new = nothing

        # Close IO
        close(template_io)

        # Remove mmap files for all iterations except the last one
        if step != steps
            rm(joinpath(mmap_dir, mmap_filename))            
        else
            # Force synchronization between in-memory and on-disk version
            Mmap.sync!(template)            
        end
    end

    template = nothing

    # Return full path to template mmap file and its length
    return joinpath(mmap_dir, mmap_filename), template_length
end

function get_final_result_2(input_file::String, steps::Int64)

    template_in = get_template(input_file)
    rules_dict  = get_insertion_rules(input_file)

    template = grow_polymer_2(template_in, rules_dict, steps)
    
    count_dict = countmap(template)
    template = nothing

    all_counts = collect(values(count_dict))
    count_dict = nothing

    max_count, min_count = maximum(all_counts), minimum(all_counts)

    return max_count - min_count
end

function get_final_result_2_mmap(input_file::String, steps::Int64, 
                                 mmap_filenames::Vector{String})

    template_in = get_template(input_file)
    rules_dict  = get_insertion_rules(input_file)

    pol_output  = grow_polymer_2_mmap(template_in, rules_dict, steps, mmap_filenames)

    template_mmap_file = pol_output[1]
    template_length    = pol_output[2]

    template_io = open(template_mmap_file, "r+")
    template    = Mmap.mmap(template_io, Vector{Char}, template_length)
     
    count_dict = countmap(template)
    template = nothing

    all_counts = collect(values(count_dict))
    count_dict = nothing

    # Close IO stream and remove mmap file
    close(template_io)
    rm(template_mmap_file)

    max_count, min_count = maximum(all_counts), minimum(all_counts)

    return max_count - min_count
end

function get_final_result_big(input_file::String, steps_initial::Int64, steps_total::Int64,
                              pol_size::Int64)

    template_in = get_template(input_file)
    rules_dict  = get_insertion_rules(input_file)

    # Polymer growth until steps_initial
    template_out = grow_polymer_2(template_in, rules_dict, steps_initial)

    # Create a dict to keep track of number of elements
    count_dict = countmap(template_out)
    all_keys   = count_dict |> keys |> collect

    # Set all counters to 0 to avoid double counting later    
    for key in all_keys
        count_dict[key] = 0
    end

    pol_full_size = length(template_out)
       
    @info "$(steps_initial) steps are done, will split and continue \
           with polymer length $(pol_full_size) and segment size $(pol_size)"

    i_start, num_segments = 1, 1
    last_pol = false

    while i_start < pol_full_size

        # Check if we have reached the last polymer segment
        if pol_full_size - i_start ≤ pol_size
            i_end = pol_full_size
            last_pol = true

        else
            i_end = i_start + pol_size - 1
        end

        # Stop when only one element is left after iterating through all segments
        if i_start == i_end
            break
        end

        @info "Segment # $(num_segments)"

        @time begin

            # Read from input file to create initial template, cleared later to save memory
            # template_out = grow_polymer_2(get_template(input_file), rules_dict, steps_initial)

            # Input template for each segment        
            template_in = template_out[i_start:i_end]

            # Input template for common segment
            if ~last_pol
                template_in_common = template_out[i_end:i_end + 1]
            end

            # Save memory
            # template_out = nothing

            template_out_sub = grow_polymer_2_mmap(template_in, rules_dict, steps_total - steps_initial)

            # Calculate occurences of each element
            count_dict_sub = countmap(template_out_sub)

            for key in collect(keys(count_dict_sub))
                count_dict[key] += count_dict_sub[key]
            end

            # Save memory
            template_out_sub = nothing

            # Stop at last polymer segment
            if last_pol
                break
            end

            i_start = i_end + 1
            num_segments += 1
            
            # Calculate growth for common elements between two segments
            template_out_sub = grow_polymer_2(template_in_common, rules_dict, steps_total - steps_initial)

            # Remove first element
            popat!(template_out_sub, 1)

            # Remove last element only when not at the end of polymer sequence
            if i_start != pol_full_size
                popat!(template_out_sub, length(template_out_sub))
            end    

            count_dict_sub = countmap(template_out_sub)

            for key in collect(keys(count_dict_sub))
                count_dict[key] += count_dict_sub[key]
            end
            
            # Save memory
            template_out_sub = nothing

        end        

    end
    
    template_out = nothing

    # Calculate most/least common element    
    all_counts = collect(values(count_dict))
    count_dict = nothing        

    max_count, min_count = maximum(all_counts), minimum(all_counts)

    return max_count - min_count
end

function get_final_result_big_mmap(input_file::String, steps_initial::Int64, steps_total::Int64,
                                   pol_size::Int64; mmap_filename = "dummy.bin", mmap_length = 0)

    mmap_dir = "/mnt/sabrent/home/vikas/Desktop/Julia_mmap"

    rules_dict  = get_insertion_rules(input_file)
    template_out = Vector{Char}[]

    if ~isfile(joinpath(mmap_dir, mmap_filename))

        template_in = get_template(input_file)
        
        # Polymer growth until steps_initial
        pol_output = grow_polymer_2_mmap(template_in, rules_dict, steps_initial, mmap_filename)
        
        template_mmap_file = pol_output[1]
        template_length    = pol_output[2]

        template_io  = open(template_mmap_file, "r+")
        template_out = Mmap.mmap(template_io, Vector{Char}, template_length)         
    else
        template_io  = open(joinpath(mmap_dir, mmap_filename), "r+")
        template_out = Mmap.mmap(template_io, Vector{Char}, mmap_length)         
    end

    # Create a dict to keep track of number of elements
    count_dict = countmap(template_out)
    all_keys   = count_dict |> keys |> collect

    # Set all counters to 0 to avoid double counting later    
    for key in all_keys
        count_dict[key] = 0
    end

    pol_full_size = length(template_out)
       
    @info "$(steps_initial) steps are done, will split and continue \
           with polymer length $(pol_full_size) and segment size $(pol_size)"

    i_start, num_segments = 1, 1
    last_pol = false

    while i_start < pol_full_size

        # Check if we have reached the last polymer segment
        if pol_full_size - i_start ≤ pol_size
            i_end = pol_full_size
            last_pol = true

        else
            i_end = i_start + pol_size - 1
        end

        # Stop when only one element is left after iterating through all segments
        if i_start == i_end
            break
        end

        @info "Segment # $(num_segments)"

        @time begin

            # Input template for each segment        
            template_in = template_out[i_start:i_end]

            # Input template for common segment
            if ~last_pol
                template_in_common = template_out[i_end:i_end + 1]
            end

            template_out_sub = grow_polymer_2(template_in, rules_dict, steps_total - steps_initial)

            #=pol_output_sub = grow_polymer_2_mmap(template_in, rules_dict, steps_total - steps_initial, 
                                                ["insert_2.bin", "template_2.bin"])

            template_mmap_file = pol_output_sub[1]
            template_length    = pol_output_sub[2]
        
            template_io_sub  = open(template_mmap_file, "r+")
            template_out_sub = Mmap.mmap(template_io_sub, Vector{Char}, template_length)=#

            # Calculate occurences of each element
            count_dict_sub = countmap(template_out_sub)

            for key in collect(keys(count_dict_sub))
                count_dict[key] += count_dict_sub[key]
            end

            # Save memory
            template_out_sub = nothing

            # Stop at last polymer segment
            if last_pol
                break
            end

            i_start = i_end + 1
            num_segments += 1
            
            # Calculate growth for common elements between two segments
            template_out_sub = grow_polymer_2(template_in_common, rules_dict, steps_total - steps_initial)

            # Remove first element
            popat!(template_out_sub, 1)

            # Remove last element only when not at the end of polymer sequence
            if i_start != pol_full_size
                popat!(template_out_sub, length(template_out_sub))
            end    

            count_dict_sub = countmap(template_out_sub)

            for key in collect(keys(count_dict_sub))
                count_dict[key] += count_dict_sub[key]
            end
            
            # Save memory
            template_out_sub = nothing

            # Close IO stream and remove mmap file
            #=close(template_io_sub)
            rm(template_mmap_file)=#

        end    

    end
    
    template_out = nothing

    # Close IO stream and remove mmap file
    close(template_io)
    rm(template_mmap_file)

    # Calculate most/least common element    
    all_counts = collect(values(count_dict))
    count_dict = nothing        

    max_count, min_count = maximum(all_counts), minimum(all_counts)

    return max_count - min_count
end