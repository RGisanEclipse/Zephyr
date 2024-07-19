//
//  SettingsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    private var options: [SettingsModel] = []
    var userData: UserModel?
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        setupOptions()
        navigationItem.largeTitleDisplayMode = .always
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Settings.cellIdentifier)
    }
    
    private func setupOptions() {
        options = [
            SettingsModel(title: "Edit Profile", handler: { [weak self] in
                self?.handleEditProfile()
            }),
            SettingsModel(title: "Logout") { [weak self] in
                self?.handleLogout()
            }
        ]
    }
    
    private func handleLogout() {
        let actionSheet = UIAlertController(title: Constants.Settings.logoutTitle, message: Constants.Settings.logoutMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            AuthManager.shared.logOutUser { loggedOut in
                DispatchQueue.main.async{
                    if loggedOut{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                            print("LoginViewController could not be instantiated")
                            return
                        }
                        loginVC.modalPresentationStyle = .fullScreen
                        self.present(loginVC, animated: true, completion: nil)
                    } else{
                        // Error Occurred
                    }
                }
            }
        }))
        actionSheet.popoverPresentationController?.sourceView = settingsTableView
        actionSheet.popoverPresentationController?.sourceRect = settingsTableView.bounds
        present(actionSheet, animated: true)
    }
    private func handleEditProfile(){
        self.performSegue(withIdentifier: Constants.Settings.toEditProfile, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Settings.toEditProfile{
            let destinationVC = segue.destination as! EditProfileViewController
            destinationVC.userData = userData
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        options[indexPath.row].handler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Settings.cellIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = options[indexPath.row].title
        cell.contentConfiguration = content
        
        return cell
    }
}
