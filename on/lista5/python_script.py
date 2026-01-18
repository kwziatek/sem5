import matplotlib.pyplot as plt

# Przygotowanie danych
n_values = [16, 10000, 50000, 100000, 500000, 1000000] # poprawione ostatnie n

# Dane surowe (pary: wykres1, wykres2)
raw_data = [
    (9.646809571707696e-16, 6.894341957538586e-16),
    (5.215827297052513e-16, 2.365546464294078e-14),
    (5.054032266947501e-16, 9.65475836554891e-14),
    (4.749019704488779e-16, 3.115066768812978e-13),
    (4.37358491350195e-16, 7.6310749713549e-13),
    (4.175695651834823e-16, 8.630624480114938e-14)
]

# Rozdzielenie danych na dwie listy
y1 = [val[0] for val in raw_data]
y2 = [val[1] for val in raw_data]

# Tworzenie wykresu
plt.figure(figsize=(10, 6))

plt.plot(n_values, y1, 'o-', label='z pivotem', color='blue')
plt.plot(n_values, y2, 's-', label='bez pivotu', color='red')

# Ustawienie skali logarytmicznej (kluczowe przy tak małych/dużych wartościach)
plt.xscale('log')
plt.yscale('log')

# Dodanie opisów
plt.title('Błąd względny algorytmu eliminacji Gaussa w zależności od rozmiaru macierzy')
plt.xlabel('rozmiar macierzy n (skala logarytmiczna)')
plt.ylabel('Wartość błędu względnego(skala logarytmiczna)')
plt.grid(True, which="both", ls="-", alpha=0.5)
plt.legend()

# Wyświetlenie wykresu
plt.savefig('comparison_plot.png')