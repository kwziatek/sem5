#include <iostream>
#include <climits>
#include <fstream>
#include <sstream>
#include <chrono>
#include <bits/stdc++.h>
using namespace std;

vector<int> dijkstra(vector<vector<pair<int,int>>>& adj, int src, int max_weight) {
    int n = static_cast<int>(adj.size());
    if (src < 0 || src >= n) return {};

    using Key = unsigned long long;
    const Key INF = (std::numeric_limits<Key>::max() >> 2);

    struct RadixHeap {
        Key last = 0;
        size_t sz = 0;
        std::vector<std::vector<std::pair<Key,int>>> buckets;
        RadixHeap(): buckets(65) {}
        static inline int bindex(Key last, Key key) {
            if (key == last) return 0;
            Key x = key ^ last;
            return 64 - __builtin_clzll(x); // returns 1..64
        }
        void push(Key key, int val) {
            int bi = bindex(last, key);
            buckets[bi].emplace_back(key, val);
            ++sz;
        }
        bool empty() const { return sz == 0; }
        std::pair<Key,int> pop() {
            if (buckets[0].empty()) {
                int i = 1;
                while (i < (int)buckets.size() && buckets[i].empty()) ++i;
                if (i == (int)buckets.size()) return {0, -1};
                Key new_last = buckets[i][0].first;
                for (auto &p : buckets[i]) if (p.first < new_last) new_last = p.first;
                // redistribute
                for (auto &p : buckets[i]) {
                    int bi = bindex(new_last, p.first);
                    buckets[bi].push_back(p);
                }
                buckets[i].clear();
                last = new_last;
            }
            auto p = buckets[0].back(); buckets[0].pop_back(); --sz;
            return p;
        }
    };

    RadixHeap heap;
    std::vector<Key> dist64(n, INF);
    dist64[src] = 0;
    heap.push(0, src);

    while (!heap.empty()) {
        auto pr = heap.pop();
        Key d = pr.first;
        int u = pr.second;
        if (u < 0) break;
        if (d != dist64[u]) continue; // outdated
        for (auto &edge : adj[u]) {
            int v = edge.first;
            int w = edge.second;
            if (dist64[u] == INF) continue;
            Key nd = dist64[u] + static_cast<Key>(w);
            if (nd < dist64[v]) {
                dist64[v] = nd;
                heap.push(nd, v);
            }
        }
    }

    vector<int> out(n);
    for (int i = 0; i < n; ++i) {
        if (dist64[i] == INF || dist64[i] > static_cast<Key>(INT_MAX)) out[i] = INT_MAX;
        else out[i] = static_cast<int>(dist64[i]);
    }
    return out;
}

int source_function(int argc, char* argv[]) {
    if(string(argv[1]) != "-d") {
        cerr << "Expected: '-d', but received: " << argv[1] << "\n ";
        return 1;
    }

    ifstream file(argv[2]);

    if(!file.is_open()) {
        cerr << "Could not load file: " << argv[2];
    }

    vector<vector<pair<int, int>>> adj;
    char c;
    string s;
    int e, v, min_w = INT_MAX, max_w= INT_MIN;

    bool cond = true;
    string line;
    int count = 0;
    while(getline(file, line)) {
        if(line[0] == 'c') {
            continue;
        }

        if(line[0] == 'p' && cond) {
            stringstream ss(line);
            ss >> c >> s >> v >> e;
            // use 0-based indexing internally
            adj.resize(v);
            cond = false;
        }

        if(line[0] == 'a' && !cond) {
            stringstream ss(line);
            int u, vv, w;
            ss >> c >> u >> vv >> w;
            // convert to 0-based
            --u; --vv;
            if (u < 0 || u >= (int)adj.size() || vv < 0 || vv >= (int)adj.size()) {
                continue;
            }
            if(w < min_w) {
                min_w = w;
            }
            if(w > max_w) {
                max_w = w;
            }
            adj[u].push_back({vv, w});
            count++;
        }

        if(count == e) {
            break;
        }
        
    }

    file.close();

    /*
    checking the adj list

    for (int i = 0; i < adj.size(); ++i) {
        for (auto& p : adj[i]) {
            cout << i << " " << p.first << " " << p.second << "\n";
        }
    }
    int src = 1;

    vector<int> result = dijkstra(adj, src);

    cout << "result \n";
    for (int i = 1; i < result.size(); i++) {
        cout << result[i] << " ";
    }
    cout << "\n";
    */

    if(string(argv[3]) != "-ss") {
        cerr << "Expected: '-ss', but received: " << argv[3] << "\n ";
        return 1;
    }

    ifstream ss_file(argv[4]);

    if(!ss_file.is_open()) {
        cerr << "Could not load file: " << argv[4];
    }

    vector<int> sources;

    while(getline(ss_file, line)) {
        if(line[0] == 's') {
            stringstream ss(line);
            char ch;
            int src;
            ss >> ch >> src;
            --src; // convert to 0-based
            if (src >= 0 && src < (int)adj.size()) sources.push_back(src);
        }
    }

    /*for(int i : sources) {
        vector<int> result = dijkstra(adj, i);
        cout << "Source: " << i << "\n";
        for (int j = 1; j < result.size(); j++) {
            cout << result[j] << " ";
        }
        cout << "\n";
    }*/
    

    if(string(argv[5]) != "-oss") {
        cerr << "Expected: '-oss', but received: " << argv[5] << "\n ";
        return 1;
    }

    ofstream res_file(argv[6]);

    if(!res_file.is_open()) {
        cerr << "Could not open file to write: " << argv[5];
    }

    // adding some comments to output file
    res_file << "c This file contains the shortest path results for given sources\n";
    res_file << "c Generated radix_heap_dijkstra.cpp\n";
    res_file << "c -------------------------------------------\n";

    // adding problem line, file line and graph line to output file
    res_file << "p res sp ss karol" << "\n";
    res_file << "f " << argv[2] << " " << argv[4] << "\n";
    res_file << "g " << v << " " << e << " " << min_w << " " << max_w << "\n";
    res_file << "c -------------------------------------------\n";


    chrono::microseconds total_time(0);
    for(int i : sources) {
        auto start = chrono::high_resolution_clock::now();
        dijkstra(adj, i, max_w);
        auto end = chrono::high_resolution_clock::now();
        auto duration = chrono::duration_cast<chrono::microseconds>(end - start);
        total_time += duration;
    }
    
    chrono::duration<double, milli> average_time = total_time / sources.size();
    res_file << "t " << average_time.count() << "\n";
    
    res_file.close();

    return 0;
}

