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

    // Initialize distance array
    vector<int> dist(n, INT_MAX);
    dist[src] = 0;

    // Use C+1 buckets where C = max_weight
    int C = max(1, max_weight);

    // If C too large, fallback to priority-queue Dijkstra
    const int C_LIMIT = 2000000; // avoid allocating enormous bucket arrays
    if (C > C_LIMIT) {
        using P = pair<int,int>;
        priority_queue<P, vector<P>, greater<P>> pq;
        pq.emplace(0, src);

        while (!pq.empty()) {
            auto [d, u] = pq.top(); pq.pop();
            if (d > dist[u]) continue;
            for (auto &edge : adj[u]) {
                int v = edge.first;
                int w = edge.second;
                if (dist[u] + w < dist[v]) {
                    dist[v] = dist[u] + w;
                    pq.emplace(dist[v], v);
                }
            }
        }

        return dist;
    }

    vector<vector<int>> buckets(C + 1);
    buckets[0].push_back(src);

    long long current_dist = 0;
    int idx = 0; // bucket index = current_dist % (C+1)

    // helper to find next non-empty bucket; returns -1 if none
    auto find_next_non_empty = [&](int start_idx) -> int {
        for (int i = 0; i <= C; ++i) {
            int j = (start_idx + i) % (C + 1);
            if (!buckets[j].empty()) return i; // distance offset
        }
        return -1;
    };

    int processed_nodes = 0;
    vector<char> seen(n, 0);

    while (true) {
        int offset = find_next_non_empty(idx);
        if (offset < 0) break; // no more nodes to process

        // advance current distance and idx
        current_dist += offset;
        idx = (idx + offset) % (C + 1);

        // pop one node from this bucket
        while (!buckets[idx].empty()) {
            int u = buckets[idx].back(); buckets[idx].pop_back();

            // if this entry is outdated, skip
            if (dist[u] != current_dist) continue;

            // process u
            ++processed_nodes;

            for (auto &edge : adj[u]) {
                int v = edge.first;
                int w = edge.second;
                if (dist[u] == INT_MAX) continue;
                long long nd = static_cast<long long>(dist[u]) + w;
                if (nd < dist[v]) {
                    dist[v] = static_cast<int>(nd);
                    int bi = static_cast<int>(nd % (C + 1));
                    buckets[bi].push_back(v);
                }
            }
        }
        // move to next bucket index (current_dist will increase in next find)
        idx = (idx + 1) % (C + 1);
        ++current_dist;
    }

    return dist;
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
    res_file << "c Generated by dial_dijkstra.cpp\n";
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
    res_file << "c Generated by dial_dijkstra.cpp\n";
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