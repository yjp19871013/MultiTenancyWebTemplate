package admin

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/log"
	"{{ .ProjectConfig.PackageName }}/service"
)

// GetRoles godoc
// @Summary 获取角色
// @Description 获取角色
// @Tags (admin)角色管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Success 200 {object} dto.GetRoleNamesResponse
// @Failure 400 {object} dto.GetRoleNamesResponse
// @Failure 500 {object} dto.GetRoleNamesResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/roles [get]
func GetRoles(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("GetRoles", err.Error())
		}
	}()

	roleNames, err := service.GetRoles()
	if err != nil {
		c.JSON(http.StatusOK, dto.GetRoleNamesResponse{
			MsgResponse: dto.FormSuccessMsgResponse("获取角色成功"),
			RoleNames:   make([]string, 0),
		})
		return
	}

	c.JSON(http.StatusOK, dto.GetRoleNamesResponse{
		MsgResponse: dto.FormSuccessMsgResponse("获取角色成功"),
		RoleNames:   roleNames,
	})
}
