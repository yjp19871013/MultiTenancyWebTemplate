package middleware

import (
	"bytes"
	"fmt"
	"github.com/gin-gonic/gin"
	"io/ioutil"
	"{{ .ProjectConfig.PackageName }}/service/model"
)

const (
	contextBodyData    = "context-body-data"
	contextUserInfoKey = "context-user-info"
	contextOrgInfoKey  = "context-org-info"
)

func ReloadBodyData(c *gin.Context) error {
	bodyDataContext, exist := c.Get(contextBodyData)
	if !exist {
		return fmt.Errorf("bodyData不存在")
	}

	bodyData, ok := bodyDataContext.([]byte)
	if !ok {
		return fmt.Errorf("ubodyData转换失败")
	}

	if c.Request.Body != nil {
		_ = c.Request.Body.Close()
		c.Request.Body = nil
	}

	c.Request.Body = ioutil.NopCloser(bytes.NewReader(bodyData))

	return nil
}

func GetContextUserInfo(c *gin.Context) (*model.UserInfo, error) {
	userInfoContext, exist := c.Get(contextUserInfoKey)
	if !exist {
		return nil, fmt.Errorf("userUnfo不存在")
	}

	userInfo, ok := userInfoContext.(*model.UserInfo)
	if !ok {
		return nil, fmt.Errorf("userUnfo转换失败")
	}

	return userInfo, nil
}

func GetContextOrgInfo(c *gin.Context) (*model.OrganizationInfo, error) {
	orgInfo, exist := c.Get(contextOrgInfoKey)
	if !exist {
		return nil, fmt.Errorf("orgInfo不存在")
	}

	retOrgInfo, ok := orgInfo.(*model.OrganizationInfo)
	if !ok {
		return nil, fmt.Errorf("orgInfo转换失败")
	}

	return retOrgInfo, nil
}

