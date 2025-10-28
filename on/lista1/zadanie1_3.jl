function find_max(T)
    x = T(1.0)
    # Exponentially increase until overflow
    while isfinite(x*2)
        x *= 2
    end
    # Now x is the largest power of 2 without overflow
    # Step up in smaller increments
    increment = x / 2
    while increment > 0
        if isfinite(x + increment)
            x += increment
        end
        increment /= 2
    end
    return x
end

println(floatmax(Float16))
println("Float16 max:  ", find_max(Float16))
println()

println(floatmax(Float32))
println("Float32 max:  ", find_max(Float32))
println()

println(floatmax(Float64))
println("Float64 max:  ", find_max(Float64))
println()
