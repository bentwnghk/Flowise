# Build local monorepo image
# docker build --no-cache -t  flowise .

# Run image
# docker run -d -p 3000:3000 -v /宿主机/pdf目录:/app/pdf flowise

FROM node:20-alpine
RUN apk add --update libc6-compat python3 make g++
# needed for pdfjs-dist
RUN apk add --no-cache build-base cairo-dev pango-dev

# 添加以下依赖 -----BEGIN-----
# 安装Puppeteer系统依赖（完整版）
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    # 繁體中文字體
    ttf-arphic-ukai \        # 文鼎PL中楷
    noto-fonts-cjk \         # 思源字體（覆盖简繁）
    font-noto-cjk-extra \    # 扩展符号
    font-wqy-zenhei \        # 文泉驿正黑
    libx11 \
    libxcomposite \
    libxdamage \
    libxext \
    libxfixes \
    libxrandr \
    libxrender \
    libxscrnsaver \
    libxtst

# 配置字体缓存
RUN fc-cache -f && fc-list | grep -E "AR PL|Noto"
# -----END-----

# Install PNPM globaly
RUN npm install -g pnpm

# 明确指定Puppeteer路径 -----
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# 解决Alpine兼容性问题 -----
ENV NODE_OPTIONS=--max-old-space-size=8192
ENV LD_LIBRARY_PATH=/usr/lib

WORKDIR /usr/src

# Copy app source
COPY . .

# 安装Puppeteer依赖 -----
RUN pnpm add puppeteer-core  # 使用系统Chromium时必须用puppeteer-core
RUN pnpm install
RUN pnpm build

EXPOSE 3000

# 创建PDF存储目录并设置权限 -----
RUN mkdir -p /app/pdf && chown -R node:node /app/pdf

CMD [ "pnpm", "start" ]
