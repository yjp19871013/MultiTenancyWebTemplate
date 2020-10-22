package main

import (
	"context"
	"github.com/gin-gonic/gin"
	DEATH "gopkg.in/vrecan/death.v3"
	"log"
	"net/http"
	"{{ .ProjectConfig.PackageName }}/config"
	"{{ .ProjectConfig.PackageName }}/router"
	"{{ .ProjectConfig.PackageName }}/service"
	"syscall"
	"time"
)

// @title {{ .ProjectConfig.SwaggerAppName }}
// @version {{ .ProjectConfig.Version }}
// @BasePath /
func main() {
	service.Init()

	r := gin.Default()

	router.InitRouter(r)

	srv := &http.Server{
		Addr:    ":" + config.Get{{ .ProjectConfig.ProjectName }}Config().ServerConfig.Port,
		Handler: r,
	}

	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	death := DEATH.NewDeath(syscall.SIGINT, syscall.SIGTERM)
	_ = death.WaitForDeath()
	log.Println("Shutdown Server ...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server Shutdown:", err)
	}

	log.Println("Server exiting")
}
