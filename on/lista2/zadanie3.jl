#Author: Karol Wziątek

using LinearAlgebra, Random, Printf

# Hilbert matrix
function hilb(n)
    A = zeros(Float64, n, n)
    for i in 1:n, j in 1:n
        A[i,j] = 1.0/(i + j - 1)
    end
    return A
end

# losowa macierz o zadanym wskaźniku uwarunkowania c
function matcond(n, c; rng = MersenneTwister(1234))
    # losowe ortogonalne U,V przez QR
    X = randn(rng, n, n); Q, _ = qr(X); U = Matrix(Q)
    Y = randn(rng, n, n); Q2, _ = qr(Y); V = Matrix(Q2)
    # sing. wartości rozmieszczone wykładniczo: od 1 do 1/c
    s = 10 .^ range(0, -log10(c), length = n)
    S = Diagonal(s)
    A = U * S * V'
    return A
end

# pojedynczy eksperyment dla danej A
function testA(A)
    n = size(A,1)
    x_true = ones(n)
    b = A * x_true

    x_gauss = A \ b
    x_inv   = inv(A) * b

    err_gauss = norm(x_gauss - x_true) / norm(x_true)
    err_inv   = norm(x_inv - x_true)   / norm(x_true)

    return (cond=cond(A), rank=rank(A), err_gauss=err_gauss, err_inv=err_inv)
end

# 1) Hilbert: rosnące n
println("Hilbert matrices:")
for n in 2:12
    A = hilb(n)
    r = testA(A)
    @printf("n=%2d  cond(A)=%.3e  rank=%d  err_gauss=%.3e  err_inv=%.3e\n",
            n, r.cond, r.rank, r.err_gauss, r.err_inv)
end

# 2) losowa macierz: n = 5,10,20; c = 1,10,1e3,1e7,1e12,1e16
println("\nRandom matrices with target condition numbers:")
conds = [1.0, 1e1, 1e3, 1e7, 1e12, 1e16]
for n in (5,10,20)
    println("\nn = $n")
    for c in conds
        A = matcond(n, c)
        r = testA(A)
        @printf("target c=%6.1e  rank=%d  err_gauss=%.3e  err_inv=%.3e\n",
                c, r.rank, r.err_gauss, r.err_inv)
    end
end