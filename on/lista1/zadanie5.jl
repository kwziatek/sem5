# Vector in Float64
x64 = [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957]
y64 = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

# Vector in Float32
x32 = Float32.(x64)
y32 = Float32.(y64)

function dot_forward(x, y)
    S = zero(eltype(x))
    for i in 1:length(x)
        S += x[i] * y[i]
    end
    return S
end

function dot_backward(x, y)
    S = zero(eltype(x))
    for i in length(x):-1:1
        S += x[i] * y[i]
    end
    return S
end

function dot_abs_descending(x, y)
    products = x .* y
    pos = filter(p -> p > 0, products)
    neg = filter(p -> p < 0, products)
    S_pos = sum(sort(pos, rev=true))
    S_neg = sum(sort(neg))
    return S_pos + S_neg
end

function dot_abs_ascending(x, y)
    products = x .* y
    pos = filter(p -> p > 0, products)
    neg = filter(p -> p < 0, products)
    S_pos = sum(sort(pos))
    S_neg = sum(sort(neg, rev=true))
    return S_pos + S_neg
end

println("Float64:")
println("Forward:  ", dot_forward(x64, y64))
println("Backward: ", dot_backward(x64, y64))
println("Abs Desc: ", dot_abs_descending(x64, y64))
println("Abs Asc:  ", dot_abs_ascending(x64, y64))

println("\nFloat32:")
println("Forward:  ", dot_forward(x32, y32))
println("Backward: ", dot_backward(x32, y32))
println("Abs Desc: ", dot_abs_descending(x32, y32))
println("Abs Asc:  ", dot_abs_ascending(x32, y32))

# Exact value to compare
exact = -1.00657107000000e-11
println("\nExact value: ", exact)
