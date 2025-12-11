#!/bin/bash
set -euo pipefail

# 配置部分
IPSET_NAME="whitelist_cdn"              # ipset 集合名称
IP_URL="https://quzei.com/sh/cdn_ips.txt" # 你的在线 IP 列表地址
TEMP_FILE="/tmp/cdn_ips_download.txt"   # 临时下载路径

echo "📥 正在从网站下载 IP 列表..."
# 下载文件，如果失败则退出脚本
if ! curl -fsSL -o "$TEMP_FILE" "$IP_URL"; then
  echo "❌ 下载失败，请检查网址是否正确。"
  exit 1
fi

echo "🧹 清理旧规则..."
# 1. 如果之前有针对这个集合的防火墙规则，先删除
iptables -D INPUT -m set --match-set "$IPSET_NAME" src -j ACCEPT 2>/dev/null || true
iptables -D OUTPUT -m set --match-set "$IPSET_NAME" dst -j ACCEPT 2>/dev/null || true

# 2. 如果之前运行过脚本，先清空并销毁旧的 ipset 集合
if ipset list -n | grep -qw "$IPSET_NAME"; then
  ipset flush "$IPSET_NAME"
  ipset destroy "$IPSET_NAME"
fi

# 3. 创建新的 ipset 集合 (类型为 hash:net，支持网段)
echo "📦 创建新的 IP 集合：$IPSET_NAME"
ipset create "$IPSET_NAME" hash:net

echo "🔄 正在解析并导入 IP..."
# 逐行读取下载的文件
while read -r line; do
  # 去除每行的前后空格
  ip=$(echo "$line" | xargs)
  # 跳过空行和以 # 开头的注释行
  [[ -z "$ip" || "$ip" == \#* ]] && continue
  
  # 将 IP 添加到集合中 (屏蔽错误输出，防止个别格式错误的 IP 刷屏)
  ipset add "$IPSET_NAME" "$ip" 2>/dev/null || true
done < "$TEMP_FILE"

echo "🚧 添加防火墙放行规则..."
# ⚠️ 关键点：这里使用的是 -j ACCEPT (放行/打开)，而不是 DROP
# -I INPUT 1 表示插入到第一行，优先级最高
iptables -I INPUT 1 -m set --match-set "$IPSET_NAME" src -j ACCEPT

# (可选) 如果你也想放行流出到这些 IP 的流量，请取消下面这行的注释
# iptables -I OUTPUT 1 -m set --match-set "$IPSET_NAME" dst -j ACCEPT

# 删除临时文件
rm -f "$TEMP_FILE"

echo "✅ 成功！已从网站获取 IP 并将其全部设置为【允许访问】。"
