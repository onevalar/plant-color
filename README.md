# PlantColor 植物彩雅

一个展示中国传统植物色彩文化的iOS应用。

## 修复内容

### ✅ 已修复的问题

1. **数据文件问题**
   - 将 `PlantColor.json` 从 `植物彩雅文档/` 复制到 `PlantColor/Resources/`
   - 确保应用启动时能正确加载颜色数据

2. **Info.plist 配置完善**
   - 添加了完整的应用配置信息
   - 包含权限描述、设备支持、界面方向等
   - 添加了隐私权限说明

3. **错误处理机制改进**
   - 创建了 `Logger.swift` 统一日志管理
   - 替换所有 `print` 语句为proper的日志记录
   - 添加了 `ErrorExtension.swift` 提供用户友好的错误描述

4. **配置管理优化**
   - 创建了 `AppConfig.plist` 配置文件
   - 将敏感信息从硬编码移到配置文件
   - 改进了 `AppConfigs.swift` 的配置读取逻辑

5. **代码质量提升**
   - 添加了单元测试框架 `UnitTests.swift`
   - 改进了错误处理机制
   - 优化了第三方库初始化

6. **构建警告修复**
   - 解决了 "Create Symlinks to Header Folders" 警告
   - 解决了 "Ignoring duplicate libraries: '-lc++'" 警告
   - 优化了CocoaPods配置和post_install脚本

### 🔧 技术改进

- **日志系统**: 使用 `os.log` 框架，支持不同级别的日志记录
- **错误处理**: 自定义错误类型和用户友好的错误描述  
- **配置管理**: 从配置文件读取敏感信息，提高安全性
- **测试框架**: 简单的单元测试框架，确保核心功能正常
- **构建优化**: 解决CocoaPods构建警告，优化编译设置

### 📱 功能特性

- 展示中国传统植物色彩
- 支持Widget小组件
- 自动切换颜色展示
- 自定义内容设置
- 友盟统计集成

### 🛠 开发环境

- iOS 12.0+
- Swift 5.0+
- Xcode 12.0+
- CocoaPods

### 📦 依赖库

- RealmSwift (数据库)
- Kingfisher (图片加载)
- SnapKit (布局)
- MJRefresh (下拉刷新)
- MBProgressHUD (加载提示)
- 友盟SDK (统计)

### 🚀 运行项目

1. **安装依赖**：
   ```bash
   pod install
   ```

2. **运行构建优化脚本**（可选）：
   ```bash
   ./scripts/build_optimizer.sh
   ```

3. **打开项目**：
   ```bash
   open PlantColor.xcworkspace
   ```

4. **选择目标设备并运行**

### 📋 注意事项

- 确保 `PlantColor.json` 文件在正确位置
- 检查 `AppConfig.plist` 中的配置信息
- 在真机上测试Widget功能
- 确保网络权限正常
- 使用 `PlantColor.xcworkspace` 而不是 `.xcodeproj`

### 🔍 调试信息

应用会在控制台输出详细的日志信息，包括：
- 应用初始化状态
- 数据加载结果
- 错误信息详情
- 测试结果
- 构建环境检查

在DEBUG模式下会自动运行单元测试，检查核心功能是否正常。

### 🛠 构建警告解决方案

#### "Create Symlinks to Header Folders" 警告
- **原因**: CocoaPods脚本构建阶段没有指定输出文件
- **解决**: 重新安装Pods并优化post_install配置

#### "Ignoring duplicate libraries: '-lc++'" 警告
- **原因**: 链接器发现重复的C++标准库
- **解决**: 在Podfile中过滤重复的链接标志

#### 构建优化
- 清理DerivedData缓存
- 重新安装Pods依赖
- 优化编译设置
- 设置正确的模块化头文件配置 