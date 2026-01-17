# Karol Wziątek 279734

# ========================================================
# PRZYKŁAD UŻYCIA I TESTY
# ========================================================

using .blocksys
using LinearAlgebra

# Nazwy plików (przykładowe)
FILE_A = "input_A.txt"
FILE_B = "input_B.txt" 
CALCULATED_B = "calculated_B.txt"
FILE_X_NO_PIVOT = "x_without_pivot.txt"
FILE_X_PIVOT = "x_with_pivot.txt"
FILE_X_NO_PIVOT_CAL_B = "x_wihtout_pivot_cal_B.txt"
FILE_X_PIVOT_CAL_B = "x_with_pivot_cal_B.txt"

# 1. Funkcja generująca przykładowe dane testowe
# Tworzy plik input_A.txt w zadanym formacie dla n=16, l=4
function generate_test_data_files()
    open("A.txt", "w") do f
        n = 16
        l = 4
        println(f, "$n $l")
        # Generowanie bloków diagonalnych A (pełne)
        for k in 1:div(n,l)
            offset = (k-1)*l
            for i in 1:l, j in 1:l
                # Dominująca przekątna
                val = (i==j) ? 10.0 : 1.0
                println(f, "$(offset+i) $(offset+j) $val")
            end
        end
        # Generowanie bloków C (naddiagonalne - diagonalne)
        for k in 1:div(n,l)-1
            row_offset = (k-1)*l
            col_offset = k*l
            for i in 1:l
                println(f, "$(row_offset+i) $(col_offset+i) 0.5")
            end
        end
        # Generowanie bloków B (poddiagonalne - specyficzne: wiersz 1, kolumna ostatnia)
        for k in 2:div(n,l)
            row_offset = (k-1)*l
            col_offset = (k-2)*l
            # Cały pierwszy wiersz bloku B
            for j in 1:l
                println(f, "$(row_offset+1) $(col_offset+j) 0.2")
            end
            # Ostatnia kolumna bloku B (poza elementem [1,l] który już był)
            for i in 2:l
                println(f, "$(row_offset+i) $(col_offset+l) 0.2")
            end
        end
    end
    println("Wygenerowano plik A.txt")
end

# Uruchomienie generowania danych testowych
generate_test_data_files()

# ----------------------------------------------------------
# SCENARIUSZ 1: Obliczanie prawej strony i rozwiązywanie
# ----------------------------------------------------------
println("\n=== SCENARIUSZ 1: Obliczanie b i rozwiązywanie w pamięci ===")

# 1. Wczytanie A i generowanie b na podstawie x=(1...1)
println("\n[1] Wczytanie macierzy A z pliku...")
A = load_matrix(FILE_A)
x_exact = ones(Float64, A.n) # Dokładny wynik to same jedynki

println("[1] Obliczanie wektora prawych stron b = Ax...")
b_computed = compute_rhs(A, x_exact)

# ZAPISUJEMY obliczone b do pliku calculated_B.txt 
open(CALCULATED_B, "w") do f
    println(f, A.n)
    for val in b_computed
        println(f, val)
    end
end
println("-> Zapisano wektor b do pliku: $CALCULATED_B")

# 2. Rozwiązanie Ax = b (bez wyboru elementu) - dane w pamięci
println("\n[2] Rozwiązywanie Gauss (bez pivotu, dane w pamięci)...")
x_sol_1 = solve_gauss(A, b_computed, pivot=false)
err_1 = norm(x_sol_1 - x_exact) / norm(x_exact)

save_solution(FILE_X_NO_PIVOT_CAL_B, x_sol_1, err_1)
println("-> Błąd względny: $err_1")

# 3. Rozwiązanie Ax = b (z wyborem elementu) - dane w pamięci
println("\n[3] Rozwiązywanie Gauss (z pivotem, dane w pamięci)...")
x_sol_2 = solve_gauss(A, b_computed, pivot=true)
err_2 = norm(x_sol_2 - x_exact) / norm(x_exact)

save_solution(FILE_X_PIVOT_CAL_B, x_sol_2, err_2)
println("-> Błąd względny: $err_2")


# -----------------------------------------------------------
# SCENARIUSZ 2: Wczytywanie A i b z plików i rozwiązywanie
# -----------------------------------------------------------
println("\n=== SCENARIUSZ 2: Wczytywanie A i b z plików ===")

# 4. Wczytanie zarówno macierzy A jak i wektora b z plików
println("\n[4] Wczytywanie macierzy A i wektora b z dysku...")
A_from_file = load_matrix(FILE_A)
b_from_file = load_vector(FILE_B)

println("-> Wczytano A: rozmiar $(A_from_file.n)")
println("-> Wczytano b: rozmiar $(length(b_from_file))")

# 5. Rozwiązanie wczytanego układu (BEZ wyboru elementu głównego)
println("\n[5] Rozwiązywanie wczytanego układu (BEZ pivotu)...")
t5_start = time()
x_file_no_pivot = solve_gauss(A_from_file, b_from_file, pivot=false)
t5_end = time()

# Weryfikacja (znając x_exact z generatora)
# err_file_no = norm(x_file_no_pivot - x_exact) / norm(x_exact)
save_solution(FILE_X_NO_PIVOT, x_file_no_pivot, 0)

println("-> Czas obliczeń: $(round(t5_end - t5_start, digits=4))s")
# println("-> Błąd względny: $err_file_no")
println("-> Wynik zapisano do: $FILE_X_NO_PIVOT")

# 6. Rozwiązanie wczytanego układu (Z częściowym WYBOREM elementu głównego)
println("\n[6] Rozwiązywanie wczytanego układu (Z pivotem)...")
t6_start = time()
x_file_pivot = solve_gauss(A_from_file, b_from_file, pivot=true)
t6_end = time()

# Weryfikacja
# err_file_pivot = norm(x_file_pivot - x_exact) / norm(x_exact)
save_solution(FILE_X_PIVOT, x_file_pivot, 0)

println("-> Czas obliczeń: $(round(t6_end - t6_start, digits=4))s")
# println("-> Błąd względny: $err_file_pivot")
println("-> Wynik zapisano do: $FILE_X_PIVOT")

println("\nTesty zakończone pomyślnie.")