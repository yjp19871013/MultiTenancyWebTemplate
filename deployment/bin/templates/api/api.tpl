package api

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/config"
)

// Version godoc
// @Summary 获取平台版本
// @Description 获取平台版本
// @Tags 获取平台版本
// @Success 200 {string} string
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/version [get]
func Version(c *gin.Context) {
	c.String(http.StatusOK, "Version: "+config.Get{{ .ProjectConfig.ProjectName }}Config().Version)
}
