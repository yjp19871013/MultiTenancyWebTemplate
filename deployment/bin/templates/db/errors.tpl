package db

import "errors"

const (
	dbErrHasExist = "Error 1062"
)

var (
	ErrParam          = errors.New("没有传递必要的参数")
    ErrRecordHasExist = errors.New("记录已存在")
    ErrRecordNotExist = errors.New("记录不存在")
)
