//
//  OrderDetailTableViewCell.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/7.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var iceNameLabel: UILabel!
    @IBOutlet weak var sugarNameLabel: UILabel!
    @IBOutlet weak var sizeNameLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
   
    var orderDetailList: OrderDetail? {
        didSet {
         
            productNameLabel.text = orderDetailList!.getProductName()
            iceNameLabel.text = orderDetailList!.getIceName()
            sugarNameLabel.text = orderDetailList!.getSugarName()
            sizeNameLabel.text = orderDetailList!.getSizeName()
            productPriceLabel.text = String(orderDetailList!.getProductPrice())
            productQuantityLabel.text = String(orderDetailList!.getProductQuantity())
      
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


