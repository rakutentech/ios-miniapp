import UIKit

internal class MiniAppNavigationBar: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var nextButton: UIBarButtonItem!
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
        case nextButton:
            action = .forward
        default:
            break
        }
        self.delegate?.miniAppNavigationBar(self, didTriggerAction: action)
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
                buttons.append(nextButton)
            }
        }
        self.toolBar.items = buttons
    }
}
