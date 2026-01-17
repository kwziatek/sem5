# Załóżmy, że kod modułu jest w pliku blocksys.jl
include("blocksys.jl")
include("matrixgen.jl")
using .blocksys

# --- DANE ---
# Pliki wygenerowane np. przez matrixgen (lub przykładowe)
file_A = matrixgen(10, 4.5) 
# file_b = "b.txt" # Opcja 1: mamy plik z b
output_file = "wyniki.txt"

# 1. Wczytanie macierzy A
println("Wczytywanie macierzy A...")
A = blocksys.load_matrix(file_A)
n = A.n

# 2. Generowanie wektora prawych stron (Opcja z listy nr 2 [cite: 81])
# Zakładamy, że dokładne rozwiązanie to wektor jedynek
println("Generowanie b = Ax dla x = [1, ..., 1]...")
x_exact = ones(Float64, n)
b = blocksys.multiply_Ax(A, x_exact)

# (Alternatywnie: wczytanie b z pliku)
# b = blocksys.load_vector(file_b)

# 3. Rozwiązanie układu Ax = b
println("Rozwiązywanie układu (Eliminacja Gaussa)...")
# Wariant bez wyboru elementu głównego (false) lub z wyborem (true)
x_calc = blocksys.solve_gauss(A, b, pivot=true)

# 4. Weryfikacja i zapis
println("Zapisywanie wyników...")
blocksys.save_results(output_file, x_calc, x_exact)

println("Gotowe. Wyniki w pliku $output_file")