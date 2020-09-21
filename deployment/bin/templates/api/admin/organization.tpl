package admin

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/service"
	"{{ .ProjectConfig.PackageName }}/log"
	"github.com/gin-gonic/gin"
	"net/http"
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

	request := new(dto.CreateOrganizationRequest)
	err = c.ShouldBindJSON(request)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.CreateOrganizationResponse{
			MsgResponse:            dto.FormFailureMsgResponse("创建组织失败", err),
			OrganizationInfoWithID: *dto.FormOrganizationInfoWithID(nil),
		})
		return
	}

	orgInfo, err := service.CreateOrganization(request.Name)
	if err != nil {
		c.JSON(http.StatusOK, dto.CreateOrganizationResponse{
			MsgResponse:            dto.FormFailureMsgResponse("创建组织失败", err),
			OrganizationInfoWithID: *dto.FormOrganizationInfoWithID(nil),
		})
		return
	}

	c.JSON(http.StatusOK, dto.CreateOrganizationResponse{
		MsgResponse:            dto.FormSuccessMsgResponse("创建组织成功"),
		OrganizationInfoWithID: *dto.FormOrganizationInfoWithID(orgInfo),
	})
}

// GetOrganizations godoc
// @Summary 获取组织
// @Description 获取组织
// @Tags (admin)组织管理
// @Accept  json
// @Produce json
// @Param Authorization header string true "Authentication header"
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

	query := new(dto.GetOrganizationsQuery)
	err = c.ShouldBindQuery(query)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.GetOrganizationsResponse{
			MsgResponse:   dto.FormFailureMsgResponse("获取组织失败", err),
			TotalCount:    0,
			Organizations: dto.FormOrganizationInfoWithIDBatch(nil),
		})
		return
	}

	orgInfos, totalCount, err := service.GetOrganizations(query.PageNo, query.PageSize)
	if err != nil {
		c.JSON(http.StatusOK, dto.GetOrganizationsResponse{
			MsgResponse:   dto.FormFailureMsgResponse("获取组织失败", err),
			TotalCount:    0,
			Organizations: dto.FormOrganizationInfoWithIDBatch(nil),
		})
		return
	}

	c.JSON(http.StatusOK, dto.GetOrganizationsResponse{
		MsgResponse:   dto.FormSuccessMsgResponse("获取组织成功"),
		TotalCount:    totalCount,
		Organizations: dto.FormOrganizationInfoWithIDBatch(orgInfos),
	})
}

