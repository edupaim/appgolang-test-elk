package main

import (
	"os"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

func RunApplication() error {

	logrus.SetFormatter(&logrus.JSONFormatter{})

	file, err := os.OpenFile("logrus.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
	if err != nil {
		return err
	}
	logrus.SetOutput(file)

	// Use the following code if you need to write the logs to file and console at the same time.
	// gin.DefaultWriter = io.MultiWriter(f, os.Stdout)

	router := gin.Default()

	gin.DebugPrintRouteFunc = func(httpMethod, absolutePath, handlerName string, nuHandlers int) {
		logrus.WithFields(logrus.Fields{
			"httpMethod":   httpMethod,
			"absolutePath": absolutePath,
			"handlerName":  handlerName,
			"nuHandlers":   nuHandlers,
		}).Infoln("gin log")
	}

	router.GET("/ping", func(c *gin.Context) {
		c.String(200, "pong2")
	})

	return router.Run(":8080")
}

func main() {
	RunApplication()
}
