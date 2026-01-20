#include <iostream>
#include <vector>
#include <queue>
#include <cmath>
#include <random>
#include <chrono>
#include <string>
#include <algorithm>

using namespace std;

struct Edge {
    int to;
    long long capacity;
    long long flow;
    int rev;
};

class HypercubeFlow {
    int k;
    int num_v;
    vector<vector<Edge>> adj;
    int augmenting_paths_count = 0;

    int hammingWeight(int n) {
        int weight = 0;
        while (n > 0) {
            if (n & 1) weight++;
            n >>= 1;
        }
        return weight;
    }

    int zeroCount(int n) {
        return k - hammingWeight(n);
    }

public:
    HypercubeFlow(int k_val) : k(k_val) {
        num_v = 1 << k;
        adj.resize(num_v);
    }

    void generateGraph() {
        mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
        for (int i = 0; i < num_v; ++i) {
            for (int bit = 0; bit < k; ++bit) {
                int j = i ^ (1 << bit);
                // Krawędź od mniejszej do większej wagi Hamminga
                if (hammingWeight(j) > hammingWeight(i)) {
                    int h_i = hammingWeight(i);
                    int z_i = zeroCount(i);
                    int h_j = hammingWeight(j);
                    int z_j = zeroCount(j);
                    int l = max({h_i, z_i, h_j, z_j});
                    
                    uniform_int_distribution<long long> dist(1, 1LL << l);
                    long long cap = dist(rng);
                    
                    addEdge(i, j, cap);
                }
            }
        }
    }

    void addEdge(int u, int v, long long cap) {
        adj[u].push_back({v, cap, 0, (int)adj[v].size()});
        adj[v].push_back({u, 0, 0, (int)adj[u].size() - 1});
    }

    long long edmondsKarp(int s, int t) {
        long long max_flow = 0;
        while (true) {
            vector<int> parent(num_v, -1);
            vector<int> edge_from(num_v, -1);
            queue<int> q;
            
            q.push(s);
            parent[s] = s;

            while (!q.empty() && parent[t] == -1) {
                int u = q.front();
                q.pop();
                for (int i = 0; i < adj[u].size(); ++i) {
                    Edge &e = adj[u][i];
                    if (parent[e.to] == -1 && e.capacity > e.flow) {
                        parent[e.to] = u;
                        edge_from[e.to] = i;
                        q.push(e.to);
                    }
                }
            }

            if (parent[t] == -1) break;

            long long push = 1e18;
            for (int v = t; v != s; v = parent[v]) {
                int u = parent[v];
                push = min(push, adj[u][edge_from[v]].capacity - adj[u][edge_from[v]].flow);
            }

            for (int v = t; v != s; v = parent[v]) {
                int u = parent[v];
                int idx = edge_from[v];
                adj[u][idx].flow += push;
                int rev_idx = adj[u][idx].rev;
                adj[v][rev_idx].flow -= push;
            }

            max_flow += push;
            augmenting_paths_count++;
        }
        return max_flow;
    }

    void printFlow() {
        for (int u = 0; u < num_v; ++u) {
            for (const auto &e : adj[u]) {
                if (e.capacity > 0) { // Tylko krawędzie oryginalne
                    cout << u << " -> " << e.to << " flow: " << e.flow << "/" << e.capacity << endl;
                }
            }
        }
    }

    int getPathsCount() { return augmenting_paths_count; }
};

int main(int argc, char* argv[]) {
    int k = 0;
    bool printFlow = false;

    for (int i = 1; i < argc; ++i) {
        string arg = argv[i];
        if (arg == "--size") k = stoi(argv[++i]);
        else if (arg == "--printFlow") printFlow = true;
    }

    if (k <= 0) return 1;

    auto start = chrono::high_resolution_clock::now();
    HypercubeFlow hf(k);
    hf.generateGraph();
    long long result = hf.edmondsKarp(0, (1 << k) - 1);
    auto end = chrono::high_resolution_clock::now();
    
    chrono::duration<double> elapsed = end - start;

    cout << "Maksymalny przepływ: " << result << endl;
    if (printFlow) hf.printFlow();

    // stderr: czas oraz liczba ścieżek [cite: 20]
    cerr << elapsed.count() << endl;
    cerr << hf.getPathsCount() << endl;

    return 0;
}