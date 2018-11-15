//
//  ProductEditeTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/8.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit

class ProductEditeTableViewController: UITableViewController {
 
    @IBOutlet weak var categoryNameField: UITextField!
    
    @IBOutlet weak var productImageLabel: UILabel!
    
    @IBOutlet weak var productNameField: UITextField!
  
    @IBOutlet weak var unitPriceOfMediumSizeField: UITextField!
    
    @IBOutlet weak var unitPriceOfLargeSizeField: UITextField!
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    var category: Category?
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let category = category {
            categoryNameField.text = category.categoryName
        }
        if let product = product { // self.product { 可不寫self,用sadow in方式
            productImageLabel.text = product.productImage
            productNameField.text = String(product.productName)
            unitPriceOfMediumSizeField.text = product.unitPriceOfMediumSize
            unitPriceOfLargeSizeField.text = product.unitPriceOfLargeSize
        }
        updateSaveButtonState()

    }
    
    @IBAction func textFieldBeginEditing(_ sender: Any) {
        updateSaveButtonState()
    }
    
    
    func updateSaveButtonState() {
        let categoryName = categoryNameField.text ?? ""
        let productImage = productImageLabel.text ?? ""
        let productName = productNameField.text ?? ""
        let unitPriceOfMediumSize = unitPriceOfMediumSizeField.text ?? ""
        let unitPriceOfLargeSize = unitPriceOfLargeSizeField.text ?? ""
        
        
        let isCategoryNameExist = !categoryName.isEmpty
        let isProductImageExist = !productImage.isEmpty
        let isProductNameExist = !productName.isEmpty
        let isUnitPriceOfMediumSizeExist = !unitPriceOfMediumSize.isEmpty
        let isUnitPriceOfLargeSizeExist = !unitPriceOfLargeSize.isEmpty
        let shouldEnable = isCategoryNameExist && isProductImageExist && isProductNameExist && isUnitPriceOfMediumSizeExist && isUnitPriceOfLargeSizeExist
        saveBarButtonItem.isEnabled = shouldEnable
        
        
    }

  
    
    // MARK: - Navigation

   // 換頁,前進或後退,用func prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "saveProduct" else {
            return
        }
        
        guard productNameField.text!.count > 0 else {
            return
        }
        
        // nil coalster "??" 如果nil就...
        let categoryName = categoryNameField.text ?? ""
        let productImage = productImageLabel.text ?? ""
        let productName = productNameField.text ?? ""
//        let symbol = Character(emojiSymbol!)
        let unitPriceOfMediumSize = unitPriceOfMediumSizeField.text ?? ""
        let unitPriceOfLargeSize = unitPriceOfLargeSizeField.text ?? ""
        category = Category(categoryName: categoryName, products: [Product(productImage: productImage, productName: productName, unitPriceOfMediumSize: unitPriceOfMediumSize, unitPriceOfLargeSize: unitPriceOfLargeSize)])
//        product = Product(productImage: productImage, productName: productName, unitPriceOfMediumSize: unitPriceOfMediumSize, unitPriceOfLargeSize: unitPriceOfLargeSize)
   
        
    }
    

}
