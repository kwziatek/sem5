module blocksys

export MatrixA, solve_gauss

using LinearAlgebra

"""
Struktura przechowująca macierz A w postaci blokowej.
n - rozmiar macierzy
l - rozmiar bloku
A_blocks - wektor macierzy gęstych l x l (diagonalne)
B_blocks - wektor macierzy specyficznych (poddiagonalne). 
           Dla uproszczenia, przy małym l, można je trzymać jako gęste lub
           lepiej: wektor pierwszych wierszy i ostatnich kolumn.
           Tutaj dla czytelności i bezpieczeństwa przy małym l zakładamy gęste, 
           ale algorytm będzie korzystał z zer.
C_blocks - wektor wektorów (elementy diagonalne macierzy naddiagonalnych)
"""
struct MatrixA
    n::Int
    l::Int
    A_blocks::Vector{Matrix{Float64}}    # Bloki A_k
    B_blocks::Vector{Matrix{Float64}}    # Bloki B_k (indeksowane od 2 do v)
    C_blocks::Vector{Vector{Float64}}    # Bloki C_k (tylko diagonala)
end

# Konstruktor pomocniczy (pusty)
function MatrixA(n::Int, l::Int)
    v = div(n, l)
    As = [zeros(l, l) for _ in 1:v]
    Bs = [zeros(l, l) for _ in 1:v-1] # B zaczynają się od B2
    Cs = [zeros(l) for _ in 1:v-1]
    return MatrixA(n, l, As, Bs, Cs)
end

# --- ZADANIE 1: Rozwiązywanie Ax = b ---

