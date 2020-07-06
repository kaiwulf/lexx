// Code generated from Cmd.g4 by ANTLR 4.7.1. DO NOT EDIT.

package parser

import (
	"fmt"
	"unicode"

	"github.com/antlr/antlr4/runtime/Go/antlr"
)

// Suppress unused import error
var _ = fmt.Printf
var _ = unicode.IsLetter

var serializedLexerAtn = []uint16{
	3, 24715, 42794, 33075, 47597, 16764, 15335, 30598, 22884, 2, 10, 45, 8,
	1, 4, 2, 9, 2, 4, 3, 9, 3, 4, 4, 9, 4, 4, 5, 9, 5, 4, 6, 9, 6, 4, 7, 9,
	7, 4, 8, 9, 8, 4, 9, 9, 9, 3, 2, 3, 2, 3, 2, 3, 2, 3, 3, 3, 3, 3, 4, 3,
	4, 3, 5, 3, 5, 3, 6, 3, 6, 3, 7, 6, 7, 33, 10, 7, 13, 7, 14, 7, 34, 3,
	8, 6, 8, 38, 10, 8, 13, 8, 14, 8, 39, 3, 8, 3, 8, 3, 9, 3, 9, 2, 2, 10,
	3, 3, 5, 4, 7, 5, 9, 6, 11, 7, 13, 8, 15, 9, 17, 10, 3, 2, 5, 3, 2, 50,
	59, 5, 2, 11, 12, 15, 15, 34, 34, 4, 2, 67, 92, 99, 124, 2, 46, 2, 3, 3,
	2, 2, 2, 2, 5, 3, 2, 2, 2, 2, 7, 3, 2, 2, 2, 2, 9, 3, 2, 2, 2, 2, 11, 3,
	2, 2, 2, 2, 13, 3, 2, 2, 2, 2, 15, 3, 2, 2, 2, 2, 17, 3, 2, 2, 2, 3, 19,
	3, 2, 2, 2, 5, 23, 3, 2, 2, 2, 7, 25, 3, 2, 2, 2, 9, 27, 3, 2, 2, 2, 11,
	29, 3, 2, 2, 2, 13, 32, 3, 2, 2, 2, 15, 37, 3, 2, 2, 2, 17, 43, 3, 2, 2,
	2, 19, 20, 7, 112, 2, 2, 20, 21, 7, 103, 2, 2, 21, 22, 7, 121, 2, 2, 22,
	4, 3, 2, 2, 2, 23, 24, 7, 44, 2, 2, 24, 6, 3, 2, 2, 2, 25, 26, 7, 49, 2,
	2, 26, 8, 3, 2, 2, 2, 27, 28, 7, 45, 2, 2, 28, 10, 3, 2, 2, 2, 29, 30,
	7, 47, 2, 2, 30, 12, 3, 2, 2, 2, 31, 33, 9, 2, 2, 2, 32, 31, 3, 2, 2, 2,
	33, 34, 3, 2, 2, 2, 34, 32, 3, 2, 2, 2, 34, 35, 3, 2, 2, 2, 35, 14, 3,
	2, 2, 2, 36, 38, 9, 3, 2, 2, 37, 36, 3, 2, 2, 2, 38, 39, 3, 2, 2, 2, 39,
	37, 3, 2, 2, 2, 39, 40, 3, 2, 2, 2, 40, 41, 3, 2, 2, 2, 41, 42, 8, 8, 2,
	2, 42, 16, 3, 2, 2, 2, 43, 44, 9, 4, 2, 2, 44, 18, 3, 2, 2, 2, 5, 2, 34,
	39, 3, 8, 2, 2,
}

var lexerDeserializer = antlr.NewATNDeserializer(nil)
var lexerAtn = lexerDeserializer.DeserializeFromUInt16(serializedLexerAtn)

var lexerChannelNames = []string{
	"DEFAULT_TOKEN_CHANNEL", "HIDDEN",
}

var lexerModeNames = []string{
	"DEFAULT_MODE",
}

var lexerLiteralNames = []string{
	"", "'new'", "'*'", "'/'", "'+'", "'-'",
}

var lexerSymbolicNames = []string{
	"", "NEW", "MUL", "DIV", "ADD", "SUB", "NUMBER", "WHITESPACE", "VAR",
}

var lexerRuleNames = []string{
	"NEW", "MUL", "DIV", "ADD", "SUB", "NUMBER", "WHITESPACE", "VAR",
}

type CmdLexer struct {
	*antlr.BaseLexer
	channelNames []string
	modeNames    []string
	// TODO: EOF string
}

var lexerDecisionToDFA = make([]*antlr.DFA, len(lexerAtn.DecisionToState))

func init() {
	for index, ds := range lexerAtn.DecisionToState {
		lexerDecisionToDFA[index] = antlr.NewDFA(ds, index)
	}
}

func NewCmdLexer(input antlr.CharStream) *CmdLexer {

	l := new(CmdLexer)

	l.BaseLexer = antlr.NewBaseLexer(input)
	l.Interpreter = antlr.NewLexerATNSimulator(l, lexerAtn, lexerDecisionToDFA, antlr.NewPredictionContextCache())

	l.channelNames = lexerChannelNames
	l.modeNames = lexerModeNames
	l.RuleNames = lexerRuleNames
	l.LiteralNames = lexerLiteralNames
	l.SymbolicNames = lexerSymbolicNames
	l.GrammarFileName = "Cmd.g4"
	// TODO: l.EOF = antlr.TokenEOF

	return l
}

// CmdLexer tokens.
const (
	CmdLexerNEW        = 1
	CmdLexerMUL        = 2
	CmdLexerDIV        = 3
	CmdLexerADD        = 4
	CmdLexerSUB        = 5
	CmdLexerNUMBER     = 6
	CmdLexerWHITESPACE = 7
	CmdLexerVAR        = 8
)