int pair_to_pair_function(int argc, char* argv[]) {
    
        if(string(argv[1]) != "-d") {
        cerr << "Expected: '-d', but received: " << argv[1] << "\n ";
        return 1;
    }

    ifstream file(argv[2]);

    if(!file.is_open()) {
        cerr << "Could not load file: " << argv[2];
    }

    vector<vector<pair<int, int>>> adj;
    char c;
    string s;
    int e, v, min_w = INT_MAX, max_w= INT_MIN;

    bool cond = true;
    string line;
    int count = 0;
    while(getline(file, line)) {
        if(line[0] == 'c') {
            continue;
        }

        if(line[0] == 'p' && cond) {
            stringstream ss(line);
            ss >> c >> s >> v >> e;
            // use 0-based internal indices
            adj.resize(v);
            cond = false;
        }

        if(line[0] == 'a' && !cond) {
            stringstream ss(line);
            int u, vv, w;
            ss >> c >> u >> vv >> w;
            // convert to 0-based
            --u; --vv;
            if (u < 0 || u >= (int)adj.size() || vv < 0 || vv >= (int)adj.size()) {
                continue;
            }
            if(w < min_w) {
                min_w = w;
            }
            if(w > max_w) {
                max_w = w;
            }
            adj[u].push_back({vv, w});
            count++;
        }

        if(count == e) {
            break;
        }
        
    }

    file.close();

    /*
    checking the adj list

    for (int i = 0; i < adj.size(); ++i) {
        for (auto& p : adj[i]) {
            cout << i << " " << p.first << " " << p.second << "\n";
        }
    }
    int src = 1;

    vector<int> result = dijkstra(adj, src);

    cout << "result \n";
    for (int i = 1; i < result.size(); i++) {
        cout << result[i] << " ";
    }
    cout << "\n";
    */

    if(string(argv[3]) != "-p2p") {
        cerr << "Expected: '-p2p', but received: " << argv[3] << "\n ";
        return 1;
    }

    ifstream p2p_file(argv[4]);

    if(!p2p_file.is_open()) {
        cerr << "Could not load file: " << argv[4];
    }

    vector<pair<int,int>> pairs;

    while(getline(p2p_file, line)) {
        if(line[0] == 'q') {
            stringstream ss(line);
            char ch;
            int first, second;
            ss >> ch >> first >> second;
            // convert to 0-based and validate later
            --first; --second;
            if (first >= 0 && first < (int)adj.size() && second >= 0 && second < (int)adj.size()) {
                pairs.push_back({first, second});
            }
        }
    }

    /*for(int i : sources) {
        vector<int> result = dijkstra(adj, i);
        cout << "Source: " << i << "\n";
        for (int j = 1; j < result.size(); j++) {
            cout << result[j] << " ";
        }
        cout << "\n";
    }*/
    

    if(string(argv[5]) != "-op2p") {
        cerr << "Expected: '-oss', but received: " << argv[5] << "\n ";
        return 1;
    }

    ofstream res_file(argv[6]);

    if(!res_file.is_open()) {
        cerr << "Could not open file to write: " << argv[5];
    }

    // adding some comments to output file
    res_file << "c This file contains the shortest path results for given pairs\n";
    res_file << "c Generated by radix_heap_dijkstra.cpp\n";
    res_file << "c -------------------------------------------\n";

    // adding problem line, file line and graph line to output file
    res_file << "p res sp ss karol" << "\n";
    res_file << "f " << argv[2] << " " << argv[4] << "\n";
    res_file << "g " << v << " " << e << " " << min_w << " " << max_w << "\n";
    res_file << "c -------------------------------------------\n";

    for(pair<int,int> pr : pairs) {
        int f = pr.first;
        int s = pr.second;
        if (f < 0 || f >= (int)adj.size() || s < 0 || s >= (int)adj.size()) continue;
        vector<int> res = dijkstra(adj, f, max_w);
        long long dist = (res[s] == INT_MAX) ? -1 : res[s];
        // write 1-based node ids in output to match input format
        res_file << "d " << (f+1) << " " << (s+1) << " " << dist << "\n";
    }
    
    res_file.close();

    return 0;
}


int main(int argc, char* argv[]) {
   
   if(string(argv[3]) == "-ss"){
        source_function(argc, argv);
   } else if(string(argv[3]) == "-p2p") {
        pair_to_pair_function(argc, argv);
   } else {
        cerr << "Expected: '-ss' or '-p2p', but received: " << argv[3] << "\n ";
        return 1;
   }
    
    return 0;
}