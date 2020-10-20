package test

import (
	"{{ .ProjectConfig.PackageName }}/config"
	"net/http"
	"testing"
)

func TestVersion(t *testing.T) {
	NewToolKit(t).Request("/{{ .ProjectConfig.UrlPrefix }}/api/version", http.MethodGet).
		AssertStatusCode(http.StatusOK).
		AssertBodyEqual("Version: " + config.Get{{ .ProjectConfig.ProjectName }}Config().Version)
}
