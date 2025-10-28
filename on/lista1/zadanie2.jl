function check(T)
    
    result = T(3.0)*(T(4.0)/T(3.0)-T(1.0)) - T(1.0)
    return isapprox(result, eps(T))
end

println(check(Float16))
println(check(Float32))
println(check(Float64))