import Foundation

internal extension UITextView {
    @IBInspectable var localizationKey: String? {
        get {
           return nil
        }
        set {
            self.text = newValue?.localizedString()
        }
    }
}

internal extension UIBarButtonItem {
    @IBInspectable var localizationKey: String? {
        get {
           return nil
        }
        set {
            self.title = newValue?.localizedString()
        }
    }
}

internal extension UIButton {
    @IBInspectable var localizationKey: String? {
        get {
           return nil
        }
        set {
            self.setTitle(newValue?.localizedString(), for: .normal)
        }
    }
}

internal extension UILabel {
    @IBInspectable var localizationKey: String? {
        get {
           return nil
        }
        set {
            self.text = newValue?.localizedString()
        }
    }
}
