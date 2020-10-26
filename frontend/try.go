package main

import (
    "fmt"
    "./cmd"
)

func main() {

    var input string
    fmt.Println("Enter string: ")

    for {
        fmt.Scanln(&input)
        t := cmd.Cmd(input)
        fmt.Println(t)
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
