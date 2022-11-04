//
//  LoginViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/11/21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userNameTextField.text = "Brendon"
        passwordTextField.text = "test-1234"
    }
    
    @IBAction func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func login() {
        
        let userName = userNameTextField.text ?? ""
        if userName.isEmpty == true {
            showMessage(message: "Username can't be empty")
            return
        }
        
        let password = passwordTextField.text ?? ""
        if password.isEmpty == true {
            showMessage(message: "Password can't be empty")
            return
        }
        
        let loginApi = "https://brandon-appdjango.herokuapp.com/auth/token/login/"//"https://aqueous-peak-57786.herokuapp.com/auth/token/login/"
        let url = URL(string: loginApi)
        guard let requestUrl = url else { fatalError() }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let parameters = ["username": userName, "password": password]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
        
            do {
                // make sure this JSON is in the format we expect
                if let data = data,
                   let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                   /* if let message = json["detail"] as? String {
                        self?.showMessage(message: message)
                    } else */ if (json["auth_token"] as? String) != nil {
                        appSession.token = json["auth_token"] as? String
                        self?.loginSuccess()
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }

        }
        task.resume()
    }
    
    func loginSuccess() {
        DispatchQueue.main.async { [weak self] in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController")
            
            vc.modalPresentationStyle = .fullScreen
            
            self?.present(vc, animated: true)
        }
    }

    func showMessage(message: String) {
        let vc = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async { [weak self] in
            self?.present(vc, animated: true)
        }
    }
}
