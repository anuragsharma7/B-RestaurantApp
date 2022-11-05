//
//  Meal.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/12/21.
//

import Foundation
import SwiftyJSON

class Meal {
    
    var id: Int?
    var name: String?
    var short_description: String?
    var image: String?
    var price: Float?
    var extras: [Extras]?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.short_description = json["short_description"].string
        self.image = json["image"].string
        self.price = json["price"].float
        //self.extras = json["extras"].arrayValue
        
        self.extras = [Extras]()
        for i in json["extras"].arrayValue {
            let j = Extras(json: i)
            self.extras?.append(j)
        }
    }
}

class Extras {
    var title: String?
    var items: [Item]?
    
    init(json: JSON) {
        self.title = json["title"].string
        
        self.items = [Item]()
        for i in json["items"].arrayValue {
            let j = Item(json: i)
            self.items?.append(j)
        }
    }
}

class Item {
    
    var price: Float?
    var id: Int?
    var name: String?
    
    init(json: JSON) {
        self.id = json["id"].int
        self.price = json["price"].float
        self.name = json["name"].string
    }
}
 
