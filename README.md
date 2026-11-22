# AutoBuild-OpenWrt

[![GitHub Stars](https://img.shields.io/github/stars/xkgg/AutoBuild-OpenWrt?style=flat-square&logo=github&label=Stars)](https://github.com/xkgg/AutoBuild-OpenWrt/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/xkgg/AutoBuild-OpenWrt?style=flat-square&logo=github&label=Forks)](https://github.com/xkgg/AutoBuild-OpenWrt/network/members)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/xkgg/AutoBuild-OpenWrt/Redmi-AX6000.yml?branch=master&label=Redmi%20AX6000&style=flat-square&logo=githubactions)](https://github.com/xkgg/AutoBuild-OpenWrt/actions)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/xkgg/AutoBuild-OpenWrt/Build_OP_RAX3000M.yml?branch=master&label=RAX3000M&style=flat-square&logo=githubactions)](https://github.com/xkgg/AutoBuild-OpenWrt/actions)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04%20LTS-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/24.04/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](./LICENSE)

> **基于 GitHub Actions (Ubuntu 24.04) 全自动编译 Redmi AX6000 & 移动 CMCC RAX3000M 固件，集成 OpenClash、超大磁盘扩容与全自动 Release 发布。**

---

## 📱 固件支持与默认配置

| 设备型号 | 工作流文件 | 源码分支 | 默认后台 IP | 默认账号 | 默认密码 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Redmi AX6000** | [Redmi-AX6000.yml](.github/workflows/Redmi-AX6000.yml) | ImmortalWrt `v24.10.6` | `192.168.31.1` | `root` | 空 或 `password` |
| **CMCC RAX3000M** (中国移动) | [Build_OP_RAX3000M.yml](.github/workflows/Build_OP_RAX3000M.yml) | OpenWrt `v24.10.8` | `192.168.10.1` | `root` | 空 或 `password` |

* **默认主题**：Argon
* **常用内置插件**：
  * **OpenClash**（自动集成并校验 Meta 内核，具备 3 次网络重试与下载容灾）
  * **网络唤醒**（LAN-Wake）
  * **FRP 客户端 / 服务端**（内网穿透）
  * **MiniUPnP**
  * **Alist**（文件列表程序）
  * **TTYD 终端**

---

## ⚡ 核心改进与特性

1. **全面升级 Ubuntu 24.04 LTS**
   * 工作流 `runs-on` 全面升级为现代稳定的 `ubuntu-24.04` 环境。
   * 采用专属的 [depends-ubuntu-2404](depends-ubuntu-2404) 依赖清单与 [install-deps-ubuntu-2404.sh](install-deps-ubuntu-2404.sh)，剔除废弃软件包，保证安装过程零报错。

2. **深度系统瘦身与磁盘扩容 (~60GB+ 编译空间)**
   * **环境瘦身**：通过 [clean-ubuntu-2404.sh](clean-ubuntu-2404.sh) 深度清除无用的 Dotnet、Android SDK、GHC 等大型运行时套件，释放 25GB+ 根目录空间，并针对 Ubuntu 24.04 严格保护 deb822 官方源配置（`ubuntu.sources`）。
   * **磁盘合并**：采用 `maximize-build-space@v10` 自动合并挂载，为构建过程提供超过 60GB 的充足可用空间。

3. **依赖与插件下载容灾**
   * OpenClash 内核下载加入多重重试校验与指数退避机制，网络波动时不中断主构建流程。
   * 全面修复补丁脚本中的权限判断与文件安全清理逻辑。

4. **全自动 Release 与日志归档**
   * 固件编译完成后自动打包并推送到 GitHub Releases。
   * 无论编译成功或失败均自动上传 `openwrt-build-logs` artifact，方便回溯诊断。
   * 自动定期清理历史工作流运行记录与过期 Releases，保持仓库轻量清爽。

---

## 🚀 使用方法

### 1. 准备工作
1. 点击右上角 **Fork** 按钮将本仓库分叉到你自己的 GitHub 账号下。
2. 进入你自己仓库的 **Settings** -> **Actions** -> **General** -> **Workflow permissions**，勾选 **Read and write permissions** 并保存（确保 Actions 具备发布 Release 和管理文件的权限）。

### 2. 触发编译
1. 进入仓库顶部的 **Actions** 页面。
2. 在左侧列表中选择需要编译的设备（如 `Build_Redmi_AX6000` 或 `Build_OP_RAX3000M`）。
3. 点击右侧 **Run workflow** 下拉按钮：
   * 可选勾选 `SSH_ACTION`（开启 tmate 远程终端进行 `make menuconfig` 调试配置）。
4. 点击绿色的 **Run workflow** 开始全自动编译。

### 3. 获取固件
* **Releases 页面**：构建完成后，将在仓库的 **Releases** 处自动发布包含固件包、md5/sha256 与构建配置的发布版本。
* **Artifacts**：构建过程中也可在当前运行记录页底部的 `Artifacts` 下载临时固件包或构建日志。

---

## 🛠️ 自定义配置

* **修改机型配置**：可以直接修改根目录下的对应配置文件（如 `redmi_ac2100.config`、`rax3000openwrt.config`）。
* **修改网络与默认设置**：编辑 [customize.sh](customize.sh) 或 [rax3000m/customize.sh](rax3000m/customize.sh) 可调整默认管理 IP、时区、WiFi 名称及 DHCP 分配策略。
* **添加插件**：编辑 [patches/Plugins-ax6000.sh](patches/Plugins-ax6000.sh) 或 [patches/Plugins.sh](patches/Plugins.sh) 添加或更新自定义插件源。

---

## 🤝 致谢

* [OpenWrt](https://github.com/openwrt/openwrt) & [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
* [eSirPlayground/AutoBuild-OpenWrt](https://github.com/esirplayground/AutoBuild-OpenWrt)
* [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
* [0118Add/Openwrt-CI](https://github.com/0118Add/Openwrt-CI)
* [vernesong/OpenClash](https://github.com/vernesong/OpenClash)
* [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
* [easimon/maximize-build-space](https://github.com/easimon/maximize-build-space)
* [softprops/action-gh-release](https://github.com/softprops/action-gh-release)

---

## 📄 开源许可证

本项目基于 [MIT 许可证](LICENSE) 协议发布。
