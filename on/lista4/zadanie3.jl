# Karol Wziątek - 279734
# obliczanie postaci naturalnej wielomianu

function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    n = length(x) - 1
    a = zeros(Float64, n + 1)

    # a reprezentuje aktualny wielomian w postaci naturalnej
    a[n + 1] = fx[n + 1]   # współczynnik przy x^n

    for k = n:-1:1
        # przesunięcie współczynników (mnożenie przez x)
        for i = k+1:n
            a[i] = a[i] - x[k] * a[i + 1]
        end

        # wyraz wolny
        a[k] = fx[k] - x[k] * a[k + 1]
    end

    return a
end
