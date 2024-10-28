GRPC_MAIN_FILE=grpc/main.go
HTTP_MAIN_FILE=http/main.go

.PHONY: gen-grpc
gen-grpc:
	-@protoc -I=. --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative,require_unimplemented_servers=false api/*.proto
	-@go fmt ./...
	-@protoc-go-inject-tag -input=api/*.pb.go

dep: ## Get the dependencies
	@go mod tidy

build-grpc: dep ## Build the binary file
	@#echo "Building with flags: go build -ldflags \"-s -w\" -ldflags \"-X '${VERSION_PATH}.GitBranch=${BUILD_BRANCH}' -X '${VERSION_PATH}.GitCommit=${BUILD_COMMIT}' -X '${VERSION_PATH}.BuildTime=${BUILD_TIME}' -X '${VERSION_PATH}.GoVersion=${BUILD_GO_VERSION}'\" -o bin/main $(MAIN_FILE)"
	go build -ldflags "-s -w" -o bin/grpc-server $(GRPC_MAIN_FILE)

build-http: dep ## Build the binary file
	@#echo "Building with flags: go build -ldflags \"-s -w\" -ldflags \"-X '${VERSION_PATH}.GitBranch=${BUILD_BRANCH}' -X '${VERSION_PATH}.GitCommit=${BUILD_COMMIT}' -X '${VERSION_PATH}.BuildTime=${BUILD_TIME}' -X '${VERSION_PATH}.GoVersion=${BUILD_GO_VERSION}'\" -o bin/main $(MAIN_FILE)"
	go build -ldflags "-s -w" -o bin/http-server $(HTTP_MAIN_FILE)