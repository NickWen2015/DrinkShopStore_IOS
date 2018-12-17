//
//  OrderTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/6.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit
import Photos

class OrderTableViewController: UITableViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    
    var orders: [Order] = []
    
    static let TAG = "OrderTableViewController"
    let communicator = Communicator.shared
    
    // Unwind Segue
    @IBAction func unwindToOrderListByChangeOrderStatus(segue: UIStoryboardSegue) {
        communicator.getAllOrder { (result, error) in
            if let error = error {
                PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }

            guard let result = result else {
                PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "result is nil")
                return
            }

            PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "result OK.")

            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("\(#line) Fail to generate jsonData.")
                return
            }

            let decoder = JSONDecoder()
            guard let orderObject = try? decoder.decode([Order].self, from: jsonData) else {
                print("\(#line) Fail to decode [Order] jsonData.")
                return
            }

            self.orders = orderObject
            PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "SET orders OK.")

            self.tableView.reloadData()

        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // 準備資料
        communicator.getAllOrder { (result, error) in
            if let error = error {
                PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }
            
            guard let result = result else {
                PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "result is nil")
                return
            }
            
            PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "result OK.")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("\(#line) Fail to generate jsonData.")
                return
            }
            
            let decoder = JSONDecoder()
            guard let orderObject = try? decoder.decode([Order].self, from: jsonData) else {
                print("\(#line) Fail to decode [Order] jsonData.")
                return
            }
            
            self.orders = orderObject
            PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "SET orders OK.")
            
            self.tableView.reloadData()
            
        }
        
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as!OrderTableViewCell
        
        // Configure the cell...
        
        // 取得
        let orderList = orders[indexPath.row]
        cell.orderList = orderList
        
        return cell
        
    }
    
    
    // Unwind Segue
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //         看看使用者選到了哪一個indexpath
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            // 取得該indexpat的orderDetail
            let orderDetailDisplay = orders[selectedIndexPath.row]
            
            // 取得下一頁
            let orderDetailVC = segue.destination as!
            OrderDetailViewController
            
//            let destination = segue.destination as!
//            UINavigationController
//            let orderDetailVC = destination.topViewController as!
//            OrderDetailViewController
            
            
            guard let orderId = orderDetailDisplay.orderId else {
                print("ERROR: orderId is nil")
                return
            }

            // 將orderDetailId放在下一頁
            orderDetailVC.orderId = "\(orderId)"
            orderDetailVC.order = orderDetailDisplay
            
        }
    }

}

extension Communicator {
    
    // 取得全部的未結訂單
    func getAllOrder(completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.ORDERSSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "getAllOrder"]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
   
}

