import Foundation

public protocol MiniAppFallbackViewable: UIView {
    var onRetry: (() -> Void)? {get set}
}

extension MiniAppViewController {

    class FallbackView: UIView, MiniAppFallbackViewable {

        var onRetry: (() -> Void)?

        lazy var contentStackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [iconImageView, titleLabel, retryButton])
            view.axis = .vertical
            view.distribution = .fillProportionally
            view.alignment = .center
            view.spacing = 20
            return view
        }()

        lazy var iconImageView: UIImageView = {
            let view = UIImageView()
            view.image = UIImage(named: "error_bubble", in: Bundle.miniAppSDKBundle(), with: .none)
            view.contentMode = .scaleAspectFit
            return view
        }()

        lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.text = MASDKLocale.localize(.uiFallbackTitle)
            view.textColor = .secondaryLabel
            view.font = .systemFont(ofSize: 12, weight: .regular)
            view.textAlignment = .center
            view.numberOfLines = 5
            return view
        }()

        lazy var retryButton: UIButton = {
            let view = UIButton(type: .system)
            view.setTitle(MASDKLocale.localize(.uiFallbackButtonRetry), for: .normal)
            view.layer.cornerRadius = 20
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
            view.tintColor = .secondaryLabel
            view.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
            return view
        }()

        init() {
            super.init(frame: .zero)

            addSubview(contentStackView)
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                contentStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])

            retryButton.addTarget(self, action: #selector(retryPressed), for: .touchUpInside)
            retryButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                retryButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }

        required init?(coder: NSCoder) { return nil }

        @objc
        func retryPressed() {
            onRetry?()
        }
    }
}
