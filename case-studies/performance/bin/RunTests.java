/* Alloy Analyzer 4 -- Copyright (c) 2006-2009, Felix Chang
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.alloy4.Err;
import edu.mit.csail.sdg.alloy4.ErrorWarning;
import edu.mit.csail.sdg.alloy4compiler.ast.Command;
import edu.mit.csail.sdg.alloy4compiler.ast.Module;
import edu.mit.csail.sdg.alloy4compiler.parser.CompUtil;
import edu.mit.csail.sdg.alloy4compiler.translator.A4Options;
import edu.mit.csail.sdg.alloy4compiler.translator.A4Solution;
import edu.mit.csail.sdg.alloy4compiler.translator.TranslateAlloyToKodkod;

public final class RunTests {

    /*
     * Execute every command in every file.
     *
     * This method parses every file, then execute every command.
     *
     * If there are syntax or type errors, it may throw
     * a ErrorSyntax or ErrorType or ErrorAPI or ErrorFatal exception.
     * You should catch them and display them,
     * and they may contain filename/line/column information.
     */
    public static void main(String[] args) throws Err {
        A4Reporter rep = null;

        int totalCommands = 0;
        int totalFailures = 0;

        for(String filename:args) {
            // Parse+typecheck the model
            Module world = CompUtil.parseEverything_fromFile(rep, null, filename);

            // Choose some default options for how you want to execute the commands
            A4Options options = new A4Options();

            // XXX MemSynth: Sat4J is actually faster than Glucose!
            options.solver = A4Options.SatSolver.SAT4J;
            options.skolemDepth = 1;

            for (Command command: world.getAllCommands()) {
                // Execute the command
                A4Solution ans = TranslateAlloyToKodkod.execute_command(rep, world.getAllReachableSigs(), command, options);
                
                // if there's an expected solution, this is a test; otherwise,
                // we should just report the result
                if (command.expects == -1) {
                    System.out.println("[" + filename + "] " + command + ": " +
                        (ans.satisfiable() ? "SAT" : "UNSAT"));
                } else {
                    totalCommands += 1;
                    totalFailures += 1;
                    if (command.expects == 1 && !ans.satisfiable()) {
                        System.out.println("FAILURE: [" + filename + "] " + command + ": expect SAT, got UNSAT");
                    } else if (command.expects == 0 && ans.satisfiable()) {
                        System.out.println("FAILURE: [" + filename + "] " + command + ": expect UNSAT, got SAT");
                    } else {
                        totalFailures -= 1;  // returned correct answer
                    }
                }
            }
        }

        if (totalFailures > 0)
            System.out.println("");
        System.out.println("ran " + totalCommands + " commands; " + totalFailures + " failures");
        System.exit(totalFailures > 0 ? 1 : 0);
    }
}
