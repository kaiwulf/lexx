// Code generated from cmd/Cmd.g4 by ANTLR 4.7.1. DO NOT EDIT.

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

// EnterLine is called when production line is entered.
func (s *BaseCmdListener) EnterLine(ctx *LineContext) {}

// ExitLine is called when production line is exited.
func (s *BaseCmdListener) ExitLine(ctx *LineContext) {}

// EnterCommand is called when production command is entered.
func (s *BaseCmdListener) EnterCommand(ctx *CommandContext) {}

// ExitCommand is called when production command is exited.
func (s *BaseCmdListener) ExitCommand(ctx *CommandContext) {}

// EnterMulDivPre is called when production MulDivPre is entered.
func (s *BaseCmdListener) EnterMulDivPre(ctx *MulDivPreContext) {}

// ExitMulDivPre is called when production MulDivPre is exited.
func (s *BaseCmdListener) ExitMulDivPre(ctx *MulDivPreContext) {}

// EnterAddSubPre is called when production AddSubPre is entered.
func (s *BaseCmdListener) EnterAddSubPre(ctx *AddSubPreContext) {}

// ExitAddSubPre is called when production AddSubPre is exited.
func (s *BaseCmdListener) ExitAddSubPre(ctx *AddSubPreContext) {}

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

// EnterFun is called when production fun is entered.
func (s *BaseCmdListener) EnterFun(ctx *FunContext) {}

// ExitFun is called when production fun is exited.
func (s *BaseCmdListener) ExitFun(ctx *FunContext) {}

// EnterPrefix is called when production prefix is entered.
func (s *BaseCmdListener) EnterPrefix(ctx *PrefixContext) {}

// ExitPrefix is called when production prefix is exited.
func (s *BaseCmdListener) ExitPrefix(ctx *PrefixContext) {}
