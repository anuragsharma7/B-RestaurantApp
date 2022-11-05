//
//  CartViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/6/21.
//

import UIKit
import MapKit


class CartViewController: UIViewController {

    @IBOutlet weak var tableViewCart: UITableView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var viewAddress: UIView!
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var buttonCheckout: UIButton!
    
    
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSideMenu()
        configUI()
        configLocation()
        
        
    }
    
    func configSideMenu() {
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func configUI() {
        if Cart.currentCart.items.count == 0 {
            // Show a message
            let labelMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            labelMessage.center = self.view.center
            labelMessage.textAlignment = NSTextAlignment.center
            labelMessage.text = "Your cart is empty. Please select a meal"
            self.view.addSubview(labelMessage)
            
        } else {
            // Display all of the UI controller
            self.tableViewCart.isHidden = false
            self.viewTotal.isHidden = false
            self.viewAddress.isHidden = false
            self.map.isHidden = false
            self.buttonCheckout.isHidden = false
            
            self.fetchMeals()
        }
    }
    
    func configLocation() {
        // Show current user's location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = true
        }
    }
    
    func fetchMeals() {
        self.tableViewCart.reloadData()
        self.labelTotal.text = "$\(Cart.currentCart.getTotalValue())"
    }
    
    @IBAction func goToCheckout(_ sender: Any) {
        if self.textFieldAddress.text == "" {
            // Show alert that this field is required
            let alertController = UIAlertController(
                title: "No Address",
                message: "Address is required",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default) { alert in
                self.textFieldAddress.becomeFirstResponder()
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Cart.currentCart.address = textFieldAddress.text
            self.performSegue(withIdentifier: "ViewCheckout", sender: self)
        }
    }
    
}

extension CartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let address = textField.text
        Cart.currentCart.address = address
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!) { placemarks, error in
            if error != nil {
                print("Error: ", error!)
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                let region = MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                self.map.setRegion(region, animated: true)
                self.locationManager.stopUpdatingLocation()
                
                // Create a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                self.map.addAnnotation(dropPin)
            }
        }
        
        return true
    }
}

extension CartViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didupdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let center = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.map.setRegion(region, animated: true)
        }
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.currentCart.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartViewCell
        
        let mealItem = Cart.currentCart.items[indexPath.row]
        cell.labelQty.text = "\(mealItem.qty)"
        cell.labelMealName.text = mealItem.meal.name
        cell.labelSubTotal.text = "$\(mealItem.meal.price! * Float(mealItem.qty))"
        
        return cell
    }
}
