# Mihomo For Magisk
![](https://socialify.git.ci/icewithcola/Mihomo_For_Magisk/image?description=1&forks=1&issues=1&name=1&owner=1&pulls=1&stargazers=1&theme=Dark)
Mihomo For Magisk 是一个简单的 Mihomo 通过 Magisk/KSU/Apatch 运行的模块。提供基本的 Mihomo 功能支持。
## 下载
- [![CI Build](https://github.com/icewithcola/Mihomo_For_Magisk/actions/workflows/main.yml/badge.svg)](https://github.com/icewithcola/Mihomo_For_Magisk/actions/workflows/main.yml)
- [![Telegram](https://img.shields.io/static/v1?label=Telegram&message=@mfm_updates&color=5BCEFA)](https://t.me/mfm_updates)

## 特性
- 自助打包更新`Mihomo`
- 可预下载`Mihomo`资源包(GeoX,MMDB,Dashboard)
- 可以自带下载附加资源(providers)
- 更新资源带有验证逻辑防止更坏掉

## 打包方式
在linux下
`./pack.sh -a`（需要gzip,wget,curl,python3等依赖）

## 自定义部分
### files.config
存储打包时的变量，具体请看该文件中的注释
|`pack_arch`|对应变量|特殊说明|
|--|--|--|
|arm64|`mihomo_arch_arm64`|默认指安卓平台`android-arm64-v8`|
|amd64|`mihomo_arch_amd64`|默认使用`android-amd64`|

**注意**
`amd64`无测试（无设备），已知AVD上需要`linux-amd64-compatible`

|`mihomo_tag`|说明|
|---|---|
|`latest`|指向最新稳定版|
|`Prerelease-Alpha`|指向最新测试版|
|release tag例如`v1.1.4`|指向指定的版本|

**注意**
`pack_arch`的值在不同版本**不一定相同**  
`curl_version` 可以手动指定curl的版本，注意`x.y.z-k`这样的版本可能无法正常获取到下载链接
#### 注意
更新`files.config`中的链接时请同时更新`./clash/clash.config`中的相同部分，*(可忽略没有的变量)*。  
当且仅当自用时才填上您的订阅链接，**否则您的订阅也会被打包**，分发这样的打包可能会造成您的订阅泄漏
### clash/template
此处是您的模板，在文件首部添加 `#keep` 以防止升级时修改  
如果`template` 没有 `dns` 块，会从 `config.yaml` 的 `dns` 开始合并  
否则config时会从`config.yaml`的`proxy:`行开始合并，故请将其他需要合并的部分放在`proxy`下方  
最终合并结果是
```
template 中的内容 ...
config.yaml proxy:/dns: 这一行以下的内容 ...
```
## 功能
### 开启
`/data/clash/scripts/clash.service -s`

### 关闭
`/data/clash/scripts/clash.service -k`

### 更新订阅
`/data/clash/scripts/clash.tool -s`  
**可能需要多试几次多手动重启几次才可以**

### WebUI
请打开 [http://127.0.0.1:9090/ui](http://127.0.0.1:9090/ui) 或在 Magisk 模块列表中点击 **操作** 打开  
默认只允许本机打开，否则请修改 `template` 并添加保留，此时设置一个 `secret` 更好
## Links
[Mihomo](https://github.com/MetaCubeX/mihomo)  
[Magisk](https://github.com/topjohnwu/Magisk)  
[CFM](https://github.com/taamarin/ClashforMagisk)