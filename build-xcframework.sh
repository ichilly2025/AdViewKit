#!/bin/bash

# AdViewKit XCFramework 构建脚本

set -e

FRAMEWORK_NAME="AdViewKit"
BUILD_DIR="build"
XCFRAMEWORK_PATH="${FRAMEWORK_NAME}.xcframework"

echo "🧹 清理旧的构建文件..."
rm -rf "${BUILD_DIR}"
rm -rf "${XCFRAMEWORK_PATH}"

echo "📦 构建 iOS 设备架构..."
xcodebuild archive \
    -scheme ${FRAMEWORK_NAME} \
    -destination "generic/platform=iOS" \
    -archivePath "${BUILD_DIR}/ios.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "📱 构建 iOS 模拟器架构..."
xcodebuild archive \
    -scheme ${FRAMEWORK_NAME} \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "${BUILD_DIR}/ios-simulator.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "🔨 创建 XCFramework..."
xcodebuild -create-xcframework \
    -framework "${BUILD_DIR}/ios.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${BUILD_DIR}/ios-simulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${XCFRAMEWORK_PATH}"

echo "✅ XCFramework 创建成功: ${XCFRAMEWORK_PATH}"
echo "📊 大小:"
du -sh "${XCFRAMEWORK_PATH}"

echo ""
echo "🎉 完成！现在可以："
echo "1. 将 ${XCFRAMEWORK_PATH} 提交到 git"
echo "2. 用户通过 Swift Package Manager 安装"
