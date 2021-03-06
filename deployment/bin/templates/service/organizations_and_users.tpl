package service

import (
	"{{ .ProjectConfig.PackageName }}/db"
	"{{ .ProjectConfig.PackageName }}/service/model"
)

func AddUsersToOrganization(orgID uint64, userIDs []uint64) error {
	if orgID == 0 || userIDs == nil || len(userIDs) == 0 {
		return model.ErrParam
	}

	orgExist, err := db.NewOrganizationQuery().SetID(orgID).NotName(adminOrganizationName).CheckCount(1)
	if err != nil {
		return err
	}

	if !orgExist {
		return model.ErrOrganizationNotExist
	}

	users, err := db.NewUserQuery().SetIDs(userIDs).NotUserName(adminUserName).Query(0, 0)
	if err != nil {
	    if err == db.ErrRecordNotExist {
	        return model.ErrUserNotExist
	    }

		return err
	}

	if len(users) != len(userIDs) {
		return model.ErrUserPartialNotExist
	}

	return db.AddUsersToOrganization(orgID, users)
}

func DeleteUsersFromOrganization(orgID uint64, userIDs []uint64) error {
	if orgID == 0 || userIDs == nil || len(userIDs) == 0 {
		return model.ErrParam
	}

	orgExist, err := db.NewOrganizationQuery().SetID(orgID).NotName(adminOrganizationName).CheckCount(1)
	if err != nil {
		return err
	}

	if !orgExist {
		return model.ErrOrganizationNotExist
	}

	users, err := db.NewUserQuery().SetIDs(userIDs).NotUserName(adminUserName).Query(0, 0)
	if err != nil {
	    if err == db.ErrRecordNotExist {
	        return model.ErrUserNotExist
	    }

		return err
	}

	if len(users) != len(userIDs) {
		return model.ErrUserPartialNotExist
	}

	return db.DeleteUsersFromOrganization(orgID, users)
}

func GetUsersInOrganization(orgID uint64, userID uint64, pageNo int, pageSize int) ([]model.UserInfo, int64, error) {
	if orgID == 0 {
		return nil, 0, model.ErrParam
	}

	orgExist, err := db.NewOrganizationQuery().SetID(orgID).NotName(adminOrganizationName).CheckCount(1)
	if err != nil {
		return nil, 0, err
	}

	if !orgExist {
		return nil, 0, model.ErrOrganizationNotExist
	}

	users, err := db.NewOrganizationsAndUsersQuery().SetUserID(userID).NotUserName(adminUserName).
	    GetUsersInOrganization(orgID, pageNo, pageSize)
	if err != nil {
	    if err == db.ErrRecordNotExist {
	        return make([]model.UserInfo, 0), 0, nil
	    }

		return nil, 0, err
	}

	totalCount, err := db.NewOrganizationsAndUsersQuery().SetUserID(userID).
	    NotUserName(adminUserName).CountUsersInOrganization(orgID)
	if err != nil {
		return nil, 0, err
	}

	return model.TransferUserToUserInfoBatch(users), totalCount, nil
}
