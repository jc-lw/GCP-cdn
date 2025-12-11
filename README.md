不包含CDN的流量，如果要防止CDN，可以用论坛脚本屏蔽所有CDN访问。真的永久，就是200G限制+CDN禁用，要不然每个月还会扣些钱

https://github.com/jc-lw/GCP-cdn/edit/main/image.png


```
sudo apt update

```

```
sudo apt install -y ipset curl
```

关闭 CDN 流量

```
curl --progress-bar -O https://raw.githubusercontent.com/jc-lw/GCP-cdn/refs/heads/main/noGCP.sh && chmod 777 noGCP.sh && ./noGCP.sh
```

开启 CDN 流量

```
curl --progress-bar -O https://raw.githubusercontent.com/jc-lw/GCP-cdn/refs/heads/main/yesGCP.sh && chmod 777 yesGCP.sh && ./yesGCP.sh
```
