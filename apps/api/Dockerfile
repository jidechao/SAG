FROM python:3.12-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# 默认镜像只安装本地 SQLite/LanceDB 所需依赖；生产覆盖传 postgres。
ARG SAG_API_EXTRAS=""
# 可选的 PyPI 镜像源（如国内网络传 https://pypi.tuna.tsinghua.edu.cn/simple）；默认走官方源。
ARG PIP_INDEX_URL=""

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential curl \
 && rm -rf /var/lib/apt/lists/*

# 先装第三方依赖；业务代码变化不会让这一层失效。
COPY pyproject.toml ./
RUN pip install ${PIP_INDEX_URL:+--index-url "$PIP_INDEX_URL"} --upgrade pip hatchling \
 && python -c 'import os, tomllib; p=tomllib.load(open("pyproject.toml", "rb")); deps=list(p["project"]["dependencies"]); deps += p["project"]["optional-dependencies"].get(os.environ.get("SAG_API_EXTRAS", ""), []); print("\n".join(deps))' > /tmp/requirements.txt \
 && pip install ${PIP_INDEX_URL:+--index-url "$PIP_INDEX_URL"} -r /tmp/requirements.txt

# 再安装本项目本身（无依赖解析，保持快速重建）。
COPY sag_api ./sag_api
COPY sag_agent ./sag_agent
RUN pip install --no-deps --no-build-isolation .

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -fsS http://localhost:8000/api/v1/system/health || exit 1

CMD ["uvicorn", "sag_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
