下载依赖
sudo apt update

sudo apt install -y ipset curl


关闭 CDN 流量

```
curl --progress-bar -O https://raw.githubusercontent.com/jc-lw/GCP-cdn/refs/heads/main/noGCP.sh && chmod 777 noGCP.shh && ./noGCP.sh
```

开启 CDN 流量

```
curl --progress-bar -O https://raw.githubusercontent.com/jc-lw/GCP-cdn/refs/heads/main/yesGCP.sh && chmod 777 yesGCP.shh && ./yesGCP.sh
```
