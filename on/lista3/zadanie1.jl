#Karol Wziątek - obliczenia naukowe lista 3

function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
    fa = f(a)
    fb = f(b)

    #Sprawdzanie czy istnieje pierwiastek
    if fa * fb > 0
        return (NaN, NaN, 0, 1)
    end

    it = 0

    #Wyznaczenie kolejnej wartości 
    r = (a + b) / 2
    fr = f(r)

    #Sprawdzanie warunku dokładności 
    while b - a > delta && abs(fr) > epsilon
        it += 1

        #Wyznaczenia kolejnej wartości 
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

    return (r, fr, it, 0)
end