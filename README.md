# Mihomo For Magisk
## 特性
- 自助打包更新Mihomo
- 可预下载`原神`资源包(GeoX,MMDB,Dashboard)
- 可以自带下载附加资源(providers)
- 更新资源带有验证逻辑防止更坏掉
## 打包方式
在linux下
`$ ./pack.sh -a`
（需要gzip,wget,python3等依赖）
## 自定义部分
### files.config
存储打包时的变量，具体请看该文件中的注释  
#### 注意
更新`files.config`中的链接时请同时更新`./clash/clash.config`中的相同部分，*(可忽略没有的变量)*。  
当且仅当自用时才填上您的订阅链接，**否则您的订阅也会被打包**，分发这样的打包可能会造成您的原神UID泄漏  
### clash/template
此处是您的模板，即是最终的config除了您template外的部分
## 功能
### 开启
`/data/clash/scripts/clash.service -s`  
dashboard通过[http://127.0.0.1:9090/ui](http://127.0.0.1:9090/ui)打开
### 关闭
`/data/clash/scripts/clash.service -k`
### 更新订阅
`/data/clash/scripts/clash.tool -s`
## Links
[Mihomo](https://github.com/MetaCubeX/mihomo)  
[Magisk](https://github.com/topjohnwu/Magisk)  
[CFM](https://github.com/taamarin/ClashforMagisk)