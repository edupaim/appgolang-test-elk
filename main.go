package main

import (
	"os"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"path"
	"net/http"
	"time"
	)

func Logger(c *gin.Context) {
		t := time.Now()
		c.Next()
		latency := time.Since(t)
		latencyMsec := latency.Seconds() * float64(time.Second/time.Millisecond)
		logrus.WithFields(logrus.Fields{
			"status":       c.Writer.Status(),
			"latency":      latencyMsec,
			"httpMethod":   c.Request.Method,
			"absolutePath": c.Request.URL.Path,
		}).Infoln("http request")
}

func RunApplication() error {
	logrus.SetFormatter(&logrus.JSONFormatter{})
	err := os.MkdirAll(path.Dir("./log/logrus.log"), os.ModePerm)
	if err != nil {
		return err
	}
	file, err := os.OpenFile("./log/logrus.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, os.ModePerm)
	if err != nil {
		return err
	}
	logrus.SetOutput(file)
	router := gin.Default()
	router.Use(Logger)
	router.GET("/ok", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})
	router.GET("/bad-request", func(c *gin.Context) {
		c.String(http.StatusBadRequest, "pong")
	})
	return router.Run(":9331")
}

func main() {
	RunApplication()
}
