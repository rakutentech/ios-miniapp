import UIKit

internal class MiniAppNavigationBar: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var spacer: UIBarButtonItem!
    @IBOutlet var toolBar: UIToolbar!
    weak var delegate: MiniAppNavigationBarDelegate?
    var buttons: [UIBarButtonItem]!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    func initialize() {
        fromNib()
        buttons = []
    }

    @IBAction func buttonTaped(_ sender: UIBarButtonItem) {
        var action: MiniAppNavigationAction!
        switch sender {
        case backButton:
            action = .back
        case forwardButton:
            action = .forward
        default:
            break
        }
        if action != nil {
            self.delegate?.miniAppNavigationBar(didTriggerAction: action)
        }
    }
}

extension MiniAppNavigationBar: MiniAppNavigationDelegate {
    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate) {
        self.delegate = delegate
    }

    func miniAppNavigation(canUse actions: [MiniAppNavigationAction]) {
        buttons = []
        actions.forEach { (action) in
            switch action {
            case .back :
                buttons.append(backButton)
            case .forward:
                buttons.append(spacer)
                buttons.append(forwardButton)
            }
        }
        self.toolBar.items = buttons
    }
}
