#!/bin/bash

# PlantColor 构建优化脚本
# 用于解决构建警告和优化构建过程

echo "🔧 PlantColor 构建优化脚本开始..."

# 检查是否在项目根目录
if [ ! -f "Podfile" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 清理旧的构建文件
echo "🧹 清理旧的构建文件..."
rm -rf ~/Library/Developer/Xcode/DerivedData/PlantColor-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 重新安装Pods
echo "📦 重新安装Pods..."
pod deintegrate
pod install

# 检查Xcode版本
echo "🔍 检查Xcode版本..."
xcodebuild -version

# 检查iOS SDK
echo "🔍 检查iOS SDK..."
xcodebuild -showsdks | grep iOS

# 验证项目文件
echo "✅ 验证项目文件..."
if [ -f "PlantColor/Resources/PlantColor.json" ]; then
    echo "✅ PlantColor.json 存在"
else
    echo "❌ PlantColor.json 不存在"
fi

if [ -f "PlantColor/Resources/AppConfig.plist" ]; then
    echo "✅ AppConfig.plist 存在"
else
    echo "❌ AppConfig.plist 不存在"
fi

if [ -f "PlantColor.xcworkspace" ]; then
    echo "✅ PlantColor.xcworkspace 存在"
else
    echo "❌ PlantColor.xcworkspace 不存在"
fi

# 设置正确的权限
echo "🔐 设置文件权限..."
chmod +x scripts/build_optimizer.sh

echo "✅ 构建优化完成！"
echo "💡 提示: 现在可以打开 PlantColor.xcworkspace 进行构建" 