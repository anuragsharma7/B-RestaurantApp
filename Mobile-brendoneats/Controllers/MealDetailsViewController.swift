//
//  MealDetailsViewController.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/6/21.
//

import UIKit
import ExpyTableView

class MealDetailsViewController: UIViewController {
    
    @IBOutlet weak var buttonDecrease: UIButton!
    @IBOutlet weak var buttonIncrease: UIButton!
    @IBOutlet weak var buttonAddToCart: UIButton!
    @IBOutlet weak var buttonCart: UIButton!
    
    @IBOutlet weak var imageMealImage: UIImageView!
    @IBOutlet weak var labelMealName: UILabel!
    @IBOutlet weak var labelMealDescription: UILabel!
    
    @IBOutlet weak var labelQty: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var expandableTableView: ExpyTableView!
    
    var generalLabel = UILabel()
    var restaurant: Restaurant?
    var meal: Meal?
    var qty = 1
    
    var arrSingleSelect: [Item] = []
    var arrMultipleSelect: [Item] = []
    var arrCheckbox: [Int] = []
    
    var lastAddedPriceForSingleSelection: Float = 0.0
     
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Delegate and Datasource to self controller
        expandableTableView.delegate = self
        expandableTableView.dataSource = self
        
        DispatchQueue.main.async {
            self.formatButtons()
            self.fetchMeal() //udpate UI for text
            self.checkBadge()
        }
        
        print("Meal ===> \(meal!)")
        
