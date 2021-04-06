import Foundation

// MARK: - Fallback
extension MiniAppViewController {

    class FallbackView: UIView {

        var onRetry: (() -> Void)?

        lazy var contentStackView: UIStackView = {
            let view = UIStackView(arrangedSubviews: [iconImageView, titleLabel, retryButton])
            view.axis = .vertical
            view.distribution = .fill
            view.spacing = 20
            return view
        }()

        lazy var iconImageView: UIImageView = {
            let view = UIImageView()
            view.image = UIImage(systemName: "info")
            view.contentMode = .scaleAspectFit
            return view
        }()

        lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.text = "ui_loading_failed_error".localizedString()
            view.textColor = .secondaryLabel
            view.font = .systemFont(ofSize: 12, weight: .regular)
            view.textAlignment = .center
            view.numberOfLines = 5
            return view
        }()

        lazy var retryButton: UIButton = {
            let view = UIButton(type: .system)
            view.setTitle("ui_retry_button_title".localizedString(), for: .normal)
            view.layer.cornerRadius = 20
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            return view
        }()

        init() {
            super.init(frame: .zero)

            addSubview(contentStackView)
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                contentStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                contentStackView.widthAnchor.constraint(equalToConstant: 140)
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
