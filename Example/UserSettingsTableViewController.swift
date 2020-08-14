import UIKit
import MiniApp

class UserSettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var modifyProfileSettingsButton: UIBarButtonItem!

    var userProfileImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.roundedCornerImageView()
        setProfileImage(image: retrieveProfileSettings())
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func setProfileImage(image: UIImage?) {
        guard let profileImage = image else {
            editPhotoButton.setTitle("Add Photo", for: .normal)
            return
        }
        editPhotoButton.setTitle("Edit", for: .normal)
        self.imageView.image = profileImage
        self.userProfileImage = profileImage
    }

    @IBAction func showPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }

    @IBAction func modifyProfileSettings() {
        if modifyProfileSettingsButton.title == "Edit" {
            modifyProfileSettingsButton.title = "Save"
        } else {
            if !saveProfileSettings() {
                return
            }
            modifyProfileSettingsButton.title = "Edit"
        }
        displayNameTextField.isEnabled = !displayNameTextField.isEnabled
        editPhotoButton.isEnabled = !editPhotoButton.isEnabled
        editPhotoButton.isHidden  = !editPhotoButton.isHidden
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("User cancelled the operation")
            return
        }
        setProfileImage(image: image)
    }

    func saveProfileSettings(forKey key: String = "ProfileImage") -> Bool {
        let name = displayNameTextField.text?.trimTrailingWhitespaces()
        guard let userDisplayName = name, !userDisplayName.isEmpty else {
            self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_user_profile_name_not_found", comment: ""))
            return false
        }

        if let data = try? PropertyListEncoder().encode(UserProfileModel(displayName: userDisplayName, profileImage: self.userProfileImage)) {
            UserDefaults.standard.set(data, forKey: key)
            return true
        }
        return false
    }

    func retrieveProfileSettings(key: String = "ProfileImage") -> UIImage? {
        if let userProfile = UserDefaults.standard.data(forKey: key) {
            let userProfileData = try? PropertyListDecoder().decode(UserProfileModel.self, from: userProfile)
            self.displayNameTextField.text = userProfileData?.displayName
            guard let imageData = userProfileData?.profileImageData else {
                return nil
            }
            return UIImage(data: imageData)
        }
        return nil
    }
}

extension UIImageView {
    func roundedCornerImageView() {
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
    }
}

struct UserProfileModel: Codable {
    var displayName: String?
    var profileImageData: Data?

    init(displayName: String, profileImage: UIImage?) {
        self.displayName = displayName
        self.profileImageData = profileImage?.pngData()
    }
}
