package test

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/utils"
	"net/http"
	"testing"
	"strings"
	"strconv"
)

func TestOrganizationCreateAndDelete(t *testing.T) {
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		CreateOrganization(nil).DeleteOrganization()
}

func TestGetAllOrganizations(t *testing.T) {
	getOrganizationsResponse := new(dto.GetOrganizationsResponse)
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("pageNo", "0").
		SetQueryParams("pageSize", "0").
		SetJsonResponse(getOrganizationsResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/organizations", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getOrganizationsResponse.Success, getOrganizationsResponse.Msg).
		AssertGreaterOrEqual(getOrganizationsResponse.TotalCount, int64(0)).
		AssertEqual(int64(len(getOrganizationsResponse.Organizations)), getOrganizationsResponse.TotalCount)
}

func TestGetOrganizationsPaging(t *testing.T) {
	getOrganizationsResponse := new(dto.GetOrganizationsResponse)
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("pageNo", "1").
		SetQueryParams("pageSize", "10").
		SetJsonResponse(getOrganizationsResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/organizations", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getOrganizationsResponse.Success, getOrganizationsResponse.Msg).
		AssertGreaterOrEqual(int64(10), int64(len(getOrganizationsResponse.Organizations))).
		AssertGreaterOrEqual(getOrganizationsResponse.TotalCount, int64(0))
}

func (toolKit *ToolKit) CreateOrganization(orgInfo *dto.OrganizationInfoWithID) *ToolKit {
	uuid, err := utils.GetUUID()
	if err != nil {
		toolKit.t.Fatal("生成uuid失败")
	}

	orgName := "测试" + strings.Split(uuid, "-")[0]

	createOrganizationResponse := new(dto.CreateOrganizationResponse)
	getOrganizationsResponse := new(dto.GetOrganizationsResponse)

	NewToolKit(toolKit.t).SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetJsonBody(&dto.CreateOrganizationRequest{
			OrganizationInfo: dto.OrganizationInfo{Name: orgName},
		}).
		SetJsonResponse(createOrganizationResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/organization", http.MethodPost).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, createOrganizationResponse.Success, createOrganizationResponse.Msg).
		AssertNotEqual(0, createOrganizationResponse.ID).
		AssertEqual(orgName, createOrganizationResponse.Name).
		SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("orgId", strconv.FormatUint(createOrganizationResponse.ID, 10)).
		SetQueryParams("pageNo", "1").
		SetQueryParams("pageSize", "1").
		SetJsonResponse(getOrganizationsResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/organizations", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getOrganizationsResponse.Success, getOrganizationsResponse.Msg).
		AssertEqual(int64(1), getOrganizationsResponse.TotalCount).
		AssertEqual(createOrganizationResponse.ID, getOrganizationsResponse.Organizations[0].ID).
		AssertEqual(orgName, getOrganizationsResponse.Organizations[0].Name)

	toolKit.orgInfo = &createOrganizationResponse.OrganizationInfoWithID

	if orgInfo != nil {
		createOrganizationResponseOrgInfo := createOrganizationResponse.OrganizationInfoWithID
		orgInfo.ID = createOrganizationResponseOrgInfo.ID
		orgInfo.Name = createOrganizationResponseOrgInfo.Name
	}

	return toolKit
}

func (toolKit *ToolKit) DeleteOrganization() *ToolKit {
	deleteOrganizationResponse := new(dto.MsgResponse)

	NewToolKit(toolKit.t).SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetJsonResponse(deleteOrganizationResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/organization/"+strconv.FormatUint(toolKit.orgInfo.ID, 10), http.MethodDelete).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, deleteOrganizationResponse.Success, deleteOrganizationResponse.Msg)

	toolKit.orgInfo = nil

	return toolKit
}
