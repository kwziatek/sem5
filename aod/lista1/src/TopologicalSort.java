import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;

public class TopologicalSort {
    private int n, m;
    private List<List<Integer>> listOfNeighbours;
    private List<List<Integer>> edgesForTree;
    private boolean[] visited;
    private boolean printTree;


    public static void main(String[] args) {
        TopologicalSort topologicalSort = new TopologicalSort(args[0]);
        topologicalSort.start();
    }

    private TopologicalSort(String fileName) {
        listOfNeighbours = new ArrayList<>();
        edgesForTree = new ArrayList<>();
        readDataFromFile(fileName);
        visited = new boolean[listOfNeighbours.size() + 1];
    }

    private void start() {
        //printListOfNeighbours(listOfNeighbours);

        List<Integer> sortedGraph = topologicalSort();
        if(sortedGraph != null && n <= 200) {
            System.out.println(sortedGraph);
        }
    }

    private void readDataFromFile(String name) {
        File myObject = new File(name);
        try (Scanner myReader = new Scanner(myObject)) {
            String d = myReader.nextLine();
            n = Integer.parseInt(myReader.nextLine());
            fillArrayList(this.listOfNeighbours, n);
            m = Integer.parseInt(myReader.nextLine());
            for(int i = 1; i <= m; i++) {
                String pairOfInts = myReader.nextLine();
                String[] pairs = pairOfInts.split(" ");
                int x = Integer.parseInt(pairs[0]);
                int y = Integer.parseInt(pairs[1]);
                listOfNeighbours.get(x).add(y);

            }
        } catch (FileNotFoundException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }

    private void printListOfNeighbours(List<List<Integer>> list) {
        for(List<Integer> l: list) {
            System.out.println(l);
        }
    }

    private void fillArrayList(List<List<Integer>> list, int n) {
        for(int i = 0; i <= n; i++) {
            list.add(new ArrayList<>());
        }
    }

    List<Integer> topologicalSort() {

        //calculate the in-degree for each vertex
        int[] inDegree = new int[n + 1];
        for(int i = 1; i <= n; i++) {
            for(int node: listOfNeighbours.get(i)) {
                inDegree[node]++;
            }
        }

        //store vertices with in-degree 0
        Queue<Integer> q = new LinkedList<>();
        for(int i = 1; i <= n; i++) {
            if(inDegree[i] == 0) {
                q.offer(i);
            }
        }

        //poll the vertices form q and remove redundant edges, repeat the process for new vertices with 0 in-degree edges
        List<Integer> result = new ArrayList<>();
        while(!q.isEmpty()) {
            int node = q.poll();
            result.add(node);

            for(int neighbour: listOfNeighbours.get(node)) {
                inDegree[neighbour]--;
                if(inDegree[neighbour] == 0) {
                    q.offer(neighbour);
                }
            }
        }

        if(result.size() != n) {
            System.out.println("graph is cyclic");
            return null;
        }
        System.out.println("graph is not cyclic");
        return result;
    }

//    private boolean checkForCycle() {
//        boolean[] restack = new boolean[n + 1];
//        for(int i = 1; i <= n; i++) {
//            if(!visited[i] && dfsForCycle(i, restack)) {
//                return true;
//            }
//        }
//        return false;
//    }
//
//    private boolean dfsForCycle(int v, boolean[] reStack) {
//        if(reStack[v]) {
//            return true;
//        }
//        if(visited[v]) {
//            return false;
//        }
//
//        visited[v] = true;
//        reStack[v] = true;
//
//        for(int u: listOfNeighbours.get(v)) {
//            if(dfsForCycle(u, reStack)) {
//                return true;
//            }
//        }
//
//        reStack[v] = false;
//        return false;
//    }
}
