import UIKit

extension UITextView {
    func createHyperLinkAttributedText(fullText: String, textToLink: String, urlString: String) {
        let paragStyle = NSMutableParagraphStyle()
        paragStyle.alignment = .center
        let attributedFullText = NSMutableAttributedString(string: fullText)
        let linkTextRange = attributedFullText.mutableString.range(of: textToLink)
        let fullTextRange = NSRange(location: 0, length: attributedFullText.length)
        attributedFullText.addAttribute(.link, value: urlString, range: linkTextRange)
        attributedFullText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: fullTextRange)
        attributedFullText.addAttribute(.paragraphStyle, value: paragStyle, range: fullTextRange)
        attributedFullText.addAttribute(.foregroundColor, value: UIColor.label, range: fullTextRange)
        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.actionBlue
        ]
        self.attributedText = attributedFullText
    }
}
