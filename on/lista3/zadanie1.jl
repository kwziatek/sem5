function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)

    fa = f(a)
    fb = f(b)

    # Sprawdzenie czy funkcja zmienia znak w przedziale
    if fa * fb > 0
        return (NaN, NaN, 0, 1)   # err = 1
    end

    it = 0
    # Maksymalna liczba iteracji to taka, która gwarantuje osiągnięcie dokładności delta - bezpiecznik
    maxit = ceil(Int, log2((b - a) / delta))

    r = (a + b) / 2
    fr = f(r)

    while (b - a) / 2 > delta && abs(fr) > epsilon && it < maxit
        it += 1

        if fa * fr < 0
            b = r
            fb = fr
        else
            a = r
            fa = fr
        end

        r = (a + b) / 2
        fr = f(r)
    end

    # err = 0
    return (r, fr, it, 0)
end