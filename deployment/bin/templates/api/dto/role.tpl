package dto

type GetRoleNamesResponse struct {
	MsgResponse
	RoleNames []string `json:"roleNames" binding:"required"`
}