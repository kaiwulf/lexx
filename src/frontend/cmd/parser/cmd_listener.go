// Code generated from Cmd.g4 by ANTLR 4.7.1. DO NOT EDIT.

package parser // Cmd

import "github.com/antlr/antlr4/runtime/Go/antlr"

// CmdListener is a complete listener for a parse tree produced by CmdParser.
type CmdListener interface {
	antlr.ParseTreeListener

	// EnterStart is called when entering the start production.
	EnterStart(c *StartContext)

	// EnterLine is called when entering the line production.
	EnterLine(c *LineContext)

	// EnterCommand is called when entering the command production.
	EnterCommand(c *CommandContext)

	// EnterNumber is called when entering the Number production.
	EnterNumber(c *NumberContext)

	// EnterFunc is called when entering the func production.
	EnterFunc(c *FuncContext)

	// EnterMulDiv is called when entering the MulDiv production.
	EnterMulDiv(c *MulDivContext)

	// EnterAddSub is called when entering the AddSub production.
	EnterAddSub(c *AddSubContext)

	// EnterPrefix is called when entering the prefix production.
	EnterPrefix(c *PrefixContext)

	// ExitStart is called when exiting the start production.
	ExitStart(c *StartContext)

	// ExitLine is called when exiting the line production.
	ExitLine(c *LineContext)

	// ExitCommand is called when exiting the command production.
	ExitCommand(c *CommandContext)

	// ExitNumber is called when exiting the Number production.
	ExitNumber(c *NumberContext)

	// ExitFunc is called when exiting the func production.
	ExitFunc(c *FuncContext)

	// ExitMulDiv is called when exiting the MulDiv production.
	ExitMulDiv(c *MulDivContext)

	// ExitAddSub is called when exiting the AddSub production.
	ExitAddSub(c *AddSubContext)

	// ExitPrefix is called when exiting the prefix production.
	ExitPrefix(c *PrefixContext)
}
