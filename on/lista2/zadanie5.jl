#Author: Karol Wziątek

using Printf

# Eksperyment 1: logistyczny model z obcięciem
function logistic_truncation(p0, r, n_iter)
    p = Float32(p0)
    results = Float32[]
    for n in 1:n_iter
        p = p + r * p * (1 - p)
        push!(results, p)
        # po 10 iteracjach wykonujemy obcięcie do 3 miejsc po przecinku
        if n == 10
            p = floor(p * 1000) / 1000  # obcięcie
        end
    end
    return results
end 

# zwykłe 40 iteracji bez obcięcia
function logistic_standard(p0, r, n_iter)
    p = Float32(p0)
    results = Float32[]
    for n in 1:n_iter
        p = p + r * p * (1 - p)
        push!(results, p)
    end
    return results
end

# Eksperyment 2: porównanie Float32 i Float64
function logistic_compare_types(p0, r, n_iter)
    p32 = Float32(p0)
    p64 = Float64(p0)
    results32 = Float32[]
    results64 = Float64[]
    for n in 1:n_iter
        p32 = p32 + r * p32 * (1 - p32)
        p64 = p64 + r * p64 * (1 - p64)
        push!(results32, p32)
        push!(results64, p64)
    end
    return results32, results64
end

# --- przykładowe wywołania ---
p0 = 0.01
r = 3.0
n_iter = 40

# eksperyment 1
standard = logistic_standard(p0, r, n_iter)
truncated = logistic_truncation(p0, r, n_iter)

println("Eksperyment 1: standard Float32 vs obcięcie po 10 iteracjach")
for n in 1:n_iter
    @printf("%d & %.10f & %.10f \\\\ \n", n, standard[n], truncated[n])
end

# eksperyment 2
results32, results64 = logistic_compare_types(p0, r, n_iter)

println("Eksperyment 2: Float32 vs Float64")
for n in 1:n_iter
    @printf("%d & %.10f & %.10f \\\\ \n", n, results32[n], results64[n])
end
