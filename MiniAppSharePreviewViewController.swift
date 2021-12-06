import Foundation
import UIKit

public class MiniAppSharePreviewViewController: UIViewController {

    let promotionText: String
    let promotionImageUrl: String

    lazy var promotionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = promotionText
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()

    lazy var promotionImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var closeBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closePressed))
        return view
    }()

    init(promotionText: String, promotionImageUrl: String) {
        self.promotionText = promotionText
        self.promotionImageUrl = promotionImageUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Share"
        view.backgroundColor = .systemBackground
        navigationItem.setRightBarButton(closeBarButton, animated: false)

        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPreviewImage()
    }
    
    func setupUI() {
        view.addSubview(promotionLabel)
        NSLayoutConstraint.activate([
            promotionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            promotionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            promotionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        view.addSubview(promotionImageView)
        NSLayoutConstraint.activate([
            promotionImageView.topAnchor.constraint(equalTo: promotionLabel.bottomAnchor, constant: 20),
            promotionImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promotionImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promotionImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.667, constant: -40),
        ])

        promotionImageView.addSubview(loadingIndicatorView)
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: promotionImageView.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: promotionImageView.centerYAnchor),
        ])
    }

    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }

    func loadPreviewImage() {
        loadingIndicatorView.startAnimating()
        DispatchQueue.global().async { [weak self] in
            guard
                let imageUrlString = self?.promotionImageUrl,
                let imageUrl = URL(string: imageUrlString),
                let imageData = try? Data(contentsOf: imageUrl),
                let image = UIImage(data: imageData)
            else {
                self?.loadingIndicatorView.stopAnimating()
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.promotionImageView.image = image
                self?.loadingIndicatorView.stopAnimating()
            }
        }
    }
}
