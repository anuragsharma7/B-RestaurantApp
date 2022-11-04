//
//  CartViewCell.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/12/21.
//

import UIKit

class CartViewCell: UITableViewCell {

    @IBOutlet weak var labelQty: UILabel!
    @IBOutlet weak var labelMealName: UILabel!
    @IBOutlet weak var labelSubTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
