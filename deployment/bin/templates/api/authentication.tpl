package api

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/log"
	"{{ .ProjectConfig.PackageName }}/service"
)

// Challenge godoc
// @Summary Token检查
// @Description Token检查
// @Tags 登录
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 401 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/challenge [post]
func Challenge(c *gin.Context) {
	dto.Response200Json(c, "成功")
}

// GetAccessToken godoc
// @Summary 获取Token
// @Description 获取Token
// @Tags 登录
// @Accept  json
// @Produce json
// @Param GetAccessTokenRequest body dto.GetAccessTokenRequest true "获取Token信息"
// @Success 200 {object} dto.GetAccessTokenResponse
// @Failure 400 {object} dto.GetAccessTokenResponse
// @Failure 401 {object} dto.GetAccessTokenResponse
// @Failure 500 {object} dto.GetAccessTokenResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/getAccessToken [post]
func GetAccessToken(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("GetAccessToken", err.Error())
		}
	}()

	request := &dto.GetAccessTokenRequest{}
	err = c.ShouldBindJSON(request)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.GetAccessTokenResponse{
			MsgResponse: dto.FormFailureMsgResponse("获取Token失败", err),
			AccessToken: "",
		})
		return
	}

	token, err := service.GetAndUpdateAccessToken(request.Username, request.Password)
	if err != nil {
		c.JSON(http.StatusOK, dto.GetAccessTokenResponse{
			MsgResponse: dto.FormFailureMsgResponse("获取Token失败", err),
			AccessToken: "",
		})
		return
	}

	c.JSON(http.StatusOK, dto.GetAccessTokenResponse{
		MsgResponse: dto.FormSuccessMsgResponse("获取Token成功"),
		AccessToken: token,
	})
}
