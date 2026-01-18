# Karol Wziątek 279734

# ========================================================
# IMPLEMENTACJA ROZWIĄZANIA PROBLEMU + FUNKCJE POMOCNICZE
# ========================================================

module blocksys

using LinearAlgebra
using Printf

export BlockMatrix, load_matrix, load_vector, save_solution, compute_rhs, solve_gauss

"""
    BlockMatrix

Struktura przechowująca macierz blokową A o specyficznej strukturze rzadkiej.
n - rozmiar macierzy
l - rozmiar bloków wewnętrznych
Ak - wektor macierzy diagonalnych (gęste l x l)
Bk - wektor macierzy poddiagonalnych (gęste l x l) - indeksowane od 2 do v
Ck - wektor macierzy naddiagonalnych (gęste l x l) - indeksowane od 1 do v-1
"""
mutable struct BlockMatrix
    n::Int
    l::Int
    Ak::Vector{Matrix{Float64}}
    Bk::Vector{Matrix{Float64}} # Przechowujemy jako gęste dla uproszczenia operacji na blokach
    Ck::Vector{Matrix{Float64}} 

    function BlockMatrix(n::Int, l::Int)
        v = div(n, l)
        Ak = [zeros(Float64, l, l) for _ in 1:v]
        Bk = [zeros(Float64, l, l) for _ in 1:v-1] # B2...Bv
        Ck = [zeros(Float64, l, l) for _ in 1:v-1] # C1...Cv-1
        new(n, l, Ak, Bk, Ck)
    end
end

"""
    set_val!(A::BlockMatrix, i::Int, j::Int, val::Float64)

Wstawia wartość do odpowiedniego bloku macierzy na podstawie globalnych indeksów (i, j).
"""
function set_val!(A::BlockMatrix, i::Int, j::Int, val::Float64)
    l = A.l
    # Wyznaczenie indeksów bloków
    block_row = div(i - 1, l) + 1
    block_col = div(j - 1, l) + 1
    
    # Lokalne indeksy wewnątrz bloku
    local_i = (i - 1) % l + 1
    local_j = (j - 1) % l + 1

    if block_row == block_col
        # Macierz Ak
        A.Ak[block_row][local_i, local_j] = val
    elseif block_row == block_col + 1
        # Macierz Bk (poddiagonalna). Indeks w wektorze Bk przesunięty o 1 (B2 jest pod indeksem 1)
        # Bk[k] odpowiada blokowi B_{k+1}
        A.Bk[block_row - 1][local_i, local_j] = val
    elseif block_row == block_col - 1
        # Macierz Ck (naddiagonalna)
        A.Ck[block_row][local_i, local_j] = val
    else
        # Ignorujemy wartości poza pasmem (zgodnie ze strukturą nie powinny występować lub są 0)
    end
end

"""
    load_matrix(filepath::String) -> BlockMatrix

Wczytuje macierz A z pliku tekstowego zgodnie z formatem.
"""
function load_matrix(filepath::String)
    open(filepath, "r") do file
        line = readline(file)
        dims = split(line)
        n = parse(Int, dims[1])
        l = parse(Int, dims[2])
        
        A = BlockMatrix(n, l)
        
        for line in eachline(file)
            parts = split(line)
            if length(parts) >= 3
                i = parse(Int, parts[1])
                j = parse(Int, parts[2])
                val = parse(Float64, parts[3])
                set_val!(A, i, j, val)
            end
        end
        return A 
    end
end

"""
    load_vector(filepath::String) -> Vector{Float64}

Wczytuje wektor prawych stron b z pliku.
"""
function load_vector(filepath::String)
    open(filepath, "r") do file
        line = readline(file) # Pierwsza linia to rozmiar n
        n = parse(Int, strip(line))
        b = Vector{Float64}(undef, n)
        idx = 1
        for line in eachline(file)
            if !isempty(strip(line))
                b[idx] = parse(Float64, strip(line))
                idx += 1
            end
        end
        return b
    end

end

"""
    save_solution(filepath::String, x::Vector{Float64}, relative_error::Union{Float64, Nothing}=nothing)

Zapisuje rozwiązanie do pliku. Jeśli podano błąd względny, jest on zapisywany w pierwszej linii.
"""
function save_solution(filepath::String, x::Vector{Float64}, relative_error::Union{Float64, Nothing}=nothing)
    open(filepath, "w") do file
        if relative_error !== nothing
            println(file, relative_error)
        end
        for val in x
            println(file, val)
        end
    end
