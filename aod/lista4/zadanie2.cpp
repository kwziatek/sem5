#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>
#include <random>
#include <string>
#include <chrono>
#include <fstream> // Dodano dla obsługi plików

using namespace std;

struct Edge {
    int to;
    int capacity;
    int flow;
    int rev;
};

class FlowNetwork {
    vector<vector<Edge>> adj;
    vector<int> parent;
    vector<int> edge_idx;

public:
    FlowNetwork(int n) : adj(n), parent(n), edge_idx(n) {}

    void addEdge(int u, int v, int cap) {
        adj[u].push_back({v, cap, 0, (int)adj[v].size()});
        adj[v].push_back({u, 0, 0, (int)adj[u].size() - 1});
    }

    bool bfs(int s, int t) {
        fill(parent.begin(), parent.end(), -1);
        queue<int> q;
        q.push(s);
        parent[s] = s;

        while (!q.empty()) {
            int u = q.front();
            q.pop();

            for (int i = 0; i < (int)adj[u].size(); ++i) {
                Edge &e = adj[u][i];
                if (parent[e.to] == -1 && e.capacity - e.flow > 0) {
                    parent[e.to] = u;
                    edge_idx[e.to] = i;
                    if (e.to == t) return true;
                    q.push(e.to);
                }
            }
        }
        return false;
    }

    int maxFlow(int s, int t) {
        int flow = 0;
        while (bfs(s, t)) {
            int path_flow = 1e9;
            for (int v = t; v != s; v = parent[v]) {
                int u = parent[v];
                path_flow = min(path_flow, adj[u][edge_idx[v]].capacity - adj[u][edge_idx[v]].flow);
            }
            for (int v = t; v != s; v = parent[v]) {
                int u = parent[v];
                int idx = edge_idx[v];
                adj[u][idx].flow += path_flow;
                int rev_idx = adj[u][idx].rev;
                adj[v][rev_idx].flow -= path_flow;
            }
            flow += path_flow;
        }
        return flow;
    }

    // Zmodyfikowana funkcja printMatching przyjmująca strumień wyjściowy
    void printMatching(int size_v1, ostream& out) {
        for (int u = 1; u <= size_v1; ++u) {
            for (const auto &e : adj[u]) {
                if (e.to > size_v1 && e.to <= 2 * size_v1 && e.flow == 1) {
                    out << u - 1 << " - " << e.to - size_v1 - 1 << "\n";
                }
            }
        }
    }
};

int main(int argc, char* argv[]) {
    int k = 0, i_param = 0;
    bool printMatchingFlag = false;
    string matchingFileName = "";

    for (int j = 1; j < argc; ++j) {
        string arg = argv[j];
        if (arg == "--size") k = stoi(argv[++j]);
        else if (arg == "--degree") i_param = stoi(argv[++j]);
        else if (arg == "--printMatching") {
            printMatchingFlag = true;
            // Sprawdzamy czy podano nazwę pliku, jeśli nie - domyślnie wypisz na cout
            if (j + 1 < argc && argv[j+1][0] != '-') {
                matchingFileName = argv[++j];
            }
        }
    }

    if (k == 0 || i_param == 0) {
        cerr << "Usage: --size k --degree i [--printMatching [filename]]" << endl;
        return 1;
    }

    auto start_time = chrono::high_resolution_clock::now();

    int n_half = 1 << k; 
    int source = 0;
    int sink = 2 * n_half + 1;
    FlowNetwork fn(sink + 1);

    mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
    uniform_int_distribution<int> dist(0, n_half - 1);

    for (int u = 1; u <= n_half; ++u) {
        fn.addEdge(source, u, 1);
        for (int j = 0; j < i_param; ++j) {
            int v = dist(rng) + n_half + 1;
            fn.addEdge(u, v, 1);
        }
    }

    for (int v = n_half + 1; v <= 2 * n_half; ++v) {
        fn.addEdge(v, sink, 1);
    }

    int max_matching = fn.maxFlow(source, sink);

    auto end_time = chrono::high_resolution_clock::now();
    chrono::duration<double> elapsed = end_time - start_time;

    // Wynik na standardowe wyjście [cite: 30]
    cout << "Maksymalne skojarzenie: " << max_matching << endl;

    if (printMatchingFlag) {
        if (!matchingFileName.empty()) {
            ofstream outFile(matchingFileName);
            if (outFile.is_open()) {
                fn.printMatching(n_half, outFile);
                outFile.close();
                cerr << "Skojarzenie zapisano do pliku: " << matchingFileName << endl;
            } else {
                cerr << "Błąd: Nie można otworzyć pliku do zapisu!" << endl;
            }
        } else {
            fn.printMatching(n_half, cout);
        }
    }

    // Czas pracy na stderr [cite: 30]
    cerr << "Czas pracy: " << elapsed.count() << " s" << endl;

    return 0;
}