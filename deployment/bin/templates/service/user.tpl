package service

import (
	"{{ .ProjectConfig.PackageName }}/casbin"
	"{{ .ProjectConfig.PackageName }}/db"
	"{{ .ProjectConfig.PackageName }}/service/model"
	"{{ .ProjectConfig.PackageName }}/utils"
)

const (
	userPasswordKey = "fs0351su123per"
)

const (
	userAccessTokenExpSec = 3 * 3600
)

const (
	adminUserName     = "{{ .AdminUserConfig.Username }}"
    adminUserPassword = "{{ .AdminUserConfig.Password }}"
    adminUserRoleName = "{{ .AdminUserConfig.Role }}"
)

func initAdmin(orgInfo *model.OrganizationInfo) error {
    if orgInfo == nil {
        return model.ErrParam
    }

	exist, err := db.NewUserQuery().SetOrganizationID(orgInfo.ID).SetUserName(adminUserName).CheckCount(1)
    if err != nil {
        return err
    }

    if exist {
        return nil
    }

    userInfo, err := CreateSuperAdminUser(orgInfo, adminUserName, adminUserPassword)
    if err != nil {
        return err
    }

    err = db.AddUsersToOrganization(orgInfo.ID, []db.User{db.User{ID: userInfo.ID}})
    if err != nil {
        return err
    }

    return nil
}

func CreateSuperAdminUser(orgInfo *model.OrganizationInfo, username string, password string) (*model.UserInfo, error) {
	if orgInfo == nil || utils.IsStringEmpty(username) || utils.IsStringEmpty(password) {
		return nil, model.ErrParam
	}

	return createUser(orgInfo, username, password, adminUserRoleName)
}

func CreateCommonUser(orgInfo *model.OrganizationInfo, username string, password string, roleName string) (*model.UserInfo, error) {
	if orgInfo == nil || utils.IsStringEmpty(username) || utils.IsStringEmpty(password) || utils.IsStringEmpty(roleName) {
		return nil, model.ErrParam
	}

	if roleName == adminUserRoleName {
		return nil, model.ErrRoleNotExist
	}

	return createUser(orgInfo, username, password, roleName)
}

func UpdateCommonUserPassword(orgID uint64, id uint64, password string) error {
	if orgID == 0 || id == 0 || utils.IsStringEmpty(password) {
		return model.ErrParam
	}

	_, err := db.NewUserQuery().SetOrganizationID(orgID).SetID(id).NotUserName(adminUserName).QueryOne()
	if err != nil {
		if err == db.ErrRecordNotExist {
			return model.ErrUserNotExist
		}

		return err
	}

	userData := map[string]interface{}{
		db.UserColumnPassword: utils.Hmac(userPasswordKey, password),
	}

	return db.NewUserQuery().SetOrganizationID(orgID).SetID(id).Updates(userData)
}

func DeleteCommonUser(orgInfo *model.OrganizationInfo, id uint64) error {
	if orgInfo == nil || id == 0 {
		return model.ErrParam
	}

	user, err := db.NewUserQuery().SetOrganizationID(orgInfo.ID).SetID(id).NotUserName(adminUserName).QueryOne()
	if err != nil {
		if err == db.ErrRecordNotExist {
			return model.ErrUserNotExist
		}

		return err
	}

	err = casbin.DeleteRoleForUser(orgInfo.Name, user.ID, user.Role)
	if err != nil {
		return err
	}

	err = user.DeleteByOrgIDAndID()
    if err != nil {
        return err
    }

	return nil
}

func GetUserOrgIDByToken(token string) (*model.OrganizationInfo, *model.UserInfo, error) {
	if utils.IsStringEmpty(token) {
		return nil, nil, model.ErrParam
	}

	user, err := db.NewUserQuery().SetToken(token).QueryOne()
	if err != nil {
		if err == db.ErrRecordNotExist {
			return nil, nil, model.ErrUserNotExist
		}

		return nil, nil, err
	}

	organizations, err := db.NewOrganizationsAndUsersQuery().GetOrganizationsOfUser(user.ID, 0, 0)
	if err != nil {
	    if err == db.ErrRecordNotExist {
	        return nil, nil, model.ErrOrganizationNotExist
	    }

		return nil, nil, err
	}

	var findOrganization *db.Organization
	for _, organization := range organizations {
		if organization.ID == user.OrganizationID {
			findOrganization = &organization
		}
	}

	if findOrganization == nil {
		return nil, nil, model.ErrUserCurrentOrganizationNotExist
	}

	return model.TransferOrganizationToOrganizationInfo(findOrganization), model.TransferUserToUserInfo(user), nil
}

func createUser(orgInfo *model.OrganizationInfo, username string, password string, roleName string) (*model.UserInfo, error) {
	roleExist, err := casbin.HasRole(roleName)
	if err != nil {
		return nil, err
	}

	if !roleExist {
		return nil, model.ErrRoleNotExist
	}

	user := &db.User{
		UserName:       username,
		Password:       utils.Hmac(userPasswordKey, password),
		Role:           roleName,
		OrganizationID: orgInfo.ID,
	}

	err = user.Create()
	if err != nil {
	    if err == db.ErrRecordHasExist {
            return nil, model.ErrUserHasExist
        }

		return nil, err
	}

	err = casbin.AddRoleForUser(orgInfo.Name, user.ID, user.Role)
	if err != nil {
		return nil, err
	}

	return model.TransferUserToUserInfo(user), err
}

func GetUsers(orgID uint64, userID uint64, pageNo int, pageSize int) ([]model.UserInfo, int64, error) {
	users, err := db.NewUserQuery().SetOrganizationID(orgID).SetID(userID).NotUserName(adminUserName).
	    OrderByDesc(db.UserColumnID).Query(pageNo, pageSize)
	if err != nil {
	    if err == db.ErrRecordNotExist {
	        return make([]model.UserInfo, 0), 0, nil
	    }

		return nil, 0, err
	}

	totalCount, err := db.NewUserQuery().SetOrganizationID(orgID).SetID(userID).NotUserName(adminUserName).Count()
	if err != nil {
		return nil, 0, err
	}

	return model.TransferUserToUserInfoBatch(users), totalCount, nil
}

func SetUserCurrentOrganization(userID uint64, currentOrgID uint64) error {
	if userID == 0 || currentOrgID == 0 {
		return model.ErrParam
	}

	orgExist, err := db.NewOrganizationQuery().SetID(currentOrgID).NotName(adminOrganizationName).CheckCount(1)
	if err != nil {
		return err
	}

	if !orgExist {
		return model.ErrOrganizationNotExist
	}

	userExist, err := db.NewUserQuery().SetID(userID).NotUserName(adminUserName).CheckCount(1)
	if err != nil {
		return err
	}

	if !userExist {
	    return model.ErrUserNotExist
	}

	organizations, err := db.NewOrganizationsAndUsersQuery().GetOrganizationsOfUser(userID, 0, 0)
	if err != nil {
	    if err == db.ErrRecordNotExist {
            return model.ErrUserCurrentOrganizationNotExist
        }

		return err
	}

	find := false
	for _, organization := range organizations {
		if organization.ID == currentOrgID {
			find = true
		}
	}

	if !find {
		return model.ErrUserCurrentOrganizationNotExist
	}

	updateData := map[string]interface{} {
		db.UserColumnOrganizationID: currentOrgID,
	}

	return db.NewUserQuery().SetID(userID).Updates(updateData)
}
