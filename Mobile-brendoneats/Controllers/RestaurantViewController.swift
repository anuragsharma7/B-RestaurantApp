//
//  RestaurantViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/5/21.
//

import UIKit

class RestaurantViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tableViewRestaurant: UITableView!
    @IBOutlet weak var searchBarRestaurant: UISearchBar!
    
    var restaurants = [Restaurant]()
    var filteredRestaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.fetchRestaurants()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewMealList" {
            let controller = segue.destination as! MealTableViewController
            controller.restaurant = restaurants[(tableViewRestaurant.indexPathForSelectedRow!.row)]
        }
    }
    
    func fetchRestaurants() {
        APIManager.shared.getRestaurants { json in
            if json != nil {
                //print(json!)
                
                self.restaurants = []
                if let listRes = json!["restaurants"].array {
                    for item in listRes {
                        let restaurant = Restaurant(json: item)
                        self.restaurants.append(restaurant)
                    }
                }
                
                self.tableViewRestaurant.reloadData()
            }
        }
    }
      
}

extension RestaurantViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredRestaurants = self.restaurants.filter({ (res: Restaurant) -> Bool in
            return res.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.tableViewRestaurant.reloadData()
    }
}

extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarRestaurant.text != "" {
            return self.filteredRestaurants.count
        }
        return self.restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantViewCell
        
        let restaurant: Restaurant
        if searchBarRestaurant.text != "" {
            restaurant = filteredRestaurants[indexPath.row]
        } else {
            restaurant = restaurants[indexPath.row]
        }
        
        cell.labelResName.text = restaurant.name
        cell.labelResAddress.text = restaurant.address
        
        if let logo = restaurant.logo {
            let url = "\(logo)"
            Utils.loadImage(cell.imageResLogo, url)
        }
        
        return cell
    }
}
