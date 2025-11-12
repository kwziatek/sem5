set Shifts;       # zmiany
set Districts;    # dzielnice

param min_shift{Shifts} >= 0;       # minimalna liczba radiowozów na zmianę
param min_district{Districts} >= 0; # minimalna liczba radiowozów na dzielnicę

param min_cars{Districts, Shifts} >= 0; # minimalne przypisanie dla danej zmiany/dzielnicy
param max_cars{Districts, Shifts} >= 0; # maksymalne przypisanie dla danej zmiany/dzielnicy

var x{d in Districts, s in Shifts} >= 0; # liczba radiowozów przydzielona do dzielnicy d ze zmiany s

# ----- Funkcja celu -----
minimize total_cars: sum{d in Districts, s in Shifts} x[d,s];

# ----- Ograniczenia -----

# 1) minimalna liczba radiowozów dla każdej dzielnicy i zmiany
s.t. district_min_limit{d in Districts, s in Shifts}:
    x[d,s] >= min_cars[d,s];

# 2) maksymalna liczba radiowozów dla każdej dzielnicy i zmiany
s.t. district_max_limit{d in Districts, s in Shifts}:
    x[d,s] <= max_cars[d,s];

# 2) minimalna liczba radiowozów dla każdej zmiany
s.t. shift_min{s in Shifts}:
    sum{d in Districts} x[d,s] >= min_shift[s];

# 3) minimalna liczba radiowozów dla każdej dzielnicy (łączna po wszystkich zmianach)
s.t. district_min{d in Districts}:
    sum{s in Shifts} x[d,s] >= min_district[d];

