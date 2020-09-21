package model

import "{{ .ProjectConfig.PackageName }}/db"

type UserInfo struct {
	ID       uint64
	UserName string
	RoleName string
}

func TransferUserToUserInfo(user *db.User) *UserInfo {
	if user == nil {
		return &UserInfo{}
	}

	return &UserInfo{
		ID:       user.ID,
		UserName: user.UserName,
		RoleName: user.Role,
	}
}

func TransferUserToUserInfoBatch(users []db.User) []UserInfo {
	infos := make([]UserInfo, 0)
	if users == nil {
		return infos
	}

	for _, user := range users {
		infos = append(infos, *TransferUserToUserInfo(&user))
	}

	return infos
}
