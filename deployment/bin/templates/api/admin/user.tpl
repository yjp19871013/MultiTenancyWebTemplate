package admin

import (
	"errors"
	"github.com/gin-gonic/gin"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/api/middleware"
	"{{ .ProjectConfig.PackageName }}/log"
	"{{ .ProjectConfig.PackageName }}/service"
	"{{ .ProjectConfig.PackageName }}/utils"
	"strconv"
)

// CreateUser godoc
// @Summary 创建用户
// @Description 创建用户
// @Tags (admin)用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param AdminCreateUserRequest body dto.AdminCreateUserRequest true "用户信息"
// @Success 200 {object} dto.CreateUserResponse
// @Failure 400 {object} dto.CreateUserResponse
// @Failure 500 {object} dto.CreateUserResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/user [post]
func CreateUser(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("CreateUser", err.Error())
		}
	}()

	formFailureResponse := func() *dto.CreateUserResponse {
        return &dto.CreateUserResponse{
            MsgResponse: dto.FormFailureMsgResponse("创建用户失败", err),
            UserInfo:    *dto.FormUserInfoWithID(nil),
        }
    }

	request := new(dto.AdminCreateUserRequest)
	err = c.ShouldBindJSON(request)
	if err != nil {
		c.JSON(http.StatusBadRequest, formFailureResponse())
		return
	}

	orgInfo, err := middleware.GetContextParamOrgInfo(c)
    if err != nil {
        c.JSON(http.StatusOK, formFailureResponse())
        return
    }

    userInfo, err := service.CreateCommonUser(orgInfo, request.Username, request.Password, request.RoleName)
    if err != nil {
        c.JSON(http.StatusOK, formFailureResponse())
        return
    }

	c.JSON(http.StatusOK, dto.CreateUserResponse{
		MsgResponse: dto.FormSuccessMsgResponse("创建用户成功"),
		UserInfo:    *dto.FormUserInfoWithID(userInfo),
	})
}

// UpdateUser godoc
// @Summary 修改用户密码
// @Description 修改用户密码
// @Tags (admin)用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param AdminUpdateUserPasswordRequest body dto.AdminUpdateUserPasswordRequest true "修改用户密码请求"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/user [put]
func UpdateUserPassword(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("UpdateUserPassword", err.Error())
		}
	}()

	request := new(dto.AdminUpdateUserPasswordRequest)
	err = c.ShouldBindJSON(request)
	if err != nil {
		dto.Response400Json(c, err)
		return
	}

	err = service.UpdateCommonUserPassword(request.OrgID, request.ID, request.Password)
	if err != nil {
		dto.Response200FailJson(c, err)
		return
	}

	dto.Response200Json(c, "修改用户密码成功")
}

// DeleteUser godoc
// @Summary 删除用户
// @Description 删除用户
// @Tags (admin)用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param userId path uint64 true "用户ID"
// @Param orgId query uint64 true "组织ID"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/user/{userId} [delete]
func DeleteUser(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("DeleteUser", err.Error())
		}
	}()

	userIDStr := c.Param("userId")
	if utils.IsStringEmpty(userIDStr) {
		dto.Response400Json(c, errors.New("没有传递用户ID"))
		return
	}

	userID, err := strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		dto.Response400Json(c, err)
		return
	}

	query := new(dto.AdminDeleteUserQuery)
    err = c.ShouldBindQuery(query)
    if err != nil {
        dto.Response400Json(c, err)
        return
    }

    orgInfo, err := middleware.GetContextParamOrgInfo(c)
    if err != nil {
        dto.Response200FailJson(c, err)
        return
    }

    err = service.DeleteCommonUser(orgInfo, userID)
    if err != nil {
        dto.Response200FailJson(c, err)
        return
    }

	dto.Response200Json(c, "删除用户成功")
}

// GetUsers godoc
// @Summary 获取用户
// @Description 获取用户
// @Tags (admin)用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param orgId query uint64 false "组织ID"
// @Param userId query uint64 false "用户ID"
// @Param pageNo query int false "页码"
// @Param pageSize query int false "页大小"
// @Success 200 {object} dto.GetUsersResponse
// @Failure 400 {object} dto.GetUsersResponse
// @Failure 500 {object} dto.GetUsersResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/users [get]
func GetUsers(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("GetUsers", err.Error())
		}
	}()

    formFailureResponse := func() *dto.GetUsersResponse {
        return &dto.GetUsersResponse{
            MsgResponse: dto.FormFailureMsgResponse("获取用户失败", err),
            TotalCount:  0,
            Infos:       dto.FormUserInfoWithIDBatch(nil),
        }
    }

	query := new(dto.AdminGetUsersQuery)
	err = c.ShouldBindQuery(query)
	if err != nil {
		c.JSON(http.StatusBadRequest, formFailureResponse())
		return
	}

	userInfos, totalCount, err := service.GetUsers(query.OrgID, query.UserID, query.PageNo, query.PageSize)
	if err != nil {
		c.JSON(http.StatusOK, formFailureResponse())
		return
	}

	c.JSON(http.StatusOK, dto.GetUsersResponse{
		MsgResponse: dto.FormSuccessMsgResponse("获取用户成功"),
		TotalCount:  totalCount,
		Infos:       dto.FormUserInfoWithIDBatch(userInfos),
	})
}

// SetUserCurrentOrganization godoc
// @Summary 设置用户当前组织
// @Description 设置用户当前组织
// @Tags (admin)用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param AdminSetUserCurrentOrganizationRequest body dto.AdminSetUserCurrentOrganizationRequest true "设置用户当前组织信息"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/set/user/currentOrganization [post]
func SetUserCurrentOrganization(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("SetUserCurrentOrganization", err.Error())
		}
	}()

	request := new(dto.AdminSetUserCurrentOrganizationRequest)
	err = c.ShouldBindJSON(request)
	if err != nil {
		dto.Response400Json(c, err)
		return
	}

	err = service.SetUserCurrentOrganization(request.UserID, request.CurrentOrgID)
	if err != nil {
		dto.Response200FailJson(c, err)
		return
	}

	dto.Response200Json(c, "设置用户当前组织成功")
}
