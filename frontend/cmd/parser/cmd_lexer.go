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
	3, 24715, 42794, 33075, 47597, 16764, 15335, 30598, 22884, 2, 14, 94, 8,
	1, 4, 2, 9, 2, 4, 3, 9, 3, 4, 4, 9, 4, 4, 5, 9, 5, 4, 6, 9, 6, 4, 7, 9,
	7, 4, 8, 9, 8, 4, 9, 9, 9, 4, 10, 9, 10, 4, 11, 9, 11, 4, 12, 9, 12, 4,
	13, 9, 13, 4, 14, 9, 14, 4, 15, 9, 15, 4, 16, 9, 16, 4, 17, 9, 17, 3, 2,
	3, 2, 3, 3, 3, 3, 3, 4, 3, 4, 3, 5, 3, 5, 3, 6, 3, 6, 3, 7, 3, 7, 3, 8,
	3, 8, 3, 9, 3, 9, 3, 10, 3, 10, 3, 11, 3, 11, 3, 12, 3, 12, 3, 12, 3, 12,
	3, 13, 3, 13, 3, 13, 3, 13, 3, 14, 6, 14, 65, 10, 14, 13, 14, 14, 14, 66,
	3, 14, 3, 14, 6, 14, 71, 10, 14, 13, 14, 14, 14, 72, 5, 14, 75, 10, 14,
	3, 15, 6, 15, 78, 10, 15, 13, 15, 14, 15, 79, 3, 15, 3, 15, 3, 16, 5, 16,
	85, 10, 16, 3, 16, 3, 16, 6, 16, 89, 10, 16, 13, 16, 14, 16, 90, 3, 17,
	3, 17, 2, 2, 18, 3, 3, 5, 4, 7, 2, 9, 2, 11, 2, 13, 2, 15, 5, 17, 6, 19,
	7, 21, 8, 23, 9, 25, 10, 27, 11, 29, 12, 31, 13, 33, 14, 3, 2, 6, 3, 2,
	50, 59, 4, 2, 46, 46, 48, 48, 5, 2, 11, 12, 15, 15, 34, 34, 4, 2, 67, 92,
	99, 124, 2, 96, 2, 3, 3, 2, 2, 2, 2, 5, 3, 2, 2, 2, 2, 15, 3, 2, 2, 2,
	2, 17, 3, 2, 2, 2, 2, 19, 3, 2, 2, 2, 2, 21, 3, 2, 2, 2, 2, 23, 3, 2, 2,
	2, 2, 25, 3, 2, 2, 2, 2, 27, 3, 2, 2, 2, 2, 29, 3, 2, 2, 2, 2, 31, 3, 2,
	2, 2, 2, 33, 3, 2, 2, 2, 3, 35, 3, 2, 2, 2, 5, 37, 3, 2, 2, 2, 7, 39, 3,
	2, 2, 2, 9, 41, 3, 2, 2, 2, 11, 43, 3, 2, 2, 2, 13, 45, 3, 2, 2, 2, 15,
	47, 3, 2, 2, 2, 17, 49, 3, 2, 2, 2, 19, 51, 3, 2, 2, 2, 21, 53, 3, 2, 2,
	2, 23, 55, 3, 2, 2, 2, 25, 59, 3, 2, 2, 2, 27, 64, 3, 2, 2, 2, 29, 77,
	3, 2, 2, 2, 31, 88, 3, 2, 2, 2, 33, 92, 3, 2, 2, 2, 35, 36, 7, 42, 2, 2,
	36, 4, 3, 2, 2, 2, 37, 38, 7, 43, 2, 2, 38, 6, 3, 2, 2, 2, 39, 40, 7, 112,
	2, 2, 40, 8, 3, 2, 2, 2, 41, 42, 7, 103, 2, 2, 42, 10, 3, 2, 2, 2, 43,
	44, 7, 121, 2, 2, 44, 12, 3, 2, 2, 2, 45, 46, 9, 2, 2, 2, 46, 14, 3, 2,
	2, 2, 47, 48, 7, 44, 2, 2, 48, 16, 3, 2, 2, 2, 49, 50, 7, 49, 2, 2, 50,
	18, 3, 2, 2, 2, 51, 52, 7, 45, 2, 2, 52, 20, 3, 2, 2, 2, 53, 54, 7, 47,
	2, 2, 54, 22, 3, 2, 2, 2, 55, 56, 5, 7, 4, 2, 56, 57, 5, 9, 5, 2, 57, 58,
	5, 11, 6, 2, 58, 24, 3, 2, 2, 2, 59, 60, 5, 7, 4, 2, 60, 61, 5, 11, 6,
	2, 61, 62, 5, 9, 5, 2, 62, 26, 3, 2, 2, 2, 63, 65, 5, 13, 7, 2, 64, 63,
	3, 2, 2, 2, 65, 66, 3, 2, 2, 2, 66, 64, 3, 2, 2, 2, 66, 67, 3, 2, 2, 2,
	67, 74, 3, 2, 2, 2, 68, 70, 9, 3, 2, 2, 69, 71, 5, 13, 7, 2, 70, 69, 3,
	2, 2, 2, 71, 72, 3, 2, 2, 2, 72, 70, 3, 2, 2, 2, 72, 73, 3, 2, 2, 2, 73,
	75, 3, 2, 2, 2, 74, 68, 3, 2, 2, 2, 74, 75, 3, 2, 2, 2, 75, 28, 3, 2, 2,
	2, 76, 78, 9, 4, 2, 2, 77, 76, 3, 2, 2, 2, 78, 79, 3, 2, 2, 2, 79, 77,
	3, 2, 2, 2, 79, 80, 3, 2, 2, 2, 80, 81, 3, 2, 2, 2, 81, 82, 8, 15, 2, 2,
	82, 30, 3, 2, 2, 2, 83, 85, 7, 15, 2, 2, 84, 83, 3, 2, 2, 2, 84, 85, 3,
	2, 2, 2, 85, 86, 3, 2, 2, 2, 86, 89, 7, 12, 2, 2, 87, 89, 7, 15, 2, 2,
	88, 84, 3, 2, 2, 2, 88, 87, 3, 2, 2, 2, 89, 90, 3, 2, 2, 2, 90, 88, 3,
	2, 2, 2, 90, 91, 3, 2, 2, 2, 91, 32, 3, 2, 2, 2, 92, 93, 9, 5, 2, 2, 93,
	34, 3, 2, 2, 2, 10, 2, 66, 72, 74, 79, 84, 88, 90, 3, 8, 2, 2,
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
	"", "'('", "')'", "'*'", "'/'", "'+'", "'-'",
}

var lexerSymbolicNames = []string{
	"", "", "", "MUL", "DIV", "ADD", "SUB", "NEW", "NWE", "NUMBER", "WHITESPACE",
	"NEWLINE", "VAR",
}

var lexerRuleNames = []string{
	"T__0", "T__1", "N", "E", "W", "DIGIT", "MUL", "DIV", "ADD", "SUB", "NEW",
	"NWE", "NUMBER", "WHITESPACE", "NEWLINE", "VAR",
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
	CmdLexerT__0       = 1
	CmdLexerT__1       = 2
	CmdLexerMUL        = 3
	CmdLexerDIV        = 4
	CmdLexerADD        = 5
	CmdLexerSUB        = 6
	CmdLexerNEW        = 7
	CmdLexerNWE        = 8
	CmdLexerNUMBER     = 9
	CmdLexerWHITESPACE = 10
	CmdLexerNEWLINE    = 11
	CmdLexerVAR        = 12
)
