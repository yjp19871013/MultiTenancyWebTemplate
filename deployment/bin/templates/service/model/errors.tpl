package model

import "errors"

var (
	ErrParam                           = errors.New("没有传递必要的参数")
    ErrTokenInvalid                    = errors.New("无效的token")
    ErrOrganizationNotExist            = errors.New("组织不存在")
    ErrOrganizationHasExist            = errors.New("组织已存在")
    ErrUserNotExist                    = errors.New("用户不存在")
    ErrUserHasExist                    = errors.New("用户已存在")
    ErrUserPartialNotExist             = errors.New("一些用户不存在")
    ErrRoleNotExist                    = errors.New("角色不存在")
    ErrUserCurrentOrganizationNotExist = errors.New("用户不属于当前组织")
)
