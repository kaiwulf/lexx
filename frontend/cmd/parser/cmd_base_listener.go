// Code generated from Cmd.g4 by ANTLR 4.7.1. DO NOT EDIT.

package parser // Cmd

import "github.com/antlr/antlr4/runtime/Go/antlr"

// BaseCmdListener is a complete listener for a parse tree produced by CmdParser.
type BaseCmdListener struct{}

var _ CmdListener = &BaseCmdListener{}

// VisitTerminal is called when a terminal node is visited.
func (s *BaseCmdListener) VisitTerminal(node antlr.TerminalNode) {}

// VisitErrorNode is called when an error node is visited.
func (s *BaseCmdListener) VisitErrorNode(node antlr.ErrorNode) {}

// EnterEveryRule is called when any rule is entered.
func (s *BaseCmdListener) EnterEveryRule(ctx antlr.ParserRuleContext) {}

// ExitEveryRule is called when any rule is exited.
func (s *BaseCmdListener) ExitEveryRule(ctx antlr.ParserRuleContext) {}

// EnterStart is called when production start is entered.
func (s *BaseCmdListener) EnterStart(ctx *StartContext) {}

// ExitStart is called when production start is exited.
func (s *BaseCmdListener) ExitStart(ctx *StartContext) {}

// EnterCommand is called when production command is entered.
func (s *BaseCmdListener) EnterCommand(ctx *CommandContext) {}

// ExitCommand is called when production command is exited.
func (s *BaseCmdListener) ExitCommand(ctx *CommandContext) {}

// EnterNumber is called when production Number is entered.
func (s *BaseCmdListener) EnterNumber(ctx *NumberContext) {}

// ExitNumber is called when production Number is exited.
func (s *BaseCmdListener) ExitNumber(ctx *NumberContext) {}

// EnterMulDiv is called when production MulDiv is entered.
func (s *BaseCmdListener) EnterMulDiv(ctx *MulDivContext) {}

// ExitMulDiv is called when production MulDiv is exited.
func (s *BaseCmdListener) ExitMulDiv(ctx *MulDivContext) {}

// EnterAddSub is called when production AddSub is entered.
func (s *BaseCmdListener) EnterAddSub(ctx *AddSubContext) {}

// ExitAddSub is called when production AddSub is exited.
func (s *BaseCmdListener) ExitAddSub(ctx *AddSubContext) {}
