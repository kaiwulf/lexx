package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Println("LEXX")

	for {
		fmt.Print("---!> ")
		input, _ := reader.ReadString('\n')
        input = strings.TrimSpace(input)

        if input == "exit" {
            break
        }

        // Execute the Go code using a temporary file
        tmpFile, err := os.CreateTemp("", "gorepl*.go")
        if err != nil {
            fmt.Println("Error creating temporary file:", err)
            continue
        }

        defer os.Remove(tmpFile.Name()) // Clean up the file later

        _, err = tmpFile.WriteString("package main\nfunc main() {\n" + input + "\n}")
        if err != nil {
            fmt.Println("Error writing to temporary file:", err)
            continue
        }

        tmpFile.Close()

        cmd := exec.Command("go", "run", tmpFile.Name())
        output, err := cmd.CombinedOutput()

        if err != nil {
            fmt.Println("Error executing code:", err)
        } else {
            fmt.Println(string(output))
        }
    }
}