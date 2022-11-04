//
//  SignUpViewController.swift
//  Mobile-brendoneats
//
//  Created by Shengge Han on 6/13/22.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func signUpButtonPressed() {
        let username = userNameTextField.text ?? ""
        if username.isEmpty == true {
            showError(message: "Username can't be empty")
            return
        }
        
        let password = passwordTextField.text ?? ""
        if password.isEmpty == true {
            showError(message: "Password can't be empty")
            return
        }
        
        let email = emailTextField.text ?? ""
        if email.isEmpty == true {
            showError(message: "Email can't be empty")
            return
        }
        
        APIManager.shared.signUp(username: username, password: password, email: email) { [weak self] result in
            switch result {
            case .success(let value):
                if value["id"] is Int {
                    self?.login(username: username, password: password)
                } else {
                    self?.handleErrorResponse(value: value)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func login(username: String, password: String) {
        APIManager.shared.logIn(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let value):
                if let authToken = value["auth_token"] as? String {
                    self?.loginSuccess()
                    appSession.token = authToken
                } else {
                    self?.handleErrorResponse(value: value)
                }
            case .failure(let error):
                self?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func loginSuccess() {
        DispatchQueue.main.async { [weak self] in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController")
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }
    }
    
    func handleErrorResponse(value: [String: Any]) {
        var errorMessages: [String] = []
        for key in value.keys {
            if let message = value[key] as? String {
                errorMessages.append(message)
            } else if let messages = value[key] as? [String] {
                errorMessages.append(contentsOf: messages)
            }
        }
        
        self.showError(message: errorMessages.joined(separator: "\n"))
    }

    func showError(message: String) {
        let vc = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async { [weak self] in
            self?.present(vc, animated: true)
        }
    }
}
