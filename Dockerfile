ARG PYTHON_VERSION=3.6

FROM python:${PYTHON_VERSION}-slim-buster AS build_image

WORKDIR /app

COPY . .

RUN apt update && apt install make git -y

# [编译代码]
RUN make build


ARG PYTHON_VERSION=3.6
FROM python:${PYTHON_VERSION}-slim-buster AS run_image

ENV PYTHONUNBUFFERED=1

COPY --from=build_image /app/pyc/ /
COPY requirements.txt /

RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

ENTRYPOINT ["python3", "main.pyc"]