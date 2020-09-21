package db

import (
	"gorm.io/gorm"
	"{{ .ProjectConfig.PackageName }}/utils"
	"strings"
)

const (
	UserColumnID             = "id"
	UserColumnUserName       = "user_name"
	UserColumnPassword       = "password"
	UserColumnToken          = "token"
	UserColumnRole           = "role"
	UserColumnOrganizationID = "organization_id"
)

type User struct {
	ID       uint64 `gorm:"primary_key;"`
	UserName string `gorm:"not null;unique;type:varchar(256);"`
	Password string `gorm:"not null;type:varchar(256);"`
	Token    string `gorm:"type:varchar(512)"`
	Role     string `gorm:"not null;type:varchar(128)"`

	Organizations  []Organization `gorm:"many2many:organizations_and_users;"`
    OrganizationID uint64
}

func (user *User) Create() error {
	if user.OrganizationID == 0 || utils.IsStringEmpty(user.UserName) ||
        utils.IsStringEmpty(user.Password) || utils.IsStringEmpty(user.Role) {
        return ErrParam
    }

    err := getInstance().Create(user).Error
    if err != nil {
        if strings.Contains(err.Error(), dbErrHasExist) {
            return ErrUserHasExist
        }

        return err
    }

    return nil
}

func (user *User) Delete() error {
	if user.ID == 0 {
		return ErrParam
	}

	tx := getInstance().Begin()

	err := tx.Model(user).Association("Organizations").Clear()
	if err != nil {
		tx.Rollback()
		return err
	}

	err = tx.Delete(user).Error
	if err != nil {
		tx.Rollback()
		return err
	}

	tx.Commit()

	return nil
}

type UserQuery struct {
	db *gorm.DB
}

func NewUserQuery() *UserQuery {
	query := new(UserQuery)
	query.db = getInstance()

	return query
}

func (query *UserQuery) SetOrganizationID(orgID uint64) *UserQuery {
	if orgID != 0 {
		query.db = query.db.Where(UserColumnOrganizationID+" = ?", orgID)
	}

	return query
}

func (query *UserQuery) SetID(id uint64) *UserQuery {
	if id != 0 {
		query.db = query.db.Where(UserColumnID+" = ?", id)
	}

	return query
}

func (query *UserQuery) SetIDs(ids []uint64) *UserQuery {
	if ids == nil || len(ids) != 0 {
		query.db = query.db.Where(UserColumnID+" IN (?)", ids)
	}

	return query
}

func (query *UserQuery) SetUserName(userName string) *UserQuery {
	if !utils.IsStringEmpty(userName) {
		query.db = query.db.Where(UserColumnUserName+" = ?", userName)
	}

	return query
}

func (query *UserQuery) SetPassword(password string) *UserQuery {
	if !utils.IsStringEmpty(password) {
		query.db = query.db.Where(UserColumnPassword+" = ?", password)
	}

	return query
}

func (query *UserQuery) SetRole(role string) *UserQuery {
	if !utils.IsStringEmpty(role) {
		query.db = query.db.Where(UserColumnRole+" = ?", role)
	}

	return query
}

func (query *UserQuery) SetToken(token string) *UserQuery {
	if !utils.IsStringEmpty(token) {
		query.db = query.db.Where(UserColumnToken+" = ?", token)
	}

	return query
}

func (query *UserQuery) NotUserName(userName string) *UserQuery {
	if !utils.IsStringEmpty(userName) {
		query.db = query.db.Not(UserColumnUserName+" = ?", userName)
	}

	return query
}

func (query *UserQuery) Query(pageNo int, pageSize int) ([]User, error) {
	users := make([]User, 0)

	if pageNo != 0 && pageSize != 0 {
		offset := (pageNo - 1) * pageSize
		query.db = query.db.Offset(offset).Limit(pageSize)
	}

	err := query.db.Find(&users).Error
	if err != nil {
		return nil, err
	}

	if len(users) == 0 {
		return nil, ErrUserNotExist
	}

	return users, nil
}

func (query *UserQuery) QueryOne() (*User, error) {
	user := new(User)

	err := query.db.First(user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrUserNotExist
		}

		return nil, err
	}

	return user, nil
}

func (query *UserQuery) Count() (int64, error) {
	var count int64
	err := query.db.Model(&User{}).Count(&count).Error
	if err != nil {
		return 0, err
	}

	return count, nil
}

func (query *UserQuery) CheckExist() (bool, error) {
	var count int64
	err := query.db.Model(&User{}).Count(&count).Error
	if err != nil {
		return false, err
	}

	return count > 0, nil
}

func (query *UserQuery) CheckCount(checkCount int64) (bool, error) {
	var count int64
	err := query.db.Model(&User{}).Count(&count).Error
	if err != nil {
		return false, err
	}

	return count == checkCount, nil
}

func (query *UserQuery) Updates(updateData map[string]interface{}) error {
	if updateData == nil || len(updateData) == 0 {
		return ErrParam
	}

	return query.db.Model(&User{}).Updates(updateData).Error
}


