import Foundation
import MiniApp
import UIKit

final class KeyboardNotificationHelper: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyWindow = UIApplication.shared.keyWindow
            let totalHeight = keyWindow?.bounds.height ?? 0
            let navBarHeight: CGFloat =
                (keyWindow?.safeAreaInsets.top ?? 0) +
                (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
            let keyboardHeight = keyboardSize.height
            let screenHeight = totalHeight - navBarHeight - keyboardHeight
            MiniApp.shared().keyboardShown(navigationBarHeight: navBarHeight, screenHeight: screenHeight, keyboardheight: keyboardHeight)
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        MiniApp.shared().keyboardShown(navigationBarHeight: 0, screenHeight: 0, keyboardheight: 0)
    }
}
