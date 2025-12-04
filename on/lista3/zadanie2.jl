#Karol Wziątek - obliczenia naukowe lista 3

function mstycznych(f, pf, x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    x = x0

    for it = 1:maxit
        fx = f(x)
        pfx = pf(x)

        # Sprawdzenie, czy pochodna bliska zeru
        if abs(pfx) < eps()
            return (x, fx, it, 2)
        end

        # Obliczenie kolejnego przybliżenia
        x_new = x - fx / pfx

        # Sprawdzenie warunku dokładności (różnicy kolejnych przybliżeń)
        if abs(x_new - x) < delta || abs(f(x_new)) < epsilon
            return (x_new, f(x_new), it, 0)
        end

        x = x_new
    end

    # Jeśli nie osiągnięto dokładności
    return (x, f(x), maxit, 1)
end
