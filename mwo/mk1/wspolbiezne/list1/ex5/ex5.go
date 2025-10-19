package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
	"unicode"
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
	Symbol    rune
}

var Board [Board_Width][Board_Height] chan bool
var deadlockTime = 3 * Max_Delay

func initBoard() {
	for i := 0; i < Board_Width; i++ {
		for j := 0; j < Board_Height; j++ {
			Board[i][j] = make(chan bool, 1)
		}
	}
}

func checkIfFieldEmpty(x int, y int) bool{
	stopper := time.After(deadlockTime)
	select {
	case Board[x][y] <- true:
		return true
	case <- stopper:
		return false
	}
}

func leaveField(x int, y int) {
	<- Board[x][y]
}


func main() {
	// Kanał do komunikacji z printerem
	events := make(chan Event)
	var wg sync.WaitGroup
	wg.Add(Nr_Of_Travelers)

	// Wątek printera
	go func() {
		for event := range events {
			fmt.Printf("%d %d %d %d %c\n", 
				event.Timestamp, 
				event.ID, 
				event.X, 
				event.Y, 
				event.Symbol)
		}
		fmt.Println("exiting for loop")
	}()

	initBoard()
	// Nagłówek z parametrami
	fmt.Printf("-1 %d %d %d\n", 
		Nr_Of_Travelers, 
		Board_Width, 
		Board_Height)

	// Uruchamianie podróżników
	for id := 0; id < Nr_Of_Travelers; id++ {
		//wg.Add(1)
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

	x := id
	y := id
	checkIfFieldEmpty(x, y)
	
	// Liczba kroków do wykonania
	steps := Min_Steps + r.Intn(Max_Steps-Min_Steps+1)
	
	// Symbol podróżnika
	symbol := rune('A' + id)

	// Dostępne kierunki ruchu (4 kierunki)
	directions := [][2]int{
				{-1, 0},
		{0, -1},          {0, 1},
				{1, 0},
	}

	// Losowy kierunek - w zależności od parzystosci id
	dir := directions[0]
	vertical := r.Intn(2)
	if id % 2 == 0 {
		if(vertical == 1) {
			dir = directions[3]
		} else {
			dir = directions[0]
		}
	} else {
		if(vertical == 1) {
			dir = directions[1]
		} else {
			dir = directions[2]
		}
	}
	dx, dy := dir[0], dir[1]

	for i := 0; i < steps; i++ {
		// Losowe opóźnienie
		delay := Min_Delay + time.Duration(r.Float64()*float64(Max_Delay-Min_Delay))
		time.Sleep(delay)

		// Aktualizacja pozycji z uwzględnieniem topologii torusa
		newX := (x + dx + Board_Width) % Board_Width
		newY := (y + dy + Board_Height) % Board_Height

		ok := false

		if(!checkIfFieldEmpty(newX,newY)) {
			symbol = unicode.ToLower(symbol)
			ok = true
		} else {
			leaveField(x,y)
			x = newX
			y = newY
		}


		// Wysłanie zdarzenia
		events <- Event{
			Timestamp: time.Now().UnixNano(),
			ID:        id,
			X:         x,
			Y:         y,
			Symbol:    symbol,
		}
		if(ok) {
			break
		}
	}
}