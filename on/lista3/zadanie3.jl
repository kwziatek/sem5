#Karol Wziątek - obliczenia naukowe lista 3

function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    fx0 = f(x0)
    fx1 = f(x1)

    for it = 1:maxit
        # Sprawdzenie dzielenia przez bardzo małą różnicę
        if abs(fx1 - fx0) < eps()
            return (x1, fx1, it, 1)  # brak postępu -> traktujemy jak błąd
        end

        # Wzór metody siecznych
        x2 = x1 - fx1 * (x1 - x0) / (fx1 - fx0)
        fx2 = f(x2)

        # Sprawdzenie warunków dokładności
        if abs(x2 - x1) < delta || abs(fx2) < epsilon
            return (x2, fx2, it, 0)
        end

        # Przesuwamy iterację
        x0, fx0 = x1, fx1
        x1, fx1 = x2, fx2
    end

    # Po maxit iteracjach brak zbieżności
    return (x1, f(x1), maxit, 1)
end
