# 多租户Web项目模板

一个基于Golang的简单项目模板，结合使用gin,gorm,casbin等框架，实现了多租户的RBAC

使用方法(Linux下运行)

1. 填写deployment/bin/config.yml
2. go run main.go --help 查看使用方法
3. go run main.go [选项] 生成代码
4. 输出目录中有生成的项目可以使用

另外，该项目移除deployment目录后，通过修改config，可以实现自己的模板，用于模板的渲染
