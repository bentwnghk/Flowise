# Stage 1: Build stage
FROM node:20-alpine AS build

USER root

# Skip downloading Chrome for Puppeteer (saves build time)
ENV PUPPETEER_SKIP_DOWNLOAD=true

# Install latest Flowise globally (specific version can be set: flowise@1.0.0)
RUN npm install -g flowise

# Stage 2: Runtime stage
FROM node:20-alpine

# 添加edge仓库获取最新字体包
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "https://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# Install runtime dependencies
# RUN apk add --no-cache chromium git python3 py3-pip make g++ build-base cairo-dev pango-dev
RUN apk add --no-cache \
    chromium \
    git \
    python3 \
    py3-pip \
    make \
    g++ \
    build-base \
    cairo-dev \
    pango-dev \
    nss \
    freetype \
    harfbuzz \
    font-noto-cjk-extra \
    font-hanazono \
    libx11 \
    libxcomposite \
    libxdamage \
    libxext \
    libxfixes \
    libxrandr \
    libxrender \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

# 更新字体缓存
RUN fc-cache -f

# Set the environment variable for Puppeteer to find Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy Flowise from the build stage
COPY --from=build /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=build /usr/local/bin /usr/local/bin

# 创建PDF存储目录并设置权限
RUN mkdir -p /root/.flowise/pdf && chown -R root:root /root/.flowise/pdf

ENTRYPOINT ["flowise", "start"]