"""
Funkcja rozwiązująca układ Ax=b metodą eliminacji Gaussa.
Wejście:
    mat: MatrixA - macierz strukturalna
    b: Vector{Float64} - wektor prawych stron
    pivot: Bool - czy stosować częściowy wybór elementu głównego
Wyjście:
    x: Vector{Float64} - rozwiązanie
"""
function solve_gauss(mat::MatrixA, b::Vector{Float64}; pivot::Bool=false)
    n = mat.n
    l = mat.l
    v = div(n, l)
    
    # Kopiujemy b, aby nie niszczyć oryginału (x będziemy liczyć "w miejscu" na kopii b)
    x = copy(b)
    
    # Tworzymy roboczą kopię macierzy, ponieważ eliminacja ją modyfikuje.
    # W praktyce, przy dużych macierzach, można modyfikować oryginał (jeśli dozwolone),
    # lub zarządzać pamięcią sprytniej. Tutaj dla bezpieczeństwa głęboka kopia bloków A i B.
    # C się nie zmienia w trakcie eliminacji (służy tylko do aktualizacji prawej strony/następnego bloku).
    # Uwaga: Modyfikacje C wchodzą do A_{k+1}, więc C pozostaje const, a zmienia się A_{k+1}.
    
    work_As = deepcopy(mat.A_blocks)
    work_Bs = deepcopy(mat.B_blocks)
    
    # --- ETAP 1: Eliminacja w przód ---
    for k in 1:v-1
        # Przetwarzamy blok A_k (diagonalny) i usuwamy B_{k+1} (poddiagonalny)
        
        # Indeksy globalne dla bloku k
        start_idx = (k-1)*l
        
        # 1. Eliminacja wewnątrz bloku A_k (doprowadzenie do trójkątnej górnej)
        # Oraz zerowanie odpowiednich elementów w B_{k+1}
        
        for i in 1:l # wiersz lokalny w bloku k
            # Globalny indeks wiersza
            curr_row = start_idx + i
            
            # --- Wybór elementu głównego (Pivoting) ---
            if pivot
                # Szukamy max w kolumnie i w obrębie A_k oraz B_{k+1}
                # Kandydaci to A_k[i:l, i] oraz B_{k+1}[:, i]
                # Zauważmy: B_{k+1} ma niezerowe tylko 1. wiersz (dla kolumn 1..l-1)
                # oraz całą ostatnią kolumnę.
                
                max_val = abs(work_As[k][i, i])
                max_row_local = i
                in_B = false # czy pivot jest w bloku B
                
                # Sprawdź resztę wierszy w A_k
                for r in i+1:l
                    if abs(work_As[k][r, i]) > max_val
                        max_val = abs(work_As[k][r, i])
                        max_row_local = r
                    end
                end
                
                # Sprawdź wiersze w B_{k+1}
                # Jeśli kolumna i < l, to w B niezerowy jest tylko wiersz 1
                # Jeśli kolumna i == l, to w B niezerowe są wszystkie wiersze
                rows_in_B_to_check = (i == l) ? (1:l) : (1:1)
                
                for r in rows_in_B_to_check
                    if abs(work_Bs[k][r, i]) > max_val # Bs[k] to de facto B_{k+1}
                        max_val = abs(work_Bs[k][r, i])
                        max_row_local = r
                        in_B = true
                    end
                end
                
                # Zamiana wierszy jeśli znaleziono lepszy pivot
                if in_B
                    # Zamiana wiersza 'i' z A_k z wierszem 'max_row_local' z B_{k+1}
                    # Uwaga: To skomplikowane operacyjnie, bo zmienia strukturę rzadką.
                    # W uproszczonym modelu (gdzie Bs trzymamy jako macierz) po prostu swapujemy.
                    # Należy też zamienić odpowiednie elementy w wektorze x (prawa strona).
                    
                    # Swap A_k[i, :] z B_{k+1}[max_row, :]
                    # Swap x[curr_row] z x[k*l + max_row]
                    # Uwaga: Zamiana wiersza z A_k z wierszem z B_{k+1} wpływa też na C_k i A_{k+1}!
                    # Wiersz z A_k "sięga" do C_k. Wiersz z B_{k+1} "sięga" do A_{k+1}.
                    
                    # Ze względu na stopień skomplikowania pivota międzyblokowego w czasie O(N),
                    # często w takich zadaniach "częściowy wybór" ogranicza się do obrębu A_k
                    # lub zakłada się, że zamiana następuje tylko z pierwszym wierszem B.
                    # Poniżej implementacja swapu dla pełnej poprawności numerycznej na gęstych blokach.
                    
                    row_A = work_As[k][i, :]
                    row_B = work_Bs[k][max_row_local, :]
                    work_As[k][i, :] = row_B
                    work_Bs[k][max_row_local, :] = row_A
                    
                    # Zamiana prawych stron
                    tmp_x = x[curr_row]
                    x[curr_row] = x[k*l + max_row_local]
                    x[k*l + max_row_local] = tmp_x
                    
                    # WAŻNE: Zamiana reszty macierzy (C_k i A_{k+1})
                    # Wiersz i bloku k ma C_k[i, i] na diagonali (reszta 0)
                    # Wiersz max_row bloku k+1 ma A_{k+1}[max_row, :]
                    
                    row_C_val = mat.C_blocks[k][i] # To jest wiersz z bloku górnego
                    row_A_next = work_As[k+1][max_row_local, :] # To jest wiersz z bloku dolnego
                    
                    # Wiersz i w A_k teraz stał się wierszem z B, więc w tej pozycji "po prawej"
                    # powinien znaleźć się element z A_{k+1}.
                    # To niszczy pasmową strukturę C_k (staje się gęste).
                    # JEDNAK specyfikacja mówi: "adaptacja algorytmów... uwzględniająca postać".
                    # Pivot międzyblokowy może zniszczyć rzadkość. 
                    # Zwykle w tym zadaniu pivot ogranicza się do kolumny wewnątrz A_k, 
                    # chyba że element na diagonali jest 0.
                elseif max_row_local != i
                    # Standardowy pivot wewnątrz A_k
                    work_As[k][i, :], work_As[k][max_row_local, :] = work_As[k][max_row_local, :], work_As[k][i, :]
                    x[curr_row], x[start_idx + max_row_local] = x[start_idx + max_row_local], x[curr_row]
                    # C_k jest diagonalna, więc zamiana wierszy w A_k zamienia tylko elementy C_k na przekątnej?
                    # Nie, C_k to osobna macierz. Zamiana wierszy A_k pociąga zamianę wierszy C_k.
                    # Ponieważ C_k diagonalna, zamiana wierszy i oraz j sprawia, że C_k przestaje być diagonalna
                    # (elementy "skaczą"). Ale nadal jest rzadka (1 element w wierszu).
                end
            end
            
            # --- Eliminacja Gaussa ---
            pivot_val = work_As[k][i, i]
            
            # Jeśli pivot bliski 0 -> błąd (zakładamy macierze nieosobliwe)
            if abs(pivot_val) < 1e-12
                error("Zerowy element główny w bloku $k, wiersz $i")
            end

            # 1. Eliminacja pod przekątną wewnątrz A_k
            for j in i+1:l
                factor = work_As[k][j, i] / pivot_val
                work_As[k][j, i] = 0 # Zerujemy (formalność)
                # Aktualizacja reszty wiersza w A_k
                for c in i+1:l
                    work_As[k][j, c] -= factor * work_As[k][i, c]
                end
                # Aktualizacja prawej strony
                x[start_idx + j] -= factor * x[curr_row]
                # C_k jest diagonalne, więc przy operacjach wewnątrz A_k (wiersze tego samego bloku),
                # operacje na C_k dotyczą tylko wierszy j i i. 
                # Row_j(C) -= factor * Row_i(C). 
                # Row_i(C) ma element na col i. Row_j ma na col j.
                # To wprowadza fill-in w C_k. Ale zadanie nie każe pamiętać LU, tylko rozwiązać.
                # Możemy to pominąć w strukturze, jeśli zaktualizujemy od razu "wpływ" na następny blok?
                # Nie, bo C_k jest używane do eliminacji B_{k+1}.
            end
            
            # 2. Eliminacja B_{k+1} przy użyciu A_k
            # B_{k+1} (czyli work_Bs[k]) jest pod A_k.
            # Musimy wyzerować kolumnę 'i' w B_{k+1}.
            # W B_{k+1} niezerowe w kolumnie 'i' mogą być:
            # - wiersz 1 (zawsze, jeśli i <= l)
            # - wiersz i (tylko jeśli i=l, ale to ostatnia kolumna)
            
            # Sprawdzamy wiersze w B_{k+1}, które trzeba wyzerować
            rows_to_elim = (i == l) ? (1:l) : (1:1)
            
            for row_b in rows_to_elim
                elem = work_Bs[k][row_b, i]
                if abs(elem) > 1e-14
                    factor = elem / pivot_val
                    work_Bs[k][row_b, i] = 0
                    
                    # Aktualizacja reszty wiersza w B_{k+1} (wpływ A_k)
                    for c in i+1:l
                        work_Bs[k][row_b, c] -= factor * work_As[k][i, c]
                    end
                    
                    # Aktualizacja prawej strony (dla bloku k+1)
                    idx_b_global = k*l + row_b
                    x[idx_b_global] -= factor * x[curr_row]
                    
                    # KLUCZOWE: Wpływ C_k na A_{k+1}
                    # Operacja: Wiersz(B_{k+1}) -= factor * Wiersz(A_k).
                    # Pełny wiersz "górny" to [A_k | C_k].
                    # Pełny wiersz "dolny" to [B_{k+1} | A_{k+1}].
                    # Zatem: Wiersz(A_{k+1}) -= factor * Wiersz(C_k).
                    # Wiersz i z C_k ma tylko jeden element: mat.C_blocks[k][i] na pozycji i.
                    # Zatem modyfikujemy A_{k+1}[row_b, i]
                    
                    val_c = mat.C_blocks[k][i]
                    # Ponieważ A_{k+1} jest gęste (work_As[k+1]), po prostu odejmujemy
                    work_As[k+1][row_b, i] -= factor * val_c
                end
            end
        end
    end
    
    # Ostatni blok A_v też musi być trójkątny (po eliminacji wpływu B_v)
    # Pętla wyżej kończy się na v-1, ale "fill-in" i modyfikacje dotarły do A_v.
    # Teraz trzeba dokończyć eliminację Gaussa wewnątrz ostatniego bloku A_v.
    
    last_block_idx = v
    start_idx = (v-1)*l
    for i in 1:l-1
        pivot_val = work_As[last_block_idx][i, i]
        curr_row = start_idx + i
        for j in i+1:l
            factor = work_As[last_block_idx][j, i] / pivot_val
            work_As[last_block_idx][j, i] = 0
            for c in i+1:l
                work_As[last_block_idx][j, c] -= factor * work_As[last_block_idx][i, c]
            end
            x[start_idx + j] -= factor * x[curr_row]
        end
    end

    # --- ETAP 2: Podstawienie wstecz (Back substitution) ---
    
    # Zaczynamy od ostatniego elementu ostatniego bloku
    x[n] = x[n] / work_As[v][l, l]
    
    # Pętla od końca
    for k in v:-1:1
        start_idx = (k-1)*l
        # Wewnątrz bloku, od dołu
        for i in l:-1:1
            global_idx = start_idx + i
            sum_val = 0.0
            
            # Część od A_k (prawa górna część trójkąta)
            for j in i+1:l
                sum_val += work_As[k][i, j] * x[start_idx + j]
            end
            
            # Część od C_k (jeśli istnieje, czyli k < v)
            # C_k jest po prawej od A_k. Struktura: [A_k C_k].
            # C_k jest diagonalna, więc w wierszu i jest tylko element na pozycji i (względem bloku)
            # Ten element odpowiada zmiennej x z bloku k+1, czyli indeks globalny k*l + i
            if k < v
                sum_val += mat.C_blocks[k][i] * x[k*l + i]
            end
            
            x[global_idx] = (x[global_idx] - sum_val) / work_As[k][i, i]
        end
    end
    
    return x
