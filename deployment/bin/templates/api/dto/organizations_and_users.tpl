package dto

type (
	AdminAddUsersToOrganizationRequest struct {
		OrgID   uint64   `json:"orgId" binding:"required"`
		UserIDs []uint64 `json:"userIds" binding:"required"`
	}

    AdminDeleteUsersFromOrganizationQuery struct {
        OrgID   uint64   `form:"orgId" binding:"required"`
    }

	AdminGetUsersInOrganizationQuery struct {
	    UserID   uint64 `form:"userId"`
		PageNo   int    `form:"pageNo"`
		PageSize int    `form:"pageSize"`
	}
)
