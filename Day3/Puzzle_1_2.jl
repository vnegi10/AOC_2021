# Convery binary string to decimal
function binary_to_decimal(binary::String)

    decimal = 0
    pos = 1

    for i in range(start = length(binary)-1, step = -1, stop = 0)

        decimal = decimal + parse(Int64, binary[pos]) * 2^i
        pos += 1

    end

    return decimal
end

# Calculate power from binary diagnostic report
function get_power_submarine(input_file::String)

    lines = readlines(input_file)
    
    # Assuming all numbers in the given list have the same size
    binary_size = length(lines[1])

    all_lines = ""
    for line in lines
        all_lines *= line
    end

    gamma = ""
    eps   = ""

    for index = 1:binary_size
        
        all_bits = Any[]

        for i in range(start = index, step = binary_size, stop = length(all_lines))
            push!(all_bits, all_lines[i])
        end

        num_zeros = count(==('0'), all_bits)
        num_ones  = count(==('1'), all_bits)

        if num_zeros > num_ones
            gamma = gamma * "0"
            eps   = eps * "1"
        else
            gamma = gamma * "1"
            eps   = eps * "0"
        end

    end

    return binary_to_decimal(gamma) * binary_to_decimal(eps) 
end

# Separate O2 and CO2 bits from initial data
function separate_oxygen_co2_bits(input_file::String, start_index::Int64)

    lines = readlines(input_file)
    
    # Assuming all numbers in the given list have the same size
    binary_size = length(lines[1])

    all_lines = ""
    for line in lines
        all_lines *= line
    end

    all_bits = Any[]

    oxygen_bits = ""
    co2_bits = ""

    for i in range(start = start_index, step = binary_size, stop = length(all_lines))
        push!(all_bits, all_lines[i])
    end

    num_zeros = count(==('0'), all_bits)
    num_ones  = count(==('1'), all_bits)

    if num_ones ≥ num_zeros
        for i in range(start = start_index, step = binary_size, stop = length(all_lines))
            if all_lines[i] == '1'
                oxygen_bits = oxygen_bits * all_lines[i:i+binary_size-1]
            end

            if all_lines[i] == '0'
                co2_bits = co2_bits * all_lines[i:i+binary_size-1]
            end
        end
    else
        for i in range(start = start_index, step = binary_size, stop = length(all_lines))
            if all_lines[i] == '0'
                oxygen_bits = oxygen_bits * all_lines[i:i+binary_size-1]
            end

            if all_lines[i] == '1'
                co2_bits = co2_bits * all_lines[i:i+binary_size-1]
            end
        end
    end

    return oxygen_bits, co2_bits, binary_size
end

# Process bits according to gas type
function process_bits(gas_bits::String, gas_type::String, 
                      start_index::Int64, binary_size::Int64)

    all_bits = Any[]

    new_gas_bits = ""
    
    for i in range(start = start_index, step = binary_size, stop = length(gas_bits))
        push!(all_bits, gas_bits[i])
    end

    num_zeros = count(==('0'), all_bits)
    num_ones  = count(==('1'), all_bits)

    pos = start_index - 1

    if num_ones ≥ num_zeros
        for i in range(start = start_index, step = binary_size, stop = length(gas_bits))
            if gas_type == "O2" && gas_bits[i] == '1'
                new_gas_bits = new_gas_bits * gas_bits[i-pos:i-pos+binary_size-1]
            end

            if gas_type == "CO2" && gas_bits[i] == '0'
                new_gas_bits = new_gas_bits * gas_bits[i-pos:i-pos+binary_size-1]
            end            
        end
        
    else
        for i in range(start = start_index, step = binary_size, stop = length(gas_bits))
            if gas_type == "O2" && gas_bits[i] == '0'
                new_gas_bits = new_gas_bits * gas_bits[i-pos:i-pos+binary_size-1]
            end 
            
            if gas_type == "CO2" && gas_bits[i] == '1'
                new_gas_bits = new_gas_bits * gas_bits[i-pos:i-pos+binary_size-1]
            end 
        end   
        
    end
    
    return new_gas_bits
end

function get_gas_bits(input_gas_bits::String, gas_type::String, binary_size::Int64)

    start_index = 2

    while length(input_gas_bits) > binary_size
        new_gas_bits = process_bits(input_gas_bits, gas_type, start_index, binary_size)
        input_gas_bits = new_gas_bits
        start_index += 1
    end

    return input_gas_bits
end

# Calculate life support rating
function get_life_support_rating(input_file::String, start_index::Int64)

    results = separate_oxygen_co2_bits(input_file, start_index)

    oxygen_bits = results[1]
    co2_bits    = results[2]
    binary_size = results[3]

    final_oxygen_bits = get_gas_bits(oxygen_bits, "O2", binary_size)

    final_co2_bits = get_gas_bits(co2_bits, "CO2", binary_size)

    return binary_to_decimal(final_oxygen_bits) * binary_to_decimal(final_co2_bits)
end






























