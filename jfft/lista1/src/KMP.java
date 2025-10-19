import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class KMP {
    public static void main(String[] args) throws FileNotFoundException {
        //String pattern = "ABABCABAB";
        //String word = "BABABABABCABABCABAB";
        //System.out.println(preSuf(pattern));
        String pattern = args[0];
        File file = new File(args[1]);
        Scanner scanner = new Scanner(file);
        String word = scanner.nextLine();
        System.out.println(KMP(pattern, word, preSuf(pattern)));
    }

    // create a method that for a given pattern creates a prefix suffix table
    private static List<Integer> preSuf(String pattern) {
        List<Integer> preSufTable = new ArrayList<>();
        preSufTable.add(0);
        int pointer = 0;
        for(int i = 1; i < pattern.length(); i++) {
            if(pattern.charAt(i) == pattern.charAt(pointer))  {
                preSufTable.add(preSufTable.get(i - 1) + 1);
                pointer++;
            }
            else {
                preSufTable.add(0);
                pointer = 0;
            }
        }
        return preSufTable;
    }

    private static List<Integer> KMP(String pattern, String word, List<Integer> preSuf) {
        int pointer = 0;
        List<Integer> result = new ArrayList<>();
        for(int i = 0; i < word.length(); i++) {
            if(pointer == pattern.length()) {
                result.add(i - pattern.length());
                pointer = preSuf.get(Math.max(0, pointer - 1));
            }

            while(word.charAt(i) != pattern.charAt(pointer) && pointer != 0) {
                pointer = preSuf.get(Math.max(0, pointer - 1));
            }

            if(word.charAt(i) == pattern.charAt(pointer)) {
                pointer ++;
            }


        }


        if(pointer == pattern.length()) {
            result.add(word.length() - pattern.length());
        }
        return result;
    }
}
