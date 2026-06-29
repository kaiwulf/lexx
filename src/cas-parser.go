package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"

	"github.com/antlr4-go/antlr/v4"
)

// CASVisitor implements the CASVisitor interface
type CASVisitor struct {
	BaseCASVisitor
}

// Value represents a value in our CAS system
type Value struct {
	Type      string      // "number", "variable", "expression"
	Number    float64     // Used for numeric values
	String    string      // Used for variables and expressions
	IsComplex bool        // Whether this is a complex number
}

func (v *Value) String() string {
	switch v.Type {
	case "number":
		return fmt.Sprintf("%g", v.Number)
	default:
		return v.String
	}
}

// Visit implementations for each rule
func (v *CASVisitor) VisitExprCommand(ctx *ExprCommandContext) interface{} {
	result := v.Visit(ctx.Expression())
	fmt.Printf("= %v\n", result)
	return result
}

func (v *CASVisitor) VisitExitCommand(ctx *ExitCommandContext) interface{} {
	fmt.Println("Goodbye!")
	os.Exit(0)
	return nil
}

func (v *CASVisitor) VisitQuitCommand(ctx *QuitCommandContext) interface{} {
	fmt.Println("Goodbye!")
	os.Exit(0)
	return nil
}

func (v *CASVisitor) VisitHelpCommand(ctx *HelpCommandContext) interface{} {
	fmt.Println("Available commands:")
	fmt.Println("  Mathematical expressions using +, -, *, /, ^")
	fmt.Println("  Functions: sin, cos, tan, log, ln, etc.")
	fmt.Println("  Integration: int[expression]")
	fmt.Println("  Differentiation: diff[expression]")
	fmt.Println("  Set operations: union, intersection, etc.")
	fmt.Println("  exit/quit - Exit the program")
	fmt.Println("  help - Show this help message")
	return nil
}

func (v *CASVisitor) VisitIntegralExpr(ctx *IntegralExprContext) interface{} {
	expr := v.Visit(ctx.Expression())
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("∫(%v)", expr),
	}
}

func (v *CASVisitor) VisitDifferentialExpr(ctx *DifferentialExprContext) interface{} {
	expr := v.Visit(ctx.Expression())
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("d/dx(%v)", expr),
	}
}

func (v *CASVisitor) VisitFunctionExpr(ctx *FunctionExprContext) interface{} {
	funcName := ctx.FUNC().GetText()
	arg := v.Visit(ctx.Expression()).(*Value)
	
	if arg.Type != "number" {
		return &Value{
			Type:   "expression",
			String: fmt.Sprintf("%s(%v)", funcName, arg),
		}
	}

	var result float64
	switch funcName {
	case "sin":
		result = math.Sin(arg.Number)
	case "cos":
		result = math.Cos(arg.Number)
	case "tan":
		result = math.Tan(arg.Number)
	case "log":
		result = math.Log10(arg.Number)
	case "ln":
		result = math.Log(arg.Number)
	default:
		panic(fmt.Sprintf("Unknown function: %s", funcName))
	}

	return &Value{
		Type:   "number",
		Number: result,
	}
}

func (v *CASVisitor) VisitSetOperationExpr(ctx *SetOperationExprContext) interface{} {
	op := ctx.SETOP().GetText()
	left := v.Visit(ctx.Expression(0))
	right := v.Visit(ctx.Expression(1))
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("%s(%v, %v)", op, left, right),
	}
}

func (v *CASVisitor) VisitPowerExpr(ctx *PowerExprContext) interface{} {
	base := v.Visit(ctx.Expression(0)).(*Value)
	exp := v.Visit(ctx.Expression(1)).(*Value)
	
	if base.Type == "number" && exp.Type == "number" {
		return &Value{
			Type:   "number",
			Number: math.Pow(base.Number, exp.Number),
		}
	}
	
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("(%v^%v)", base, exp),
	}
}

