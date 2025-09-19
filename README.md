# AI小说生成器 Flutter版

一个基于Flutter开发的AI小说生成器应用程序，可以帮助用户快速生成小说内容、管理章节和角色等。
为[原Python版本](https://github.com/YILING0013/AI_NovelGenerator)的Flutter重构版本。

## 功能特性

- 自动生成小说内容和章节
- 小说架构智能规划
- 章节蓝图设计
- 角色状态动态跟踪
- 全文内容概览
- 精确的章节管理
- 个性化配置设置
- 中英文双语支持
- 多种LLM模型支持（DeepSeek、GPT、Gemini等）

## 技术栈

- Flutter 3.x
- Dart 2.17+
- Provider 状态管理
- Material Design 3
- i18n 国际化支持
- WebDAV 同步支持

## 项目结构

```
lib/
├── main.dart                # 应用入口
├── app/                     # 应用配置
├── data/                    # 数据层
├── domain/                  # 业务层
├── presentation/           # UI层
└── utils/                  # 工具类
```

## 安装使用

### 方式一：直接下载使用

1. 前往 [Releases](https://github.com/ahhhhhhhman/AI_NovelGenerator_flutter/releases) 页面
2. 下载对应平台的安装包：
   - Windows: 下载 `.exe` 安装包
3. 运行安装程序或直接打开应用即可使用

### 方式二：源码安装

#### 环境要求

- Flutter 3.0+
- Dart 2.17+
- Android Studio / VS Code / IntelliJ IDEA

#### 安装步骤

1. 克隆项目：
```bash
git clone https://github.com/ahhhhhhhman/AI_NovelGenerator_flutter
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行应用：
```bash
flutter run -d <platform>  # platform可以是windows/chrome/android等
```

## LLM模型配置

支持多种大语言模型服务，在`C:\Users\{用户名}\Documents\novel_generator_flutter\config.json`中配置：

```json
{
    "llm_configs": {
        "DeepSeek V3": {
            "base_url": "https://api.deepseek.com/v1",
            "model_name": "deepseek-chat"
        },
        "GPT 5": {
            "base_url": "https://api.openai.com/v1",
            "model_name": "gpt-5"
        },
        "Gemini 2.5 Pro": {
            "base_url": "https://generativelanguage.googleapis.com/v1beta/openai",
            "model_name": "gemini-2.5-pro"
        }
    }
}
```

## 其他功能

### WebDAV同步
- 支持配置和数据的云端同步
- 自动备份和恢复
- 实时同步更新

### 国际化
- 支持中文和英文
- 自动适应系统语言
- 可手动切换语言

## 许可证

GNU Affero General Public License v3.0 (AGPL-3.0)

## 联系我们

如有问题或建议，欢迎提交Issue或Pull Request。