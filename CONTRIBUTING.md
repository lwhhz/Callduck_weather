# 贡献指南

感谢你考虑为观天象天气应用做出贡献！我们欢迎所有形式的贡献。

## 🤔 如何贡献

### 报告 Bug

如果你发现了 bug，请通过 [GitHub Issues](../../issues) 提交报告。提交时请包含：

- **清晰的标题**：简要描述问题
- **详细描述**：包括预期行为和实际行为
- **复现步骤**：提供详细的步骤让我们能够重现问题
- **环境信息**：
  - 操作系统和版本
  - Flutter 版本
  - 应用版本
- **截图**：如果适用，添加截图帮助解释问题
- **日志**：相关的错误日志或控制台输出

### 建议新功能

我们欢迎新功能建议！请在 Issue 中详细描述：

- 功能描述
- 使用场景
- 预期效果
- 可能的实现方案（可选）

### 提交代码

#### 开发环境设置

1. Fork 本仓库
2. 克隆你的 fork：
   ```bash
   git clone https://github.com/your-username/callduck_weather.git
   cd callduck_weather
   ```
3. 安装依赖：
   ```bash
   flutter pub get
   ```
4. 创建功能分支：
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### 代码规范

- **Dart 代码风格**：遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- **格式化**：使用 `dart format .` 格式化代码
- **分析**：确保通过 `flutter analyze` 检查
- **注释**：为公共 API 添加文档注释
- **命名**：
  - 文件名：snake_case
  - 类名：PascalCase
  - 变量和函数：camelCase
  - 常量：camelCase 或 SCREAMING_CAPS

#### 提交信息规范

使用清晰的提交信息：

```
类型(范围): 简短描述

详细描述（可选）

关闭 #issue编号（可选）
```

类型包括：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

示例：
```
feat(weather): 添加空气质量指数显示

在天气详情页面添加 AQI 显示，支持不同污染等级的颜色标识。

关闭 #123
```

#### Pull Request 流程

1. 确保代码通过所有测试：
   ```bash
   flutter test
   ```

2. 确保代码格式正确：
   ```bash
   dart format .
   flutter analyze
   ```

3. 提交 Pull Request，包含：
   - 清晰的标题和描述
   - 相关 Issue 的链接
   - 测试说明
   - 截图（如果是 UI 相关的改动）

4. 等待代码审查
   - 我们会尽快审查你的 PR
   - 可能会提出修改建议
   - 修改后请重新提交

#### 测试要求

- 为新功能添加单元测试
- 确保所有测试通过
- 测试覆盖率应保持或提高

## 📋 行为准则

请阅读并遵守我们的 [行为准则](CODE_OF_CONDUCT.md)。

## ❓ 问题？

如果你有任何问题，可以：
- 在 [Discussions](../../discussions) 中提问
- 创建 Issue
- 查看现有文档

## 🙏 感谢

感谢所有贡献者的付出！你的每一份贡献都让这个项目变得更好。
