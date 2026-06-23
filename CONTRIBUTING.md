# 贡献指南 / Contributing

感谢你愿意贡献！🎉

## 报告 Bug / Reporting Bugs

1. 确认在最新版本复现
2. 用 [Bug Report 模板](../../issues/new?template=bug_report.md) 提 Issue
3. 提供 macOS 版本、错误日志、复现步骤

## 提功能建议 / Feature Requests

1. 先在 [Issues](../../issues) 搜有没有人提过
2. 用 [Feature Request 模板](../../issues/new?template=feature_request.md) 提
3. 解释**为什么要这个功能**，而不只是**想要什么**

## 提 PR / Pull Requests

1. Fork 这个仓库
2. 创建分支 (`git checkout -b feature/xxx`)
3. 改完跑一遍：
   ```bash
   swift build -c release        # 验证编译
   bash install-安装.command       # 验证打包
   ```
4. 提 PR 描述清楚改了什么、为什么

### 代码规范

- Swift 代码遵守 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 注释用英文（代码里），文档用中文（README / Issues / PR）
- 4 空格缩进
- 保持简单：能不加抽象就不加

## 提 PR 前自检

- [ ] `swift build -c release` 通过
- [ ] 没有引入硬编码的 token / cookie / 密码
- [ ] 没有把 `.build/` / `MiniMaxMeter.app/` 提交
- [ ] README 里的指令都试过一遍
- [ ] 新功能有截图（如果适用）

## 不接受

- 把项目改名（叫 MiniMaxMeter 就一直叫）
- 加任何形式的 telemetry / 上传用户数据
- 加依赖（保持零运行时依赖）

## 许可

提交 PR 即同意按 [MIT LICENSE](LICENSE) 授权你的贡献。