end

"""
    compute_rhs(A::BlockMatrix, x::Vector{Float64}) -> Vector{Float64}

Oblicza b = Ax wykorzystując strukturę blokową (złożoność O(n)).
"""
function compute_rhs(A::BlockMatrix, x::Vector{Float64})
    n = A.n
    l = A.l
    b = zeros(Float64, n)
    v = div(n, l)

    # Iteracja po blokach wierszy
    for k in 1:v
        row_start = (k-1)*l + 1
        row_end = k*l
        
        # Część diagonalna: Ak * x_k
        # Pobieramy fragment wektora x odpowiadający kolumnom bloku Ak
        x_part_curr = x[row_start:row_end]
        b[row_start:row_end] += A.Ak[k] * x_part_curr
        
        # Część naddiagonalna: Ck * x_{k+1}
        if k < v
            col_start_next = k*l + 1
            col_end_next = (k+1)*l
            x_part_next = x[col_start_next:col_end_next]
            b[row_start:row_end] += A.Ck[k] * x_part_next
        end
        
        # Część poddiagonalna: Bk * x_{k-1}
        if k > 1
            col_start_prev = (k-2)*l + 1
            col_end_prev = (k-1)*l
            x_part_prev = x[col_start_prev:col_end_prev]
            # Bk indeksowane od 1 do v-1, gdzie Bk[1] to blok B2
            b[row_start:row_end] += A.Bk[k-1] * x_part_prev
        end
    end
    return b
end

"""
    get_element(A::BlockMatrix, i, j)

Pomocnicza funkcja do pobierania elementu (używana w eliminacji Gaussa).
"""
function get_element(A::BlockMatrix, i::Int, j::Int)
    l = A.l
    block_row = div(i - 1, l) + 1
    block_col = div(j - 1, l) + 1
    local_i = (i - 1) % l + 1
    local_j = (j - 1) % l + 1

    if block_row == block_col
        return A.Ak[block_row][local_i, local_j]
    elseif block_row == block_col + 1
        return A.Bk[block_row - 1][local_i, local_j]
    elseif block_row == block_col - 1
        return A.Ck[block_row][local_i, local_j]
    else
        return 0.0
    end
end

