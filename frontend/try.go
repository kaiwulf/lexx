package main

import (
    "fmt"
    "./cmd"
)

func main() {

    var input string


    for {
        fmt.Scanln(input)
        cmd.Cmd(input)
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
