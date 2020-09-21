package main

import (
	"flag"
	"fmt"
	"go-web-template/config"
	"go-web-template/template-tools"
	"go-web-template/utils"
	"os"
	"os/exec"
)

var (
	configFile   string
	templatesDir string
	outputDir    string
)

func init() {
	flag.StringVar(&configFile, "f", "config.yml", "Config YAML File Path")
	flag.StringVar(&templatesDir, "t", "templates", "Template Files Directory")
	flag.StringVar(&outputDir, "o", "generated", "Output Files Directory")
}

func main() {
	flag.Parse()

	conf, err := config.LoadConfig(configFile)
	if err != nil {
		panic(err)
	}

	err = template_tools.ParseTemplatesDir(templatesDir, outputDir, conf)
	if err != nil {
		panic(err)
	}

	err = os.Chdir(outputDir)
	if err != nil {
		panic(err)
	}

	fmt.Println("swag init")
	err = exec.Command("/bin/bash", "-c", "swag init").Run()
	if err != nil {
		panic(err)
	}
	fmt.Println("swag init complete")

	if utils.PathExists("go.mod") {
		err := os.Remove("go.mod")
		if err != nil {
			panic(err)
		}
	}

	if utils.PathExists("go.sum") {
		err := os.Remove("go.sum")
		if err != nil {
			panic(err)
		}
	}

	fmt.Println("go mod init", conf.ProjectConfig.PackageName)
	err = exec.Command("/bin/bash", "-c", "go mod init "+conf.ProjectConfig.PackageName).Run()
	if err != nil {
		panic(err)
	}
	fmt.Println("go mod init", conf.ProjectConfig.PackageName, "complete")

	fmt.Println("go mod tidy")
	err = exec.Command("/bin/bash", "-c", "go mod tidy").Run()
	if err != nil {
		panic(err)
	}
	fmt.Println("go mod tidy complete")
}
