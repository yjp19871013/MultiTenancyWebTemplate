package config

import (
	"errors"
	"go-web-template/utils"
	"gopkg.in/yaml.v2"
	"io/ioutil"
)

type projectConfig struct {
	Version            string `yaml:"version"`
	ProjectName        string `yaml:"projectName"`
	LowCaseProjectName string `yaml:"lowCaseProjectName"`
	PackageName        string `yaml:"packageName"`
	SwaggerAppName     string `yaml:"swaggerAppName"`
	UrlPrefix          string `yaml:"urlPrefix"`
	BuildName          string `yaml:"buildName"`
	JwtSecretKey       string `yaml:"jwt_secret_key"`
}

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
	Domain         string `yaml:"domain"`
}

type adminUserConfig struct {
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Role     string `yaml:"role"`
}

type TemplateConfig struct {
	ProjectConfig      projectConfig   `yaml:"project"`
	ServerConfig       serverConfig    `yaml:"server"`
	DatabaseConfig     databaseConfig  `yaml:"database"`
	CasbinConfig       casbinConfig    `yaml:"casbin"`
	AdminUserConfig    adminUserConfig `yaml:"admin"`
	RoleConfigFilePath string          `yaml:"role_config_file_path"`
}

func LoadConfig(configFile string) (*TemplateConfig, error) {
	if utils.IsStringEmpty(configFile) {
		return nil, errors.New("没有传递必要的参数")
	}

	if !utils.PathExists(configFile) {
		return nil, errors.New("配置文件不存在")
	}

	conf := new(TemplateConfig)
	yamlFile, err := ioutil.ReadFile(configFile)
	if err != nil {
		return nil, err
	}

	err = yaml.Unmarshal(yamlFile, conf)
	if err != nil {
		return nil, err
	}

	return conf, nil
}
