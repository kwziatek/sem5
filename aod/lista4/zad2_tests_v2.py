import subprocess
import re
import matplotlib.pyplot as plt
import os
from collections import defaultdict

# ================= KONFIGURACJA =================
# Zakres k zgodnie z zadaniem: od 3 do 10 [cite: 31]
K_VALUES = range(3, 11) 
REPETITIONS = 10  # Liczba powtórzeń dla uśrednienia wyniku
EXECUTABLE = "./zadanie2"
OUTPUT_DIR = "wykresy_czasu"
# ================================================

def run_cpp_program(k, i):
    """Uruchamia program C++ i zwraca wielkość skojarzenia oraz czas wykonania."""
    cmd = [EXECUTABLE, "--size", str(k), "--degree", str(i)]
    
    # Uruchamiamy proces, przechwytując stdout i stderr
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    # Parsowanie wyjścia standardowego (wynik skojarzenia)
    match_output = re.search(r"Maksymalne skojarzenie:\s*(\d+)", result.stdout)
    matching_size = int(match_output.group(1)) if match_output else 0
    
    # Parsowanie wyjścia błędów (czas wykonania)
    match_time = re.search(r"Czas pracy:\s*([0-9.]+)", result.stderr)
    duration = float(match_time.group(1)) if match_time else 0.0
    
    return matching_size, duration

def main():
    if not os.path.exists(EXECUTABLE):
        print(f"Błąd: Nie znaleziono pliku {EXECUTABLE}. Skompiluj kod C++.")
        return

    # Tworzenie katalogu na wykresy
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Rozpoczynam eksperymenty. Wykresy trafią do folderu '{OUTPUT_DIR}/'.")
    
    # Przechowywanie wyników: results_time[i][k] = średni czas
    results_time = defaultdict(dict)
    
    # --- ZBIERANIE DANYCH ---
    total_iterations = sum(k * REPETITIONS for k in K_VALUES)
    current_iter = 0

    for k in K_VALUES:
        # i zmienia się od 1 do k [cite: 31]
        for i in range(1, k + 1):
            sum_time = 0
            
            for _ in range(REPETITIONS):
                _, duration = run_cpp_program(k, i)
                sum_time += duration
                
                current_iter += 1
                # Wyświetlanie postępu
                percent = (current_iter / total_iterations) * 100
                print(f"\rPostęp: {percent:.1f}% (k={k}, i={i})", end="")

            avg_time = sum_time / REPETITIONS
            results_time[i][k] = avg_time

    print("\n\nZakończono pomiary. Generowanie osobnych wykresów dla każdego 'i'...")

    # --- GENEROWANIE WYKRESÓW ---
    # Znajdź wszystkie unikalne wartości i, jakie wystąpiły w eksperymencie
    all_i_values = sorted(results_time.keys())

    for i in all_i_values:
        # Pobierz dane dla konkretnego i
        data_for_i = results_time[i]
        
        # Sortujemy po k, aby wykres był linią
        ks = sorted(data_for_i.keys())
        times = [data_for_i[k] for k in ks]
        
        # Jeśli mamy mniej niż 2 punkty, wykres liniowy może wyglądać dziwnie, ale narysujemy go z markerami
        plt.figure(figsize=(8, 6))
        plt.plot(ks, times, marker='o', linestyle='-', color='b', label=f'i = {i}')
        
        plt.title(f"Czas działania w zależności od k (dla stopnia i={i})")
        plt.xlabel("Rozmiar k (Wierzchołków: 2*2^k)")
        plt.ylabel("Średni czas wykonania [s]")
        plt.grid(True, which="both", ls="--")
        
        # Opcjonalnie: skala logarytmiczna, jeśli czasy rosną bardzo szybko
        # plt.yscale('log') 
        
        plt.legend()
        
        # Zapis do pliku
        filename = os.path.join(OUTPUT_DIR, f"czas_stopien_{i}.png")
        plt.savefig(filename)
        plt.close() # Zamknij figurę, aby zwolnić pamięć
        
        print(f"Wygenerowano: {filename}")

    print("\nGotowe. Wszystkie wykresy zostały zapisane.")

if __name__ == "__main__":
    main()