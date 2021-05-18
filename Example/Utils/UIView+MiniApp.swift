import Foundation
import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner = .allCorners, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func addBorderAndColor(color: UIColor,
                           width: CGFloat,
                           cornerRadius: CGFloat = 6,
                           clipsToBounds: Bool = true) {
            self.layer.borderWidth  = width
            self.layer.borderColor  = color.cgColor
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds      = clipsToBounds
    }
}

extension UIButton {
    func roundedCornerButton() {
       self.clipsToBounds = true
       self.layer.cornerRadius = 20
       self.layer.borderWidth = 2
       self.layer.borderColor = UIColor.white.cgColor
    }
}

@IBDesignable extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            layer.borderColor = newValue!.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }
}
