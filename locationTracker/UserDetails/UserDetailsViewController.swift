//
//  UserDetailsViewController.swift
//  locationTracker
//
//  Created by Rutwik Shinde on 05/03/22.
//

import UIKit

class UserDetailsViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var proceedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        nameField.delegate = self
        numberField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkToEnableProceedBtn()
    }
    
    func checkToEnableProceedBtn() {
        if nameField.text != "", numberField.text != "" {
            proceedBtn.isEnabled = true
        } else {
            proceedBtn.isEnabled = false
        }
    }
    
    @IBAction func proceedBtnTapped(_ sender: Any) {
        saveUserData()
        let locationVC = DisplayLocationViewController()
        locationVC.modalPresentationStyle = .fullScreen
        present(locationVC, animated: true)
    }
    
    func saveUserData() {
        UserDefaults.standard.set(nameField.text, forKey: UserDefaults.Keys.name.rawValue)
        UserDefaults.standard.set(numberField.text, forKey: UserDefaults.Keys.number.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaults.Keys.isLoggedIn.rawValue)
    }
}

extension UserDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
