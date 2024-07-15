import UIKit
import FirebaseStorage
import Photos

class EditProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    private var models = [[EditProfileFormModel]]()
    var userData: UserModel?
    private var selectedImage: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Settings.EditProfile.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.Settings.EditProfile.cellIdentifier)
        configureModels()
        setupProfilePictureButton()
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        updateUserData()
    }
    
    @IBAction func didTapProfilePhotoButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: Constants.Settings.EditProfile.editProfilePictureTitle, message: Constants.Settings.EditProfile.editProfilePictureMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Remove Profile Picture", style: .destructive, handler: { _ in
            // Logic to remove profilePicture
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func configureModels() {
        guard let userData = userData else {
            print("userData is nil")
            return
        }
        
        var sectionOne = [EditProfileFormModel]()
        sectionOne.append(EditProfileFormModel(label: "First Name", placeholder: userData.name?.first ?? "", value: nil))
        sectionOne.append(EditProfileFormModel(label: "Last Name", placeholder: userData.name?.last ?? "", value: nil))
        sectionOne.append(EditProfileFormModel(label: "Username", placeholder: userData.userName, value: nil))
        sectionOne.append(EditProfileFormModel(label: "Bio", placeholder: userData.bio, value: nil))
        models.append(sectionOne)
        
        let secondSectionLabels = ["Email", "Phone", "Gender"]
        var sectionTwo = [EditProfileFormModel]()
        for label in secondSectionLabels {
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)", value: nil)
            sectionTwo.append(model)
        }
        models.append(sectionTwo)
    }
    
    private func setupProfilePictureButton() {
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = CGFloat(0.2)
        profilePictureButton.layer.borderColor = CGColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        profilePictureButton.sd_setImage(with: userData?.profilePicture, for: .normal, placeholderImage: UIImage(named: "userPlaceholder"))
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func updateUserData() {
        guard let userData = userData else {
            print("userData is nil")
            return
        }
        
        var updatedData: [String: Any] = [:]
        if let firstName = models[0][0].value {
            updatedData["firstName"] = firstName
        }
        if let lastName = models[0][1].value {
            updatedData["lastName"] = lastName
        }
        if let username = models[0][2].value {
            updatedData["userName"] = username
        }
        if let bio = models[0][3].value {
            updatedData["bio"] = bio
        }
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            StorageManager.shared.uploadImage(data: imageData) { url in
                if let downloadURL = url {
                    updatedData["profilePicture"] = downloadURL.absoluteString
                }
                self.saveUserData(updatedData: updatedData, for: userData.userName)
            }
        } else {
            saveUserData(updatedData: updatedData, for: userData.userName)
        }
    }
    
    private func saveUserData(updatedData: [String: Any], for userName: String) {
        DatabaseManager.shared.updateUserData(for: userName, with: updatedData) { success in
            if success {
                print("User data successfully updated")
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                print("Failed to update user data")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension EditProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Settings.EditProfile.cellIdentifier, for: indexPath) as! FormTableViewCell
        cell.label.text = model.label
        cell.textField.placeholder = model.placeholder
        cell.textField.text = model.value
        cell.delegate = self
        cell.model = model
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Private information" : nil
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            profilePictureButton.setImage(editedImage, for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profilePictureButton.setImage(originalImage, for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITableViewDelegate
extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - FormTableViewCell
extension EditProfileViewController: FormTableViewDelegate {
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        if let indexPath = tableView.indexPath(for: cell) {
            models[indexPath.section][indexPath.row].value = updatedModel.value
        }
    }
}
