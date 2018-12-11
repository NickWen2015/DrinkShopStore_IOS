//
//  LogSQLite.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/11/15.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation
import SQLite

class LogSQLite {
    
    // Product 表
    static let tableName_allProduct = "DrinkShopStoreLogAllProduct"
    static let id = "id"
    static let categoryId = "categoryId"
    static let category = "category"
    static let name = "name"
    static let priceM = "priceM"
    static let priceL = "priceL"
    
    var db: Connection!
    var logTable_allProduct = Table(tableName_allProduct)
    var idColumn = Expression<Int>(id)
    var categoryIdColumn = Expression<Int>(categoryId)
    var categoryColumn = Expression<String>(category)
    var nameColumn = Expression<String>(name)
    var priceMColumn = Expression<Int>(priceM)
    var priceLColumn = Expression<Int>(priceL)
    
    var productCount = [String]()
    
    init() {
        // Prepare DB filename/path.
        let filemanager = FileManager.default
        //        guard let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        //            return
        //        }
        let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURLPath = documentsURL.appendingPathComponent("log.sqlite").path
        var isNewDB = false
        if !filemanager.fileExists(atPath: fullURLPath) {
            isNewDB = true
        }
        
        // Prepare connection of DB.
        do {
            db = try Connection(fullURLPath)
        } catch {
            assertionFailure("Fail to create connection.")
            return
        }
        
        // Create Table at the first time.
        if isNewDB {
            do {
                
                let command_allProduct = logTable_allProduct.create { (builder) in
                    builder.column(idColumn)
                    builder.column(categoryIdColumn)
                    builder.column(categoryColumn)
                    builder.column(nameColumn)
                    builder.column(priceMColumn)
                    builder.column(priceLColumn)
                }
                //                try db.run(command_version)
                try db.run(command_allProduct)
                PrintHelper.println(tag: "LogSQLite", line: #line, "DB CREATE OK!")
                
                // 加入初始值
                //                append(version: 0, to: "append")
                
            } catch {
                assertionFailure("Fail to create table: \(error).")
            }
        } else {
            // Keep mid into messageIDs.
            do {
                // SELECT * FROM "DrinkShopStoreLogAllProduct"
                for product in try db.prepare(logTable_allProduct) {
                    productCount.append(product[nameColumn])
                }
            } catch {
                assertionFailure("Fail to execute prepare command: \(error)")
            }
            print("There are total \(productCount.count) products in DB")
        }
    }
    
    // 資料總比數
    var count: Int {
        return productCount.count
    }
    
    // 新增 Product
    func append(_ product: Product) {
        
        let id = product.getId()
        let categoryId = product.getCategoryId()
        let category = product.getCategory()
        let name = product.getName()
        let priceM = product.getPriceM()
        let priceL = product.getPriceL()
        
        let command_allProduct = logTable_allProduct.insert(
            idColumn <- id,
            categoryIdColumn <- categoryId,
            categoryColumn <- category,
            nameColumn <- name,
            priceMColumn <- priceM,
            priceLColumn <- priceL
        )
        do {
            try db.run(command_allProduct)
            //            let newProduct = try db.run(command_allProduct)
            //            productCount.append(String(newProduct))
        } catch {
            assertionFailure("\(#line) Fail to insert a new product: \(error)")
        }
    }
    
    // 使用 類別 搜尋 商品
    func searchProductInCategory(to category: String) -> [Product] {
        var products: [Product] = []
        
        let cond = logTable_allProduct.filter(categoryColumn == category)
        
        do {
            // SELECT * FROM "DrinkShopStoreLog WHERE category = category"
            for product in try db.prepare(cond) {
                let id = product[idColumn]
                let categoryId = product[categoryIdColumn]
                let category = product[categoryColumn]
                let name = product[nameColumn]
                let priceM = product[priceMColumn]
                let priceL = product[priceLColumn]
                
                //                let productObj = Product.init(id: id, categoryId: categoryId, category: category, name: name, priceM: priceM, priceL: priceL)
                var productObj = Product()
                productObj.id = id
                productObj.categoryId = categoryId
                productObj.category = category
                productObj.name = name
                productObj.priceM = priceM
                productObj.priceL = priceL
                
                
                products.append(productObj)
            }
        } catch {
            assertionFailure("Fail to execute prepare command: \(error).")
        }
        
        return products
    }
    
    
    // 使用 id 搜尋 商品
    func searchProductInId(to id: Int) -> [String] {
        var products = [String]()
        
        let cond = logTable_allProduct.filter(idColumn == id)
        
        do {
            // SELECT * FROM "DrinkShopStoreLog WHERE id = id"
            for product in try db.prepare(cond) {
                let id = product[idColumn]
                let categoryId = product[categoryIdColumn]
                let category = product[categoryColumn]
                let name = product[nameColumn]
                let priceM = product[priceMColumn]
                let priceL = product[priceLColumn]
                
                products.append(String(id))
                products.append(String(categoryId))
                products.append(category)
                products.append(name)
                products.append(String(priceM))
                products.append(String(priceL))
            }
        } catch {
            assertionFailure("Fail to execute prepare command: \(error).")
        }
        
        return products
    }
    
}

// MARK: - Common Func
extension LogSQLite {
    // 刪除
    func delete(table: Table) {
        do {
            try db.run(table.delete())
        } catch {
            assertionFailure("\(#line) Fail to delete: \(error).")
        }
        PrintHelper.println(tag: "LogSQLite", line: #line, "PASSED: \(#function) \(table) OK")
    }
}


