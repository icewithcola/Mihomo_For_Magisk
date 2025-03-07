# CHANGELOG
## 1.4.2-1
- clash.internal.config -> keep_dns 弃用
- 不使用此功能没有必要更新
## 1.4.2
- 合并 dns 修复
- 现在 template 没有 dns 就会自动从 config.yaml 加
- template 加上 '#keep' 即可在更新保留
- 快看看新 README
## 1.4.1
- internal: 可以合并的时候保留 dns (clash.internal.config -> keep_dns)
- 模块列表可以看到模块检测到的环境类型
## 1.4.0
- 尝试支持 KSU/Apatch
- 分离 clash.config 适合修改和不适合修改的逻辑
## 1.3.2
- 添加 `action.sh`，现在可以在 magisk 里面点开 webui
## 1.3.1
- 继续优化 template，细分 template DNS
- template DNS 减少使用 AliDNS 解决可能的严重限速问题
- 现在更多信息会打印到 `stdout`
## 1.3.0
- 使用更新的 [MetacubeXD](https://github.com/MetaCubeX/metacubexd) 作为 dashboard
- template 默认的 DNS 加强，减少被劫持的可能
## 1.2.8-1
- 修改默认`template`， 修改错误的`fallback-filter`，修改默认 DNS 服务器
## 1.2.8
- 修复iptables处理逻辑
## 1.2.7
- 现在会发布到 Telegram Channel
- 修复CI打包的逻辑错误
## 1.2.6
- 修复错误
- 更新默认template
## 1.2.5
- 修复错误
## 1.2.4 
- 优化更新`config.yaml`体验，现在理应只需要一次`/data/clash/scripts/clash.tool -s`
## 1.2.3
- 现在会更新cacert.pem了（需要 curl `7.68.0` 以上以支持etag相关功能）
- 修复typo（欢迎大家继续找typo等）
## 1.2.2
- 修复上个版本的bug
## 1.2.1
- 现在Magisk管理页面会有内核版本了
- 修复typo导致不复制provider
## 1.2.0
- 现在 Github Actions 可以自动打包，可以直接安装 
## 1.1.1
- 优化了输出的文件名，现在不会默认删除release文件夹了
## 1.1.0
- 现在可以打包amd64了
- 现在可以自定义更多内容了
- 为新的自定义增加了简单的手动检查功能
## 1.0.3
- 现在安装时如果打包的是空的`config.yaml`，则会从上一个安装中复制
- 修好了更新订阅的功能
- 修复了默认`files.config`把curl`amd64`看成`arm64`的弱智bug
## 1.0.2
- 优化了安装时的逻辑
- 现在安装时可以知道`原神`版本
- 现在打包时下载providers需要python3，解决了可能的打包失败以及原来逻辑可能出现的错误
- 现在不检查打包完整性，因为理应不可以有不完整的包
## 1.0.1
- 修复了部分情况下打包失败的问题
## 1.0.0
- 初步完成了可用的版本