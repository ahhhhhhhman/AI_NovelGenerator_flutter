# AI小说生成器 Flutter版

一个基于Flutter开发的AI小说生成器应用程序，可以帮助用户快速生成小说内容、管理章节和角色等。

## 功能特性

- 自动生成小说内容
- 章节结构管理
- 角色状态跟踪
- 全文概览视图
- 章节管理功能
- 个性化设置
- 多语言支持（中英文）

## 界面预览

![主界面](screenshots/main_interface.png)

## 技术栈

- Flutter 3.x
- Dart
- Provider 状态管理
- Material Design 3
- 国际化支持 (i18n)

## 项目结构

```
lib/
├── main.dart                 # 应用入口文件
├── pages/                    # 页面组件
│   ├── home_page.dart        # 主页
│   ├── generator_page.dart   # 生成器页面
│   ├── favorites_page.dart   # 收藏页面
│   ├── settings_page.dart    # 设置页面
│   ├── profile_page.dart     # 个人资料页面
│   ├── search_page.dart      # 搜索页面
│   └── other_settings_page.dart # 其他设置页面
├── po/                       # 国际化相关文件
│   ├── po_localizations.dart # 本地化实现
│   └── translations/         # 翻译文件
└── assets/                   # 静态资源文件
```

## 安装与运行

### 环境要求

- Flutter 3.0 或更高版本
- Dart 2.17 或更高版本
- Android Studio / VS Code / IntelliJ IDEA (推荐)

### 安装步骤

1. 克隆项目到本地：
```bash
git clone <项目地址>
```

2. 进入项目目录：
```bash
cd ai_novelgenerator_flutter
```

3. 获取依赖包：
```bash
flutter pub get
```

4. 运行应用程序：
```bash
# 运行在Chrome浏览器上
flutter run -d chrome

# 运行在Windows桌面端
flutter run -d windows

# 运行在Android设备上
flutter run -d android
```

## 使用说明

1. **导航栏操作**：
   - 点击左侧导航栏图标可切换不同功能模块
   - 点击底部箭头按钮可收缩/展开导航栏

2. **主要功能模块**：
   - **主要功能**：应用的核心功能入口
   - **小说架构**：构建小说的整体结构
   - **章节蓝图**：设计具体章节的内容蓝图
   - **角色状态**：管理小说中的角色信息
   - **全文概述**：查看小说的完整内容概览
   - **章节管理**：管理各个章节的内容
   - **其他设置**：应用的其他配置选项

## 国际化支持

本项目支持多语言切换，目前支持：
- 简体中文
- 英语

语言会根据系统设置自动切换，也可以在设置中手动更改。

## 开发指南

### 添加新页面

1. 在 `lib/pages/` 目录下创建新的页面文件
2. 在 `lib/main.dart` 中导入新页面
3. 在 `_MyHomePageState` 的 `build` 方法中添加页面切换逻辑
4. 在导航栏中添加对应的 `NavigationRailDestination`

### 添加新翻译

1. 修改 `lib/po/translations/zh/LC_MESSAGES/messages.po` 文件添加中文翻译
2. 如果需要支持其他语言，创建对应语言的.po文件
3. 运行翻译生成命令更新本地化文件

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 许可证

本项目采用GNU Affero General Public License v3.0 (AGPL-3.0)许可证。

### 商业使用声明

本项目仅供个人学习和非商业用途使用。如需将本项目用于商业用途，必须获得版权所有者的明确授权并支付相应费用。

详细信息请参阅：
- [LICENSE](LICENSE) - AGPL-3.0许可证全文
- [COMMERCIAL_LICENSE.md](COMMERCIAL_LICENSE.md) - 商业许可证说明

### 联系方式

如需获得商业许可证或有任何疑问，请联系：

Email: your-email@example.com