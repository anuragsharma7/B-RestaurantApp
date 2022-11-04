//
//  PaymentViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/8/21.
//

import UIKit
import Lottie
import Stripe

class PaymentViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    var paymentIntentClientSecret: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
        
        // Diable Postal Code
        cardTextField.postalCodeEntryEnabled = false
        
        // Initialize the payment intent
        self.startCheckout()
    }
    
    func startCheckout() {
        APIManager.shared.createPaymentIntent { json in

            guard let client_secret = json?["client_secret"] else {
                return
            }
            self.paymentIntentClientSecret = "\(client_secret)"
        }
    }
    @IBAction func placeOrder(_ sender: Any) {
        APIManager.shared.getLatestOrder { json in
            // If the latest order is already delivered
            if json!["last_order"]["restaurant"]["name"] == "" || json!["last_order"]["status"] == "Delivered" {
                // Process the payment and create an order
                guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
                    return;
                }
                
                // Collect the card details
                let cardParams = self.cardTextField.cardParams
                let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
                print(paymentIntentClientSecret)
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
                paymentIntentParams.paymentMethodParams = paymentMethodParams
                
                // Submit the payment
                STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { status, paymentIntent, error in
                    switch (status) {
                    case .failed:
                        print("Payment failed: \(error?.localizedDescription ?? "")")
                        break
                    case .canceled:
                        print("Payment canceled: \(error?.localizedDescription ?? "")")
                        break
                    case .succeeded:
                        print("Payment succeeded: \(paymentIntent?.description ?? "")")
                        APIManager.shared.createOrder { json in
                            Cart.currentCart.reset()
                            self.performSegue(withIdentifier: "ViewDelivery", sender: self)
                        }
                        break
                    @unknown default:
                        fatalError()
                        break
                    }
                }
                
            } else {
                // Show alert message saying that you currently still have an order
                let alertView = UIAlertController(title: "Already Order?", message: "Your current order is not completed", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let okAction = UIAlertAction(title: "Go to order", style: .default) { action in
                    self.performSegue(withIdentifier: "ViewDelivery", sender: self)
                }
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
            
        }
    }
}

extension PaymentViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
