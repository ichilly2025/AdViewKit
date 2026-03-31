# AdViewKit

一个用于显示广告图片的 iOS 库，通过 ID 映射到图片 URL，代码以二进制形式分发保护实现逻辑。

## 特性

- ✅ 代码隐藏：以 XCFramework 二进制形式分发
- ✅ 简单易用：通过 Swift Package Manager 安装
- ✅ 双平台支持：UIKit 和 SwiftUI
- ✅ 自动缓存：内置图片缓存机制
- ✅ 异步加载：不阻塞主线程

## 安装

### Swift Package Manager

在 Xcode 中：
1. File → Add Package Dependencies
2. 输入仓库 URL
3. 选择版本

或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/your-username/AdViewKit.git", from: "1.0.0")
]
```

## 使用方法

### UIKit

```swift
import AdViewKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let adView = AdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        adView.loadAd(withID: "ad_001")
        view.addSubview(adView)
    }
}
```

### SwiftUI

```swift
import SwiftUI
import AdViewKit

struct ContentView: View {
    var body: some View {
        AdViewSwiftUI(adID: "ad_001")
            .frame(width: 300, height: 250)
    }
}
```

## 构建 XCFramework

1. 确保你在 macOS 上安装了 Xcode
2. 运行构建脚本：

```bash
chmod +x build-xcframework.sh
./build-xcframework.sh
```

3. 生成的 `AdViewKit.xcframework` 会在项目根目录
4. 提交到 git 仓库，用户即可通过 SPM 安装

## 更新广告映射

编辑 `Sources/AdViewKitSource/Resources/AdMappings.json`：

```json
{
  "ad_001": "https://example.com/images/ad1.jpg",
  "ad_002": "https://example.com/images/ad2.jpg"
}
```

然后重新构建 XCFramework。

## 项目结构

```
AdViewKit/
├── Sources/AdViewKitSource/          # 源代码（用于构建）
│   ├── AdViewKit.swift               # 核心实现
│   └── Resources/
│       └── AdMappings.json           # ID 到 URL 的映射
├── AdViewKit.xcodeproj/              # Xcode 项目
├── Package.swift                     # Swift Package 配置
├── build-xcframework.sh              # 构建脚本
└── AdViewKit.xcframework/            # 编译后的二进制（git 提交）
```

## 许可证

MIT License
