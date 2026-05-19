# Mihomo For Magisk

![Repository Overview](https://socialify.git.ci/icewithcola/Mihomo_For_Magisk/image?description=1&forks=1&issues=1&name=1&owner=1&pulls=1&stargazers=1&theme=Dark)

Mihomo For Magisk 是一个适用于 Magisk/KSU/Apatch 的 Mihomo 模块，旨在提供 Mihomo 相关功能的便捷支持，使其能够在 Android 设备上更高效地运行。

## 📥 下载
- [![CI Build](https://github.com/icewithcola/Mihomo_For_Magisk/actions/workflows/main.yml/badge.svg)](https://github.com/icewithcola/Mihomo_For_Magisk/actions/workflows/main.yml)
- [![Telegram](https://img.shields.io/static/v1?label=Telegram&message=@mfm_updates&color=5BCEFA)](https://t.me/mfm_updates)

## 🌟 主要特性
- **一次手动打包，后续支持空包更新**
- **自动下载 Mihomo 运行所需资源** (如 GeoX, MMDB, Dashboard)
- **可选手动打包**，自动下载附加资源（包括 `config.yaml`、`proxy_providers`、`rule_providers`）
- **运行时动态更新 `config.yaml`**，保证配置的实时性

## 🔧 打包方式
在 Linux 终端运行以下命令进行打包：

```sh
./pack.sh -a
```

⚠️ 需要以下依赖：`gzip`, `wget`, `curl`, `python3`。

## 🛠 自定义配置
### 📄 files.config
该文件用于存储打包过程中的变量配置，具体内容可参考文件内的注释。

| 变量名 | 对应值 | 说明 |
|--------|--------|------|
| `pack_arch` | `mihomo_arch_arm64` | 默认为 `android-arm64-v8` |
| `pack_arch` | `mihomo_arch_amd64` | 默认为 `android-amd64`，但 **未经过测试** |

⚠️ `amd64` 版本未经过测试（因缺少设备），已知 AVD 上需要 `linux-amd64-compatible`。

#### 📌 版本选择 (`mihomo_tag`)
| 版本值 | 说明 |
|--------|------|
| `latest` | 指向最新稳定版本 |
| `Prerelease-Alpha` | 指向最新测试版 |
| `v1.1.4` (示例) | 指向指定版本 |

⚠️ `pack_arch` 在不同版本之间 **可能不相同**。 

🔹 `curl_version` 允许手动指定 `curl` 的版本，但某些特殊格式 (`x.y.z-k`) 可能无法正确获取下载链接。

### ⚠️ 注意事项
更新 `files.config` 中的下载链接时，请同时更新 `./clash/clash.config` 里的相同部分（如果适用）。

⚠️ **仅在自用时填写订阅链接，否则您的订阅信息可能会被打包进模块，造成泄露风险！**

## 🎛 Clash 配置
### 📁 clash/template
- 在 `template` 文件的开头添加 `#keep`，可防止更新时被覆盖。
- 如果 `template` 中 **没有** `dns` 块，则会从 `config.yaml` 的 `dns` 开始合并。
- 否则，将从 `config.yaml` 的 `proxy:` 行开始合并，因此 **请将其他需要合并的内容放在 `proxy` 下方**。

🔹 **最终合并方式示例**：
```yaml
template 中的内容 ...
config.yaml proxy:/dns: 这一行以下的内容 ...
```

### ✏️ clash/rewrite.yaml
模块默认会附带一个 **空** 的 `rewrite.yaml`
内核启动前，已合并的 `template + config.yaml` 会按 `rewrite.yaml` 的规则做一次 in-place 改写。
默认空文件 = 不做任何处理，安装后用户按需要填写。升级时如果你已经动过它（文件非空），会自动迁移到新的安装。

🔹 **语法**：
```yaml
rule-name:
  add-after: <regex>      # 与 add-before 二选一
  add-before: <regex>     # 与 add-after 二选一
  insert-content: '<single-line content>'
```
规则锚点有两种，二选一：
- `add-after`: 在 **第一个匹配行之后** 插入一行 `<insert-content>`。
- `add-before`: 在 **第一个匹配行之前** 插入一行 `<insert-content>`。
- 同时设置 `add-after` 和 `add-before`，或两者都不设置：该规则会被跳过并记 warning。
- `insert-content` **必须用单引号 `'...'` 包裹**，引号会被剥掉，剩下内容**原样插入**（包括用户自己写的前导空格）。引擎不再做缩进推断，需要什么样的对齐就在引号里写什么样。
- `insert-content` 必须是单行字符串，不能换行，如果有多行内容需求，可以使用 json 字符串，或者自己写 `\n`

🔹 **示例**：
```yaml
add-secret:
  add-after: ^external-controller:
  insert-content: 'secret: my-secret-token'

inject-fake-ip-filter:
  add-after: ^  fake-ip-filter:
  insert-content: '    - "*.custom.com"'

prepend-rule:
  add-before: ^  - MATCH,Proxy$
  insert-content: '  - DOMAIN-SUFFIX,example.com,Proxy'
```
对应输出（注意 `insert-content` 引号里写多少前导空格，输出就有多少）：
```yaml
external-controller: 127.0.0.1:9090
secret: my-secret-token
...
  fake-ip-filter:
    - "*.custom.com"
    - "*.lan"

rules:
  - DOMAIN-SUFFIX,example.com,Proxy
  - MATCH,Proxy
```

🔹 **行为**：
- 引擎按 `<insert-content>` 字面值逐字插入，不做任何缩进规范化或推断；写出来什么就插什么。
- `insert-content` 没有用 `'...'` 包裹 → 当前规则被跳过，`run.logs` 中会出现 `[warn][rewrite] rewrite 规则 [name] insert-content 必须使用单引号包裹 ... 已跳过.` 提示。
- `add-after` / `add-before` 找不到任何匹配行 → 当前规则被跳过，`run.logs` 中会出现 `[warn][rewrite] rewrite 规则 [name] 未匹配 ... 规则为空.` 提示。
- 内核因为改写后的配置启动失败时，会把改写前 / 改写后的 unified diff 写到 `run.logs` 里（"rewrite 改动片段"），方便定位是哪条规则导致内核启动失败。
- `rewrite.yaml` 留空（默认）= 完全不处理，启动行为和以前一样。

### 📝 日志
所有运行时脚本统一使用 `clash/scripts/clash.log` 作为 logger，日志格式：
```
[HH:MM:SS][LEVEL][TAG] message
```
- `LEVEL` ∈ `info` / `warn` / `error`；`TAG` 是组件名（`service` / `tool` / `rewrite` / `sub` / `iptables`）。
- `info` 级 = 仅写入 `run.logs`；`warn` / `error` 以及关键里程碑级 `info`（内核启动 / 订阅更新成功 / rewrite 应用统计 等）= 同时输出到 `stdout`。
- 手动运行 `clash.service -s` / `clash.tool -s` 时，终端能直接看到关键事件；过去这些只写文件、用户看不到。
- 用 `grep '\[rewrite\]' /data/clash/run/run.logs` 可以按组件过滤。

## ⚡️ 操作指南
### ✅ 启动 Mihomo
```sh
/data/clash/scripts/clash.service -s
```

### ❌ 关闭 Mihomo
```sh
/data/clash/scripts/clash.service -k
```

### 🔄 更新订阅
```sh
/data/clash/scripts/clash.tool -s
```
⚠️ **可能需要多次尝试并手动重启，确保更新成功。**

🤔 在 Magisk 中更新模块后，可以通过重启 mihomo 完成更新，而无需重启

### 🌐 WebUI 访问
访问 [http://127.0.0.1:9090/ui](http://127.0.0.1:9090/ui) 或在 Magisk 模块列表中点击 **操作** 打开。

🔹 **默认仅允许本机访问**，如需远程访问，请修改 `template` 并添加 `#keep`，建议同时设置 `secret` 以增强安全性。

## 🔗 相关链接
- [Mihomo 官方仓库](https://github.com/MetaCubeX/mihomo)
- [Magisk 官方仓库](https://github.com/topjohnwu/Magisk)
- [Clash for Magisk (CFM)](https://github.com/taamarin/ClashforMagisk)

---
📢 **欢迎贡献代码，提出 Issue，或加入 Telegram 讨论！** 🚀
