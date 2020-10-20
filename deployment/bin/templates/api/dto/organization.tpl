package dto

import "{{ .ProjectConfig.PackageName }}/service/model"

type CreateOrganizationRequest struct {
	OrganizationInfo
}

type CreateOrganizationResponse struct {
	MsgResponse
	OrganizationInfoWithID
}

type GetOrganizationsQuery struct {
    ID       uint64 `form:"id"`
	PageNo   int `form:"pageNo"`
	PageSize int `form:"pageSize"`
}

type GetOrganizationsResponse struct {
	MsgResponse
	TotalCount    int64                    `json:"totalCount" binding:"required"`
	Organizations []OrganizationInfoWithID `json:"organizations" binding:"required"`
}

type OrganizationInfo struct {
	Name string `json:"name" binding:"required"`
}

type OrganizationInfoWithID struct {
	ID   uint64 `json:"id" binding:"required"`
	Name string `json:"name" binding:"required"`
}

func FormOrganizationInfoWithID(orgInfo *model.OrganizationInfo) *OrganizationInfoWithID {
	if orgInfo == nil {
		return &OrganizationInfoWithID{}
	}

	return &OrganizationInfoWithID{
		ID:   orgInfo.ID,
		Name: orgInfo.Name,
	}
}

func FormOrganizationInfoWithIDBatch(orgInfos []model.OrganizationInfo) []OrganizationInfoWithID {
	retOrgInfos := make([]OrganizationInfoWithID, 0)

	if orgInfos == nil {
		return retOrgInfos
	}

	for _, orgInfo := range orgInfos {
		retOrgInfos = append(retOrgInfos, *FormOrganizationInfoWithID(&orgInfo))
	}

	return retOrgInfos
}
