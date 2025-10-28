function eta(T)
    e = T(1.0) 
    while T(0.0) + e/2 > 0.0
        e /= 2
    end
    return e
end

println(nextfloat(Float16(0.0)))
println(eta(Float16))
println()

println(nextfloat(Float32(0.0)))
println(eta(Float32))
println()

println(nextfloat(Float64(0.0)))
println(eta(Float64))
println()
