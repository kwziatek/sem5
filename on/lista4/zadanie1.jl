# Karol Wziątek - 279734
# Ilorazy różnicowe - implementacja bez użycia macierzy

function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
    n = length(x)

    if length(f) != n
        error("Wektory x i f muszą mieć tę samą długość")
    end

    # Kopia f – tutaj będą nadpisywane ilorazy różnicowe
    fx = copy(f)

    # Obliczanie ilorazów różnicowych bez macierzy
    for j in 2:n
        for i in n:-1:j
            fx[i] = (fx[i] - fx[i-1]) / (x[i] - x[i-j+1])
        end
    end

    return fx
end
