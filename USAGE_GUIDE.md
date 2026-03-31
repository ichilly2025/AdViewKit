# AdViewKit 使用指南

## 快速开始

### 第一步：构建 XCFramework

在项目根目录运行：

```bash
./build-xcframework.sh
```

这会生成 `AdViewKit.xcframework` 文件夹。

### 第二步：发布到 Git

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/your-username/AdViewKit.git
git push -u origin main
git tag 1.0.0
git push --tags
```

### 第三步：用户安装

用户在他们的 iOS 项目中：

1. Xcode → File → Add Package Dependencies
2. 输入你的仓库 URL
3. 选择版本 1.0.0

## 代码示例

### UIKit 完整示例

```swift
import UIKit
import AdViewKit

class AdViewController: UIViewController {
    private let adView = AdView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 AdView
        adView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adView)
        
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            adView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            adView.widthAnchor.constraint(equalToConstant: 300),
            adView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        // 加载广告
        adView.loadAd(withID: "ad_001")
    }
}
```

### SwiftUI 完整示例

```swift
import SwiftUI
import AdViewKit

struct AdDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("广告展示")
                .font(.headline)
            
            AdViewSwiftUI(adID: "ad_001")
                .frame(width: 300, height: 250)
                .cornerRadius(8)
            
            AdViewSwiftUI(adID: "ad_002")
                .frame(width: 300, height: 250)
                .cornerRadius(8)
        }
        .padding()
    }
}
```

### 在 ScrollView 中使用

```swift
struct AdListView: View {
    let adIDs = ["ad_001", "ad_002", "ad_003"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(adIDs, id: \.self) { adID in
                    AdViewSwiftUI(adID: adID)
                        .frame(height: 200)
                        .padding(.horizontal)
                }
            }
        }
    }
}
```

## 更新广告内容

### 修改映射文件

编辑 `Sources/AdViewKitSource/Resources/AdMappings.json`：

```json
{
  "ad_001": "https://cdn.example.com/ads/banner1.jpg",
  "ad_002": "https://cdn.example.com/ads/banner2.jpg",
  "ad_003": "https://cdn.example.com/ads/banner3.jpg",
  "ad_special": "https://cdn.example.com/ads/special-offer.jpg"
}
```

### 重新构建和发布

```bash
# 1. 重新构建
./build-xcframework.sh

# 2. 提交更新
git add AdViewKit.xcframework Sources/AdViewKitSource/Resources/AdMappings.json
git commit -m "Update ad mappings"
git push

# 3. 发布新版本
git tag 1.0.1
git push --tags
```

用户更新到新版本后，新的广告映射会自动生效。

## 特性说明

### 自动缓存

图片下载后会自动缓存在内存中，同一个 ad ID 的图片只会下载一次。

### 加载状态

- UIKit: 显示 `UIActivityIndicatorView` 加载指示器
- SwiftUI: 显示 `ProgressView` 加载指示器

### 错误处理

如果 ad ID 不存在或图片加载失败，会显示灰色占位符。

## 常见问题

### Q: 用户能看到我的映射文件吗？

A: 不能。映射文件被编译到 XCFramework 二进制中，用户无法直接访问。

### Q: 如何添加更多广告？

A: 在 `AdMappings.json` 中添加新的 ID-URL 对，然后重新构建 XCFramework。

### Q: 支持哪些图片格式？

A: 支持 iOS 原生支持的所有格式：JPG, PNG, GIF, WebP 等。

### Q: 图片缓存会占用多少内存？

A: 默认最多缓存 50 张图片，使用 NSCache 自动管理内存。

### Q: 可以自定义占位符吗？

A: 当前版本使用灰色背景作为占位符。如需自定义，可以在源码中修改 `showPlaceholder()` 方法。

## 技术细节

- 最低支持：iOS 13.0+
- 语言：Swift 5.9+
- 架构：支持 arm64 (真机) 和 x86_64/arm64 (模拟器)
- 线程安全：所有 UI 更新都在主线程执行
