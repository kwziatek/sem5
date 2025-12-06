CXX = g++
CXXFLAGS = -std=c++17 -O2 -Wall

SRC = normal_dijkstra.cpp
BIN = dijkstra

# Default target
all: $(BIN)

$(BIN): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $^

.PHONY: run clean

# Usage: make run DATA=graph.gr SOURCES=sources.ss OUT=results.res
DATA ?= duze_dane.gr
SOURCES ?= zrodla.ss
OUT ?= wyniki.ss.res

run: $(BIN)
	./$(BIN) -d $(DATA) -ss $(SOURCES) -oss $(OUT)

clean:
	rm -f $(BiN)
