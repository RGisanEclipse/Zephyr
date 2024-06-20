//
//  SettingsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    var options: [SettingsModel] = []
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOptions()
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Settings.cellIdentifier)
    }
    
    private func setupOptions() {
        options = [
            SettingsModel(title: "Logout") { [weak self] in
                self?.handleLogout()
            }
        ]
    }
    
    private func handleLogout() {
        AuthManager.shared.logOutUser { loggedOut in
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
