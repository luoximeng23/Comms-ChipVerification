# Dockerfile — UCAgent 完整验证环境（预编译二进制版）
# 直接拷贝已编译的 Picker + Verilator + libxspcomm，跳过源码编译
# 目标：x86_64 Linux，离线交付内网机
FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# ============================================================
# 国内网络加速
# ============================================================
ENV NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node \
    NPM_CONFIG_REGISTRY=https://registry.npmmirror.com \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# ============================================================
# 系统依赖（SWIG 从 apt 安装，版本 4.0.2 — Picker 已预编译，无需 SWIG 编译能力）
# ============================================================
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential gcc-11 g++-11 cmake make autoconf automake \
        libtool pkg-config bison flex ccache git curl wget ca-certificates \
        python3.11 python3.11-dev python3.11-venv python3-pip python3-dev \
        perl help2man libfl2 libfl-dev zlib1g zlib1g-dev \
        libgoogle-perftools-dev numactl perl-doc \
        libpcre2-dev byacc swig \
        gtkwave \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# 设置 Python 3.11 为默认
# ============================================================
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --set python3 /usr/bin/python3.11 && \
    pip3 install --upgrade pip setuptools wheel

# ============================================================
# 设置 GCC-11 为默认
# ============================================================
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 110 && \
    update-alternatives --set gcc /usr/bin/gcc-11 && \
    update-alternatives --set g++ /usr/bin/g++-11

# ============================================================
# 拷贝预编译的 Picker + Verilator + libxspcomm（从 WSL 原环境直接复制）
# ============================================================
COPY prebuilt/usrlocal/ /usr/local/
RUN ldconfig && \
    chmod +x /usr/local/bin/picker /usr/local/bin/verilator_bin /usr/local/bin/verilator_coverage_bin_dbg

# ============================================================
# 安装 Node.js 20.x + OpenCode（AI 后端）
# ============================================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g opencode-ai@latest && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# 安装 Python 依赖（与当前环境保持一致）
# ============================================================
RUN pip3 install --no-cache-dir \
    pytoffee \
    toffee-test \
    "langchain>=1.2.15" \
    "langchain-openai>=1.1.6" \
    "langchain-community>=0.3.31" \
    "langchain-anthropic>=1.4.6" \
    "langgraph>=1.0.5" \
    "langmem>=0.0.30" \
    "langchain-mcp-adapters>=0.1.11" \
    "openai>=1.109.1" \
    "psutil>=7.1.0" \
    "langfuse>=3.9.1" \
    "gitpython>=3.1.43" \
    "textual>=7.3.0" \
    "Jinja2>=3.1.6" \
    "fastapi>=0.135.0" \
    "uvicorn[standard]>=0.42.0" \
    "docker>=7.1.0" \
    "kubernetes>=33.1.0" \
    && rm -rf /root/.cache/pip

# ============================================================
# 安装 UCAgent
# ============================================================
COPY UCAgent/ /root/tools/UCAgent/
WORKDIR /root/tools/UCAgent
RUN pip3 install -e . && rm -rf /root/.cache/pip

# ============================================================
# 安装 Comms_Verification 插件
# ============================================================
COPY Comms_Verification/ /root/tools/Comms_Verification/

# ============================================================
# 复制 workspace 目录（含全部验证输出：报告、覆盖率、波形等）
# ============================================================
COPY workspace_async_fifo/ /root/workspace_async_fifo/
COPY workspace_adder/ /root/workspace_adder/
COPY workspace_Adder_output/ /root/tools/UCAgent/output/workspace_Adder/

# ============================================================
# 用户级 UCAgent 配置模板（API Key 在运行时通过 -e 注入）
# ============================================================
RUN mkdir -p /root/.ucagent && \
    echo '# UCAgent 配置 — 运行时通过环境变量覆盖' > /root/.ucagent/setting.yaml && \
    echo 'openai:' >> /root/.ucagent/setting.yaml && \
    echo '  model_name: "$(OPENAI_MODEL: deepseek-v4-pro)"' >> /root/.ucagent/setting.yaml && \
    echo '  openai_api_key: "$(OPENAI_API_KEY: your_api_key)"' >> /root/.ucagent/setting.yaml && \
    echo '  openai_api_base: "$(OPENAI_API_BASE: https://api.deepseek.com/v1)"' >> /root/.ucagent/setting.yaml && \
    echo '  temperature: $(OPENAI_TEMPERATURE: null)' >> /root/.ucagent/setting.yaml && \
    echo '  max_tokens: $(OPENAI_MAX_TOKENS: 384000)' >> /root/.ucagent/setting.yaml && \
    echo 'call_time_out: $(UC_CALL_TIMEOUT: 600)' >> /root/.ucagent/setting.yaml

# ============================================================
# 环境变量
# ============================================================
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/root/tools/UCAgent:/root/tools/Comms_Verification \
    PATH="/root/tools/UCAgent:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    HOME=/root \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ============================================================
# 入口脚本
# ============================================================
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'echo "╔══════════════════════════════════════╗"' >> /entrypoint.sh && \
    echo 'echo "║   UCAgent Docker 验证环境           ║"' >> /entrypoint.sh && \
    echo 'echo "╠══════════════════════════════════════╣"' >> /entrypoint.sh && \
    echo 'echo "║ Verilator: $(verilator --version 2>&1 | head -1)"' >> /entrypoint.sh && \
    echo 'echo "║ Picker:    $(picker --version 2>&1 | head -1)"' >> /entrypoint.sh && \
    echo 'echo "║ SWIG:      $(swig -version 2>&1 | head -3 | tail -1 | xargs)"' >> /entrypoint.sh && \
    echo 'echo "║ Python:    $(python3 --version 2>&1)"' >> /entrypoint.sh && \
    echo 'echo "║ Node.js:   $(node --version 2>&1)"' >> /entrypoint.sh && \
    echo 'echo "╠══════════════════════════════════════╣"' >> /entrypoint.sh && \
    echo 'echo "║ LLM API:  $OPENAI_API_BASE"' >> /entrypoint.sh && \
    echo 'echo "║ LLM Model: $OPENAI_MODEL"' >> /entrypoint.sh && \
    echo 'echo "╠══════════════════════════════════════╣"' >> /entrypoint.sh && \
    echo 'echo "║ Workspaces:"' >> /entrypoint.sh && \
    echo 'echo "║   ~/workspace_async_fifo/"' >> /entrypoint.sh && \
    echo 'echo "║   ~/workspace_adder/"' >> /entrypoint.sh && \
    echo 'echo "║   ~/tools/UCAgent/output/workspace_Adder/"' >> /entrypoint.sh && \
    echo 'echo "╚══════════════════════════════════════╝"' >> /entrypoint.sh && \
    echo 'echo ""' >> /entrypoint.sh && \
    echo 'cd /root && exec bash' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/entrypoint.sh"]
