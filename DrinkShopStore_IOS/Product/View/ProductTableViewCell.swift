//
//  ProductTableViewCell.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/8.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
  
    @IBOutlet weak var productNameLabel: UILabel!
   
    @IBOutlet weak var unitPriceOfMediumSizeLabel: UILabel!
    
    @IBOutlet weak var unitPriceOfLargeSizeLabel: UILabel!
    
    
    var imageList: Data? {
        didSet {
            productImageView.image = UIImage(data: imageList!)
        }
    }
    
    var productList: Product? {
        didSet {
            
            
            productNameLabel.text = String(productList!.getName())
            unitPriceOfMediumSizeLabel.text = String(productList!.getPriceM())
            unitPriceOfLargeSizeLabel.text = String(productList!.getPriceL())

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


