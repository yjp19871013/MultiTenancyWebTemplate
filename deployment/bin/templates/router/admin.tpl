package router

import (
	"github.com/gin-gonic/gin"
	"{{ .ProjectConfig.PackageName }}/api/admin"
	"{{ .ProjectConfig.PackageName }}/api/middleware"
)

var (
	adminPostRouter = map[string][]gin.HandlerFunc{
		"/organization":                 {admin.CreateOrganization},
        "/user":                         {middleware.CheckOrganizationIDJson(), admin.CreateUser},
        "/add/users/organization":       {middleware.CheckOrganizationIDJson(), admin.AddUsersToOrganization},
        "/set/user/currentOrganization": {admin.SetUserCurrentOrganization},
	}

	adminDeleteRouter = map[string][]gin.HandlerFunc{
		"/user/:id": {middleware.CheckOrganizationIDQuery(), admin.DeleteUser},

		"/delete/users/:userIds": {
            middleware.CheckOrganizationIDQuery(), admin.DeleteUsersFromOrganization,
        },
	}

	adminPutRouter = map[string][]gin.HandlerFunc{
		"/user": {middleware.CheckOrganizationIDJson(), admin.UpdateUserPassword},
	}

	adminGetRouter = map[string][]gin.HandlerFunc{
	    "/organizations": {admin.GetOrganizations},
		"/roles":         {admin.GetRoles},
		"/users":         {admin.GetUsers},

		"/organization/:orgId/users": {admin.GetUsersInOrganization},
	}
)

func initAdminRouter(r *gin.Engine) {
	groupAdmin := r.Group(urlPrefix+"/api/admin", middleware.Authentication())

	for path, f := range adminGetRouter {
		groupAdmin.GET(path, f...)
	}

	for path, f := range adminPostRouter {
		groupAdmin.POST(path, f...)
	}

	for path, f := range adminDeleteRouter {
		groupAdmin.DELETE(path, f...)
	}

	for path, f := range adminPutRouter {
		groupAdmin.PUT(path, f...)
	}
}
