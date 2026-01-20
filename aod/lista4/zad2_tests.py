import subprocess
import re
import matplotlib.pyplot as plt
import time
from collections import defaultdict

# KONFIGURACJA EKSPERYMENTU
# Zgodnie z treścią zadania k od 3 do 10 
K_VALUES = range(3, 11) 
REPETITIONS = 10  # Liczba powtórzeń dla każdego punktu pomiarowego (im więcej, tym dokładniejsza średnia)
EXECUTABLE = "./zadanie2"

def run_cpp_program(k, i):
    """Uruchamia program C++ i zwraca wielkość skojarzenia oraz czas wykonania."""
    cmd = [EXECUTABLE, "--size", str(k), "--degree", str(i)]
    
    # Uruchamiamy proces
    # capture_output=True przechwytuje stdout i stderr
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    # Parsowanie wyjścia standardowego (stdout) dla wyniku
    # Szukamy liczby po "Maksymalne skojarzenie:"
    match_output = re.search(r"Maksymalne skojarzenie:\s*(\d+)", result.stdout)
    matching_size = int(match_output.group(1)) if match_output else 0
    
    # Parsowanie wyjścia błędów (stderr) dla czasu
    # Szukamy liczby po "Czas pracy:"
    match_time = re.search(r"Czas pracy:\s*([0-9.]+)", result.stderr)
    duration = float(match_time.group(1)) if match_time else 0.0
    
    return matching_size, duration

def main():
    print(f"Rozpoczynam eksperymenty. Powtórzeń na każdy punkt: {REPETITIONS}")
    
    # Słowniki do przechowywania wyników
    # results_matching[k][i] = średnia wielkość
    results_matching = defaultdict(dict)
    # results_time[i][k] = średni czas (zgodnie z wymogiem wykresu dla każdego i w zależności od k)
    results_time = defaultdict(dict)

    total_iterations = sum(k * REPETITIONS for k in K_VALUES)
    current_iter = 0

    for k in K_VALUES:
        # i zmienia się od 1 do k 
        for i in range(1, k + 1):
            sum_matching = 0
            sum_time = 0
            
            for _ in range(REPETITIONS):
                m_size, duration = run_cpp_program(k, i)
                sum_matching += m_size
                sum_time += duration
                
                current_iter += 1
                print(f"\rPostęp: {current_iter}/{total_iterations} (k={k}, i={i})", end="")

            avg_matching = sum_matching / REPETITIONS
            avg_time = sum_time / REPETITIONS
            
            results_matching[k][i] = avg_matching
            results_time[i][k] = avg_time

    print("\nGenerowanie wykresów...")

    # WYKRES 1: Wielkość skojarzenia w zależności od i (dla każdego k osobna seria) 
    plt.figure(figsize=(10, 6))
    for k in K_VALUES:
        x_vals = sorted(results_matching[k].keys())
        y_vals = [results_matching[k][x] for x in x_vals]
        plt.plot(x_vals, y_vals, marker='o', label=f'k={k} (V={2**k})')
    
    plt.title("Średnia wielkość maksymalnego skojarzenia w zależności od stopnia i")
    plt.xlabel("Stopień wierzchołka i (zbiór V1)")
    plt.ylabel("Średnia wielkość skojarzenia")
    plt.legend()
    plt.grid(True)
    plt.savefig("wykres_skojarzenia.png")
    print("Zapisano: wykres_skojarzenia.png")

    # WYKRES 2: Czas działania w zależności od k (dla wybranych i osobna seria) 
    # Rysujemy tylko dla kilku wybranych i, żeby wykres był czytelny (np. i=1, 2, 3, k/2, k)
    # Tutaj weźmiemy i=1, 2, 3 jako stałe wartości
    plt.figure(figsize=(10, 6))
    selected_degrees = [1, 2, 3]
    
    for i in selected_degrees:
        # Zbieramy dane tylko tam, gdzie i <= k (zawsze prawda dla małych i)
        x_vals = []
        y_vals = []
        for k in K_VALUES:
            if k in results_time[i]:
                x_vals.append(k)
                y_vals.append(results_time[i][k])
        
        if x_vals:
            plt.plot(x_vals, y_vals, marker='s', linestyle='--', label=f'degree i={i}')

    plt.title("Średni czas działania programu w zależności od k")
    plt.xlabel("Parametr k (rozmiar grafu)")
    plt.ylabel("Czas [s]")
    plt.legend()
    plt.grid(True)
    plt.yscale('log') # Skala logarytmiczna dla czasu jest zazwyczaj lepsza przy wykładniczym wzroście
    plt.savefig("wykres_czasu.png")
    print("Zapisano: wykres_czasu.png")

if __name__ == "__main__":
    main()