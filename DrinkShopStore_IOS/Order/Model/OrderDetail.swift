//
//  OrderDetail.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/6.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation

struct OrderDetail: Codable {
    
    var orderDetailId: Int?
    var orderId: Int?
    var productId: Int?
    var sizeId: Int?
    var sugarId: Int?
    var iceId: Int?
    var productQuantity: Int?
    var productName: String?
    var iceName: String?
    var sugarName: String?
    var sizeName: String?
    var productPrice: Int?
    
}

extension OrderDetail {
    enum CodingKeys: String, CodingKey {
        
        case orderDetailId = "order_detail_id"
        case orderId = "order_id"
        case productId = "product_id"
        case sizeId = "size_id"
        case sugarId = "sugar_id"
        case iceId = "ice_id"
        case productQuantity = "product_quantity"
        case productName = "product_name"
        case iceName = "ice_name"
        case sugarName = "sugar_name"
        case sizeName = "size_name"
        case productPrice = "product_price"
  
    }
}


extension OrderDetail {
    func getOrderDetailId() -> Int {
        guard let orderDetailId = orderDetailId else {
            return 0
        }
        return orderDetailId
    }
    
    func getOrderId() -> Int {
        guard let orderId = orderId else {
            return 0
        }
        return orderId
    }
    
    func getProductId() -> Int {
        guard let productId = productId else {
            return 0
        }
        return productId
    }
    
    func getSizeId() -> Int {
        guard let sizeId = sizeId else {
            return 0
        }
        return sizeId
    }
    
    func getSugarId() -> Int {
        guard let sugarId = sugarId else {
            return 0
        }
        return sugarId
    }
    
    func getIceId() -> Int {
        guard let iceId = iceId else {
            return 0
        }
        return iceId
    }
    
    func getProductQuantity() -> Int {
        guard let productQuantity = productQuantity else {
            return 0
        }
        return productQuantity
    }
    
    func getProductName() -> String {
        guard let productName = productName else {
            return ""
        }
        return productName
    }
    
    func getIceName() -> String {
        guard let iceName = iceName else {
            return ""
        }
        return iceName
    }
    
    func getSugarName() -> String {
        guard let sugarName = sugarName else {
            return ""
        }
        return sugarName
    }
    
    func getSizeName() -> String {
        guard let sizeName = sizeName else {
            return ""
        }
        return sizeName
    }
    
    func getProductPrice() -> Int {
        guard let productPrice = productPrice else {
            return 0
        }
        return productPrice
    }
    
}


