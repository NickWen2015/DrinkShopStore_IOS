//
//  OrderDetailTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/7.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class OrderDetailTableViewController: UITableViewController {
    
    var order: Order!
    var orderId: String!
    
    @IBOutlet weak var totalQuantityLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    //@IBOutlet weak var orderDetailIdTextLabel: UILabel!
    static let shared = OrderDetailTableViewController()
    
    var orderDetails: [OrderDetail] = []
    var orderDetail: OrderDetail?
    var price: Int?
    var qty: Int?
    var prices: [Int] = []
    var qtys: [Int] = []
    
    var coupon = Coupon()
    
    
    static let TAG = "OrderDetailTableViewController"
    let communicator = Communicator.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear order ", order)
        print("viewWillAppear orderId ", orderId)
        
        if self.orderDetails.count > 0 {
            return
        }
        
        communicator.getOrderDetailByOrderId(orderId: Int(orderId)!) { (result, error) in
            if let error = error {
                PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }
            
            guard let result = result else {
                PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "result is nil")
                return
            }
            
            PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "result OK.")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("\(#line) Fail to generate jsonData.")
                return
            }
            
            let decoder = JSONDecoder()
            guard let orderDetailObject = try? decoder.decode([OrderDetail].self, from: jsonData) else {
                print("\(#line) Fail to decode [OrderDetail] jsonData.")
                return
            }
            
            self.orderDetails = orderDetailObject
            PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "SET orderDetails OK.")
            
            //
            guard let couponId = self.order!.couponId else {
                return
            }
            
            if couponId == 0 {
                for orderDetail in self.orderDetails {
                    self.price = orderDetail.productPrice
                    self.prices.append(self.price!)
                    self.qty = orderDetail.productQuantity
                    self.qtys.append(self.qty!)
                    let totalCap: Int = self.qtys.reduce(0) { $0 + $1 }
                    let totalAmount: Int = self.prices.reduce(0) { $0 + $1 }
                    self.totalQuantityLabel.text = String(totalCap)
                    self.totalAmountLabel.text = String(totalAmount)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            }
            
            self.communicator.findCouponById(coupon_id: String(couponId)) { (result, error) in
                if let error = error {
                    PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "Error: \(error)")
                    return
                }
                
                guard let result = result else {
                    PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "result is nil")
                    return
                }
                
                PrintHelper.println(tag: OrderDetailTableViewController.TAG, line: #line, "result OK.")
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                    print("\(#line) Fail to generate jsonData.")
                    return
                }
                
                let decoder = JSONDecoder()
                guard let couponObject = try? decoder.decode(Coupon.self, from: jsonData) else {
                    print("\(#line) Fail to decode Coupon jsonData.")
                    return
                }
                
                self.coupon = couponObject
                
                for orderDetail in self.orderDetails {
                    self.price = orderDetail.productPrice
                    self.prices.append(self.price!)
                    self.qty = orderDetail.productQuantity
                    self.qtys.append(self.qty!)
                    
                    let totalCap: Int = self.qtys.reduce(0) { $0 + $1 }
                    
                    let totalAmount: Int = self.prices.reduce(0) { $0 + $1 }
                    
                    self.totalQuantityLabel.text = String(totalCap)
                    
                    let couponDiscount = self.coupon.coupon_discount * 0.1
                    let total = Double(totalAmount) * couponDiscount
                    self.totalAmountLabel.text = String(Int(total))
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            //
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 準備資料
        print("viewDidLoad order ", order)
        print("viewDidLoad orderId ", orderId)
        
        
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
        
        return orderDetails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailCell", for: indexPath) as!OrderDetailTableViewCell
        
        // Configure the cell...
        
        // 取得
        let orderDetailList = orderDetails[indexPath.row]
        cell.orderDetailList = orderDetailList
        
        return cell
        
    }
    
    // Unwind Segue
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        
    }
    
}

extension Communicator {
    
    // 取得訂單明細
    func getOrderDetailByOrderId(orderId: Int, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.ORDERSSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "getOrderDetailByOrderId", ORDERID_KEY: orderId]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    //coupon_id查詢coupon資料成功回傳coupon物件
    func findCouponById(coupon_id: String, completion: @escaping DoneHandler) {
        let parameters: [String: Any] = [ACTION_KEY: "findCouponById", COUPON_ID_KEY: coupon_id]
        doPost(urlString: COUPONSERVLET_URL, parameters: parameters, completion: completion)
    }
    
}
