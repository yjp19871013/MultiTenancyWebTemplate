package test

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"{{ .ProjectConfig.PackageName }}/utils"
	"net/http"
	"testing"
	"strings"
	"strconv"
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

func (toolKit *ToolKit) CreateUser(password string, role string, userInfo *dto.UserInfoWithID) *ToolKit {
	uuid, err := utils.GetUUID()
	if err != nil {
		toolKit.t.Fatal("生成uuid失败")
	}

	userName := "测试用户" + strings.Split(uuid, "-")[0]

	createUserResponse := new(dto.CreateUserResponse)
	getUsersResponse := new(dto.GetUsersResponse)
	addUsersToOrganizationResponse := new(dto.MsgResponse)
	getUsersInOrganizationResponse := new(dto.GetUsersResponse)

	NewToolKit(toolKit.t).SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetJsonBody(&dto.AdminCreateUserRequest{
			OrgID:    toolKit.orgInfo.ID,
			Password: password,
			UserInfo: dto.UserInfo{
				Username: userName,
				RoleName: role,
			},
		}).
		SetJsonResponse(createUserResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/user", http.MethodPost).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, createUserResponse.Success, createUserResponse.Msg).
		AssertNotEqual(0, createUserResponse.UserInfo.ID).
		AssertEqual(userName, createUserResponse.UserInfo.Username).
		AssertEqual(role, createUserResponse.UserInfo.RoleName).
		SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("orgId", strconv.FormatUint(toolKit.orgInfo.ID, 10)).
		SetQueryParams("userId", strconv.FormatUint(createUserResponse.UserInfo.ID, 10)).
		SetQueryParams("pageNo", "1").
		SetQueryParams("pageSize", "1").
		SetJsonResponse(getUsersResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/users", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getUsersResponse.Success, getUsersResponse.Msg).
		AssertEqual(int64(1), getUsersResponse.TotalCount).
		AssertEqual(createUserResponse.UserInfo.ID, getUsersResponse.Infos[0].ID).
		AssertEqual(createUserResponse.UserInfo.Username, getUsersResponse.Infos[0].Username).
		AssertEqual(createUserResponse.UserInfo.RoleName, getUsersResponse.Infos[0].RoleName).
		SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetJsonBody(&dto.AdminAddUsersToOrganizationRequest{
			OrgID:   toolKit.orgInfo.ID,
			UserIDs: []uint64{createUserResponse.UserInfo.ID},
		}).
		SetJsonResponse(addUsersToOrganizationResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/add/users/organization", http.MethodPost).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, addUsersToOrganizationResponse.Success, addUsersToOrganizationResponse.Msg).
		SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("userId", strconv.FormatUint(createUserResponse.UserInfo.ID, 10)).
		SetQueryParams("pageNo", "1").
		SetQueryParams("pageSize", "1").
		SetJsonResponse(getUsersInOrganizationResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/organization/"+strconv.FormatUint(toolKit.orgInfo.ID, 10)+"/users", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getUsersInOrganizationResponse.Success, getUsersInOrganizationResponse.Msg).
		AssertEqual(int64(1), getUsersInOrganizationResponse.TotalCount).
		AssertEqual(createUserResponse.UserInfo.ID, getUsersInOrganizationResponse.Infos[0].ID).
		AssertEqual(createUserResponse.UserInfo.Username, getUsersInOrganizationResponse.Infos[0].Username).
		AssertEqual(createUserResponse.UserInfo.RoleName, getUsersInOrganizationResponse.Infos[0].RoleName)

	toolKit.userInfo = &createUserResponse.UserInfo

	if userInfo != nil {
		createUserResponseUserInfo := createUserResponse.UserInfo
		userInfo.ID = createUserResponseUserInfo.ID
		userInfo.Username = createUserResponseUserInfo.Username
		userInfo.RoleName = createUserResponseUserInfo.RoleName
	}

	return toolKit
}

func (toolKit *ToolKit) DeleteUser() *ToolKit {
	deleteUsersFromOrganizationResponse := new(dto.MsgResponse)
	deleteUserResponse := new(dto.MsgResponse)

	NewToolKit(toolKit.t).SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("orgId", strconv.FormatUint(toolKit.orgInfo.ID, 10)).
		SetJsonResponse(deleteUsersFromOrganizationResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/delete/users/"+strconv.FormatUint(toolKit.userInfo.ID, 10), http.MethodDelete).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, deleteUsersFromOrganizationResponse.Success, deleteUsersFromOrganizationResponse.Msg).
		SetToken(toolKit.token).
		SetHeader("Content-Type", "application/json").
		SetQueryParams("orgId", strconv.FormatUint(toolKit.orgInfo.ID, 10)).
		SetJsonResponse(deleteUserResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/admin/user/"+strconv.FormatUint(toolKit.userInfo.ID, 10), http.MethodDelete).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, deleteUserResponse.Success, deleteUserResponse.Msg)

	toolKit.userInfo = nil

	return toolKit
}