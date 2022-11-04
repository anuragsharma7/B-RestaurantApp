//
//  ExpandableCell.swift
//  Mobile-brendoneats
//
//  Created by Sunil on 19/10/22.
//

import UIKit
import ExpyTableView

//https://stackoverflow.com/a/40111943/4933696

//protocol ExpandableCellDelegate: AnyObject {
//    func sharePressed(quantity: Int)
//}

class ExpandableCell: UITableViewCell {
    
//    var delegate: ExpandableCellDelegate?
    
    var extrasData: Item?
 
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        formatButtons()
        lblCount.text = "0"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func formatButtons() {
        btnMinus.layer.cornerRadius = btnMinus.frame.width / 2
        btnMinus.layer.masksToBounds = true
        
        btnMinus.backgroundColor = .clear
        btnMinus.layer.borderWidth = 0.80
        btnMinus.layer.borderColor = UIColor.gray.cgColor
        btnMinus.layer.backgroundColor = UIColor.systemGray5.cgColor
        
        btnPlus.layer.cornerRadius = btnPlus.frame.width / 2
        btnPlus.layer.masksToBounds = true
        
        btnPlus.backgroundColor = .clear
        btnPlus.layer.borderWidth = 0.80
        btnPlus.layer.borderColor = UIColor.gray.cgColor
        btnPlus.layer.backgroundColor = UIColor.systemGray5.cgColor
    }
    
//    @IBAction func btnMinus(_ sender: UIButton) {
//        if Int(lblCount.text!)! != 0 {
//            let count = Int(lblCount.text!)! - 1
//            lblCount.text = String(count)
//            delegate?.sharePressed(quantity: count)
//        }
//    }
//
//    @IBAction func btnPlus(_ sender: UIButton) {
//        if Int(lblCount.text!)! <= 50 {
//            let count = Int(lblCount.text!)! + 1
//            lblCount.text = String(count)
//            delegate?.sharePressed(quantity: count)
//        }
//    }
//
    
    //changeState method has a cellReuse parameter to allow you to prepare your cell for reusing.
    //All state info is allocated by ExpyTableView.
//    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
//        
//        switch state {
//        case .willExpand:
//            print("WILL EXPAND")
//            
//        case .willCollapse:
//            print("WILL COLLAPSE")
//            
//        case .didExpand:
//            print("DID EXPAND")
//            
//        case .didCollapse:
//            print("DID COLLAPSE")
//        }
//    }
}
