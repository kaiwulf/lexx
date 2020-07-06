// Code generated from Cmd.g4 by ANTLR 4.7.1. DO NOT EDIT.

package parser // Cmd

import "github.com/antlr/antlr4/runtime/Go/antlr"

// CmdListener is a complete listener for a parse tree produced by CmdParser.
type CmdListener interface {
	antlr.ParseTreeListener

	// EnterStart is called when entering the start production.
	EnterStart(c *StartContext)

	// EnterCommand is called when entering the command production.
	EnterCommand(c *CommandContext)

	// EnterNumber is called when entering the Number production.
	EnterNumber(c *NumberContext)

	// EnterMulDiv is called when entering the MulDiv production.
	EnterMulDiv(c *MulDivContext)

	// EnterAddSub is called when entering the AddSub production.
	EnterAddSub(c *AddSubContext)

	// ExitStart is called when exiting the start production.
	ExitStart(c *StartContext)

	// ExitCommand is called when exiting the command production.
	ExitCommand(c *CommandContext)

	// ExitNumber is called when exiting the Number production.
	ExitNumber(c *NumberContext)

	// ExitMulDiv is called when exiting the MulDiv production.
	ExitMulDiv(c *MulDivContext)

	// ExitAddSub is called when exiting the AddSub production.
	ExitAddSub(c *AddSubContext)
}
