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
    var name:String
    let drink:String
    let sugar:String
    let ice:String
    let volume:String
    let bubble:String
    let price:Int
    let orderid:Int
}
struct DrinkMenu:Decodable {
    var name:String
    var priceM:Int
    var priceL:Int
    var onlyHot:Bool
}
struct DrinkSettlement {
    let drinkDetail:String
    var count:Int
    let price:Int
}
