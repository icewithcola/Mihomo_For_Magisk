# Mihomo For Magisk
## 特性
- 自助打包更新Mihomo
- 可预下载`原神`资源包
- 更新资源带有验证逻辑防止更坏掉
## 打包方式
`$ ./pack.sh -a`
## 自定义部分
### files.config
存储打包时的变量  
#### 注意
更新`files.config`中的链接时请同时更新`./clash/clash.config`中的相同部分，*(可忽略没有的变量)*。  
当且仅当自用时才填上您的订阅链接，**否则您的订阅也会被打包**  
## 功能
### 开启
`/data/clash/scripts/clash.service -s`
### 关闭
`/data/clash/scripts/clash.service -k`
### 更新订阅
`/data/clash/scripts/clash.tool -s`
## Links
[Mihomo](https://github.com/MetaCubeX/mihomo)
[Magisk](https://github.com/topjohnwu/Magisk)
[CFM](https://github.com/taamarin/ClashforMagisk)