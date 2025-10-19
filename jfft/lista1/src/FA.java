import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class FA {
    public static void main(String[] args) throws FileNotFoundException {
        String pattern = args[0];
        File file = new File(args[1]);
        Scanner scanner = new Scanner(file);
        String word = scanner.nextLine();
        search(word, pattern);
    }

    public static void search(String text, String pattern) {
        int m = pattern.length();
        int[][] delta = buildTransitionTable(pattern);

        int state = 0;
        for(int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            state = delta[state][c];
            if(state == m) {
                System.out.println(i - m + 1);
            }
        }
    }

    private static int[][] buildTransitionTable(String pattern) {
        int m = pattern.length();
        int R = 128; // ASCII
        int[][] delta = new int[m + 1][R];

        for (int q = 0; q <= m; q++) {
            for (int c = 0; c < R; c++) {
                int k = Math.min(m, q + 1);
                while (k > 0 && !matches(pattern, k, q, (char) c)) {
                    k--;
                }
                delta[q][c] = k;
            }
        }
        return delta;
    }

    private static boolean matches(String pattern, int k, int q, char c) {
        if (k == 0) return true;
        if (pattern.charAt(k - 1) != c) return false;
        for (int i = 0; i < k - 1; i++) {
            if (pattern.charAt(i) != pattern.charAt(q - k + 1 + i)) return false;
        }
        return true;
    }



}
