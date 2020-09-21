package log

import (
	"log"
	"os"
	"runtime/debug"
)

func init() {
	log.SetOutput(os.Stdout)
	log.SetFlags(log.Ltime | log.LUTC)
}

func Error(prefix string, errorMsg string) {
	log.SetPrefix("[" + prefix + "]")
	log.Println("\033[0;33m" + errorMsg + "\033[0m")
	log.Println("\033[0;33m" + string(debug.Stack()) + "\033[0m")
}