"""
    solve_gauss(A_in::BlockMatrix, b_in::Vector{Float64}; pivot::Bool=false) -> Vector{Float64}

Rozwiązuje układ Ax=b metodą eliminacji Gaussa z uwzględnieniem rzadkości.
Opcja pivot=true włącza częściowy wybór elementu głównego.
Funkcja nie niszczy danych wejściowych (pracuje na kopiach).
"""
function solve_gauss(A_in::BlockMatrix, b_in::Vector{Float64}; pivot::Bool=false)
    # Tworzymy głęboką kopię struktury, aby nie modyfikować oryginału
    # W praktyce przy dużych macierzach można modyfikować w miejscu, ale tutaj dla bezpieczeństwa kopia.
    # Kopiowanie bloków:
    n = A_in.n
    l = A_in.l
    
    # Ręczne kopiowanie macierzy blokowych
    Ak = [copy(M) for M in A_in.Ak]
    Bk = [copy(M) for M in A_in.Bk]
    Ck = [copy(M) for M in A_in.Ck]
    
    # Tworzymy lokalną strukturę, na której będziemy pracować (mutowalną)
    # Zamiast pełnej struktury BlockMatrix, dla wydajności wewnątrz algorytmu
    # będziemy odwoływać się bezpośrednio do tablic Ak, Bk, Ck.
    
    b = copy(b_in)
    p = collect(1:n) # Wektor permutacji dla pivotingu

    # Funkcja pomocnicza do zapisu do naszej "kopii roboczej"
    function set_elem!(i, j, val)
        br = div(i - 1, l) + 1
        bc = div(j - 1, l) + 1
        li = (i - 1) % l + 1
        lj = (j - 1) % l + 1
        if br == bc
            Ak[br][li, lj] = val
        elseif br == bc + 1
            Bk[br - 1][li, lj] = val
        elseif br == bc - 1
            Ck[br][li, lj] = val
        end
    end

    function get_elem(i, j)
        br = div(i - 1, l) + 1
        bc = div(j - 1, l) + 1
        li = (i - 1) % l + 1
        lj = (j - 1) % l + 1
        if br == bc
            return Ak[br][li, lj]
        elseif br == bc + 1
            return Bk[br - 1][li, lj]
        elseif br == bc - 1
            return Ck[br][li, lj]
        end
        return 0.0
    end

    # ELIMINACJA
    for k in 1:n-1
        # Zakres wierszy (i) do eliminacji:
        # Ponieważ macierz jest pasmowa/blokowa, zerujemy tylko elementy pod przekątną,
        # które są niezerowe. Dolne pasmo ma szerokość ok. l.
        # Wiersz k znajduje się w bloku `curr_block_idx`.
        # Niezerowe elementy pod nim są w tym samym bloku (do końca bloku)
        # ORAZ w bloku poniżej (tylko w pewnym zakresie).
        # Heurystyka O(n): sprawdzamy tylko do k + l + 1 (lub do końca bloku B pod spodem).
        
        block_idx = div(k-1, l) + 1
        # Ostatni wiersz, który może być niezerowy w kolumnie k, to koniec następnego bloku wierszy
        max_row = min(n, (block_idx + 1) * l) 
        
        # Wybór elementu głównego
        if pivot
            pivot_row = k
            max_val = abs(get_elem(p[k], k))
            
            # Szukamy max tylko w dół w obrębie pasma
            for i in k+1:max_row
                val = abs(get_elem(p[i], k))
                if val > max_val
                    max_val = val
                    pivot_row = i
                end
            end
            
            if pivot_row != k
                p[k], p[pivot_row] = p[pivot_row], p[k]
                # Uwaga: przy zamianie wierszy zmieniamy tylko wskaźniki w p,
                # ale fizycznie nie przestawiamy wierszy w strukturze blokowej,
                # bo to zniszczyłoby strukturę.
                # W implementacji "sparse block" pivoting jest trudny bez fizycznej zamiany,
                # ponieważ struktura A zakłada, że poza pasmem są zera.
                # Jeśli pivot wyrzuci nam wiersz daleko, zniszczymy pasmo.
                # Jednak tutaj szukamy tylko w obrębie pasma (max_row), więc struktura
                # jest zachowana z dokładnością do lokalnych przesunięć.
                # Dostęp przez get_elem(p[i], ...) obsłuży to logicznie.
            end
        end

        # Właściwa eliminacja
        pivot_val = get_elem(p[k], k)
        
        if abs(pivot_val) < 1e-14
            # Dzielenie przez zero lub bliskie zeru - pomijamy lub błąd
            continue 
        end

        for i in k+1:max_row
            # Chcemy wyzerować A[p[i], k]
            val_ik = get_elem(p[i], k)
            if abs(val_ik) > 0.0
                m = val_ik / pivot_val
                # A[row i] = A[row i] - m * A[row k]
                
                # Aktualizacja b
                b[p[i]] -= m * b[p[k]]
                
                # Aktualizacja wiersza macierzy
                # Iterujemy j od k+1 tylko do zasięgu pasma
                # Pasmo górne sięga do końca następnego bloku (macierze C)
                # Czyli kolumna max to (block_idx + 1) * l
                max_col = min(n, (div(k-1, l) + 2) * l) # Zasięg C_k

                for j in k+1:max_col
                    val_kj = get_elem(p[k], j)
                    if abs(val_kj) > 0.0
                        curr = get_elem(p[i], j)
                        set_elem!(p[i], j, curr - m * val_kj)
                    end
                end
                
                # Teoretycznie powinniśmy wyzerować element pod przekątną:
                set_elem!(p[i], k, 0.0)
            end
        end
    end

    # PODSTAWIENIE WSTECZNE
    x = zeros(Float64, n)
    for k in n:-1:1
        # Suma znanych wyrazów: A[p[k], j] * x[j] dla j > k
        # Ponownie iterujemy j tylko w zakresie pasma
        block_idx = div(k-1, l) + 1
        max_col = min(n, (block_idx + 1) * l) # Zasięg C_k + A_k
        
        sum_ax = 0.0
        for j in k+1:max_col
            sum_ax += get_elem(p[k], j) * x[j]
        end
        
        x[k] = (b[p[k]] - sum_ax) / get_elem(p[k], k)
    end

    return x
end

end # module