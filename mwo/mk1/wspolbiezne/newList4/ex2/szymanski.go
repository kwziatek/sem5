package main

import (
	"fmt"
	"math/rand"
	"time"
)

const (
	NrOfProcesses = 10
	MinSteps      = 10
	MaxSteps      = 15
)

var (
	MinDelay = 10 * time.Millisecond
	MaxDelay = 50 * time.Millisecond

	flags [NrOfProcesses]int
)

type ProcessState int

const (
	LocalSection ProcessState = iota
	EntryProtocol1
	EntryProtocol2
	EntryProtocol3
	EntryProtocol4
	CriticalSection
	ExitProtocol
)

type Position struct {
	X, Y int
}

type Trace struct {
	TimeStamp time.Duration
	Id        int
	Pos       Position
	Symbol    rune
}

func AwaitAll(lo, hi int, allowed []int) {
	for {
		ok := true
		for j := lo; j <= hi; j++ {
			f := flags[j]
			match := false
			for _, a := range allowed {
				if f == a {
					match = true
					break
				}
			}
			if !match {
				ok = false
				break
			}
		}
		if ok {
			break
		}
		time.Sleep(1 * time.Millisecond) // Cooperative wait
	}
}

func AwaitAny(lo, hi int, allowed []int) {
	for {
		for j := lo; j <= hi; j++ {
			f := flags[j]
			for _, a := range allowed {
				if f == a {
					return
				}
			}
		}
		time.Sleep(1 * time.Millisecond) // Cooperative wait
	}
}

func runProcess(id int, symbol rune, seed int64, allDone *int, doneCh chan bool) {
	r := rand.New(rand.NewSource(seed))
	startTime := time.Now()

	nSteps := MinSteps + r.Intn(MaxSteps-MinSteps+1)

	log := func(state ProcessState) {
		ts := time.Since(startTime)
		fmt.Printf("%.6f %d %d %d %c\n", ts.Seconds(), id, id, int(state), symbol)
	}

	log(LocalSection)

	for step := 0; step < nSteps; step++ {
		time.Sleep(MinDelay + time.Duration(r.Int63n(int64(MaxDelay-MinDelay))))

		// ENTRY PROTOCOL
		flags[id] = 1
		time.Sleep(5 * time.Millisecond)
		log(EntryProtocol1)
		AwaitAll(0, NrOfProcesses-1, []int{0, 1, 2})

		flags[id] = 3
		time.Sleep(5 * time.Millisecond)
		log(EntryProtocol3)

		found1 := false
		for j := 0; j < NrOfProcesses; j++ {
			if flags[j] == 1 {
				found1 = true
				break
			}
		}
		if found1 {
			flags[id] = 2
			time.Sleep(5 * time.Millisecond)
			log(EntryProtocol2)
			AwaitAny(0, NrOfProcesses-1, []int{4})
		}

		flags[id] = 4
		time.Sleep(5 * time.Millisecond)
		log(EntryProtocol4)

		if id > 0 {
			AwaitAll(0, id-1, []int{0, 1})
		}

		time.Sleep(5 * time.Millisecond)
		log(CriticalSection)
		time.Sleep(MinDelay + time.Duration(r.Int63n(int64(MaxDelay-MinDelay))))

		if id < NrOfProcesses-1 {
			AwaitAll(id+1, NrOfProcesses-1, []int{0, 1, 4})
		}

		time.Sleep(5 * time.Millisecond)
		log(ExitProtocol)
		flags[id] = 0
		time.Sleep(5 * time.Millisecond)
		log(LocalSection)
	}

	doneCh <- true
}

func main() {
	doneCh := make(chan bool, NrOfProcesses)

	for i := 0; i < NrOfProcesses; i++ {
		go runProcess(i, rune('A'+i), time.Now().UnixNano()+int64(i), nil, doneCh)
	}

	for i := 0; i < NrOfProcesses; i++ {
		<-doneCh
	}

	fmt.Printf("-1 %d %d %d ", NrOfProcesses, NrOfProcesses, ExitProtocol+1)
	fmt.Println("Local_Section;Entry_Protocol_1;Entry_Protocol_2;Entry_Protocol_3;Entry_Protocol_4;Critical_Section;Exit_Protocol EXTRA_LABEL;")
}
