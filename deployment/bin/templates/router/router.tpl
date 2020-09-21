package router

import (
	"github.com/gin-gonic/gin"
	ginSwagger "github.com/swaggo/gin-swagger"
	"github.com/swaggo/gin-swagger/swaggerFiles"
	"{{ .ProjectConfig.PackageName }}/api"
	"{{ .ProjectConfig.PackageName }}/api/middleware"
	_ "{{ .ProjectConfig.PackageName }}/docs"
)

const (
	urlPrefix = "{{ .ProjectConfig.UrlPrefix }}"
)

func InitRouter(r *gin.Engine) {
	r.Use(middleware.Cors(), middleware.ReadBodyData())

	// swagger
	r.GET(urlPrefix+"/api/doc/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// auth
	r.POST(urlPrefix+"/api/getAccessToken", api.GetAccessToken)

	// challenge
	r.POST(urlPrefix+"/api/challenge", middleware.Authentication(), api.Challenge)

	// version
	r.GET(urlPrefix+"/api/version", api.Version)

	initAdminRouter(r)
}
