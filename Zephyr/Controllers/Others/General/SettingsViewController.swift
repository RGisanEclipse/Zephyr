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
        self.navigationController?.navigationBar.topItem?.title = ""
        setupOptions()
        navigationItem.largeTitleDisplayMode = .always
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UINib(nibName: Constants.Settings.cellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Settings.cellIdentifier)
        settingsTableView.register(UINib(nibName: Constants.Settings.toggleTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Settings.toggleTableViewCellIdentifier)
    }
    
    private func setupOptions() {
        options = [
            SettingsModel(title: "Edit Profile",type: Constants.Settings.SimpleType, handler: { [weak self] in
                self?.handleEditProfile()
            }),
            SettingsModel(title: "Notifications", type: Constants.Settings.ToggleType, handler: { [weak self] in
                self?.doNothing()
            }),
            SettingsModel(title: "Dark Mode", type: Constants.Settings.ToggleType, handler: { [weak self] in
                self?.doNothing()
            }),
            SettingsModel(title: "Privacy Settings", type: Constants.Settings.SimpleType, handler: { [weak self] in
                self?.doNothing()
            }),
            SettingsModel(title: "Change Password", type: Constants.Settings.SimpleType, handler: { [weak self] in
                self?.handleResetPassword()
            }),
            SettingsModel(title: "Help & Support", type: Constants.Settings.SimpleType, handler: { [weak self] in
                self?.doNothing()
            }),
            SettingsModel(title: "Logout", type: Constants.Settings.SimpleType, handler: { [weak self] in
                self?.handleLogout()
            }),
            SettingsModel(title: Constants.CurrentAppVersion, type: Constants.Settings.SimpleType, handler: { [weak self] in
                self?.doNothing()
            })
        ]
    }
    private func doNothing(){
        // Just for fun only, for those who don't have the feature live yet
        return
    }
    private func handleLogout() {
        let actionSheet = UIAlertController(title: Constants.Settings.logoutTitle, message: Constants.Settings.logoutMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            AuthManager.shared.logOutUser { [weak self] loggedOut in
                DispatchQueue.main.async {
                    if loggedOut {
                        CurrentUserDataManager.shared.clearCachedUser()
                        CurrentUserDataManager.shared.userData = nil
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                            print("LoginViewController could not be instantiated")
                            return
                        }
                        loginVC.modalPresentationStyle = .fullScreen
                        self?.present(loginVC, animated: true, completion: nil)
                    } else {
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
    private func handleResetPassword(){
        guard let userData else {return}
        let actionSheet = UIAlertController(title: "Change Password?", message: "A password reset email will be sent to your email address, and you'll be logged out.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            DatabaseManager.shared.getEmail(for: userData.userName) { email in
                if email != nil{
                    AuthManager.shared.sendPasswordResetEmail(email: email!) { success, error in
                        if success{
                            let alert = UIAlertController(title: "Reset Password", message: "A link to reset password has been sent to your email.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
                                alert.dismiss(animated: true, completion: nil)
                                AuthManager.shared.logOutUser { [weak self] loggedOut in
                                    DispatchQueue.main.async {
                                        if loggedOut {
                                            CurrentUserDataManager.shared.clearCachedUser()
                                            CurrentUserDataManager.shared.userData = nil
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                                                print("LoginViewController could not be instantiated")
                                                return
                                            }
                                            loginVC.modalPresentationStyle = .fullScreen
                                            self?.present(loginVC, animated: true, completion: nil)
                                        } else {
                                            // Error Occurred
                                        }
                                    }
                                }
                            })
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }))
        actionSheet.popoverPresentationController?.sourceView = settingsTableView
        actionSheet.popoverPresentationController?.sourceRect = settingsTableView.bounds
        present(actionSheet, animated: true)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if options[indexPath.row].type == Constants.Settings.ToggleType{
            if options[indexPath.row].title == "Dark Mode"{
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Settings.toggleTableViewCellIdentifier, for: indexPath) as! ToggleTableViewCell
                cell.delegate = self
                let interfaceStyle: String?
                if self.traitCollection.userInterfaceStyle == .dark {
                    interfaceStyle = "dark"
                } else {
                    interfaceStyle = "light"
                }
                let isOn: Bool
                if let interfaceStyle {
                    isOn = interfaceStyle == "dark"
                } else {
                    isOn = false
                }
                cell.configure(title: options[indexPath.row].title ?? Constants.empty, isOn: isOn)
                return cell
            }
            else if options[indexPath.row].title == "Notifications"{
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Settings.toggleTableViewCellIdentifier, for: indexPath) as! ToggleTableViewCell
                cell.delegate = self
                // Hardcoding to false, will change when push notifications are live
                cell.configure(title: options[indexPath.row].title ?? Constants.empty, isOn: false)
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Settings.cellIdentifier, for: indexPath) as! SettingsSimpleTableViewCell
        cell.configure(with: options[indexPath.row].title ?? Constants.empty)
        return cell
    }
}

// MARK: - ToggleTableViewCellDelegate

extension SettingsViewController: ToggleTableViewCellDelegate {
    func toggleTableViewCellDidToggle(_ cell: ToggleTableViewCell, isOn: Bool) {
        if cell.cellTitle == "Dark Mode"{
            UserDefaults.standard.set(isOn, forKey: "isDarkModeEnabled")
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if isOn {
                    window.overrideUserInterfaceStyle = .dark
                } else {
                    window.overrideUserInterfaceStyle = .light
                }
            }, completion: nil)
        } else if cell.cellTitle == "Notifications"{
            // Turn Notifications on/off
            let alert = UIAlertController(title: "Notifications", message: "Push Notifications Feature coming soon!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
                cell.toggleSwitch.setOn(false, animated: true)
                alert.dismiss(animated: true, completion: nil)
            })
            present(alert, animated: true, completion: nil)
        }
    }
}
