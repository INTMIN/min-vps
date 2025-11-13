#!/bin/bash

# 设置限速参数（单位：kbit）
LIMIT=50000  # 50Mbps = 50000kbit

# 容器列表
containers=("traffmonetizer" "repocket")

for cname in "${containers[@]}"; do
  # 获取容器 PID
  pid=$(docker inspect -f '{{.State.Pid}}' "$cname")

  # 获取容器内 eth0 的 MAC 地址
  mac=$(nsenter -t "$pid" -n ip link show eth0 | awk '/ether/ {print $2}')

  # 查找宿主机上的 veth 网卡名
  veth=$(ip link | grep -B1 "$mac" | head -n1 | awk -F: '{print $2}' | tr -d ' ')

  # 应用限速（如果未限速）
  if ! tc qdisc show dev "$veth" | grep -q "tbf"; then
    echo "Limiting $cname ($veth) to ${LIMIT}kbit"
    tc qdisc add dev "$veth" root tbf rate ${LIMIT}kbit burst 64kbit latency 50ms
  else
    echo "$cname ($veth) already limited"
  fi
done
