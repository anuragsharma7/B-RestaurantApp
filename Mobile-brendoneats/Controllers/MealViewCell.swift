//
//  MealViewCell.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/12/21.
//

import UIKit

class MealViewCell: UITableViewCell {
    
    @IBOutlet weak var labelMealName: UILabel!
    @IBOutlet weak var labelMealDescription: UILabel!
    @IBOutlet weak var labelMealPrice: UILabel!
    @IBOutlet weak var imageMealImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
