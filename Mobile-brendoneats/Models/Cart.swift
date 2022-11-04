//
//  Cart.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/12/21.
//

import Foundation

class CartItem {
    var meal: Meal
    var qty: Int
    
    init(meal: Meal, qty: Int) {
        self.meal = meal
        self.qty = qty
    }
}

class Cart {
    static let currentCart = Cart()
    
    var restaurant: Restaurant?
    var items = [CartItem]()
    var address: String?
    
    func getTotalValue() -> Float {
        var total: Float = 0
        for item in self.items {
            total = total + Float(item.qty) * item.meal.price!
        }
        return total
    }
    
    func getTotalQuantity() -> Int {
        var total: Int = 0
        for item in self.items {
            total = total + item.qty
        }
        return total
    }
    
    func reset() {
        self.restaurant = nil
        self.address = nil
        self.items = []
    }
}
