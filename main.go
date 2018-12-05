package main

import (
	"os"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"path"
)

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
	router.GET("/ping", func(c *gin.Context) {
		logrus.WithFields(logrus.Fields{
			"httpMethod":   c.Request.Method,
			"absolutePath": "/ping",
			"handlerName":  c.HandlerName(),
		}).Infoln("received http request")
		c.String(200, "pong")
	})
	return router.Run(":8080")
}

func main() {
	RunApplication()
}