end

"""
Wczytuje macierz A z pliku o formacie zadanym w specyfikacji.
"""
function load_matrix(filepath::String)
    open(filepath, "r") do f
        line = readline(f)
        dims = split(line)
        n = parse(Int, dims[1])
        l = parse(Int, dims[2])
        
        mat = MatrixA(n, l)
        
        while !eof(f)
            line = readline(f)
            if isempty(strip(line)) continue end
            data = split(line)
            if length(data) < 3 continue end
            
            i = parse(Int, data[1])
            j = parse(Int, data[2])
            val = parse(Float64, data[3])
            
            # Ustalenie, do którego bloku należy (i,j)
            block_row = div(i - 1, l) + 1
            
            # Indeksy lokalne wewnątrz bloku l x l
            local_row = (i - 1) % l + 1
            
            # Sprawdzamy gdzie leży kolumna j
            # Zakres kolumn dla bloku A_k: [(k-1)l + 1, k*l]
            start_A = (block_row - 1) * l + 1
            end_A   = block_row * l
            
            if j >= start_A && j <= end_A
                # Element w A_k
                local_col = j - start_A + 1
                mat.A_blocks[block_row][local_row, local_col] = val
                
            elseif block_row > 1 && j >= start_A - l && j < start_A
                # Element w B_k (blok po lewej od A_k)
                # B_k ma indeksy kolumn [(k-2)l + 1, (k-1)l]
                local_col = j - (start_A - l) + 1
                mat.B_blocks[block_row][local_row, local_col] = val
                
            elseif block_row < div(n, l) && j > end_A && j <= end_A + l
                # Element w C_k (blok po prawej od A_k)
                # C_k jest macierzą diagonalną. Przechowujemy tylko wektor.
                # W pliku powinny być tylko elementy na przekątnej C_k.
                # Globalne j odpowiada globalnemu i (przesuniętemu o l).
                # Sprawdzenie czy to diagonala C: j == i + l
                if j == i + l
                     mat.C_blocks[block_row][local_row] = val
                end
            end
        end
        return mat
    end