func (v *CASVisitor) VisitMultDivExpr(ctx *MultDivExprContext) interface{} {
	left := v.Visit(ctx.Expression(0)).(*Value)
	right := v.Visit(ctx.Expression(1)).(*Value)
	
	if left.Type == "number" && right.Type == "number" {
		if ctx.MULT() != nil {
			return &Value{
				Type:   "number",
				Number: left.Number * right.Number,
			}
		}
		if right.Number == 0 {
			panic("Division by zero")
		}
		return &Value{
			Type:   "number",
			Number: left.Number / right.Number,
		}
	}
	
	op := "*"
	if ctx.DIV() != nil {
		op = "/"
	}
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("(%v%s%v)", left, op, right),
	}
}

func (v *CASVisitor) VisitAddSubExpr(ctx *AddSubExprContext) interface{} {
	left := v.Visit(ctx.Expression(0)).(*Value)
	right := v.Visit(ctx.Expression(1)).(*Value)
	
	if left.Type == "number" && right.Type == "number" {
		if ctx.PLUS() != nil {
			return &Value{
				Type:   "number",
				Number: left.Number + right.Number,
			}
		}
		return &Value{
			Type:   "number",
			Number: left.Number - right.Number,
		}
	}
	
	op := "+"
	if ctx.MINUS() != nil {
		op = "-"
	}
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("(%v%s%v)", left, op, right),
	}
}

func (v *CASVisitor) VisitParenExpr(ctx *ParenExprContext) interface{} {
	return v.Visit(ctx.Expression())
}

func (v *CASVisitor) VisitNegativeExpr(ctx *NegativeExprContext) interface{} {
	expr := v.Visit(ctx.Expression()).(*Value)
	if expr.Type == "number" {
		return &Value{
			Type:   "number",
			Number: -expr.Number,
		}
	}
	return &Value{
		Type:   "expression",
		String: fmt.Sprintf("(-%v)", expr),
	}
}

func (v *CASVisitor) VisitNumberAtom(ctx *NumberAtomContext) interface{} {
	return v.Visit(ctx.Number())
}

func (v *CASVisitor) VisitVariableAtom(ctx *VariableAtomContext) interface{} {
	return &Value{
		Type:   "variable",
		String: ctx.VARIABLE().GetText(),
	}
}

func (v *CASVisitor) VisitConstantAtom(ctx *ConstantAtomContext) interface{} {
	constant := ctx.CONSTANT().GetText()
	switch constant {
	case "pi":
		return &Value{
			Type:   "number",
			Number: math.Pi,
		}
	case "e":
		return &Value{
			Type:   "number",
			Number: math.E,
		}
	default:
		return &Value{
			Type:   "constant",
			String: constant,
		}
	}
}

func (v *CASVisitor) VisitIntegerNumber(ctx *IntegerNumberContext) interface{} {
	num, _ := strconv.ParseFloat(ctx.INTEGER().GetText(), 64)
	return &Value{
		Type:   "number",
		Number: num,
	}
}

func (v *CASVisitor) VisitDecimalNumber(ctx *DecimalNumberContext) interface{} {
	num, _ := strconv.ParseFloat(ctx.DECIMAL().GetText(), 64)
	return &Value{
		Type:   "number",
		Number: num,
	}
}

func main() {
	fmt.Println("CAS System - Type 'help' for commands, 'exit' to quit")
	
	reader := bufio.NewReader(os.Stdin)
	visitor := &CASVisitor{}
	
	for {
		fmt.Print("> ")
		line, _ := reader.ReadString('\n')
		
		input := antlr.NewInputStream(line)
		lexer := NewCASLexer(input)
		stream := antlr.NewCommonTokenStream(lexer, antlr.TokenDefaultChannel)
		parser := NewCASParser(stream)
		
		// Error handling
		parser.RemoveErrorListeners()
		parser.AddErrorListener(antlr.NewDiagnosticErrorListener(true))
		
		tree := parser.Command()
		
		func() {
			defer func() {
				if r := recover(); r != nil {
					fmt.Printf("Error: %v\n", r)
				}
			}()
			visitor.Visit(tree)
		}()
	}
}
