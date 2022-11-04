//
//  MealTableViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/5/21.
//

import UIKit

class MealTableViewController: UITableViewController {
    
    var restaurant: Restaurant?
    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restaurantName = restaurant?.name {
            self.navigationItem.title = restaurantName
        }
        
        self.fetchMeals()
        self.createFloatingButton()
    }
    // i just check
    override func viewDidAppear(_ animated: Bool) {
        self.updateFloatingButton()
    }
    
    func fetchMeals() {
        if let restaurantId = restaurant?.id {
            
            APIManager.shared.getMeals(restaurantId: restaurantId) { json in
                if json != nil {
                    print(json!)
                    
                    self.meals = []
                    if let meals = json!["meals"].array {
                        for i in meals {
                            self.meals.append(Meal(json: i))
                            print(self.meals)
                        }
                        self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewMealDetails" {
            let controller = segue.destination as! MealDetailsViewController
            controller.meal = meals[(tableView.indexPathForSelectedRow!.row)]
            controller.restaurant = restaurant
        }
    }
    
    // MARK: - Floating button
    
    var floatingButton: UIButton?

    
    func createFloatingButton() {
        floatingButton = UIButton(type: .custom)
        floatingButton?.backgroundColor = .black
        floatingButton?.translatesAutoresizingMaskIntoConstraints = false
        floatingButton?.isHidden = true
        
        // Add action event for this button
        floatingButton?.addTarget(self, action: #selector(goToCart(_:)), for: .touchUpInside)
        
        DispatchQueue.main.async {
            self.tableView.addSubview(self.floatingButton!)
            
            self.floatingButton?.leadingAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            self.floatingButton?.trailingAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
            self.floatingButton?.bottomAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.bottomAnchor).isActive = true
            self.floatingButton?.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    }
    
    func updateFloatingButton() {
        let totalQty = Cart.currentCart.getTotalQuantity()
        floatingButton?.setTitle("View cart \(totalQty)", for: .normal)
        
        if totalQty == 0 {
            floatingButton?.isHidden = true
        } else {
            floatingButton?.isHidden = false
        }
    }
    
    @IBAction private func goToCart(_ sender: Any) {
        self.performSegue(withIdentifier: "ViewCartFromMeals", sender: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealViewCell
        
        let meal = meals[indexPath.row]
        cell.labelMealName.text = meal.name
        cell.labelMealDescription.text = meal.short_description
        cell.labelMealPrice.text = "$\(meal.price!)"
        
        if let image = meal.image {
            Utils.loadImage(cell.imageMealImage, "\(image)")
        }
        
        return cell
    }
}
