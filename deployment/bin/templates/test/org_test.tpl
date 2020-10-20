package test

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"net/http"
	"testing"
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
