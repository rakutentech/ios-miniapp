import Foundation
import UIKit

class PointsSettingsViewController: UITableViewController {

    @IBOutlet weak var standardPointsTextField: UITextField!
    @IBOutlet weak var termPointsTextField: UITextField!
    @IBOutlet weak var timeLimitedPointsTextField: UITextField!

    @IBOutlet weak var saveBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Points"

        tableView.tableFooterView = UIView()

        if let pointsModel = getUserPoints() {
            if let standardPoints = pointsModel.standardPoints {
                standardPointsTextField.text = String(standardPoints)
            }
            if let termPoints = pointsModel.termPoints {
                termPointsTextField.text = String(termPoints)
            }
            if let timeLimitedPoints = pointsModel.cashPoints {
                timeLimitedPointsTextField.text = String(timeLimitedPoints)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    @IBAction func savePressed(_ sender: Any) {
        [standardPointsTextField, termPointsTextField, timeLimitedPointsTextField]
        .forEach { (textField) in
            textField?.resignFirstResponder()
        }

        let pointsModel = UserPointsModel(
            standardPoints: Int(standardPointsTextField.text ?? ""),
            termPoints: Int(termPointsTextField.text ?? ""),
            cashPoints: Int(timeLimitedPointsTextField.text ?? "")
        )
        if saveUserPoints(pointsModel: pointsModel) {
            print("user points saved")
            navigationController?.popViewController(animated: true)
        } else {
            print("user point failed to save")
        }
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if textFieldText.isEmpty {
            return true
        } else if let integerValue = Int(textFieldText), integerValue <= INT_MAX {
            return true
        }
        return false
    }
}
