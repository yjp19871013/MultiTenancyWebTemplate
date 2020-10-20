package test

import (
	"{{ .ProjectConfig.PackageName }}/api/dto"
	"net/http"
	"testing"
)

func TestChallenge(t *testing.T) {
	challengeResponse := new(dto.ChallengeResponse)
	NewToolKit(t).GetAccessToken(superAdminUsername, superAdminPassword, nil).
		SetHeader("Content-Type", "application/json").
		SetJsonResponse(challengeResponse).
		Request("/{{ .ProjectConfig.UrlPrefix }}/api/challenge", http.MethodPost).
		AssertStatusCode(http.StatusOK).
		AssertEqual(true, challengeResponse.Success, challengeResponse.Msg).
		AssertEqual("超级管理员", challengeResponse.Role)
}
