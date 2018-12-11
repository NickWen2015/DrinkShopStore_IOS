//
//  Product.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/11/8.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation

struct Product: Codable {
    var id: Int?
    var categoryId: Int?
    var category: String?
    var name: String?
    var priceM: Int?
    var priceL: Int?
}

extension Product {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case categoryId = "categoryId"
        case category = "Category"
        case name = "Name"
        case priceM = "MPrice"
        case priceL = "LPrice"
    }
}

extension Product {
    func getId() -> Int {
        guard let id = id else {
            return 0
        }
        return id
    }
    
    func getCategoryId() -> Int {
        guard let categoryId = categoryId else {
            return 0
        }
        return categoryId
    }
    
    func getCategory() -> String {
        guard let category = category else {
            return ""
        }
        return category
    }
    
    func getName() -> String {
        guard let name = name else {
            return ""
        }
        return name
    }
    
    func getPriceM() -> Int {
        guard let priceM = priceM else {
            return 0
        }
        return priceM
    }
    
    func getPriceL() -> Int {
        guard let priceL = priceL else {
            return 0
        }
        return priceL
    }
}


