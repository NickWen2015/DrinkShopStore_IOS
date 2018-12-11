//
//  OrderTableViewCell.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/6.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var invoiceLabel: UILabel!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var orderAcceptTimeLabel: UILabel!
    
    
    var orderList: Order? {
        didSet {
            
            orderIdLabel.text = String(orderList!.getOrderId())
            invoiceLabel.text = orderList!.getInvoice()
            memberNameLabel.text = orderList!.getMemberName()
            orderAcceptTimeLabel.text = String(orderList!.getOrderAcceptTime().prefix(19))
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


