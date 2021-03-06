APPLICATION_NAME := $(shell grep "const ApplicationName " version.go | sed -E 's/.*"(.+)"$$/\1/')
BIN_NAME=${APPLICATION_NAME}

VERSION := $(shell grep "const Version " version.go | sed -E 's/.*"(.+)"$$/\1/')
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_DIRTY=$(shell test -n "`git status --porcelain`" && echo "+CHANGES" || true)
default: run-test

help:
	@echo 'Management commands for ${APPLICATION_NAME}:'
	@echo ''
	@echo 'Usage:'
	@echo '    make build                       Compile the project.'
	@echo '    make build-native-production     Compile the project for production to current OS type.'
	@echo '    make build-production            Compile the project for production to linux and windows (386 and arm64).'
	@echo '    make dist                        Pack the project for production to linux and windows (386 and arm64).'
	@echo '    make get-deps                    Runs glide install'
	@echo '    make up-deps                     Runs glide update'
	@echo '    make docker-build                Build a docker image of the project.'
	@echo '    make docker-push                 Push project docker image on our docker image repository'
	@echo '    make run-test                    Run tests on a compiled project.'
	@echo '    make clean                       Clean t he directory tree.'
	@echo ''

build:
	@echo "building ${BIN_NAME} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X main.VersionPrerelease=DEV" -o bin/${BIN_NAME} ./

build-native-production:
	@echo "building ${BIN_NAME} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME} ./

build-production:
	@echo "building ${BIN_NAME} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	GOOS=linux GOARCH=386 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME}32 ./
	GOOS=linux GOARCH=amd64 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME}64 ./
	GOOS=linux GOARCH=arm go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME}-arm32 ./
	GOOS=linux GOARCH=arm64 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME}-arm64 ./event-filter
	GOOS=windows GOARCH=386 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME}32.exe ./
	GOOS=windows GOARCH=amd64 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o bin/${BIN_NAME}64.exe ./

build-art:
	@echo "building Artefacts ${BIN_NAME} ${VERSION}"
	@echo "GOPATH=${GOPATH}"
	GOOS=linux GOARCH=amd64 go build -ldflags "-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" -o artefacts/${BIN_NAME} ./


dist: build-production
	@echo "building dist files for Windows"
	cd bin && mv ${BIN_NAME}32.exe ${BIN_NAME}.exe
	cd bin && zip ${BIN_NAME}_win32.zip ${BIN_NAME}.exe
	cd bin && mv ${BIN_NAME}.exe ${BIN_NAME}32.exe
	cd bin && mv ${BIN_NAME}64.exe ${BIN_NAME}.exe
	cd bin && zip ${BIN_NAME}_win64.zip ${BIN_NAME}.exe
	cd bin && mv ${BIN_NAME}.exe ${BIN_NAME}64.exe
	@echo "building dist files for Linux"
	cd bin && mv ${BIN_NAME}32 ${BIN_NAME}
	cd bin && tar -zcvf ${BIN_NAME}_linux32.tar.gz ${BIN_NAME}
	cd bin && mv ${BIN_NAME} ${BIN_NAME}32
	cd bin && mv ${BIN_NAME}64 ${BIN_NAME}
	cd bin && tar -zcvf ${BIN_NAME}_linux64.tar.gz ${BIN_NAME}
	cd bin && mv ${BIN_NAME} ${BIN_NAME}64
	@echo "building dist files for Linux (ARM)"
	cd bin && mv ${BIN_NAME}-arm32 ${BIN_NAME}
	cd bin && tar -zcvf ${BIN_NAME}_linux_arm32.tar.gz ${BIN_NAME}
	cd bin && mv ${BIN_NAME} ${BIN_NAME}-arm32
	cd bin && mv ${BIN_NAME}-arm64 ${BIN_NAME}
	cd bin && tar -zcvf ${BIN_NAME}_linux_arm64.tar.gz ${BIN_NAME}
	cd bin && mv ${BIN_NAME} ${BIN_NAME}-arm64

get-deps:
	glide install

up-deps:
	glide up

docker-build:up-deps build-native-production
	sudo docker build -t edupaim/golang-app-test-elk-beat:${VERSION} ./

docker-push:
	docker tag edupaim/golang-app-test-elk-beat:${VERSION} edupaim/golang-app-test-elk-beat:latest
	docker push edupaim/golang-app-test-elk-beat:${VERSION}
	docker push edupaim/golang-app-test-elk-beat:latest

clean:
	@test ! -e bin/${BIN_NAME} || rm bin/${BIN_NAME}

run-test:
	mkdir -p ./test/cover
	go test -race -coverpkg=./... -coverprofile=./test/cover/cover.out
	go tool cover -html=./test/cover/cover.out -o ./test/cover/cover.html