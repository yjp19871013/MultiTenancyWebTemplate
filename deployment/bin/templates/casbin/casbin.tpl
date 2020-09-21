package casbin

import (
	"fmt"
	"github.com/casbin/casbin/v2"
	gormAdapter "github.com/casbin/gorm-adapter/v2"
	_ "github.com/go-sql-driver/mysql"
	"{{ .ProjectConfig.PackageName }}/config"
	"strconv"
)

const (
	casbinSeparator = "::"
)

var enforcer *casbin.Enforcer

func init() {
	template := "%s:%s@tcp(%s)/%s"
	mysqlConfig := config.Get{{ .ProjectConfig.ProjectName }}Config().DatabaseConfig
	connStr := fmt.Sprintf(template, mysqlConfig.Username, mysqlConfig.Password, mysqlConfig.Address, mysqlConfig.Schema)
	a, err := gormAdapter.NewAdapter("mysql", connStr, true)
	if err != nil {
		panic(err)
	}

	enforcer, err = casbin.NewEnforcer(config.Get{{ .ProjectConfig.ProjectName }}Config().CasbinConfig.ConfigFilePath, a)
	if err != nil {
		panic(err)
	}
}

func AddRolePolicy(domain string, roleName string, resource string, action string) error {
	err := enforcer.LoadPolicy()
	if err != nil {
		return err
	}

	_, err = enforcer.AddPolicy(roleName, domain, resource, action)
	if err != nil {
		return err
	}

	return nil
}

func AddRoleForUser(domain string, userID uint64, roleName string) error {
	err := enforcer.LoadPolicy()
	if err != nil {
		return err
	}

	_, err = enforcer.AddGroupingPolicy(FormDomainPrefix(domain, strconv.FormatUint(userID, 10)), roleName, domain)
	if err != nil {
		return err
	}

	return nil
}

func HasPermission(domain string, roleName string, resource string, action string) (bool, error) {
	err := enforcer.LoadPolicy()
	if err != nil {
		return false, err
	}

	return enforcer.HasPolicy(roleName, domain, resource, action), nil
}

func HasRole(roleName string) (bool, error) {
	err := enforcer.LoadPolicy()
	if err != nil {
		return false, err
	}

	policies := enforcer.GetFilteredPolicy(0, roleName)
	if len(policies) == 0 {
		return false, nil
	}

	return true, nil
}

func GetRoleNames(superRoleName string) ([]string, error) {
	err := enforcer.LoadPolicy()
	if err != nil {
		return nil, err
	}

	roleNames := make([]string, 0)
	roleNameMap := make(map[string]bool)
	policies := enforcer.GetFilteredPolicy(0, "")
	for _, p := range policies {
		roleName := p[0]
		exist := roleNameMap[roleName]
		if exist || superRoleName == roleName {
			continue
		}

		roleNames = append(roleNames, roleName)
		roleNameMap[roleName] = true
	}

	return roleNames, nil
}

func DeleteRoleForUser(domain string, userID uint64, roleName string) error {
	err := enforcer.LoadPolicy()
	if err != nil {
		return err
	}

	_, err = enforcer.RemoveGroupingPolicy(FormDomainPrefix(domain, strconv.FormatUint(userID, 10)), roleName)
	if err != nil {
		return err
	}

	return nil
}

func Enforce(rvals ...interface{}) (bool, error) {
	err := enforcer.LoadPolicy()
	if err != nil {
		return false, err
	}

	return enforcer.Enforce(rvals...)
}

func FormDomainPrefix(domain string, value string) string {
	return domain + casbinSeparator + value
}
