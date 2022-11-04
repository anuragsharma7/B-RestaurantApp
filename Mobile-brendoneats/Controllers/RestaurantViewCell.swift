//
//  RestaurantViewCell.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/11/21.
//

import UIKit

class RestaurantViewCell: UITableViewCell {

    
    @IBOutlet weak var imageResLogo: UIImageView!
    @IBOutlet weak var labelResName: UILabel!
    @IBOutlet weak var labelResAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
