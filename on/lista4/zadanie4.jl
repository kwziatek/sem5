# Karol Wziątek - 279734
# funkcja interpolująca n-tego stopnia, interpolucjąca zadaną funkcję

ENV["GKSwstype"] = "100"   # tryb offscreen (bez GUI)
using Plots
gr()

function rysujNnfx(f, a::Float64, b::Float64, n::Int; wezly::Symbol = :rownoodlegle)
    # --- 1. Generowanie węzłów ---
    if wezly == :rownoodlegle
        h = (b - a)/n
        x = [a + k*h for k in 0:n]
    elseif wezly == :czebyszew
        x = [(a+b)/2 + (b-a)/2 * cos((2k+1)/(2(n+1)) * pi) for k in 0:n]
    else
        error("Niepoprawny typ węzłów")
    end

    # --- 2. Wartości funkcji w węzłach ---
    fx = [f(xk) for xk in x]

    # --- 3. Ilorazy różnicowe ---
    c = ilorazyRoznicowe(x, fx)

    # --- 4. Tworzenie gęstych punktów do rysowania ---
    X = range(a, b; length=500)
    Yf = [f(xk) for xk in X]          # wartości funkcji
    Yp = [warNewton(x, c, t) for t in X]           # wartości wielomianu Newtona

    # --- 5. Rysowanie ---
    plot(X, Yf, label="f(x)", lw=2)
    # plot(x, fx, label="f(x)") # dla funkcji anonimowych zadanych tabelą punktów
    plot!(X, Yp, label="Wielomian Newtona", lw=2, linestyle=:dash)
    scatter!(x, fx, label="Węzły interpolacji", color=:red)
    savefig("wykres.png")
end
