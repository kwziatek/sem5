set N;                  # zbiór wierzchołków (miast)
set A within {N,N};     # zbiór łuków (połączeń)

param c{A} >= 0;        # koszt przejazdu
param t{A} >= 0;        # czas przejazdu
param i0 symbolic;      # miasto początkowe
param j0 symbolic;      # miasto docelowe
param T_max >= 0;       # maksymalny dopuszczalny czas

var x{A} binary;        # 1 jeśli łuk jest częścią ścieżki, 0 wpp

# ----- Ograniczenia -----

# Bilans przepływu (warunek ścieżki)
s.t. flow_balance{i in N}:
    sum{(i,j) in A} x[i,j] - sum{(j,i) in A} x[j,i] =
        (if i = i0 then 1 else if i = j0 then -1 else 0);

# Ograniczenie czasu całkowitego
s.t. time_limit:
    sum{(i,j) in A} t[i,j] * x[i,j] <= T_max;

# ----- Funkcja celu -----
minimize total_cost:
    sum{(i,j) in A} c[i,j] * x[i,j];

# ----- Wyświetlanie wyniku -----
solve;

end;
