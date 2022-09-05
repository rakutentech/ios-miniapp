import Foundation
import UIKit

class MiniAppProgressView: UIView, MiniAppProgressViewable {

    internal var stateImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    internal var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .systemGray2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    internal var activityLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "-"
        view.textAlignment = .center
        view.textColor = .systemGray
        view.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        view.numberOfLines = 5
        return view
    }()

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30)
        ])

        self.addSubview(activityLabel)
        NSLayoutConstraint.activate([
            activityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            activityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            activityLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        self.addSubview(stateImageView)
        NSLayoutConstraint.activate([
            stateImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stateImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30),
            stateImageView.widthAnchor.constraint(equalToConstant: 25),
            stateImageView.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

    required init?(coder: NSCoder) { return nil }

    internal func updateViewState(state: MiniAppViewState) {
        DispatchQueue.main.async {
            switch state {
            case .none: self.activityLabel.text = ""
            case .loading: self.activityLabel.text = "Loading..."
            case .active: self.activityLabel.text = "Active"
            case .inactive: self.activityLabel.text = "Inactive"
            case .error(let error): self.activityLabel.text = error.localizedDescription
            }

            switch state {
            case .none, .active, .inactive, .error:
                self.activityIndicatorView.stopAnimating()
            case .loading:
                self.activityIndicatorView.startAnimating()
            }

            switch state {
            case .active:
                self.stateImageView.image = UIImage(systemName: "checkmark.circle")
                self.stateImageView.tintColor = .systemGreen
            case .error:
                self.stateImageView.image = UIImage(systemName: "xmark.circle")
                self.stateImageView.tintColor = .systemRed
            default:
                self.stateImageView.image = nil
            }
        }
    }
}
