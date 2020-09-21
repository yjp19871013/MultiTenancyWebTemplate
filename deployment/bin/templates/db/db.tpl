package db

import (
	"fmt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"{{ .ProjectConfig.PackageName }}/config"
)

var gormDb *gorm.DB

// Open 打开数据库
func Open() error {
	mysqlConfig := config.Get{{ .ProjectConfig.ProjectName }}Config().DatabaseConfig
	template := "%s:%s@tcp(%s)/%s?charset=utf8mb4&parseTime=True&loc=Local"
	connStr := fmt.Sprintf(template, mysqlConfig.Username, mysqlConfig.Password, mysqlConfig.Address, mysqlConfig.Schema)
	openDb, err := gorm.Open(mysql.Open(connStr), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return err
	}

	gormDb = openDb

	return autoMigrate(&Organization{}, &User{})
}

// GetInstance 获取数据库实例
func getInstance() *gorm.DB {
	return gormDb
}

func autoMigrate(values ...interface{}) error {
	return gormDb.AutoMigrate(values...)
}
