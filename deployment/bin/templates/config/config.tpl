package config

import (
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"os"
)

type serverConfig struct {
	Port string `yaml:"port"`
}

type databaseConfig struct {
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Address  string `yaml:"address"`
	Schema   string `yaml:"schema"`
}

type casbinConfig struct {
	ConfigFilePath string `yaml:"config_file_path"`
}

type {{ .ProjectConfig.LowCaseProjectName }}Config struct {
	Version            string         `yaml:"version"`
	ServerConfig       serverConfig   `yaml:"server"`
	DatabaseConfig     databaseConfig `yaml:"database"`
	CasbinConfig       casbinConfig   `yaml:"casbin"`
	RoleConfigFilePath string         `yaml:"role_config_file_path"`
}

var conf = &{{ .ProjectConfig.LowCaseProjectName }}Config{}

func init() {
	configFilePath := os.Getenv("CONFIG_FILE_PATH")
	data, err := ioutil.ReadFile(configFilePath)
	if err != nil {
		panic(err)
	}

	err = yaml.Unmarshal(data, conf)
	if err != nil {
		panic(err)
	}
}

func Get{{ .ProjectConfig.ProjectName }}Config() *{{ .ProjectConfig.LowCaseProjectName }}Config {
	return conf
}
