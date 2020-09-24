package middleware

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/service"
)

func CheckOrganizationIDJson() gin.HandlerFunc {
	return func(c *gin.Context) {
		request := &OrganizationIDJson{}
		err := c.ShouldBindJSON(request)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("组织ID校验失败", err))
			c.Abort()
			return
		}

		orgInfo, err := service.GetOrganizationByID(request.OrgID)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("组织校验", err))
			c.Abort()
			return
		}

		err = ReloadBodyData(c)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("加载body数据失败", err))
			c.Abort()
			return
		}

		c.Set(contextParamOrgInfoKey, orgInfo)
		c.Next()
	}
}

func CheckOrganizationIDQuery() gin.HandlerFunc {
	return func(c *gin.Context) {
		query := &OrganizationIDQuery{}
		err := c.ShouldBindQuery(query)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("组织ID校验失败", err))
			c.Abort()
			return
		}

		orgInfo, err := service.GetOrganizationByID(query.OrgID)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("组织校验", err))
			c.Abort()
			return
		}

		err = ReloadBodyData(c)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.FormFailureMsgResponse("加载body数据失败", err))
			c.Abort()
			return
		}

		c.Set(contextParamOrgInfoKey, orgInfo)
		c.Next()
	}
}
