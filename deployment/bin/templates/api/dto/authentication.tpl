package dto

type GetAccessTokenRequest struct {
	Username string `json:"username" binding:"required,excludes= "`
	Password string `json:"password" binding:"required"`
}

type GetAccessTokenResponse struct {
	MsgResponse
	AccessToken string `json:"accessToken" binding:"required,excludes= "`
}
