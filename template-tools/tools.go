package template_tools

import (
	"errors"
	"go-web-template/config"
	"go-web-template/utils"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

func ParseTemplatesDir(templatesDir string, outputDir string, conf *config.TemplateConfig) error {
	if utils.IsStringEmpty(templatesDir) || utils.IsStringEmpty(outputDir) || conf == nil {
		return errors.New("没有传递必要的参数")
	}

	if !utils.PathExists(templatesDir) {
		return errors.New("输入模板目录不存在")
	}

	if !utils.PathExists(outputDir) {
		err := os.MkdirAll(outputDir, 0755|os.ModeDir)
		if err != nil {
			return err
		}
	}

	files, err := utils.GetDirFiles(templatesDir)
	if err != nil {
		return err
	}

	for _, file := range files {
		subFileName := strings.ReplaceAll(file, templatesDir, "")
		subFileExt := filepath.Ext(subFileName)
		if subFileExt == ".tpl" {
			subFileName = strings.ReplaceAll(subFileName, subFileExt, ".go")
		}

		outputFile := filepath.Join(outputDir, subFileName)
		err := parseTemplateFile(file, outputFile, conf)
		if err != nil {
			return err
		}
	}

	return nil
}

func parseTemplateFile(inputFile string, outputFile string, conf *config.TemplateConfig) error {
	if utils.IsStringEmpty(inputFile) || utils.IsStringEmpty(outputFile) || conf == nil {
		return errors.New("没有传递必要的参数")
	}

	if !utils.PathExists(inputFile) {
		return errors.New("输入文件不存在")
	}

	bytes, err := ioutil.ReadFile(inputFile)
	if err != nil {
		return err
	}

	tpl, err := template.New(inputFile).Parse(string(bytes))
	if err != nil {
		return err
	}

	outputDir := filepath.Dir(outputFile)
	if !utils.IsStringEmpty(outputDir) {
		err := os.MkdirAll(outputDir, 0755|os.ModeDir)
		if err != nil {
			return err
		}
	}

	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}

	defer file.Close()

	err = tpl.Execute(file, conf)
	if err != nil {
		return err
	}

	return nil
}
