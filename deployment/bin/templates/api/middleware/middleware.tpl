package middleware

type IDJson struct {
	ID uint64 `json:"id" binding:"required"`
}

type OrganizationIDJson struct {
	OrgID uint64 `json:"orgId" binding:"required"`
}

type OrganizationIDQuery struct {
	OrgID uint64 `form:"orgId" binding:"required"`
}
