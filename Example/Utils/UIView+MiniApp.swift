import Foundation
import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner = .allCorners, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func setBorder(width: CGFloat = 0,
                   cornerRadius: CGFloat = 6,
                   color: UIColor? = nil,
                   clipsToBounds: Bool = true) {
            layer.borderWidth  = width
            layer.borderColor  = color?.cgColor
            layer.cornerRadius = cornerRadius
            self.clipsToBounds = clipsToBounds
    }
}

extension UIButton {
    func roundedCornerButton(color: UIColor = UIColor.white) {
        setBorder(width: 2, cornerRadius: frame.height/2, color: color)
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
