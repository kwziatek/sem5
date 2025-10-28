# derivative_forward.jl
# Julia 1.x
using Printf

# Function and the point
f(x) = sin(x) + cos(3x)
x0 = 1.0

# The exact value calculated with Bigfloat
setprecision(BigFloat, 200)
x0_big = BigFloat(1)
fprime_exact_big = cos(x0_big) - BigFloat(3) * sin(BigFloat(3) * x0_big)

println(rpad("n",3), "  ", rpad("h",22), "  ", rpad("approx (Float64)",22),
        "  ", rpad("exact (BigFloat)",26), "  ", rpad("abs err",13), "  rel err  1+h==1?")
println("-"^110)

for n in 0:54
    h = 2.0^-n           

    approx = (f(x0 + h) - f(x0)) / h

    approx_big = BigFloat(approx)          
    abs_err = abs(fprime_exact_big - approx_big)
    rel_err = abs_err / abs(fprime_exact_big)

    one_plus_h_is_one = (1.0 + h == 1.0)

    @printf("%2d  %22.15e  %22.15e  %26.18e  %13.5e  %8.5e  %5s\n",
            n, h, approx, fprime_exact_big, abs_err, rel_err, one_plus_h_is_one ? "YES" : " NO")
end