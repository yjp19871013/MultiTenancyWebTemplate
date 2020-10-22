package test

import (
	"bytes"
	"{{ .ProjectConfig.PackageName }}/router"
	"{{ .ProjectConfig.PackageName }}/service"
	"{{ .ProjectConfig.PackageName }}/utils"
	"encoding/json"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"io"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"
)

type ToolKit struct {
	t            *testing.T
	body         io.Reader
	header       map[string]string
	queryParams  map[string]string
	jsonResponse interface{}
	token        string

	responseRecorder *httptest.ResponseRecorder
}

func NewToolKit(t *testing.T) *ToolKit {
	service.Init()

	return &ToolKit{
		t:           t,
		header:      make(map[string]string),
		queryParams: make(map[string]string),
	}
}

func (toolKit *ToolKit) SetHeader(key string, value string) *ToolKit {
	toolKit.header[key] = value
	return toolKit
}

func (toolKit *ToolKit) SetQueryParams(key string, value string) *ToolKit {
	toolKit.queryParams[key] = value
	return toolKit
}

func (toolKit *ToolKit) SetJsonBody(body interface{}) *ToolKit {
	jsonBody, err := json.Marshal(body)
	if err != nil {
		toolKit.t.Fatal("转换JSON失败")
	}

	toolKit.body = bytes.NewBuffer(jsonBody)

	return toolKit
}

func (toolKit *ToolKit) SetJsonResponse(response interface{}) *ToolKit {
	responseValue := reflect.ValueOf(response)
	if responseValue.Kind() != reflect.Ptr {
		toolKit.t.Fatal("JsonResponse应该传递指针类型")
	}

	toolKit.jsonResponse = response

	return toolKit
}

func (toolKit *ToolKit) SetToken(token string) *ToolKit {
	toolKit.token = token
	return toolKit
}

func (toolKit *ToolKit) Request(url string, method string) *ToolKit {
	r := gin.Default()
	router.InitRouter(r)

	if len(toolKit.queryParams) != 0 {
		url = url + "?"
		for key, value := range toolKit.queryParams {
			url = url + key + "=" + value + "&"
		}

		url = url[:len(url)-1]

		toolKit.queryParams = make(map[string]string)
	}

	request, err := http.NewRequest(method, url, toolKit.body)
	if err != nil {
		toolKit.t.Fatal("创建请求失败", err)
	}

	if len(toolKit.header) != 0 {
		for key, value := range toolKit.header {
			request.Header.Add(key, value)
		}

		toolKit.header = make(map[string]string)
	}

	if !utils.IsStringEmpty(toolKit.token) {
		request.Header.Add("Authorization", toolKit.token)
	}

	toolKit.responseRecorder = httptest.NewRecorder()
	r.ServeHTTP(toolKit.responseRecorder, request)

	if toolKit.responseRecorder.Code == http.StatusOK && toolKit.jsonResponse != nil {
		responseBody, err := ioutil.ReadAll(toolKit.responseRecorder.Body)
		if err != nil {
			toolKit.t.Fatal("读取响应Body失败")
		}

		err = json.Unmarshal(responseBody, toolKit.jsonResponse)
		if err != nil {
			toolKit.t.Fatal("转换Response失败")
		}
	}

	return toolKit
}

func (toolKit *ToolKit) AssertStatusCode(code int) *ToolKit {
	assert.Equal(toolKit.t, code, toolKit.responseRecorder.Code)
	return toolKit
}

func (toolKit *ToolKit) AssertBodyEqual(body string) *ToolKit {
	assert.Equal(toolKit.t, body, toolKit.responseRecorder.Body.String())
	return toolKit
}

func (toolKit *ToolKit) AssertEqual(expected interface{}, actual interface{}, msgAndArgs ...interface{}) *ToolKit {
	assert.Equal(toolKit.t, expected, actual, msgAndArgs)
	return toolKit
}

func (toolKit *ToolKit) AssertNotEqual(expected interface{}, actual interface{}, msgAndArgs ...interface{}) *ToolKit {
	assert.NotEqual(toolKit.t, expected, actual, msgAndArgs)
	return toolKit
}

func (toolKit *ToolKit) AssertNotEmpty(object interface{}, msgAndArgs ...interface{}) *ToolKit {
	assert.NotEmpty(toolKit.t, object, msgAndArgs)
	return toolKit
}

func (toolKit *ToolKit) AssertGreaterOrEqual(e1 interface{}, e2 interface{}, msgAndArgs ...interface{}) *ToolKit {
	assert.GreaterOrEqual(toolKit.t, e1, e2, msgAndArgs)
	return toolKit
}
