//
//  drink.swift
//  drinkOrder
//
//  Created by 方芸萱 on 2020/9/23.
//

import Foundation

struct DrinkOrderData:Encodable {
    var data:DrinkOrder
}
struct DrinkOrder:Codable {
    let name:String
    let drink:String
    let sugar:String
    let ice:String
    let volume:String
    let bubble:String
    let price:String
    let orderid:String
}
struct DrinkMenu:Decodable {
    var name:String
    var priceM:Int
    var priceL:Int
    var onlyHot:Bool
}

