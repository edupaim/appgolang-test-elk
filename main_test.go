package main

import (
	"testing"
	"github.com/onsi/gomega"
	"net/http"
	"fmt"
	"io/ioutil"
	"time"
)

func TestApplication(t *testing.T) {
	gomega.RegisterTestingT(t)
	go func() {
		RunApplication()
	}()
	time.Sleep(50 * time.Millisecond)
	resp, err := http.Get("http://localhost:8080/ping")
	gomega.Expect(err).ShouldNot(gomega.HaveOccurred())
	bodyResponse, err := ioutil.ReadAll(resp.Body)
	gomega.Expect(err).ShouldNot(gomega.HaveOccurred())
	fmt.Println(string(bodyResponse))
	resp, err = http.Get("http://localhost:8080/ping")
	gomega.Expect(err).ShouldNot(gomega.HaveOccurred())
	bodyResponse, err = ioutil.ReadAll(resp.Body)
	gomega.Expect(err).ShouldNot(gomega.HaveOccurred())
	fmt.Println(string(bodyResponse))
	time.Sleep(50 * time.Millisecond)
}
