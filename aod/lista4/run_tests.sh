#!/bin/bash

# Nazwa pliku wykonywalnego
PROGRAM="./zadanie2"

# Sprawdzenie czy plik istnieje
if [ ! -f "$PROGRAM" ]; then
    echo "Błąd: Nie znaleziono pliku $PROGRAM. Skompiluj kod używając: g++ -O3 zadanie2.cpp -o zadanie2"
    exit 1
fi

echo "Rozpoczynam eksperymenty dla k od 1 do 16..."
echo "--------------------------------------------------"
echo -e "k\ti\tWynik (Maks. Skojarzenie)\tCzas (stderr)"
echo "--------------------------------------------------"

for k in {1..16}
do
    # Losowanie i z zakresu [1, k] zgodnie z wymogiem i <= k [cite: 27]
    i=$(( ( RANDOM % k ) + 1 ))
    
    # Dynamiczne tworzenie nazwy pliku uwzględniającej wielkość k
    OUTPUT_FILE="matching_k${k}.txt"
    
    echo -n -e "$k\t$i\t"
    
    # Wykonanie programu:
    # --size k oraz --degree i [cite: 28]
    # --printMatching przekazuje nazwę pliku wygenerowaną powyżej 
    $PROGRAM --size "$k" --degree "$i" --printMatching "$OUTPUT_FILE" 2> >(read err; echo -e "\t$err")
done

echo "--------------------------------------------------"
echo "Eksperymenty zakończone. Pliki ze skojarzeniami zostały zapisane."