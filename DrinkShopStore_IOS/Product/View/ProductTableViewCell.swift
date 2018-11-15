//
//  ProductTableViewCell.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/8.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
   
    @IBOutlet weak var unitPriceOfMediumSizeLabel: UILabel!
    
    @IBOutlet weak var unitPriceOfLargeSizeLabel: UILabel!
    
    var product: Product? {
        didSet {
            productImageLabel.text = product?.productImage
            productNameLabel.text = product?.productName
            unitPriceOfMediumSizeLabel.text = product?.unitPriceOfMediumSize
            unitPriceOfLargeSizeLabel.text = product?.unitPriceOfLargeSize
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


