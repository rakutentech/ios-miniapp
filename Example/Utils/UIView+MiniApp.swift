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
