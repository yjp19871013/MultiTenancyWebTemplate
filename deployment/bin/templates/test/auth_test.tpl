package test

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"net/http"
	"testing"
)

func TestChallenge(t *testing.T) {
	challengeResponse := new(dto.ChallengeResponse)
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword).
		SetHeader("Content-Type", "application/json").
		SetJsonResponse(challengeResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/challenge", http.MethodPost).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, challengeResponse.Success, challengeResponse.Msg).
		AssertEqual("超级管理员", challengeResponse.Role)
}

func (toolKit *ToolKit) GetAccessToken(username string, password string) *ToolKit {
	getAccessTokenResponse := new(dto.GetAccessTokenResponse)

	NewToolKit(toolKit.t).SetHeader("Content-Type", "application/json").
		SetJsonBody(&dto.GetAccessTokenRequest{
			Username: username,
			Password: password,
		}).
		SetJsonResponse(getAccessTokenResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/getAccessToken", http.MethodPost).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, getAccessTokenResponse.Success, getAccessTokenResponse.Msg).
		AssertNotEmpty(getAccessTokenResponse.AccessToken)

	toolKit.token = getAccessTokenResponse.AccessToken

	return toolKit
}