        for _ in 0..<meal!.extras![2].items!.count {
            arrCheckbox.append(0)
        }
        
    }
    
    func formatButtons() {
        buttonDecrease.layer.cornerRadius = buttonDecrease.frame.width / 2
        buttonDecrease.layer.masksToBounds = true
        
        buttonDecrease.backgroundColor = .clear
        buttonDecrease.layer.borderWidth = 1
        buttonDecrease.layer.backgroundColor = UIColor.systemGray5.cgColor
        
        buttonIncrease.layer.cornerRadius = buttonDecrease.frame.width / 2
        buttonIncrease.layer.masksToBounds = true
        
        buttonIncrease.backgroundColor = .clear
        buttonIncrease.layer.borderWidth = 1
        buttonIncrease.layer.backgroundColor = UIColor.systemGray5.cgColor
    }
    
    func fetchMeal() {
        //print(meal)
        self.labelQty.text = "\(qty)"
        self.labelMealName.text = meal?.name
        self.labelMealDescription.text = meal?.short_description
        if let price = meal?.price {
            labelTotal.text = "$\(price)"
        }
        
        if let imageUrl = meal?.image {
            Utils.loadImage(imageMealImage, "\(imageUrl)")
        }
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Badge
    
    let badgeSize: CGFloat = 24
    let badgeTag = 9830384
    
    func badgeLabel(withCount count: Int) -> UILabel {
        let badgeCount = UILabel(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))
        badgeCount.translatesAutoresizingMaskIntoConstraints = false
        badgeCount.tag = badgeTag
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .black
        badgeCount.text = String(count)
        return badgeCount
    }
    
    func showBadge() {
        buttonCart.addSubview(generalLabel)
        
        NSLayoutConstraint.activate([
            generalLabel.leftAnchor.constraint(equalTo: buttonCart.leftAnchor, constant: 14),
            generalLabel.topAnchor.constraint(equalTo: buttonCart.topAnchor, constant: -6),
            generalLabel.widthAnchor.constraint(equalToConstant: badgeSize),
            generalLabel.heightAnchor.constraint(equalToConstant: badgeSize)
        ])
    }
    
    func removeBadge() {
        if let badge = buttonCart.viewWithTag(badgeTag) {
            badge.removeFromSuperview()
        }
    }
    
    func checkBadge() {
        let totalQty = Cart.currentCart.getTotalQuantity()
        self.generalLabel = badgeLabel(withCount: totalQty)
        
        if totalQty > 0 {
            removeBadge()
            showBadge()
            buttonCart.isEnabled = true
        } else {
            removeBadge()
            buttonCart.isEnabled = false
        }
    }
    
    func addToCartGlobal() {
        let cartItem = CartItem(meal: self.meal!, qty: self.qty)
        
        // Check if a current cart and a current restaurant exist then we add this item into the existing card
        guard let cartRestaurant = Cart.currentCart.restaurant, let currentRestaurant = self.restaurant else {
            // Add this meal in the current Cart
            Cart.currentCart.restaurant = self.restaurant
            Cart.currentCart.items.append(cartItem)
            
            print(Cart.currentCart.getTotalQuantity())
            goBack()
            return
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // if ordering meal from the same restaurant
        if cartRestaurant.id == currentRestaurant.id {
            //Scenario #1 Ordering the same meal => increase the qty of an existing card
            //Scenario #2 Ordering different meal ==> just append that meal to the Cart
            
            let inCart = Cart.currentCart.items.lastIndex { (item) -> Bool in
                return item.meal.id == cartItem.meal.id
            }
            
            if let index = inCart {
                
                let alertView = UIAlertController(
                    title: "Add more?",
                    message: "Your cart already has this meal. Do you want to add more?",
                    preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(title: "Add more", style: .default) { action in
                    Cart.currentCart.items[index].qty += self.qty
                    print(Cart.currentCart.getTotalQuantity())
                    self.goBack()
                }
                
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                self.present(alertView, animated: true, completion: nil)
            } else {
                Cart.currentCart.items.append(cartItem)
                print(Cart.currentCart.getTotalQuantity())
                goBack()
            }
        } else {
            // Ordering meal from a different restaurant ==> Error
            let alertView = UIAlertController(
                title: "Start new cart?",
                message: "You're ordering meal from another restaurant. Do you want to clear the current Cart?",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "Yes", style: .default) { action in
                Cart.currentCart.items = []
                Cart.currentCart.items.append(cartItem)
                Cart.currentCart.restaurant = self.restaurant
                
                print(Cart.currentCart.getTotalQuantity())
                self.goBack()
            }
            
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    //MARK: - IBActions -
    
    // MARK: CART
    
    @IBAction func decreaseQty(_ sender: Any) {
        if qty >= 2 {
            qty -= 1
            labelQty.text = String(qty)
            
            let newText = "Add \(qty) To Cart"
            buttonAddToCart.setTitle(newText, for: .normal)
            
            if let price = meal?.price {
//                labelTotal.text = "$\(price * Float(qty))"
                labelTotal.text = "$\(Float(labelTotal.text!.dropFirst())! - price)"
            }
        }
    }
    
    @IBAction func increaseQty(_ sender: Any) {
        if qty < 99 {
            qty += 1
            labelQty.text = String(qty)
            
            let newText = "Add \(qty) To Cart"
            buttonAddToCart.setTitle(newText, for: .normal)
            
            if let price = meal?.price {
//                labelTotal.text = "$\(price * Float(qty))"
                labelTotal.text = "$\(Float(labelTotal.text!.dropFirst())! + price)"
            }
        }
    }
    
    @IBAction func addToCart(_ sender: Any) {
        addToCartGlobal()
    }
    
}


//MARK: Data Source
extension MealDetailsViewController: ExpyTableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (meal?.extras!.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Adding extra count because the first index is for Title
        return (meal?.extras?[section].items!.count)! + 1
    }
    
    // Title Cell
    // Then return your expandable cell instance from this data source method.
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        // This cell will be displayed at IndexPath with (section: section and row: 0)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCellForExpandable") as! TitleCellForExpandable
        cell.textLabel!.text = meal?.extras?[section].title ?? "N/A"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return ExpyTableViewDefaultValues.expandableStatus
    }
    
    //Cell inside expandable/collapsable
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let extras = meal?.extras![indexPath.section]
        let price = String(extras!.items?[indexPath.row - 1].price ?? 0)
        
        switch indexPath.section {
        case 0:
            //cell single selection
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleSelctionCell") as! SingleSelctionCell
            
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .gray
            
            //            if let idx = arrCheckboxSelect.firstIndex(where: { $0 === extras!.items?[indexPath.row - 1] }) {
            //                print(idx)
            //            }
            
            if arrSingleSelect.count > 0 {
                if extras!.items![indexPath.row - 1].id == arrSingleSelect[0].id {
                    cell.imgSelectUnselect.image = UIImage(systemName: "circle.fill")
                } else {
                    cell.imgSelectUnselect.image = UIImage(systemName: "circle")
                }
            }
 
            //            if let i = array.firstIndex(where: { $0.name == "Foo" }) {
            //                return array[i]
            //            }
            
            //subtracting one because Row 0 is row 1
            cell.textLabel?.text = (extras!.items![indexPath.row - 1].name)!
            cell.textLabel?.text = (cell.textLabel?.text)! + " - $" + price
            
            return cell
            
        case 1:
            //cell multiple selection
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableCell") as! ExpandableCell
            
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .gray
            
            cell.btnMinus.addTarget(self, action: #selector(btnMinusAction(_:)), for: .touchUpInside)
            cell.btnPlus.addTarget(self, action: #selector(btnPlusAction(_:)), for: .touchUpInside)
            //update data from array here
//            cell.lblCount
            //subtracting one because Row 0 is row 1
            cell.textLabel?.text = (extras!.items![indexPath.row - 1].name)!
            cell.textLabel?.text = (cell.textLabel?.text)! + " - $" + price
            // cell.detailTextLabel?.text = String(extras!.items?[indexPath.row - 1].price ?? 0)  // Update here,
            
            return cell
        case 2:
            //cell checkbox selection
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxCell") as! CheckboxCell
            
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .gray
            
            if arrCheckbox.count > 0 {
                
                cell.imgCheckbox.image = arrCheckbox[indexPath.row - 1] == 0 ? UIImage(systemName: "square") : UIImage(systemName: "square.fill")
                //
                //                if arrCheckbox[indexPath.row - 1] == 0 {
                //                    cell.imgCheckbox.image = UIImage(systemName: "square.fill")
                //                } else {
                //                    cell.imgCheckbox.image = UIImage(systemName: "square")
                //                }
                //
            }
            
            //subtracting one because Row 0 is row 1
            cell.textLabel?.text = (extras!.items![indexPath.row - 1].name)!
            cell.textLabel?.text = (cell.textLabel?.text)! + " - $" + price
            //update data from array here
//            cell.imgCheckbox.image
            return cell
        default:
            return UITableViewCell()
            
        }
        
    }
    
    
    // btn target fxns inside second section row
    @objc func btnMinusAction(_ sender: UIButton) {
        
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: expandableTableView)
        let indexPath = expandableTableView.indexPathForRow(at: buttonPosition)
        let cell = expandableTableView.cellForRow(at: indexPath!) as! ExpandableCell
        
        if Int(cell.lblCount.text!)! > 0 {
            //add to total price
            if Int(cell.lblCount.text!)! >= 0 {
                if let price: Float = meal?.extras![indexPath!.section].items![indexPath!.row - 1].price {
                    if let existingTotal = Float(labelTotal.text!.dropFirst()) {
                        
                        labelTotal.text = "$\(existingTotal - price)"
                        cell.lblCount.text = String(Int(cell.lblCount.text!)! - 1)
                    }
                    
                }
            }
        }
        
        
    }
    
    @objc func btnPlusAction(_ sender: UIButton) {
        
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: expandableTableView)
        let indexPath = expandableTableView.indexPathForRow(at: buttonPosition)
        let cell = expandableTableView.cellForRow(at: indexPath!) as! ExpandableCell
        
        if Int(cell.lblCount.text!)! >= 0 {
            if let price: Float = meal?.extras![indexPath!.section].items![indexPath!.row - 1].price {
                if let existingTotal = Float(labelTotal.text!.dropFirst()) {
                    
                    labelTotal.text = "$\(existingTotal + price)"
                    cell.lblCount.text = String(Int(cell.lblCount.text!)! + 1)
                }
                
            }
        }
        
    }
    
    
}

