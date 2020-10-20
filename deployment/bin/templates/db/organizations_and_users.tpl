package db

import (
    "gorm.io/gorm"
    "{{ .ProjectConfig.PackageName }}/utils"
)

const (
	OrganizationsAndUsersColumnUserID = "organizations_and_users.user_id"
)

func AddUsersToOrganization(orgID uint64, users []User) error {
	if orgID == 0 || users == nil || len(users) == 0 {
		return ErrParam
	}

	return getInstance().Model(&Organization{ID: orgID}).Association("Users").Append(&users)
}

func DeleteUsersFromOrganization(orgID uint64, users []User) error {
	if orgID == 0 || users == nil || len(users) == 0 {
		return ErrParam
	}

	return getInstance().Model(&Organization{ID: orgID}).Association("Users").Delete(&users)
}

type OrganizationsAndUsersQuery struct {
	db *gorm.DB
}

func NewOrganizationsAndUsersQuery() *OrganizationsAndUsersQuery {
	query := new(OrganizationsAndUsersQuery)
	query.db = getInstance()

	return query
}

func (query *OrganizationsAndUsersQuery) SetUserID(userID uint64) *OrganizationsAndUsersQuery {
	if userID != 0 {
		query.db = query.db.Where(OrganizationsAndUsersColumnUserID+" = ?", userID)
	}

	return query
}

func (query *OrganizationsAndUsersQuery) NotUserName(userName string) *OrganizationsAndUsersQuery {
    if !utils.IsStringEmpty(userName) {
        query.db = query.db.Not(UserColumnUserName+" = ?", userName)
    }

    return query
}

func (query *OrganizationsAndUsersQuery) GetOrganizationsOfUser(userID uint64, pageNo int, pageSize int) ([]Organization, error) {
	if userID == 0 {
		return nil, ErrParam
	}

	if pageNo != 0 && pageSize != 0 {
		offset := (pageNo - 1) * pageSize
		query.db = query.db.Offset(offset).Limit(pageSize)
	}

	organizations := make([]Organization, 0)
	err := query.db.Model(&User{ID: userID}).Association("Organizations").Find(&organizations)
	if err != nil {
		return nil, err
	}

	if len(organizations) == 0 {
		return nil, ErrRecordNotExist
	}

	return organizations, nil
}

func (query *OrganizationsAndUsersQuery) GetUsersInOrganization(orgID uint64, pageNo int, pageSize int) ([]User, error) {
	if orgID == 0 {
		return nil, ErrParam
	}

	if pageNo != 0 && pageSize != 0 {
		offset := (pageNo - 1) * pageSize
		query.db = query.db.Offset(offset).Limit(pageSize)
	}

	users := make([]User, 0)
	err := query.db.Model(&Organization{ID: orgID}).Association("Users").Find(&users)
	if err != nil {
		return nil, err
	}

	if len(users) == 0 {
		return nil, ErrRecordNotExist
	}

	return users, nil
}

func (query *OrganizationsAndUsersQuery) CountUsersInOrganization(orgID uint64) (int64, error) {
	if orgID == 0 {
		return 0, ErrParam
	}

	return query.db.Model(&Organization{ID: orgID}).Association("Users").Count(), nil
}

