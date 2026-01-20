import subprocess
import matplotlib.pyplot as plt
import numpy as np

K_RANGE = range(1, 17)
REPETITIONS = 5 # Można zwiększyć dla lepszej statystyki

avg_flows = []
avg_paths = []
avg_times = []

for k in K_RANGE:
    flows, paths, times = [], [], []
    print(f"Testowanie k={k}...")
    
    for _ in range(REPETITIONS):
        # Uruchomienie skompilowanego programu ./zad1
        process = subprocess.Popen(['./zad1', '--size', str(k)], 
                                   stdout=subprocess.PIPE, 
                                   stderr=subprocess.PIPE, 
                                   text=True)
        stdout, stderr = process.communicate()
        
        # Parsowanie wyników
        flow = int(stdout.split(":")[1].strip())
        err_lines = stderr.strip().split('\n')
        exec_time = float(err_lines[0])
        path_count = int(err_lines[1])
        
        flows.append(flow)
        times.append(exec_time)
        paths.append(path_count)
        
    avg_flows.append(np.mean(flows))
    avg_times.append(np.mean(times))
    avg_paths.append(np.mean(paths))

# Generowanie wykresów
plt.figure(figsize=(12, 12))

# 1. Średni przepływ
plt.subplot(3, 1, 1)
plt.plot(list(K_RANGE), avg_flows, marker='o', color='blue')
plt.title("Średnia wielkość maksymalnego przepływu od k")
plt.xlabel("k")
plt.ylabel("Przepływ")
plt.grid(True)

# 2. Liczba ścieżek powiększających
plt.subplot(3, 1, 2)
plt.plot(list(K_RANGE), avg_paths, marker='s', color='green')
plt.title("Średnia liczba ścieżek powiększających od k")
plt.xlabel("k")
plt.ylabel("Liczba ścieżek")
plt.grid(True)

# 3. Czas działania
plt.subplot(3, 1, 3)
plt.plot(list(K_RANGE), avg_times, marker='^', color='red')
plt.title("Średni czas działania od k")
plt.xlabel("k")
plt.ylabel("Czas [s]")
plt.grid(True)
plt.yscale('log') # Skala logarytmiczna dla czasu przy k=16

plt.tight_layout()
plt.savefig("zad1_wyniki.png")
plt.show()