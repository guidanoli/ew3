# syntax=docker.io/docker/dockerfile:1

###############################
## models downloader
FROM scratch AS models
ADD https://huggingface.co/unsloth/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct-Q8_0.gguf /models/SmolLM2-135M-Instruct-Q8_0.gguf

###############################
# llama.cpp builder
FROM --platform=linux/riscv64 ubuntu:24.04 AS llamacpp
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential git cmake ninja-build ca-certificates

# Build llama.cpp
RUN git clone --branch b4689 --depth=1 https://github.com/ggerganov/llama.cpp
RUN cd llama.cpp && \
    cmake -B build -G Ninja -DGGML_RVV=OFF && \
    ninja -C build llama-cli llama-server

###############################
# rootfs builder
FROM --platform=linux/riscv64 ubuntu:24.04 AS rootfs

# Configure machine memory
LABEL io.cartesi.rollups.sdk_version=0.11.1
LABEL io.cartesi.rollups.ram_size=4096Mi

# Install required packages
COPY ./requirements.txt /tmp/
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        busybox-static \
        libgomp1 \
        python3 python3-venv python3-pip git && \
        pip install --break-system-packages -r /tmp/requirements.txt && \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*

# Install guest tools
ARG MACHINE_EMULATOR_TOOLS_VERSION=0.16.1
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -i /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb && \
    rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb

# Install models
COPY --chown=dapp:dapp --from=models /models /home/dapp/models

# Install llama.cpp
COPY --from=llamacpp /llama.cpp /llama.cpp
RUN ln -s /llama.cpp/build/bin/llama-cli /usr/bin/llama-cli && \
    ln -s /llama.cpp/build/bin/llama-server /usr/bin/llama-server

# Install dapp
WORKDIR /home/dapp
COPY ./*.py .

# Set entrypoint
ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["python3", "dapp.py"]
