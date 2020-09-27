package dto

type GetAccessTokenRequest struct {
	Username string `json:"username" binding:"required,excludes= "`
	Password string `json:"password" binding:"required"`
}

type GetAccessTokenResponse struct {
	MsgResponse
	AccessToken string `json:"accessToken" binding:"required,excludes= "`
}

type ChallengeResponse struct {
	MsgResponse
	Role        string `json:"role" binding:"required"`
	NurseName   string `json:"nurseName" binding:"required"`
}