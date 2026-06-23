# Comms-ChipVerification

UCAgent 通信芯片验证 Docker 环境 — 开箱即用，离线部署。

## 目录结构

```
Comms-ChipVerification/
├── docker/
│   ├── Dockerfile          # 镜像构建文件（预编译二进制版）
│   ├── .dockerignore       # 构建排除规则
│   └── fix_picker.sh       # Picker 编译修复脚本（容器内运行）
├── README.md               # 本文件
```

## 快速开始

### 1. 下载镜像

从 [Releases](https://github.com/luoximeng23/Comms-ChipVerification/releases) 下载最新 `ucagent-latest.tar.gz`：

```bash
wget https://github.com/luoximeng23/Comms-ChipVerification/releases/download/v1.1.0/ucagent-latest.tar.gz
```

### 2. 加载镜像

```bash
docker load -i ucagent-latest.tar.gz
docker images | grep ucagent
```

### 3. 启动容器

```bash
docker run -it --name ucagent \
  -e OPENAI_API_BASE=http://内网vLLM地址:端口/v1 \
  -e OPENAI_API_KEY=内网API_KEY \
  -e OPENAI_MODEL=模型名称 \
  ucagent:latest
```

## 镜像内容

| 组件 | 版本 |
|------|------|
| Ubuntu | 22.04 |
| Verilator | 5.020 |
| Picker | 0.9.0-master-7d336d5 |
| SWIG | 4.0.2 |
| Python | 3.11 |
| Node.js | 20.x |
| UCAgent | 0.9.1 |
| Comms_Verification | 插件 |

### Workspace

- `~/workspace_async_fifo/` — Async FIFO 验证（含 Bit-Exact 报告、覆盖率、14个测试用例）
- `~/workspace_adder/` — Adder 验证（含 FST 波形、15个测试用例）

## 故障排查

### Picker 编译报错 `make release Error 2`

v1.0.0 镜像有两个已知问题（已在 v1.1.0 修复）：

1. `/usr/bin/time` 缺失 → Picker 生成的 Makefile 第 31 行调用失败
2. SWIG 版本要求 4.2.0 而镜像为 4.0.2 → CMake 配置失败

**如果使用 v1.0.0 镜像，请在容器内运行：**
```bash
bash /root/fix_picker.sh
```

**v1.1.0 镜像已内置修复，无需手动处理。**

## 自行构建

```bash
cd docker
# 需要以下目录存在于构建上下文中：
#   prebuilt/usrlocal/  — 预编译的 Picker + Verilator + libxspcomm
#   UCAgent/            — UCAgent 源码
#   Comms_Verification/ — 通信芯片验证插件
#   workspace_*/        — 预置 workspace
docker build -t ucagent:latest .
```

## 详细说明

参见 [Releases](https://github.com/luoximeng23/Comms-ChipVerification/releases) 中的 README_DOCKER.md。
