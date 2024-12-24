# 基本项目变量
# 应用名称
APP_NAME := hello-world
# 本地可执行文件存放路径
LOCALBIN := $(shell pwd )/bin

# 镜像构建相关变量
REGISTRY := harbor.tiduyun.com
PROJECT := library
TAG ?= python
IMG := $(REGISTRY)/$(PROJECT)/$(APP_NAME):$(TAG)
DOCKER_BUILDX_IMAGE := $(APP_NAME):buildx

# 构建相关变量
VERSION ?= v1.0.0
BUILD_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BUILD_COMMIT := $(shell git rev-parse HEAD)
BUILD_TIME := $(shell date '+%Y-%m-%d %H:%M:%S')
PLATFORM := linux/arm64


.PHONY: all
all: build

$(LOCALBIN):
	@mkdir -p $(LOCALBIN)


# 定义变量
MAIN_PY_PATH=src/
BUILD_DIR=pyc
VERSION_FILE=version.txt
.PHONY: build
# 编译目标
build: dep test
	mkdir -p $(BUILD_DIR)

	cp -r $(MAIN_PY_PATH)/* $(BUILD_DIR)/

	python3 -O -m compileall -b $(BUILD_DIR)/

	find $(BUILD_DIR)/ -name "*.py" | xargs rm -rf
	find $(BUILD_DIR)/ -name "__pycache__" | xargs rm -rf

	echo "buildTime: ${BUILD_TIME}" > $(BUILD_DIR)/$(VERSION_FILE)
	echo "branch: ${BUILD_BRANCH}" >> $(BUILD_DIR)/$(VERSION_FILE)
	echo "commitId: ${BUILD_COMMIT}" >> $(BUILD_DIR)/$(VERSION_FILE)
	echo "version: ${VERSION}" >> $(BUILD_DIR)/$(VERSION_FILE)

dep: ## 获取依赖项
	@pip freeze > requirements.txt
	@pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

.PHONY: run
run: dep ## 运行开发服务器
	@python3 src/main.py


# 测试任务
.PHONY: test
test:


.PHONY: lint
lint: lint-python lint-markdown lint-yaml ## 运行所有文件进行对应的静态检查任务


.PHONY: install
install: install-lint install-openapi-generator-cli ## 下载需要用到的工具

.PHONY: install-lint
install-lint: ## 安装 lint 工具
	@echo "Installing pylint to $(LOCALBIN)..."
	python3 -m venv myenv
	. myenv/bin/activate && pip install isort black flake8

.PHONY: install-openapi-generator-cli
install-openapi-generator-cli: ## 安装 openapi-generator-cli
	@if ! command -v openapi-generator-cli >/dev/null 2>&1; then \
		npm install @openapitools/openapi-generator-cli -g; \
	fi


.PHONY: lint-python
lint-python: ## 对 python 代码进行静态分析
	@# 检查导入顺序
	isort --check src/main.py

	@# 检查代码格式
	black --check src/main.py

	@# 检查代码风格问题
	flake8 --max-line-length=120 src/main.py

.PHONY: lint-markdown
lint-markdown: ## 对 Markdown 文件进行检查
	if ! command -v markdownlint >/dev/null 2>&1; then npm install -g markdownlint-cli; fi
	@# ignore markdown under 'xxx/xxx'
	markdownlint '{*.md,site/**/*.md}' --disable MD012 MD013 MD029 MD033 MD034 MD036 MD041

# 我们不使用 if ! command -v yamllint 因为某些环境可能已经预安装了 Python 版本。
# 检查特定路径确保我们使用的是 Node.js 版本，以避免冲突。
.PHONY: lint-yaml ## 对 YAML 文件进行静态分析
lint-yaml:
	YAML_LINT="$$(npm config get prefix)/bin/yamllint"; \
	if ! test -x "$${YAML_LINT}"; then \
		npm install -g yaml-lint; \
	fi; \
	"$${YAML_LINT}" "**/*.(yaml|yml)"


.PHONY: gen
gen: gen-openapi ## 自动生成代码(proto、openapi...)

UNAME := $(shell uname)
.PHONY: gen-openapi
gen-openapi: ## 生成 OpenAPI 规范
	mkdir -p /tmp/hello-world
	rm -rf /tmp/hello-world/tmp_code
	openapi-generator-cli generate -i api/openapi/v3/swagger.yaml -g python-flask -o /tmp/hello-world/tmp_code

	@# mac系统下有bug，解决方法 -i后增加空字符串，见 https://stackoverflow.com/questions/17534840/sed-throws-bad-flag-in-substitute-command/17535174
	@if [ "$(UNAME)" = "Darwin" ]; then \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i '' 's/import openapi_server\./import app.api./g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i '' 's/from openapi_server/from app.api/g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i '' 's/getattr(openapi_server\.models/getattr(app.api.models/g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i '' 's/import openapi_server\./import app.api./g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i '' 's/from openapi_server/from app.api/g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i '' 's/getattr(openapi_server\.models/getattr(app.api.models/g' {} +; \
	else \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i 's/import openapi_server\./import app.api./g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i 's/from openapi_server/from app.api/g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i 's/getattr(openapi_server\.models/getattr(app.api.models/g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i 's/import openapi_server\./import app.api./g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i 's/from openapi_server/from app.api/g' {} +; \
		find "/tmp/steamer-api/tmp_code/openapi_server/" -type f -name \*.py -exec sed -i 's/getattr(openapi_server\.models/getattr(app.api.models/g' {} +; \
	fi

	rm -rf src/api/models
	cp -r /tmp/hello-world/tmp_code/openapi_server/models src/api/models


.PHONY: clean
clean: ## 清理生成的文件
	rm -rf $(LOCALBIN)


.PHONY: docker-build
docker-build: ## 构建 Docker 镜像 Example: make docker-build VERSION=latest
	docker build --platform=$(PLATFORM)  \
	--build-arg BUILD_BRANCH="$(BUILD_BRANCH)" \
	--build-arg BUILD_COMMIT="$(BUILD_COMMIT)" \
	--build-arg BUILD_TIME="$(BUILD_TIME)" \
	--build-arg APP_NAME="$(APP_NAME)" \
	-t $(IMG) .


HOST_PORT ?= 8080
CONTAINER_PORT ?= 8080
.PHONY: docker-run
docker-run: ## 启动 Docker 容器
	docker run -d -p $(HOST_PORT):$(CONTAINER_PORT) $(IMG)

.PHONY: docker-push
docker-push: ## 推送 Docker 镜像到远程仓库
	docker push $(IMG)


# 显示帮助信息
.PHONY: help
help: ## 显示 Makefile 帮助信息
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"} {printf "  %-15s %s\n", $$1, $$2}'
