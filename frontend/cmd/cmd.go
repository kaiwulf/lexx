// example.go
package cmd

import (
    "fmt"
    "strconv"

    "./parser"
    "github.com/antlr/antlr4/runtime/Go/antlr"
)

type CmdListener struct {
    *parser.BaseCmdListener

    stack []int
}

func (l *CmdListener) push(i int) {
    l.stack = append(l.stack, i)
}

func (l *CmdListener) pop() int {
    if len(l.stack) < 1 {
        panic("stack is empty unable to pop")
    }

    // Get the last value from the stack.
    result := l.stack[len(l.stack)-1]

    // Pop the last element from the stack.
    l.stack = l.stack[:len(l.stack)-1]

    return result
}

// ExitMulDiv is called when exiting the MulDiv production.
func (l *CmdListener) ExitMulDiv(c *parser.MulDivContext) {
    right, left := l.pop(), l.pop()

    switch c.GetOp().GetTokenType() {
    case parser.CmdParserMUL:
        l.push(left * right)
    case parser.CmdParserDIV:
        l.push(left / right)
    default:
        panic(fmt.Sprintf("unexpected operation: %s", c.GetOp().GetText()))
    }
}

// ExitAddSub is called when exiting the AddSub production.
func (l *CmdListener) ExitAddSub(c *parser.AddSubContext) {
    right, left := l.pop(), l.pop()

    switch c.GetOp().GetTokenType() {
    case parser.CmdParserADD:
        l.push(left + right)
    case parser.CmdParserSUB:
        l.push(left - right)
    default:
        panic(fmt.Sprintf("unexpected operation: %s", c.GetOp().GetText()))
    }
}

// ExitNumber is called when exiting the Number production.
func (l *CmdListener) ExitNumber(c *parser.NumberContext) {
    i, err := strconv.Atoi(c.GetText())
    if err != nil {
        panic(err.Error())
    }

    l.push(i)
}

// cmd takes a string expression and returns the evaluated result.
func Cmd(input string) int {
    // Setup the input
    is := antlr.NewInputStream(input)

    // Create the Lexer
    lexer := parser.NewCmdLexer(is)
    stream := antlr.NewCommonTokenStream(lexer, antlr.TokenDefaultChannel)

    // Create the parser
    p := parser.NewCmdParser(stream)

    // Finally parse the expression (by walking the tree)
    var listener CmdListener
    antlr.ParseTreeWalkerDefault.Walk(&listener, p.Start())

    return listener.pop()
}