extension Array where Element: Equatable {
    func subtracting(_ array: Array<Element>) -> Array<Element> {
        self.filter { !array.contains($0) }
    }
}

extension MealDetailsViewController: ExpyTableViewDelegate {
    
    
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        
        if state == .willExpand {
            tableView.scrollToBottom(isAnimated: true)
        }
        //print("Current state: \(state)")
    }
    
    
    
    //All of the UITableViewDataSource and UITableViewDelegate methods will be forwarded to you right as they are.
    //Here you can see two examples below.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")
        let extras = meal?.extras![indexPath.section]
        
        if indexPath.section == 0 {
            let cell: SingleSelctionCell? = tableView.cellForRow(at: indexPath) as? SingleSelctionCell
            
            if cell?.imgSelectUnselect.image == UIImage(systemName: "circle") {
                cell?.imgSelectUnselect.image = UIImage(systemName: "circle.fill")
                arrSingleSelect = []
                arrSingleSelect.append((extras!.items?[indexPath.row - 1])!)
                print(arrSingleSelect)
                
                //add latest
                if let selectedExtrasPrice: Float = extras!.items![indexPath.row - 1].price {
                     
                    //minus last added from total
                    labelTotal.text = "$\(Float(labelTotal.text!.dropFirst())! - lastAddedPriceForSingleSelection)"
                    
                    //Now add the price user has choosen
                    
                    labelTotal.text = "$\(Float(labelTotal.text!.dropFirst())! + selectedExtrasPrice)"
                    
                    //update last added price
                    lastAddedPriceForSingleSelection = selectedExtrasPrice
                     
                }
                
            } else {
                cell?.imgSelectUnselect.image = UIImage(systemName: "circle")
            }
        } else if indexPath.section == 2 {
            
            if indexPath.row != 0 {
                
                let cell: CheckboxCell? = tableView.cellForRow(at: indexPath) as? CheckboxCell
                
                if cell?.imgCheckbox.image == UIImage(systemName: "square") {
                    cell?.imgCheckbox.image = UIImage(systemName: "square.fill")
                    arrCheckbox[indexPath.row - 1] = 1
                    
                    if let price: Float = extras!.items![indexPath.row - 1].price {
                        if let existingTotal = Float(labelTotal.text!.dropFirst()) {
                            
                            labelTotal.text = "$\(existingTotal + price)"
                        }
                    }
                    
                } else {
                    cell?.imgCheckbox.image = UIImage(systemName: "square")
                    arrCheckbox[indexPath.row - 1] = 0
                    
                    if let price: Float = extras!.items![indexPath.row - 1].price {
                        if let existingTotal = Float(labelTotal.text!.dropFirst()) {
                            
                            labelTotal.text = "$\(existingTotal - price)"
                            
                        }
                    }
                }
            }
            
        }
        
        //subtracting one because Row 0 is row 1
        // cell.textLabel?.text = extras!.items?[indexPath.row - 1].name ?? "N/A"
        if let cell: ExpandableCell = tableView.cellForRow(at: indexPath) as? ExpandableCell {
            
            //                selectedExtras.append(extras!.items?[indexPath.row - 1])
            //            } else {
            
            //                if let idx = selectedExtras.firstIndex(where: { $0 === extras!.items?[indexPath.row - 1] }) {
            //                    selectedExtras.remove(at: idx)
            //                }
            //            }
            
        }
        
        //addToCartGlobal()
        expandableTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 150.0
        }
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}

//
//extension MealDetailsViewController: ExpandableCellDelegate {
//    func sharePressed(quantity: Int) {
//        print(quantity)
//    }
//
//}


extension UITableView {
    
    func scrollToBottom(isAnimated:Bool = true) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }
    
    func scrollToTop(isAnimated:Bool = true) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension String {
    func parseToInt() -> Float? {
        return Float(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
    
    func stringToFloat() -> Float? {
        let numberFormatter = NumberFormatter()
        let number = numberFormatter.number(from: self)
        let numberFloatValue = number?.floatValue
        return numberFloatValue!
    }
}
