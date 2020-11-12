package admin

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/service"
	"{{ .ProjectConfig.PackageName }}/log"
	"{{ .ProjectConfig.PackageName }}/utils"
	"errors"
    "github.com/gin-gonic/gin"
    "net/http"
    "strconv"
)

// CreateOrganization godoc
// @Summary 创建组织
// @Description 创建组织
// @Tags (admin)组织管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param CreateOrganizationRequest body dto.CreateOrganizationRequest true "创建组织的信息"
// @Success 200 {object} dto.CreateOrganizationResponse
// @Failure 400 {object} dto.CreateOrganizationResponse
// @Failure 401 {object} dto.CreateOrganizationResponse
// @Failure 500 {object} dto.CreateOrganizationResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/organization [post]
func CreateOrganization(c *gin.Context) {
    var err error

    defer func() {
        if err != nil {
            log.Error("CreateOrganization", err.Error())
        }
    }()

    formFailureResponse := func() *dto.CreateOrganizationResponse {
        return &dto.CreateOrganizationResponse{
            MsgResponse:            dto.FormFailureMsgResponse("创建组织失败", err),
            OrganizationInfoWithID: *dto.FormOrganizationInfoWithID(nil),
        }
    }

	request := new(dto.CreateOrganizationRequest)
	err = c.ShouldBindJSON(request)
	if err != nil {
		c.JSON(http.StatusBadRequest, *formFailureResponse())
		return
	}

	orgInfo, err := service.CreateOrganization(request.Name)
	if err != nil {
		c.JSON(http.StatusOK, *formFailureResponse())
		return
	}

	c.JSON(http.StatusOK, dto.CreateOrganizationResponse{
		MsgResponse:            dto.FormSuccessMsgResponse("创建组织成功"),
		OrganizationInfoWithID: *dto.FormOrganizationInfoWithID(orgInfo),
	})
}

// DeleteOrganization godoc
// @Summary 删除组织
// @Description 删除用户
// @Tags (admin)组织管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param orgId query uint64 true "组织ID"
// @Success 200 {object} dto.MsgResponse
// @Failure 400 {object} dto.MsgResponse
// @Failure 500 {object} dto.MsgResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/organization/{orgId} [delete]
func DeleteOrganization(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("DeleteOrganization", err.Error())
		}
	}()

	orgIDStr := c.Param("orgId")
	if utils.IsStringEmpty(orgIDStr) {
		dto.Response400Json(c, errors.New("没有传递用户ID"))
		return
	}

	orgID, err := strconv.ParseUint(orgIDStr, 10, 64)
	if err != nil {
		dto.Response400Json(c, err)
		return
	}

	err = service.DeleteOrganization(orgID)
	if err != nil {
		dto.Response200FailJson(c, err)
		return
	}

	dto.Response200Json(c, "删除组织成功")
}

// GetOrganizations godoc
// @Summary 获取组织
// @Description 获取组织
// @Tags (admin)组织管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
// @Param orgId query uint64 false "组织ID"
// @Param pageNo query string false "页码"
// @Param pageSize query string false "页大小"
// @Success 200 {object} dto.GetOrganizationsResponse
// @Failure 400 {object} dto.GetOrganizationsResponse
// @Failure 500 {object} dto.GetOrganizationsResponse
// @Router /{{ .ProjectConfig.UrlPrefix }}/api/admin/organizations [get]
func GetOrganizations(c *gin.Context) {
	var err error

	defer func() {
		if err != nil {
			log.Error("GetOrganizations", err.Error())
		}
	}()

	formFailureResponse := func() *dto.GetOrganizationsResponse {
        return &dto.GetOrganizationsResponse{
            MsgResponse:   dto.FormFailureMsgResponse("获取组织失败", err),
            TotalCount:    0,
            Organizations: dto.FormOrganizationInfoWithIDBatch(nil),
        }
    }

	query := new(dto.GetOrganizationsQuery)
	err = c.ShouldBindQuery(query)
	if err != nil {
		c.JSON(http.StatusBadRequest, *formFailureResponse())
		return
	}

	orgInfos, totalCount, err := service.GetOrganizations(query.OrgID, query.PageNo, query.PageSize)
	if err != nil {
		c.JSON(http.StatusOK, *formFailureResponse())
		return
	}

	c.JSON(http.StatusOK, dto.GetOrganizationsResponse{
		MsgResponse:   dto.FormSuccessMsgResponse("获取组织成功"),
		TotalCount:    totalCount,
		Organizations: dto.FormOrganizationInfoWithIDBatch(orgInfos),
	})
}

