import UIKit

extension UIImage {
    func hasAlpha() -> Bool {
        let noAlphaCases: [CGImageAlphaInfo] = [.none, .noneSkipLast, .noneSkipFirst]
        if let alphaInfo = cgImage?.alphaInfo {
            return !noAlphaCases.contains(alphaInfo)
        } else {
            return false
        }
    }

    func dataURI() -> String? {
        var mimeType: String = ""
        var imageData: Data
        if hasAlpha(), let png = pngData() {
            imageData = png
            mimeType = "image/png"
        } else if let jpg = jpegData(compressionQuality: 1.0) {
            imageData = jpg
            mimeType = "image/jpeg"
        } else {
            return nil
        }

        return "data:\(mimeType);base64,\(imageData.base64EncodedString())"
    }
}
