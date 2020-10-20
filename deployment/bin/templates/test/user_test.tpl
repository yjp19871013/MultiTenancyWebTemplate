package test

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"net/http"
	"testing"
)

func TestCreateUserAndDeleteUser(t *testing.T) {
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		CreateOrganization(nil).CreateUser(testUserPassword, adminRoleName, nil).
		DeleteUser().DeleteOrganization()
}

func TestGetAllUsers(t *testing.T) {
	getUsersResponse := new(dto.GetUsersResponse)
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("pageNo", "0").
		SetQueryParams("pageSize", "0").
		SetJsonResponse(getUsersResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/users", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getUsersResponse.Success, getUsersResponse.Msg).
		AssertGreaterOrEqual(getUsersResponse.TotalCount, int64(0)).
		AssertEqual(int64(len(getUsersResponse.Infos)), getUsersResponse.TotalCount)
}

func TestGetUsersPaging(t *testing.T) {
	getUsersResponse := new(dto.GetUsersResponse)
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("pageNo", "1").
		SetQueryParams("pageSize", "10").
		SetJsonResponse(getUsersResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/users", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getUsersResponse.Success, getUsersResponse.Msg).
		AssertGreaterOrEqual(int64(10), int64(len(getUsersResponse.Infos))).
		AssertGreaterOrEqual(getUsersResponse.TotalCount, int64(0))
}

func TestUpdateUserPassword(t *testing.T) {
	var newToken string
	orgInfo := new(dto.OrganizationInfoWithID)
	userInfo := new(dto.UserInfoWithID)
	updateUserPasswordResponse := new(dto.MsgResponse)

	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		CreateOrganization(orgInfo).
		CreateUser(testUserPassword, adminRoleName, userInfo).SetHeader("Content-Type", "application/json").
		SetJsonBody(&dto.AdminUpdateUserPasswordRequest{
			OrgID:    orgInfo.ID,
			ID:       userInfo.ID,
			Password: "456",
		}).
		SetJsonResponse(updateUserPasswordResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/user", http.MethodPut).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, updateUserPasswordResponse.Success, updateUserPasswordResponse.Msg).
		GetAccessToken(userInfo.Username, "456", &newToken).
		AssertNotEmpty(newToken).
		GetAccessToken(superAdminUsername, superAdminPassword, nil).
		DeleteUser().
		DeleteOrganization()
}
