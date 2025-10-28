import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;

public class BipartiteGraph {

    private int n, m;
    private List<List<Integer>> listOfNeighbours;
    private boolean[] visited;
    private int[] colorArr;



    public static void main(String[] args) {
        BipartiteGraph bipartiteGraph = new BipartiteGraph(args[0]);
        bipartiteGraph.start();
    }

    private BipartiteGraph(String fileName) {
        listOfNeighbours = new ArrayList<>();
        readDataFromFile(fileName);
        visited = new boolean[n + 1];
        colorArr = new int[n + 1];
    }

    private void start() {
        //printListOfNeighbours(listOfNeighbours);
        System.out.println(isBipartite());
        if(isBipartite() && n <= 200) {
            divideGraph();
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
                if(d.equals("U")) {
                    listOfNeighbours.get(y).add(x);
                }


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

    private boolean isBipartite() {
        for(int i = 1; i <= n; i++) {
            colorArr[i] = -1;
        }

        for(int i = 1; i <= n; i++) {
            if(colorArr[i] == -1) {
                if(!isBipartiteUtil(i, colorArr)) {
                    return false;
                }
            }
        }
        return true;
    }

    private boolean isBipartiteUtil(int src, int[] colorArr) {
        colorArr[src] = 1;
        Queue<Integer> queue = new LinkedList<>();
        queue.add(src);
        while(!queue.isEmpty()) {
            int node = queue.poll();

            for(int neighbour: listOfNeighbours.get(node)) {
                if(colorArr[neighbour] == -1) {
                    colorArr[neighbour] = 1 - colorArr[node];
                    queue.add(neighbour);
                } else if(colorArr[neighbour] == colorArr[node]) {
                    return false;
                }
            }
        }
        return true;
    }

    private void divideGraph() {
        List<Integer> zero = new ArrayList<>();
        List<Integer> one = new ArrayList<>();
        for(int i = 1; i <= n; i++) {
            if(colorArr[i] == 0) {
                zero.add(i);
            } else {
                one.add(i);
            }
        }
        System.out.println(zero);
        System.out.println(one);
    }

}
