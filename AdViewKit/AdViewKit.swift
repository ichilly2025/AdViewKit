import UIKit
import SwiftUI

// MARK: - Ad Configuration Manager
final class AdConfigurationManager {
    static let shared = AdConfigurationManager()
    private var adMappings: [String: String] = [:]
    
    private init() {
        loadMappings()
    }
    
    private func loadMappings() {
        guard let url = Bundle(for: type(of: self)).url(forResource: "AdMappings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let mappings = try? JSONDecoder().decode([String: String].self, from: data) else {
            print("AdViewKit: Failed to load ad mappings")
            return
        }
        self.adMappings = mappings
    }
    
    func imageURL(for adID: String) -> URL? {
        guard let urlString = adMappings[adID],
              let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
}

// MARK: - Image Cache
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 50
    }
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// MARK: - UIKit AdView
public class AdView: UIView {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var adID: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    public func loadAd(withID adID: String) {
        self.adID = adID
        
        if let cachedImage = ImageCache.shared.image(for: adID) {
            imageView.image = cachedImage
            return
        }
        
        guard let imageURL = AdConfigurationManager.shared.imageURL(for: adID) else {
            showPlaceholder()
            return
        }
        
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.showPlaceholder()
                }
                return
            }
            
            ImageCache.shared.setImage(image, for: adID)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            }
        }.resume()
    }
    
    private func showPlaceholder() {
        activityIndicator.stopAnimating()
        imageView.image = nil
        backgroundColor = .systemGray6
    }
}

// MARK: - SwiftUI AdView
@available(iOS 13.0, *)
public struct AdViewSwiftUI: View {
    let adID: String
    @State private var image: UIImage?
    @State private var isLoading = false
    
    public init(adID: String) {
        self.adID = adID
    }
    
    public var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .onAppear {
            loadAd()
        }
    }
    
    private func loadAd() {
        if let cachedImage = ImageCache.shared.image(for: adID) {
            image = cachedImage
            return
        }
        
        guard let imageURL = AdConfigurationManager.shared.imageURL(for: adID) else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data,
                  let loadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            ImageCache.shared.setImage(loadedImage, for: adID)
            
            DispatchQueue.main.async {
                image = loadedImage
                isLoading = false
            }
        }.resume()
    }
}
