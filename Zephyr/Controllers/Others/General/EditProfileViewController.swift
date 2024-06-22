//
//  EditProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    private var models = [[EditProfileFormModel]]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Settings.EditProfile.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.Settings.EditProfile.cellIdentifier)
        configureModels()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func didTapProfilePhotoButton(_ sender: UIButton) {
        
    }
    
    private func configureModels(){
        let firstSectionLabels = ["Name", "Username", "Bio"]
        var sectionOne = [EditProfileFormModel]()
        for label in firstSectionLabels{
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)", value: nil)
            sectionOne.append(model)
        }
        models.append(sectionOne)
        
        let secondSectionLabels = ["Email", "Phone", "Gender"]
        var sectionTwo = [EditProfileFormModel]()
        for label in secondSectionLabels{
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)", value: nil)
            sectionTwo.append(model)
        }
        models.append(sectionTwo)
    }
    
}

// MARK: - UITableViewDataSource
extension EditProfileViewController: UITableViewDataSource{
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
        guard section == 1
        else{
            return nil
        }
        return "Private information"
    }
}

// MARK: - UITableViewDelegate

extension EditProfileViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - FormTableViewCell

extension EditProfileViewController: FormTableViewDelegate{
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        print(updatedModel.value ?? "NIL")
    }
}
