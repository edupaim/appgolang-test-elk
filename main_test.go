package main

import (
	"testing"
	"github.com/onsi/gomega"
	"time"
	"net/http"
	"io/ioutil"
	"fmt"
)

func TestApplication(t *testing.T) {
	gomega.RegisterTestingT(t)
	go func() {
		RunApplication()
	}()
	time.Sleep(50 * time.Millisecond)
	resp, err := http.Get("http://localhost:9331/nok")
	gomega.Expect(err).ShouldNot(gomega.HaveOccurred())
	bodyResponse, err := ioutil.ReadAll(resp.Body)
	gomega.Expect(err).ShouldNot(gomega.HaveOccurred())
	fmt.Println(string(bodyResponse))
}
