import UIKit

extension UIImageView {
    func loadImage(_ url: URL, placeholder: String? = nil, cache: ImageCache? = nil) {

        if let cachedImage = cache?[url] {
            self.image = cachedImage
        } else {
            if let imageName = placeholder {
                self.image = UIImage(named: imageName)
            } else {
                self.image = nil
            }
            UIImageView.downloadImage(url, for: self, cache: cache)
        }
    }

    class func downloadImage(_ url: URL, for imageView: UIImageView, cache: ImageCache? = nil) {
        let tag = Int(Date().timeIntervalSince1970)
        imageView.tag = tag
        DispatchQueue.global().async { [weak imageView] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if imageView?.tag == tag {
                            imageView?.image = image
                        } else {
                            print("image tag diff")
                        }
                        cache?[url] = image
                    }
                }
            }
        }
    }
}
