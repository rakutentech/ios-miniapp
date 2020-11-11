class MACustomPermissionCell: UITableViewCell {

    @IBOutlet weak var permissionTitle: UILabel!
    @IBOutlet weak var permissionDescription: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    override func prepareForReuse() {
        super.prepareForReuse()
        toggle.isOn = true
        permissionTitle.text = ""
        permissionDescription.text = ""
    }
}
