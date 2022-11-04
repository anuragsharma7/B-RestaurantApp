//
//  DeliveryViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/11/21.
//

import UIKit
import MapKit

class DeliveryViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var viewDriverInfo: UIView!
    @IBOutlet weak var imageReady: UIImageView!
    @IBOutlet weak var imageOnTheWay: UIImageView!
    @IBOutlet weak var viewOrderStatus: UIView!
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var imageDriverAvatar: UIImageView!
    @IBOutlet weak var labelDriverName: UILabel!
    @IBOutlet weak var labelCarDetails: UILabel!
    
    var orderStatus = ""
    var restaurantAddress: MKPlacemark?
    var customerAddress: MKPlacemark?
    
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Get the latest order with all details
        self.getLatestOrder()
        
        // Update the order's status every 3 seconds
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.getLatestOrderStatus()
            self.getDriverLocation()
        }
    }
    
    func getLatestOrderStatus() {
        APIManager.shared.getLatestOrderStatus { json in
            print(json!)
            
            let order = json!["last_order_status"]
            self.orderStatus = order["status"].string!
            
            self.updateStatus()
        }
    }
    
    func getLatestOrder() {
        APIManager.shared.getLatestOrder { json in
            if let order = json?["last_order"] {
                if order["status"] == "On the way",
                   let from = order["restaurant"]["address"].string,
                   let to = order["address"].string {
                    
                    // Get Driver's details
                    let driverName = order["driver"]["name"].string
                    let carModel = order["driver"]["car_model"].string ?? ""
                    let plateNumber = order["driver"]["plate_number"].string ?? ""
                    
                    self.labelDriverName.text = driverName
                    self.labelCarDetails.text = "\(carModel) - \(plateNumber)"
                    
                    self.getLocation(from, "Restaurant") { res in
                        self.restaurantAddress = res
                        
                        self.getLocation(to, "Customer") { cus in
                            self.customerAddress = cus
                            self.getDirection()
                        }
                    }
                    
                    // Update the order's status every 3 seconds
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                        self.getLatestOrderStatus()
                    }
                } else {
                    // Show a label of "No current order at the moment"
                    // I will let you do it yourself
                }
            }
        }
    }

    func updateStatus() {
        switch self.orderStatus {
            case "Ready":
                self.imageReady.alpha = 1
                break
            case "On the way":
                self.imageReady.alpha = 1
                self.imageOnTheWay.alpha = 1
                if self.viewDriverInfo.isHidden {
                    self.viewDriverInfo.isHidden = false
                    self.getLatestOrder()
                }
                break
            default:
                break
        }
    }
    
    func getDriverLocation() {
        APIManager.shared.getDriverLocation { json in
            //print(json!)
            
            if let location = json?["location"].string {
                let split = location.components(separatedBy: ",")
                let lat = split[0]
                let lng = split[1]
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat)!, longitude: CLLocationDegrees(lng)!)
                
                // Create driver pin
                if self.driverPin != nil {
                    self.driverPin.coordinate = coordinate
                } else {
                    self.driverPin = MKPointAnnotation()
                    self.driverPin.coordinate = coordinate
                    self.driverPin.title = "Driver"
                    self.map.addAnnotation(self.driverPin)
                }
                
                // Reset zoom to cover the whole 3 locations (driver, restaurant, customer)
                self.map.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                self.map.showAnnotations(self.map.annotations, animated: true)
            }
        }
    }
}


extension DeliveryViewController: MKMapViewDelegate {
    // #1 - Delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.black
        renderer.lineWidth = 5
        return renderer
    }
    
    // #2 - Convert an address (string) to a location on the map
    func getLocation(_ address: String,_ title: String,_ completionHander: @escaping (MKPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if error != nil {
                print("Error:", error!)
            }
            
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                // Create a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                self.map.addAnnotation(dropPin)
                
                completionHander(MKPlacemark.init(placemark: placemark))
            }
        }
    }
    
    // #3 - Get direction and zoom to locations on the map
    func getDirection() {
        let request = MKDirections.Request()
        request.source = MKMapItem.init(placemark: restaurantAddress!)
        request.destination = MKMapItem.init(placemark: customerAddress!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if error != nil {
                print("Error: ", error!)
            } else {
                // Show route
                self.showRoute(response: response!)
            }
        }
    }
    
    // #4 - Show route between locations and make a visible zoom
    func showRoute(response: MKDirections.Response) {
        for route in response.routes {
            self.map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
        map.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        map.showAnnotations(map.annotations, animated: true)
    }
    
    // #5 - Customize pin with image
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "MyPin"
        
        var annotationView: MKAnnotationView?
        if let dequeueAnnotaionView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeueAnnotaionView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView, let name = annotation.title! {
            switch name {
            case "Driver":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_driver")
            case "Restaurant":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_restaurant")
            case "Customer":
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_customer")
            default:
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "pin_driver")
            }
        }
        
        return annotationView
    }
}
