# Karol Wziątek - 279734
# obliczanie wartości wielomianu w punkcie t

function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(x)

    if length(fx) != n
        error("Wektory x i fx muszą mieć tę samą długość")
    end

    # Start od najwyższego ilorazu różnicowego
    nt = fx[n]

    # Uogólniony Horner
    for i in (n-1):-1:1
        nt = nt * (t - x[i]) + fx[i]
    end

    return nt
end
