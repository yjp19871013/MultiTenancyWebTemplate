package dto

import "{{ .ProjectConfig.PackageName }}/service/model"

type (
	AdminCreateUserRequest struct {
	    OrgID    uint64 `json:"orgId" binding:"required"`
		Password string `json:"password" binding:"required"`
		UserInfo
	}

	AdminUpdateUserPasswordRequest struct {
	    OrgID    uint64 `json:"orgId" binding:"required"`
		ID       uint64 `json:"id" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

    AdminDeleteUserQuery struct {
        OrgID uint64 `form:"orgId" binding:"required"`
    }

	AdminGetUsersQuery struct {
	    OrgID    uint64 `form:"orgId"`
		PageNo   int `form:"pageNo"`
		PageSize int `form:"pageSize"`
	}

	AdminSetUserCurrentOrganizationRequest struct {
        UserID        uint64 `json:"userId" binding:"required"`
        CurrentOrgID  uint64 `json:"currentOrgID" binding:"required"`
    }
)

type CreateUserResponse struct {
	MsgResponse
	ID uint64 `json:"id" binding:"required"`
}

type GetUsersResponse struct {
	MsgResponse
	TotalCount int64            `json:"totalCount" binding:"required"`
	Infos      []UserInfoWithID `json:"infos" binding:"required"`
}

type UserInfo struct {
	Username string `json:"username" binding:"required,excludes= "`
	RoleName string `json:"roleName" binding:"required"`
}

type UserInfoWithID struct {
	ID uint64 `json:"id" binding:"required"`
	UserInfo
}

func FormUserInfo(userInfo *model.UserInfo) *UserInfo {
	if userInfo == nil {
		return &UserInfo{}
	}

	return &UserInfo{
		Username: userInfo.UserName,
		RoleName: userInfo.RoleName,
	}
}

func FormUserInfoWithID(userInfo *model.UserInfo) *UserInfoWithID {
	if userInfo == nil {
		return &UserInfoWithID{}
	}

	return &UserInfoWithID{
		ID:       userInfo.ID,
		UserInfo: *FormUserInfo(userInfo),
	}
}

func FormUserInfoWithIDBatch(userInfos []model.UserInfo) []UserInfoWithID {
	retInfos := make([]UserInfoWithID, 0)
	if userInfos == nil {
		return retInfos
	}

	for _, userInfo := range userInfos {
		retInfos = append(retInfos, *FormUserInfoWithID(&userInfo))
	}

	return retInfos
}
