CXX = g++
CXXFLAGS = -std=c++17 -O2 -Wall

# Sources and binaries
SRC_NORMAL = normal_dijkstra.cpp
SRC_DIAL = dial_dijkstra.cpp
SRC_RADIX = radix_head_dijkstra.cpp

BIN_NORMAL = dijkstra
BIN_DIAL = dial
BIN_RADIX = radixheap

.PHONY: all dijkstra dial radixheap clean

# Default: build all three implementations
all: $(BIN_NORMAL) $(BIN_DIAL) $(BIN_RADIX)

$(BIN_NORMAL): $(SRC_NORMAL)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(BIN_DIAL): $(SRC_DIAL)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(BIN_RADIX): $(SRC_RADIX)
	$(CXX) $(CXXFLAGS) -o $@ $^

clean:
	rm -f $(BIN_NORMAL) $(BIN_DIAL) $(BIN_RADIX) *.o
