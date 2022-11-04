//
//  Profile.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 8/13/22.
//

import Foundation


// MARK: - Welcome
struct CustomerResponse: Codable {
    let customer: Customer?
}

// MARK: - Customer
struct Customer: Codable {
    let id: Int?
    let name, avatar, phone, address: String?
}

// open postman please
/*
 {
     "customer": {
         "id": 3,
         "name": "Brendon loh",
         "avatar": "brendon",
         "phone": "80000000",
         "address": "81 Robinson Road"
     }
 }
 */

/*
struct CustomerResponse: Codable {
    var id: Int?
    var name: String?
    var avatar: String?
    var phone: String?
    var address: String?
 } /**/*/
