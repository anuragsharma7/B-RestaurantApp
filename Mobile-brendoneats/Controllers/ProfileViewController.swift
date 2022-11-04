//
//  ProfileViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 7/25/22.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatar: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCustomerProfile()
        
        // Do any additional setup after loading the view.
    }
    
    func loadCustomerProfile() {
        //TODO: Get customer profile
        APIManager.shared.getCustomerProfile { response in
            if response != nil {
                
                DispatchQueue.main.async {
                    let customer = response?.customer
                    self.avatar.text = customer?.avatar ?? " "
                    self.phone.text = customer?.phone ?? " "
                    self.address.text = customer?.address ?? " "
                    
                }
            }
        }
    }
    
    @IBAction func update(_ sender: Any) {
        
        let avatar = self.avatar.text!
        let phone = self.phone.text!
        let address = self.address.text!
        
        APIManager.shared.updateCustomerProfile(avatar: avatar, phone: phone, address: address) { status in
            
            if status == "success" {
                
                DispatchQueue.main.async {
                    // Show alert that this field is required
                    let alertController = UIAlertController(title: "Notification", message: "Profile is updated", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                
            }
            
        }
    }
}
