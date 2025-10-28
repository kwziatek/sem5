
import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;

public class StronglyConnectedComponents {

    private int n, m, id, counter;
    private List<List<Integer>> listOfNeighbours;
    private int[] ids;
    private int[] low;
    private boolean[] onStack;
    private Stack<Integer> stack;


    public static void main(String[] args) {
        StronglyConnectedComponents stronglyConnectedComponents = new StronglyConnectedComponents(args[0]);
        stronglyConnectedComponents.start();
    }

    private StronglyConnectedComponents(String fileName) {
        listOfNeighbours = new ArrayList<>();
        readDataFromFile(fileName);
        low = new int[listOfNeighbours.size() + 1];
        ids = new int[listOfNeighbours.size() + 1];
        onStack = new boolean[listOfNeighbours.size() + 1];
        stack = new Stack<>();
        id = 0;
        counter = 0;
    }

    private void start() {
        //printListOfNeighbours(listOfNeighbours);
        findSuccs();
        if(n <= 200) {
            collectIntoComponents();
        }

        System.out.println(counter);
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

    @SuppressWarnings("unchecked")
    private void collectIntoComponents() {
        List<Integer>[] components = (List<Integer>[]) new ArrayList[n + 1];
        for(int i = 1; i <= n; i++) {
            components[i] = new ArrayList<>();
        }
        for(int i = 1; i <= n; i++) {
            components[low[i]].add(i);
        }
        for(int i = 1; i <= n; i++) {
            if(!components[i].isEmpty()) {
                System.out.println(components[i]);
            }
        }

    }

    private void findSuccs() {
        for(int i = 1; i <= n; i++) {
            if(ids[i] == 0) {
                dfs(i);
            }
        }
    }

    private void dfs(int at) {
        stack.push(at);
        onStack[at] = true;
        id++;
        ids[at] = id;
        low[at] = id;

        for(int to: listOfNeighbours.get(at)) {
            if(ids[to] == 0) {
                dfs(to);
            }
            if(onStack[to]) {
                low[at] = Math.min(low[at], low[to]);
            }
        }

        if(ids[at] == low[at]) {
            while(true) {
                Integer node = stack.pop();
                onStack[node] = false;
                low[node] = ids[at];
                if(node == at) {
                    break;
                }
            }
            counter++;
        }
    }
}

