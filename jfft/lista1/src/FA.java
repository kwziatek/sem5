import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class FA {
    public static void main(String[] args) throws FileNotFoundException {
        String pattern = args[0];
        File file = new File(args[1]);
        Scanner scanner = new Scanner(file);
        String word = scanner.nextLine();
        //System.out.println(KMP(pattern, word, preSuf(pattern)));
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
        int R = 128; // assuming ASCII alphabet
        int[][] delta = new int[m + 1][R];

        for(int q = 0; q <= m; q++) {
            for(int c = 0; c < R; c++) {

                int k = Math.min(m, q + 1);
                while(k > 0 && !matches(pattern, k, (char) c)) {
                    k--;
                }
                delta[q][c] = ;
            }
        }
        return  delta;
    }

    private static boolean matches(String pattern, int k, char c) {
        
    }

}
