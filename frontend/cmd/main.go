package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

func printRepl() {
	fmt.Print("| lexx -> ")
}

func recoverExp(text string) {
	if r := recover(); r != nil {
		fmt.Println("| lexx -> unknow command ", text)
	}
}

fun parseExp(text string) {
	
}

func printInvalidCmd(text string) {
	// We might have a panic here we so need DEFER + RECOVER
	defer recoverExp(text)
	// \n Will be ignored
	t := strings.TrimSuffix(text, "\n")
	if t != "" {
		// expression, errExp := lexx_eval.NewEvaluableExpression(text)
		// result, errEval := expression.Evaluate(nil)
		expr, errExp := parseExp(text)
		// Before we need to know if is not a Math expr
		if errExp == nil && errEval == nil {
			fmt.Println("| lexx ->", result)
		} else {
			fmt.Println("| lexx -> unknow command " + t)
		}
	}
}

func get(r *bufio.Reader) string {
	t, _ := r.ReadString('\n')
	return strings.TrimSpace(t)
}

func shouldContinue(text string) bool {
	if strings.EqualFold("exit", text) {
		return false
	}
	return true
}

func help() {
	fmt.Println("| lexx -> Welcome to Go Repl! ")
	fmt.Println("| lexx -> Wrote by Diego Pacheco - 2018 ")
	fmt.Println("| lexx -> This Are the Avaliable commands: ")
	fmt.Println("| lexx -> help   - Show you the Help")
	fmt.Println("| lexx -> cls    - Clear the Terminal Screen ")
	fmt.Println("| lexx -> exit   - Exits the Go REPL ")
	fmt.Println("| lexx -> 1 + 2  - Its possible todo Math expressions: true == true, 4 * 6 / 2, 2 > 1 ")
	fmt.Println("| lexx -> time   - Prints current date / time ")
	fmt.Println("| lexx -> ")
}

func cls() {
	cmd := exec.Command("clear")
	cmd.Stdout = os.Stdout
	cmd.Run()
}

func now() {
	fmt.Println("| lexx -> ", time.Now().Format(time.RFC850))
}

func main() {
	commands := map[string]interface{}{
		"help": help,
		"cls":  cls,
		"time": now,
	}
	reader := bufio.NewReader(os.Stdin)
	help()
	printRepl()
	text := get(reader)
	for ; shouldContinue(text); text = get(reader) {
		if value, exists := commands[text]; exists {
			value.(func())()
		} else {
			printInvalidCmd(text)
		}
		printRepl()
	}
	fmt.Println("Bye!")

}