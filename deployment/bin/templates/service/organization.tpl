package service

import (
	"{{ .ProjectConfig.PackageName }}/db"
	"{{ .ProjectConfig.PackageName }}/service/model"
	"{{ .ProjectConfig.PackageName }}/utils"
	"strings"
)

const (
	adminOrganizationName = "{{ .CasbinConfig.Domain }}"
)

func initAdminOrganization() (*model.OrganizationInfo, error) {
	organization, err := db.NewOrganizationQuery().SetName(adminOrganizationName).QueryOne()
	if err != nil && err != db.ErrOrganizationNotExist {
		return nil, err
	}

	if err == db.ErrOrganizationNotExist {
		organization = &db.Organization{Name: adminOrganizationName}
		err = organization.Create()
		if err != nil {
			return nil, err
		}
	}

	return model.TransferOrganizationToOrganizationInfo(organization), nil
}

func CreateOrganization(name string) (*model.OrganizationInfo, error) {
	if utils.IsStringEmpty(name) {
		return nil, model.ErrParam
	}

	uuid, err := utils.GetUUID()
	if err != nil {
		return nil, err
	}

	org := &db.Organization{
		Name:               name,
		ResourceIdentifier: strings.ReplaceAll(uuid, "-", "")}

	err = org.Create()
	if err != nil {
		return nil, err
	}

	return model.TransferOrganizationToOrganizationInfo(org), nil
}

func GetOrganizationByID(orgID uint64) (*model.OrganizationInfo, error) {
	if orgID == 0 {
		return nil, model.ErrParam
	}

	organization, err := db.NewOrganizationQuery().NotName(adminOrganizationName).SetID(orgID).QueryOne()
	if err != nil {
		if err == db.ErrOrganizationNotExist {
			return nil, model.ErrOrganizationNotExist
		}

		return nil, err
	}

	return model.TransferOrganizationToOrganizationInfo(organization), nil
}

func GetOrganizations(pageNo int, pageSize int) ([]model.OrganizationInfo, int64, error) {
	organizations, err := db.NewOrganizationQuery().NotName(adminOrganizationName).Query(pageNo, pageSize)
	if err != nil && err != db.ErrOrganizationNotExist {
		return nil, 0, err
	}

	totalCount, err := db.NewOrganizationQuery().NotName(adminOrganizationName).Count()
	if err != nil {
		return nil, 0, err
	}

	return model.TransferOrganizationToOrganizationInfoWithIDBatch(organizations), totalCount, nil
}
