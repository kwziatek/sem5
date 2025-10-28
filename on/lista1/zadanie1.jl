#findidng machine eplison

function mach_eps(T)
    e = T(1.0) 
    while T(1.0) + e/2 > 1.0
        e /= 2
    end
    return e
end


#comparing float16 - found be me and the built in one
println(mach_eps(Float16))
println(eps(Float16))
println()

#comparing float32 - found be me and the built in one
println(mach_eps(Float32))
println(eps(Float32))
println()

#comparing float64 - found be me and the built in one
println(mach_eps(Float64))
println(eps(Float64))
println()
