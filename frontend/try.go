package main

import (
    "fmt"
    "./cmd"
)

func main() {

    var input string
    fmt.Println("Enter string: ")

    var prompt string = "lexx>"

    for {
        fmt.Printf(prompt)
        fmt.Scanln(&input)
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
