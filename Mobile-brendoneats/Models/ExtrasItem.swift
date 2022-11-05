//
//  ExtrasItem.swift
//  Mobile-brendoneats
//
//  Created by Anurag Sharma on 05/11/22.
//

import Foundation

class ExtrasItem {
    var item: Item?
    var qty: Int?
    
    init(item: Item, qty: Int) {
        self.item = item
        self.qty = qty
    }
}

class ExtrasChoosen {
    static let ref = ExtrasChoosen()
    
    var items = [ExtrasItem]()
    
    //calculate the total price using Item's price
    
//    func getTotalValue() -> Float {
//        var total: Float = 0
//        for items in self.items {
//            total = total + Float(items.item.qty) * items.item.price!
//        }
//        return total
//    }
    
    func reset() {
        self.items = []
    }
}


