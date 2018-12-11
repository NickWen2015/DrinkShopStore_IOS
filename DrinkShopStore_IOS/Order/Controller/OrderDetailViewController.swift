//
//  OrderDetailViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/7.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController, UINavigationControllerDelegate {
    var orderDetailTableViewController: OrderDetailTableViewController!
    var orderId: String!
    
    @IBOutlet weak var orderDetailIdLabel: UILabel!
    
    static let shared = OrderDetailViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderDetailIdLabel.text = orderId
        
        let controller = self.children.first as? OrderDetailTableViewController
        controller?.orderId = orderId
        
        // Do any additional setup after loading the view.
    }
    
    
}


