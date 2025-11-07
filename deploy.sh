#!/bin/bash
set -e

echo "🚀 初始化挂机容器..."

# 加载环境变量
source .env

# 启动容器
docker-compose up -d

echo "✅ 所有容器已启动"
docker ps