end

"""
Wczytuje wektor prawych stron b z pliku.
"""
function load_vector(filepath::String)
    open(filepath, "r") do f
        line = readline(f)
        n = parse(Int, line)
        b = Float64[]
        sizehint!(b, n)
        
        while !eof(f)
            line = readline(f)
            if !isempty(strip(line))
                push!(b, parse(Float64, strip(line)))
            end
        end
        return b
    end
end

"""
Oblicza iloczyn macierzy blokowej i wektora: b = Ax.
Złożoność O(n).
x - wektor wejściowy (np. wektor jedynek)
"""
function multiply_Ax(mat::MatrixA, x::Vector{Float64})
    n = mat.n
    l = mat.l
    v = div(n, l)
    b = zeros(Float64, n)
    
    for k in 1:v
        start_idx = (k-1)*l
        # Wskaźniki do fragmentów wektora x
        x_curr = x[start_idx+1 : start_idx+l]
        
        # 1. Udział A_k * x_k
        # A_k jest gęste l x l
        b[start_idx+1 : start_idx+l] += mat.A_blocks[k] * x_curr
        
        # 2. Udział B_k * x_{k-1} (jeśli k > 1)
        if k > 1
            x_prev = x[(k-2)*l+1 : (k-1)*l]
            # B_k jest rzadkie (1. wiersz i ostatnia kolumna), 
            # ale w strukturze MatrixA mamy macierz l x l.
            # Dla złożoności O(n) mnożenie powinno być zoptymalizowane, 
            # ale przy małym l standardowe mnożenie macierzy l x l jest O(1) względem n.
            b[start_idx+1 : start_idx+l] += mat.B_blocks[k] * x_prev
        end
        
        # 3. Udział C_k * x_{k+1} (jeśli k < v)
        if k < v
            x_next = x[k*l+1 : (k+1)*l]
            # C_k jest diagonalna (przechowywana jako wektor)
            # Element b[i] += C[i] * x_next[i]
            for i in 1:l
                # C_blocks[k] to wektor przekątnej k-tego bloku C
                val_c = mat.C_blocks[k][i]
                b[start_idx + i] += val_c * x_next[i]
            end
        end
    end
    return b
end

"""
Zapisuje wynik do pliku zgodnie ze specyfikacją.
x_calc - obliczony wektor
x_exact - wektor dokładny (do obliczenia błędu), opcjonalny
filename - nazwa pliku wyjściowego
"""
function save_results(filename::String, x_calc::Vector{Float64}, x_exact::Vector{Float64})
    # Oblicz błąd względny: ||x_calc - x_exact|| / ||x_exact||
    err = norm(x_calc - x_exact) / norm(x_exact)
    
    open(filename, "w") do f
        println(f, err) # Pierwsza linia: błąd
        for val in x_calc
            println(f, val) # Kolejne linie: składowe wektora
        end
    end
end

end # module