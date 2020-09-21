package dto

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

// MsgResponse 响应消息体
type MsgResponse struct {
	// 成功 true 失败 false
	Success bool `json:"success"`

	// 消息
	Msg string `json:"msg"`
}

// Response400Json 返回400
func Response400Json(c *gin.Context, err error) {
	c.JSON(http.StatusBadRequest, FormFailureMsgResponse("参数不正确", err))
}

// Response401Json 返回401
func Response401Json(c *gin.Context, err error) {
	c.JSON(http.StatusUnauthorized, FormFailureMsgResponse("鉴权失败", err))
}

// Response500Json 返回500
func Response500Json(c *gin.Context, err error) {
	c.JSON(http.StatusInternalServerError, FormFailureMsgResponse("执行失败", err))
}

// Response200Json 执行成功,返回200
func Response200Json(c *gin.Context, msg string) {
	c.JSON(http.StatusOK, FormSuccessMsgResponse(msg))
}

// Response200FailJson 执行失败,返回200
func Response200FailJson(c *gin.Context, err error) {
	c.JSON(http.StatusOK, FormFailureMsgResponse("", err))
}

// FormSuccessMsgResponse 构造成功消息响应
func FormSuccessMsgResponse(msg string) MsgResponse {
	return MsgResponse{
		Success: true,
		Msg:     msg,
	}
}

// FormFailureMsgResponse 构造失败消息响应
func FormFailureMsgResponse(prefix string, err error) MsgResponse {
	msg := prefix
	if err != nil {
		if msg != "" {
			msg = msg + ": "
		}
		msg = msg + err.Error()
	}

	return MsgResponse{
		Success: false,
		Msg:     msg,
	}
}
