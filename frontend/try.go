package main

import (
    "fmt"
    "./cmd"
    "bufio"
    // "errors"
    "os"
    // "os/exec"
)

func main() {

    // var input string
    fmt.Println("Enter string: ")

    var prompt string = "lexx>"
    reader := bufio.NewReader(os.Stdin)
    for {
        fmt.Printf(prompt)
        
        input, err := reader.ReadString('\n')
        // fmt.Scanln(&input)
        if err != nil {
            fmt.Fprintln(os.Stderr, err)
        }
        t := cmd.Cmd(input)
        fmt.Println(prompt,t)
    }

    // Read all tokens
    // for {
    //     t := lexer.NextToken()
    //     if t.GetTokenType() == antlr.TokenEOF {
    //         break
    //     }
    //     fmt.Printf("%s (%q)\n", lexer.SymbolicNames[t.GetTokenType()], t.GetText())
    // }
}
