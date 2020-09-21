package service

import (
	"{{ .ProjectConfig.PackageName }}/db"
)

// Init 初始化service
func Init() {
	err := db.Open()
	if err != nil {
		panic(err)
	}

    orgInfo, err := initAdminOrganization()
    if err != nil {
        panic(err)
    }

	err = initPermissions(orgInfo)
	if err != nil {
		panic(err)
	}

	err = initAdmin(orgInfo)
	if err != nil {
		panic(err)
	}
}
