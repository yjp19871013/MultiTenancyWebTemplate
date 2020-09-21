package middleware

import (
	"github.com/gin-gonic/gin"
	"io/ioutil"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/api/dto"
)

func ReadBodyData() gin.HandlerFunc {
	return func(c *gin.Context) {
		bodyData, err := ioutil.ReadAll(c.Request.Body)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("读取body失败", err))
			c.Abort()
			return
		}

		_ = c.Request.Body.Close()
		c.Request.Body = nil

		c.Set(contextBodyData, bodyData)

		err = ReloadBodyData(c)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("加载body数据失败", err))
			c.Abort()
			return
		}

		c.Next()
	}
}
