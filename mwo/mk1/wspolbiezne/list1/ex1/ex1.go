package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// Stałe konfiguracyjne
const (
	Nr_Of_Travelers = 15
	Min_Steps       = 10
	Max_Steps       = 100
	Min_Delay       = 10 * time.Millisecond
	Max_Delay       = 50 * time.Millisecond
	Board_Width     = 15
	Board_Height    = 15
)

// Struktura do przekazywania informacji o zdarzeniach
type Event struct {
	Timestamp int64
	ID        int
	X         int
	Y         int
	Symbol    string
}

func main() {
	// Kanał do komunikacji z printerem
	events := make(chan Event)
	var wg sync.WaitGroup

	// Wątek printera
	go func() {
		for event := range events {
			fmt.Printf("%d %d %d %d %s\n",
				event.Timestamp,
				event.ID,
				event.X,
				event.Y,
				event.Symbol)
		}
		fmt.Println("exiting for loop")
	}()

	// Nagłówek z parametrami
	fmt.Printf("-1 %d %d %d\n",
		Nr_Of_Travelers,
		Board_Width,
		Board_Height)

	// Uruchamianie podróżników
	for id := 0; id < Nr_Of_Travelers; id++ {
		wg.Add(1)
		go traveler(id, events, &wg)
	}

	// Oczekiwanie na zakończenie wszystkich podróżników
	wg.Wait()
	fmt.Println("wait group stopped waiting")
	close(events)
	time.Sleep(time.Millisecond * 100)
}

func traveler(id int, events chan<- Event, wg *sync.WaitGroup) {
	defer wg.Done()

	// Inicjalizacja generatora liczb losowych
	src := rand.NewSource(time.Now().UnixNano() + int64(id))
	r := rand.New(src)

	// Początkowa pozycja
	x := r.Intn(Board_Width)
	y := r.Intn(Board_Height)

	// Liczba kroków do wykonania
	steps := Min_Steps + r.Intn(Max_Steps-Min_Steps+1)

	// Symbol podróżnika
	symbol := string('A' + id)

	// Dostępne kierunki ruchu (4 kierunki)
	directions := [][2]int{
		{-1, 0},
		{0, -1}, {0, 1},
		{1, 0},
	}

	for i := 0; i < steps; i++ {
		// Losowe opóźnienie
		delay := Min_Delay + time.Duration(r.Float64()*float64(Max_Delay-Min_Delay))
		time.Sleep(delay)

		// Losowy kierunek
		dir := directions[r.Intn(len(directions))]
		dx, dy := dir[0], dir[1]

		// Aktualizacja pozycji z uwzględnieniem topologii torusa
		x = (x + dx + Board_Width) % Board_Width
		y = (y + dy + Board_Height) % Board_Height

		// Wysłanie zdarzenia
		events <- Event{
			Timestamp: time.Now().UnixNano(),
			ID:        id,
			X:         x,
			Y:         y,
			Symbol:    symbol,
		}
	}
}
