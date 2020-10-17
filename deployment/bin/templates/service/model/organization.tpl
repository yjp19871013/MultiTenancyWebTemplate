package model

import "{{ .ProjectConfig.PackageName }}/db"

type OrganizationInfo struct {
	ID                 uint64
	Name               string
	ResourceIdentifier string
}

func TransferOrganizationToOrganizationInfo(org *db.Organization) *OrganizationInfo {
	if org == nil {
		return &OrganizationInfo{}
	}

	return &OrganizationInfo{
		ID:                 org.ID,
        Name:               org.Name,
        ResourceIdentifier: org.ResourceIdentifier,
	}
}

func TransferOrganizationToOrganizationInfoWithIDBatch(orgs []db.Organization) []OrganizationInfo {
	retOrgInfos := make([]OrganizationInfo, 0)

	if orgs == nil {
		return retOrgInfos
	}

	for _, org := range orgs {
		retOrgInfos = append(retOrgInfos, *TransferOrganizationToOrganizationInfo(&org))
	}

	return retOrgInfos
}
