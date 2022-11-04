//
//  TitleCellForExpandable.swift
//  Mobile-brendoneats
//
//  Created by Sunil on 19/10/22.
//

import UIKit
import ExpyTableView

class TitleCellForExpandable: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //changeState method has a cellReuse parameter to allow you to prepare your cell for reusing.
    //All state info is allocated by ExpyTableView.
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        
        switch state {
        case .willExpand:
            print("WILL EXPAND")
            
        case .willCollapse:
            print("WILL COLLAPSE")
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            print("DID COLLAPSE")
        }
    }
}
