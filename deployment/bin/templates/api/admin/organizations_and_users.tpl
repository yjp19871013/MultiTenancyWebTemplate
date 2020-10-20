package admin

import (
	"errors"
	"github.com/gin-gonic/gin"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/log"
	"{{ .ProjectConfig.PackageName }}/service"
	"{{ .ProjectConfig.PackageName }}/utils"
	"strconv"
)

// AddUsersToOrganization godoc
// @Summary 用户添加到组织
// @Description 用户添加到组织
// @Tags (admin)组织-用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param AdminAddUsersToOrganizationRequest body dto.AdminAddUsersToOrganizationRequest true "用户添加到组织信息"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/add/users/organization [post]
func AddUsersToOrganization(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("AddUsersToOrganization", err.Error())
		}
	}()

	request := new(dto.AdminAddUsersToOrganizationRequest)
	err = c.ShouldBindJSON(request)
	if err != nil {
		dto.Response400Json(c, err)
		return
	}

	err = service.AddUsersToOrganization(request.OrgID, request.UserIDs)
	if err != nil {
		dto.Response200FailJson(c, err)
		return
	}

	dto.Response200Json(c, "用户添加到组织成功")
}

// DeleteUsersFromOrganization godoc
// @Summary 从组织删除用户
// @Description 从组织删除用户
// @Tags (admin)组织-用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param userIds path string true "用户ID"
// @Param orgId query uint64 true "组织ID"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/delete/users/{userIds} [delete]
func DeleteUsersFromOrganization(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("DeleteUsersFromOrganization", err.Error())
		}
	}()

	userIDsStr := c.Param("userIds")
	if utils.IsStringEmpty(userIDsStr) {
		dto.Response400Json(c, errors.New("没有传递用户ID"))
		return
	}

	userIDs, err := utils.SpiltIDs(userIDsStr)
	if err != nil {
		dto.Response400Json(c, err)
		return
	}

	query := new(dto.AdminDeleteUsersFromOrganizationQuery)
    err = c.ShouldBindQuery(query)
    if err != nil {
        dto.Response400Json(c, err)
        return
    }

    err = service.DeleteUsersFromOrganization(query.OrgID, userIDs)
    if err != nil {
        dto.Response200FailJson(c, err)
        return
    }

	dto.Response200Json(c, "从组织删除用户成功")
}

// GetUsersInOrganization godoc
// @Summary 获取组织包含的用户
// @Description 获取组织包含的用户
// @Tags (admin)组织-用户管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param orgId path uint64 true "组织ID"
// @Param userId path uint64 true "用户ID"
// @Param pageNo query uint false "页码"
// @Param pageSize query uint false "页大小"
// @Success 200 {object} dto.GetUsersResponse
// @Failure 400 {object} dto.GetUsersResponse
// @Failure 500 {object} dto.GetUsersResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/organization/{orgId}/users [get]
func GetUsersInOrganization(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("GetUsersInOrganization", err.Error())
		}
	}()

	orgIDStr := c.Param("orgId")
	if utils.IsStringEmpty(orgIDStr) {
		c.JSON(http.StatusBadRequest, dto.GetUsersResponse{
			MsgResponse: dto.FormFailureMsgResponse("获取组织包含的用户失败", errors.New("没有传递组织ID")),
			TotalCount:  0,
			Infos:       dto.FormUserInfoWithIDBatch(nil),
		})
		return
	}

	orgID, err := strconv.ParseUint(orgIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.GetUsersResponse{
			MsgResponse: dto.FormFailureMsgResponse("获取组织包含的用户失败", err),
			TotalCount:  0,
			Infos:       dto.FormUserInfoWithIDBatch(nil),
		})
		return
	}

	query := new(dto.AdminGetUsersInOrganizationQuery)
	err = c.ShouldBindQuery(query)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.GetUsersResponse{
			MsgResponse: dto.FormFailureMsgResponse("获取组织包含的用户失败", err),
			TotalCount:  0,
			Infos:       dto.FormUserInfoWithIDBatch(nil),
		})
		return
	}

	users, totalCount, err := service.GetUsersInOrganization(orgID, query.UserID, query.PageNo, query.PageSize)
	if err != nil {
		c.JSON(http.StatusOK, dto.GetUsersResponse{
			MsgResponse: dto.FormFailureMsgResponse("获取组织包含的用户失败", err),
			TotalCount:  0,
			Infos:       dto.FormUserInfoWithIDBatch(nil),
		})
		return
	}

	c.JSON(http.StatusOK, dto.GetUsersResponse{
		MsgResponse: dto.FormSuccessMsgResponse("获取组织包含的用户成功"),
		TotalCount:  totalCount,
		Infos:       dto.FormUserInfoWithIDBatch(users),
	})
}