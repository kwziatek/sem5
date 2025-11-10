#Author: Karol Wziątek

using Printf

# Funkcja generująca ciąg
function iterate_sequence(x0::Float64, c::Float64, n_iter::Int)
    seq = Float64[]
    x = x0
    for i in 1:n_iter
        push!(seq, x)
        x = x^2 + c
    end
    return seq
end

N = 40

# Eksperymenty dla c = -2
c2_vals = [
    iterate_sequence(1.0, -2.0, N),
    iterate_sequence(2.0, -2.0, N),
    iterate_sequence(1.99999999999999, -2.0, N)
]

# Eksperymenty dla c = -1
c1_vals = [
    iterate_sequence(1.0, -1.0, N),
    iterate_sequence(-1.0, -1.0, N),
    iterate_sequence(0.75, -1.0, N),
    iterate_sequence(0.25, -1.0, N)
]

# Tabela dla c = -2
println("===== Tabela dla c = -2 =====")
for i in 1:N
    @printf("%2d & %.15f & %.15f & %.15f \\\\ \\hline\n",
        i, c2_vals[1][i], c2_vals[2][i], c2_vals[3][i])
end

println("\n===== Tabela dla c = -1 =====")
# Tabela dla c = -1
for i in 1:N
    @printf("%2d & %.15f & %.15f & %.15f & %.15f \\\\ \\hline\n",
        i, c1_vals[1][i], c1_vals[2][i], c1_vals[3][i], c1_vals[4][i])
end
