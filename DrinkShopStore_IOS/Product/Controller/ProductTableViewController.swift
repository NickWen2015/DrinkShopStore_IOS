//
//  ProductTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/5.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit
import Photos

class ProductTableViewController: UITableViewController {
    
    var categorys: [Category] = []
    var products: [Product] = []
    
    static let TAG = "ProductTableViewController"
    let communicator = Communicator.shared
    let logSQLite = LogSQLite()
    
    @IBAction func goBackFromAddDrink(segue: UIStoryboardSegue) {
        
        self.viewDidLoad()
        
        //        communicator.getAllCategory { (result, error) in
        //            if let error = error {
        //                PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "Error: \(error)")
        //                return
        //            }
        //
        //            guard let result = result else {
        //                PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "result is nil")
        //                return
        //            }
        //
        //            PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "result OK.")
        //
        //            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
        //                print("\(#line) Fail to generate jsonData.")
        //                return
        //            }
        //
        //            let decoder = JSONDecoder()
        //            guard let categoryObject = try? decoder.decode([Category].self, from: jsonData) else {
        //                print("\(#line) Fail to decode [Category] jsonData.")
        //                return
        //            }
        //
        //            self.categorys = categoryObject
        //            PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "SET categorys OK.")
        //
        //            //self.tableView.reloadData()
        //
        //        }
        //
        //
        //        communicator.getAllProduct { (result, error) in
        //            if let error = error {
        //                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: \(error)")
        //                return
        //            }
        //
        //            guard let result = result else {
        //                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: result is nil")
        //                return
        //            }
        //
        //            PrintHelper.println(tag: "ProductTableViewController", line: #line, "result OK.")
        //
        //            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
        //                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: Fail to generate jsonData.")
        //                return
        //            }
        //
        //            let decoder = JSONDecoder()
        //            guard let productObject = try? decoder.decode([Product].self, from: jsonData) else {
        //                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: Fail to decode jsonData.")
        //                return
        //            }
        //
        //            self.products = productObject
        //
        //            // CLAER TABLE DrinkShopStoreLogAllProduct
        //            self.logSQLite.delete(table: self.logSQLite.logTable_allProduct)
        //
        //            for product in self.products {
        //                self.logSQLite.append(product)
        //            }
        //
        //
        //            PrintHelper.println(tag: "ProductTableViewController", line: #line, "PASSED: \(#function) OK")
        //
        //            //self.tableView.reloadData()
        //
        //        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 準備資料
        communicator.getAllCategory { (result, error) in
            if let error = error {
                PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }
            
            guard let result = result else {
                PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "result is nil")
                return
            }
            
            PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "result OK.")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("\(#line) Fail to generate jsonData.")
                return
            }
            
            let decoder = JSONDecoder()
            guard let categoryObject = try? decoder.decode([Category].self, from: jsonData) else {
                print("\(#line) Fail to decode [Category] jsonData.")
                return
            }
            
            self.categorys = categoryObject
            PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "SET categorys OK.")
            
            self.tableView.reloadData()
            
        }
        
        communicator.getAllProduct { (result, error) in
            if let error = error {
                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: \(error)")
                return
            }
            
            guard let result = result else {
                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: result is nil")
                return
            }
            
            PrintHelper.println(tag: "ProductTableViewController", line: #line, "result OK.")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: Fail to generate jsonData.")
                return
            }
            
            let decoder = JSONDecoder()
            guard let productObject = try? decoder.decode([Product].self, from: jsonData) else {
                PrintHelper.println(tag: "ProductTableViewController", line: #line, "ERROR: Fail to decode jsonData.")
                return
            }
            
            self.products = productObject
            
            // CLAER TABLE DrinkShopStoreLogAllProduct
            self.logSQLite.delete(table: self.logSQLite.logTable_allProduct)
            
            for product in self.products {
                self.logSQLite.append(product)
            }
            
            
            PrintHelper.println(tag: "ProductTableViewController", line: #line, "PASSED: \(#function) OK")
            
            self.tableView.reloadData()
            
        }
        
        //啟用naviation導覽列上的編輯tableView紐
        navigationItem.leftBarButtonItem = editButtonItem
        
        //開啟Cell自動列高
        tableView.rowHeight =
            UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        //        tableView.estimatedRowHeight = tableView.rowHeight
        
    }
    
    // 解除註冊
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categorys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let category = categorys[section].name
        products = logSQLite.searchProductInCategory(to: category ?? "")
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as!ProductTableViewCell
        // Configure the cell...
        
        // 取得
        let category = categorys[indexPath.section].name
        products = logSQLite.searchProductInCategory(to: category ?? "")
        let productList = products[indexPath.row]
        cell.productList = productList
        
        
        self.communicator.getPhotoById(photoURL: Communicator.shared.PRODUCTSERVLET_URL, id: productList.id!) { (result, error) in
            if let error = error {
                PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }
            
            guard let data = result else {
                PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "result is nil")
                return
            }
            
            if let currentIndexPath = tableView.indexPath(for: cell),currentIndexPath == indexPath {
                
                DispatchQueue.main.async {
                    cell.productImageView.image = UIImage(data: data)
                    
                    cell.productNameLabel.text = String(productList.getName())
                    cell.unitPriceOfMediumSizeLabel.text = String(productList.getPriceM())
                    cell.unitPriceOfLargeSizeLabel.text = String(productList.getPriceL())
                    
                }
                
            }
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let category = categorys[section]
        return category.name
    }
    
    // Unwind Segue
    @IBAction func unwindToProductList(segue: UIStoryboardSegue) {
        
    }
    
    //In addition to .none, there are two other styles: .delete and .insert
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete // .none
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let category = categorys[indexPath.section].name
            products = logSQLite.searchProductInCategory(to: category ?? "")
            let productList = products[indexPath.row]
            
            //寫入資料庫
            self.communicator.productDelete(product_id: productList.id!) { (result, error) in
                if let error = error {
                    print("Delete products fail: \(error)")
                    return
                }
                
                guard let updateStatus = result as? Int else {
                    assertionFailure("modify fail.")
                    return
                }
                
                if updateStatus == 1 {
                    //跳出成功視窗
                    let alertController = UIAlertController(title: "完成", message:
                        "刪除成功", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "確定", style: .default,handler: nil))
                    self.present(alertController, animated: false, completion: nil)
                    self.viewDidLoad()
                    self.tableView.reloadData()
                    
                } else {
                    let alertController = UIAlertController(title: "失敗", message:
                        "刪除失敗", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "確定", style: .default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //         看看使用者選到了哪一個indexpath
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            // 取得該indexpat的product
            //let categoryEdit = categorys[selectedIndexPath.section]
            let category = categorys[selectedIndexPath.section].name
            products = logSQLite.searchProductInCategory(to: category ?? "")
            let productEdit = products[selectedIndexPath.row]
            
            communicator.getPhotoById(photoURL: Communicator.shared.PRODUCTSERVLET_URL, id: productEdit.id!) { (result, error) in
                if let error = error {
                    PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "Error: \(error)")
                    return
                }
                
                guard let data = result else {
                    PrintHelper.println(tag: ProductTableViewController.TAG, line: #line, "result is nil")
                    return
                }
                
                // 取得下一頁
                let destination = segue.destination as!
                UINavigationController
                let productTableVC = destination.topViewController as!
                ProductEditTableViewController
                
                DispatchQueue.main.async {
                    
                    // 將product放在下一頁
                    productTableVC.product = productEdit
                    productTableVC.categoryNameField.text = productEdit.category
                    productTableVC.productNameField.text = productEdit.name
                    productTableVC.unitPriceOfMediumSizeField.text = String(productEdit.priceM!)
                    productTableVC.unitPriceOfLargeSizeField.text = String(productEdit.priceL!)
                    productTableVC.productImageView.image = UIImage(data: data)
                }
            }
            
        }
    }
    
}

extension Communicator {
    
    // 取得全部的類別
    func getAllCategory(completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "getAllCategory"]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    // 取得全部的商品
    func getAllProduct(completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "getAllProduct"]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    // 刪除商品
    func productDelete(product_id: Int, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "productDelete", PRODUCT_ID_KEY: product_id]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
}
