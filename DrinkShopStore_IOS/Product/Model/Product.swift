//
//  Product.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/11/8.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

// Product
// Category will contain [Product]
import Foundation

struct Product: Codable {
    //var image: UIImage
    var productImage: String
    var productName: String
    var unitPriceOfMediumSize: String
    var unitPriceOfLargeSize: String

    private static var fileURL: URL {
        var documentDir =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentDir.appendPathComponent("products")
        documentDir.appendPathExtension("plist")
        print(documentDir.absoluteString)
        return documentDir
    }

    // 存檔
    static func save(_ products:[Product]) {
        let encoder = PropertyListEncoder()

        if let encodedProducts = try?
            encoder.encode(products) {
            try! encodedProducts.write(to: fileURL, options: .noFileProtection)

        }

    }

    // 讀檔
    static func load() -> [Product]? {
        let decoder = PropertyListDecoder()
        if let decodedProducts = try?
            Data(contentsOf: fileURL) {
            let result = try?
                decoder.decode(Array<Product>.self, from: decodedProducts)
            return result
        }
        return nil
    }

}
