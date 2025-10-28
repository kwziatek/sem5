import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;

public class DFS {

    private int n, m;
    private List<List<Integer>> listOfNeighbours;
    private List<List<Integer>> edgesForTree;
    private boolean[] visited;
    private boolean printTree;


    public static void main(String[] args) {
        DFS dfs = new DFS(args[0]);
        dfs.start();
    }

    private DFS(String fileName) {
        listOfNeighbours = new ArrayList<>();
        edgesForTree = new ArrayList<>();
        readDataFromFile(fileName);
        visited = new boolean[listOfNeighbours.size() + 1];
    }

    private void start() {
        printListOfNeighbours(listOfNeighbours);
        dfs(1);
        if(printTree) {
            printTree();
        }
    }

    private void readDataFromFile(String name) {
        File myObject = new File(name);
        try (Scanner myReader = new Scanner(myObject)) {
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
            printTree = Boolean.parseBoolean(myReader.nextLine());
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

    private void dfs(int v) {
        System.out.println(v);
        visited[v] = true;
        for(int node: listOfNeighbours.get(v)) {
            if(!visited[node]) {
                edgesForTree.add(new ArrayList<>(Arrays.asList(v, node)));
                dfs(node);
            }
        }
    }

    private void printTree() {
        for(List<Integer> l: edgesForTree) {
            System.out.println(l);
        }
    }

}
