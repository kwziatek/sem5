#include <iostream>
#include <vector>
#include <queue>
#include <climits>
#include <fstream>
#include <sstream>
using namespace std;

vector<int> dijkstra(vector<vector<pair<int,int>>>& adj, int src) {
    
    int V = adj.size();

    priority_queue<
        pair<int, int>,
        vector<pair<int, int>>,
        greater<pair<int, int>>
    > pq;

    vector<int> dist(V, INT_MAX);

    dist[src] = 0;
    pq.emplace(0, src);

    while(!pq.empty()) {
        auto top = pq.top();
        pq.pop();

        int d = top.first;
        int u = top.second;

        if(d > dist[u]) {
            continue;
        }

        for(auto &p : adj[u]) {
            int v = p.first;
            int w = p.second;

            if (dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                pq.emplace(dist[v], v);
            }
        }

    }

    return dist;
}

int main(int argc, char* argv[]) {

    /*
    checking the main args
    for (int i = 1; i < argc; i++) {
        cout << argv[i] << "\n";
    }
    */
    

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
    int e;

    bool cond = true;
    string line;
    int count = 0;
    while(getline(file, line)) {
        if(line[0] == 'c') {
            continue;
        }

        if(line[0] == 'p' && cond) {
            int v;
            stringstream ss(line);
            ss >> c >> s >> v >> e;
            adj.resize(v + 1);
            cond = false;
        }
        
        if(line[0] == 'a' && !cond) {
            stringstream ss(line);
            int u, v, w;
            ss >> c >> u >> v >> w;
            adj[u].push_back({v, w});
            --u; --v;
            count++;
        }

        /*
        checking the file line

        cout << line << "\n"; 
        */
        

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
    */
    

    int src = 1;

    vector<int> result = dijkstra(adj, src);

    cout << "result \n";
    for (int i = 1; i < result.size(); i++) {
        cout << result[i] << " ";
    }
    cout << "\n";
    
    return 0;
}