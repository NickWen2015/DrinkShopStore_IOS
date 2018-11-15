//
//  ProductTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/5.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController {
    var categorys: [Category] = []
    var products = [Product]()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        title = "商品管理"
        
//        if let products = Product.load() {
//            self.products = products
//            tableView.reloadData()
//        }
        
       

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        let tea = Category(categoryName: "tea", products: [Product(productImage: "drink001", productName: "綠茶", unitPriceOfMediumSize: "30", unitPriceOfLargeSize: "35"),Product(productImage: "drink002", productName: "紅茶", unitPriceOfMediumSize: "30", unitPriceOfLargeSize: "35")])
        
//        let tea = Category(categoryName: "tea",products: products)
        
        let milk = Category(categoryName: "milk", products: [Product(productImage: "drink003", productName: "奶茶", unitPriceOfMediumSize: "40", unitPriceOfLargeSize: "45")])
        
//        let milk = Category(categoryName: "milk", products: products)
        
        
        let fruit = Category(categoryName: "fruit", products: [Product(productImage: "drink004", productName: "蘋果汁", unitPriceOfMediumSize: "50", unitPriceOfLargeSize: "55")])
        
//        let fruit = Category(categoryName: "fruit", products: products)
        
        categorys += [tea, milk, fruit]
      
        
        //啟用naviation導覽列上的編輯tableView紐
        navigationItem.leftBarButtonItem = editButtonItem
        
        //開啟Cell自動列高
//        tableView.rowHeight =
//            UITableView.automaticDimension
//        tableView.estimatedRowHeight = 44.0
        
        tableView.rowHeight =
            UITableView.automaticDimension
        tableView.estimatedRowHeight = tableView.rowHeight
       
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel()
//        label.text = "p"
//        label.backgroundColor = UIColor.lightGray
//        return label
//        
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 註冊通知
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
        
        
    }
    // 解除註冊
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func save() {
        Product.save(products)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categorys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return categorys[section].product.count
        return categorys[section].products.count
        // return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as!ProductTableViewCell

        // Configure the cell...
        
        
        // 取得
//        let category = categorys[indexPath.section]
//        let product = category.product[indexPath.row]

        
        let category = categorys[indexPath.section]
        let products = category.products
        let product = products[indexPath.row]
        
        cell.product = product


        return cell
    
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let category = categorys[section].categoryName
//        return category
        
        let category = categorys[section]
        return category.categoryName
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Unwind Segue
    @IBAction func unwindToProductList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveProduct" else {
            return}
        // 新增product
        // 取得剛才使用者建立的product
        let source = segue.source as! ProductEditeTableViewController
//        if let category = source.category {
//            // 判斷使用者有沒有點選其中某列
//            if let selectedIndexPath = tableView.indexPathForSelectedRow {
//                // 修改category
//                categorys[selectedIndexPath.section] = category
//                
//                // 重新整理該indexpath畫面
//                tableView.reloadSections([0], with: .automatic)
//                
//            } else {
//                // 將最新的category插入到TableView
//                // 準備一個新的indexpath
//                // let indexpath = IndexPath(row: products.count, section: 0)
//                // 將category插入陣列
//                categorys.append(category)
//                tableView.insertSections([0], with: .automatic)
//                
//            }
//        }
        if let product = source.product {
            // 判斷使用者有沒有點選其中某列
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // 修改product
                var category = categorys[selectedIndexPath.section]
                category.products[selectedIndexPath.row] = product
                // 重新整理該indexpath畫面
                tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            } else {
                // 將最新的product插入到TableView
                // 準備一個新的indexpath
                let indexpath = IndexPath(row: products.count, section: 0)
                // 將product插入陣列
                products.append(product)
                tableView.insertRows(at: [indexpath], with: .automatic)
            }
        }
        
        
    }
    
    //In addition to .none, there are two other styles: .delete and .insert
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete // .none
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            var category = categorys[indexPath.section]
            category.products.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 看看使用者選到了哪一個indexpath
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // 取得該indexpat的product
            //let product = products[selectedIndexPath.row]
            
            let category = categorys[selectedIndexPath.section]
            let product = category.products[selectedIndexPath.row]
            
            // 取得下一頁
            let destination = segue.destination as!
            UINavigationController
            let productTableVC = destination.topViewController as!
            ProductEditeTableViewController
            // 將product放在下一頁
            productTableVC.category = category
            productTableVC.product = product
            
            
        }
    }
    
    
    

}
