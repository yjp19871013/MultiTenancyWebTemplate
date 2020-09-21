package db

import (
    "gorm.io/gorm"
	"{{ .ProjectConfig.PackageName }}/utils"
	"strings"
)

const (
	OrganizationColumnID                 = "id"
	OrganizationColumnName               = "name"
	OrganizationColumnResourceIdentifier = "resource_identifier"
)

type Organization struct {
	ID                 uint64 `gorm:"primary_key;"`
	Name               string `gorm:"not null;unique;type:varchar(512);"`
	ResourceIdentifier string `gorm:"not null;unique;type:varchar(32);"`

	Users []User `gorm:"many2many:organizations_and_users;"`
}

func (organization *Organization) Create() error {
	if utils.IsStringEmpty(organization.Name) {
		return ErrParam
	}

	uuid, err := utils.GetUUID()
	if err != nil {
		return err
	}

	organization.ResourceIdentifier = strings.ReplaceAll(uuid, "-", "")

	err = getInstance().Create(organization).Error
	if err != nil {
		if strings.Contains(err.Error(), dbErrHasExist) {
			return ErrOrganizationHasExist
		}

		return err
	}

	return nil
}

type OrganizationQuery struct {
	db *gorm.DB
}

func NewOrganizationQuery() *OrganizationQuery {
	query := new(OrganizationQuery)
	query.db = getInstance()

	return query
}

func (query *OrganizationQuery) SetID(id uint64) *OrganizationQuery {
	if id != 0 {
		query.db = query.db.Where(OrganizationColumnID+" = ?", id)
	}

	return query
}

func (query *OrganizationQuery) SetIDs(ids []uint64) *OrganizationQuery {
	if ids == nil || len(ids) != 0 {
		query.db = query.db.Where(OrganizationColumnID+" IN (?)", ids)
	}

	return query
}

func (query *OrganizationQuery) SetName(name string) *OrganizationQuery {
	if !utils.IsStringEmpty(name) {
		query.db = query.db.Where(OrganizationColumnName+" = ?", name)
	}

	return query
}

func (query *OrganizationQuery) NotName(name string) *OrganizationQuery {
	if !utils.IsStringEmpty(name) {
		query.db = query.db.Not(OrganizationColumnName+" = ?", name)
	}

	return query
}

func (query *OrganizationQuery) Query(pageNo int, pageSize int) ([]Organization, error) {
	organizations := make([]Organization, 0)

	if pageNo != 0 && pageSize != 0 {
		offset := (pageNo - 1) * pageSize
		query.db = query.db.Offset(offset).Limit(pageSize)
	}

	err := query.db.Find(&organizations).Error
	if err != nil {
		return nil, err
	}

	if len(organizations) == 0 {
		return nil, ErrOrganizationNotExist
	}

	return organizations, nil
}

func (query *OrganizationQuery) QueryOne() (*Organization, error) {
	organization := new(Organization)

	err := query.db.First(organization).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, ErrOrganizationNotExist
		}

		return nil, err
	}

	return organization, nil
}

func (query *OrganizationQuery) Count() (int64, error) {
	var count int64
	err := query.db.Model(&Organization{}).Count(&count).Error
	if err != nil {
		return 0, err
	}

	return count, nil
}

func (query *OrganizationQuery) CheckCount(checkCount int64) (bool, error) {
	var count int64
	err := query.db.Model(&Organization{}).Count(&count).Error
	if err != nil {
		return false, err
	}

	return count == checkCount, nil
}