//
//  ProductUpdateTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/8.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ProductUpdateTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
 
    @IBOutlet weak var categoryNameField: UITextField!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var unitPriceOfMediumSizeField: UITextField!
    @IBOutlet weak var unitPriceOfLargeSizeField: UITextField!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
   
    var categorys: [Category] = []
    var category: Category?
    var categoryNames = [String]()
    var product: Product?
    var productUpdateFinal: Product? // peko add 12/10
    var productInsertFinal: Product? // peko add 12/10
 
    static let TAG = "ProductUpdateTableViewController"

    let communicator = Communicator.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let category = category {
//
//            categoryNameField.text = category.name
//            //categoryNameField.text = category.name
//        }
//        if let product = product { // self.product { 可不寫self,用sadow in方式
//
//            //productImageView.image = UIImage(data: data)
//            categoryNameField.text = product.getCategory()
//            productNameField.text = product.getName()
//            unitPriceOfMediumSizeField.text = String(product.getPriceM())
//            unitPriceOfLargeSizeField.text = String(product.getPriceL())
//            //unitPriceOfLargeSizeField.text = String(product.priceL!)
//        }
        
        updateSaveButtonState()
        
        communicator.getAllCategory { (result, error) in
            if let error = error {
                PrintHelper.println(tag: ProductUpdateTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }
            
            guard let result = result else {
                PrintHelper.println(tag: ProductUpdateTableViewController.TAG, line: #line, "result is nil")
                return
            }
            
            PrintHelper.println(tag: ProductUpdateTableViewController.TAG, line: #line, "result OK.")
            
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
            PrintHelper.println(tag: ProductUpdateTableViewController.TAG, line: #line, "SET categorys OK.")

           
            for category in categoryObject {
                self.categorys.append(category)
                
                let categoryName = category.name
                self.categoryNames.append(categoryName!)
            }
           
        }
        
        // 建立 UIPickerView
        let categoryPickerView = UIPickerView()
        
        // 設定 UIPickerView 的 delegate 及 dataSource
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        // 將 UITextField 原先鍵盤的視圖更換成 UIPickerView
        categoryNameField.inputView = categoryPickerView
        
        // 加上手勢按鈕
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
     
    }
    
    @IBAction func textFieldBeginEditing(_ sender: Any) {
        updateSaveButtonState()
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    // 有幾個區塊
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 裡面有幾列
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
        return categoryNames.count
    }
    
    // 選擇到的那列要做的事
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        categoryNameField.text = categoryNames[row]
    }
    
    // 設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        return categoryNames[row]
    }
    
    func updateSaveButtonState() {
        let categoryName = categoryNameField.text ?? ""
        let productImage = self.productImageView.image
        let productName = productNameField.text ?? ""
        let unitPriceOfMediumSize = unitPriceOfMediumSizeField.text ?? ""
        let unitPriceOfLargeSize = unitPriceOfLargeSizeField.text ?? ""
        
        let isCategoryNameExist = !categoryName.isEmpty
        let isProductImageExist = !(productImage?.isEqual(nil))!
        let isProductNameExist = !productName.isEmpty
        let isUnitPriceOfMediumSizeExist = !unitPriceOfMediumSize.isEmpty
        let isUnitPriceOfLargeSizeExist = !unitPriceOfLargeSize.isEmpty

        let shouldEnable = isCategoryNameExist && isProductImageExist && isProductNameExist && isUnitPriceOfMediumSizeExist && isUnitPriceOfLargeSizeExist
        saveBarButtonItem.isEnabled = shouldEnable
        
    }

    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
       
        
        
            guard let selectedImage = productImageView.image else {
                print("Image not found!")
                return
            }
        
            let imageBase64 =  convertImageToBase64(image: selectedImage)
            //var categoryId = 0
            //var categoryId: Int?
            //let categoryName: Int! = categoryNames.index(of: categoryNameField.text!)
            let categoryName = categoryNameField.text!
        
            //        if ((category?.name = categoryName) != nil) {
            //
            //            categoryId = category!.id ?? 0
            //
            //        }
            // .equals
            //        if category!.name!.isEqual(categoryName) {
            //
            //            categoryId = category!.id ?? 0
            //
            //        }
        
            let productName = productNameField.text!
            let unitPriceOfMediumSize = Int(unitPriceOfMediumSizeField.text!)
            let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text!)
            //let product = Product(id: 0,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
        
            let categoryId = self.categorys.first { (category) -> Bool in
                return category.name == categoryName
                }?.id ?? 0
        
            let product = Product(id: 0,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
        
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
        
            guard let data = try? encoder.encode(product) else {
                assertionFailure("Cast product to json is Fail.")
                return
            }
        
            print(String(data: data, encoding: .utf8)!)
        
            guard let string = String(data: data, encoding: .utf8) else {
                assertionFailure("Cast data to string is Fail.")
                return
            }
            print("ppppppppppp")
            print(string)
            //寫入資料庫
            communicator.productUpdate(product: string, imageBase64: imageBase64) { (result, error) in
                if let error = error {
                    print("Update product fail: \(error)")
                    return
                }
                
                guard let updateStatus = result as? Int else {
                    assertionFailure("modify fail.")
                    return
                }
                
                if updateStatus == 1 {
                    // 跳出成功視窗
                    let alertController = UIAlertController(title: "完成", message:
                        "儲存成功", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
//                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "productList") as! ProductTableViewController
//                        self.present(VC, animated: true, completion: nil)
                        self.performSegue(withIdentifier: "goBackFromAddDrinkWithSegue", sender: nil)
                        
                    })
                    alertController.addAction(okBtn)
                    self.present(alertController, animated: true)
                    // 儲存按鈕 消失
                    self.saveBarButtonItem.isEnabled = false
                    
                } else {
                    let alertController = UIAlertController(title: "失敗", message:
                        "儲存失敗", preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: "確認", style: .default)
                    alertController.addAction(okBtn)
                    self.present(alertController, animated: true)
                }
            }

        
        
    
    
    
//        guard let selectedImage = productImageView.image else {
//            print("Image not found!")
//            return
//        }
//
//        let imageBase64 =  convertImageToBase64(image: selectedImage)
//        //var categoryId = 0
//        //var categoryId: Int?
//        //let categoryName: Int! = categoryNames.index(of: categoryNameField.text!)
//        let categoryName = categoryNameField.text!
//
////        if ((category?.name = categoryName) != nil) {
////
////            categoryId = category!.id ?? 0
////
////        }
//        // .equals
////        if category!.name!.isEqual(categoryName) {
////
////            categoryId = category!.id ?? 0
////
////        }
//
//        let productName = productNameField.text!
//        let unitPriceOfMediumSize = Int(unitPriceOfMediumSizeField.text!)
//        let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text!)
//        //let product = Product(id: 0,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
//
//        let categoryId = self.categorys.first { (category) -> Bool in
//            return category.name == categoryName
//        }?.id ?? 0
//
//        let product = Product(id: 0,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        guard let data = try? encoder.encode(product) else {
//            assertionFailure("Cast product to json is Fail.")
//            return
//        }
//
//        print(String(data: data, encoding: .utf8)!)
//
//        guard let string = String(data: data, encoding: .utf8) else {
//            assertionFailure("Cast data to string is Fail.")
//            return
//        }
//        print("ppppppppppp")
//        print(string)
//        //寫入資料庫
//
//
//        communicator.productInsert(product: string, imageBase64: imageBase64) { (result, error) in
//            if let error = error {
//                print("Insert product fail: \(error)")
//                return
//            }
//
//            guard let updateStatus = result as? Int else {
//                assertionFailure("modify fail.")
//                return
//            }
//
//            if updateStatus == 1 {
//                // 跳出成功視窗
//                let alertController = UIAlertController(title: "完成", message:
//                    "儲存成功", preferredStyle: .alert)
//                let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
//                    //let VC = self.storyboard?.instantiateViewController(withIdentifier: "productList") as! ProductTableViewController
//                    //self.present(VC, animated: true, completion: nil)
//                    self.performSegue(withIdentifier: "goBackFromAddDrinkWithSegue", sender: nil)
//                })
//                alertController.addAction(okBtn)
//                self.present(alertController, animated: true)
//                // 儲存按鈕 消失
//                self.saveBarButtonItem.isEnabled = false
//
//            } else {
//                let alertController = UIAlertController(title: "失敗", message:
//                    "儲存失敗", preferredStyle: .alert)
//                let okBtn = UIAlertAction(title: "確認", style: .default)
//                alertController.addAction(okBtn)
//                self.present(alertController, animated: true)
//            }
//        }
    
    
    }
    
//        communicator.productUpdate(product: string, imageBase64: imageBase64) { (result, error) in
//            if let error = error {
//                print("Update product fail: \(error)")
//                return
//            }
//
//            guard let updateStatus = result as? Int else {
//                assertionFailure("modify fail.")
//                return
//            }
//
//            if updateStatus == 1 {
//                // 跳出成功視窗
//                let alertController = UIAlertController(title: "完成", message:
//                    "儲存成功", preferredStyle: .alert)
//                let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
//                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "productList") as! ProductTableViewController
//                    self.present(VC, animated: true, completion: nil)
//                })
//                alertController.addAction(okBtn)
//                self.present(alertController, animated: true)
//                // 儲存按鈕 消失
//                self.saveBarButtonItem.isEnabled = false
//
//            } else {
//                let alertController = UIAlertController(title: "失敗", message:
//                    "儲存失敗", preferredStyle: .alert)
//                let okBtn = UIAlertAction(title: "確認", style: .default)
//                alertController.addAction(okBtn)
//                self.present(alertController, animated: true)
//            }
//        }
//    }
    
    // MARK: - Navigation

    // 換頁,前進或後退,用func prepare
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        guard segue.identifier == "saveProduct" else {
//            return
//        }
//
//        guard categoryNameField.text!.count > 0 else {
//            return
//        }
//
//        // nil coalster "??" 如果nil就...
//        //let categoryName = categoryNameField.text ?? ""
////        let productImage = productImageView.image ?? ""
//        //let productName = productNameField.text ?? ""
////        let symbol = Character(emojiSymbol!)
//        //let unitPriceOfMediumSize = Int(unitPriceOfMediumSizeField.text!) ?? 0
//        //let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text!) ?? 0
//        //let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text ?? "")
//
//        guard let selectedImage = productImageView.image else {
//            print("Image not found!")
//            return
//        }
//
//        let imageBase64 =  convertImageToBase64(image: selectedImage)
//        //var categoryId = 0
//        //var categoryId: Int?
//        //let categoryName: Int! = categoryNames.index(of: categoryNameField.text!)
//        let categoryName = categoryNameField.text!
//
//        //        if ((category?.name = categoryName) != nil) {
//        //
//        //            categoryId = category!.id ?? 0
//        //
//        //        }
//        // .equals
//        //        if category!.name!.isEqual(categoryName) {
//        //
//        //            categoryId = category!.id ?? 0
//        //
//        //        }
//
//        let productName = productNameField.text!
//        let unitPriceOfMediumSize = Int(unitPriceOfMediumSizeField.text!)
//        let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text!)
//        //let product = Product(id: 0,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
//
//        let categoryId = self.categorys.first { (category) -> Bool in
//            return category.name == categoryName
//            }?.id ?? 0
//
//        let product = Product(id: 0,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        guard let data = try? encoder.encode(product) else {
//            assertionFailure("Cast product to json is Fail.")
//            return
//        }
//
//        print(String(data: data, encoding: .utf8)!)
//
//        guard let string = String(data: data, encoding: .utf8) else {
//            assertionFailure("Cast data to string is Fail.")
//            return
//        }
//        print("ppppppppppp")
//        print(string)
//        //寫入資料庫
//
//
//        communicator.productUpdate(product: string, imageBase64: imageBase64) { (result, error) in
//            if let error = error {
//                print("Update product fail: \(error)")
//                return
//            }
//
//            guard let updateStatus = result as? Int else {
//                assertionFailure("modify fail.")
//                return
//            }
//
//            if updateStatus == 1 {
//                // 跳出成功視窗
//                let alertController = UIAlertController(title: "完成", message:
//                    "儲存成功", preferredStyle: .alert)
//                let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
//                    //                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "productList") as! ProductTableViewController
//                    //                        self.present(VC, animated: true, completion: nil)
//                    self.performSegue(withIdentifier: "goBackFromAddDrinkWithSegue", sender: nil)
//
//                })
//                alertController.addAction(okBtn)
//                self.present(alertController, animated: true)
//                // 儲存按鈕 消失
//                self.saveBarButtonItem.isEnabled = false
//
//            } else {
//                let alertController = UIAlertController(title: "失敗", message:
//                    "儲存失敗", preferredStyle: .alert)
//                let okBtn = UIAlertAction(title: "確認", style: .default)
//                alertController.addAction(okBtn)
//                self.present(alertController, animated: true)
//            }
//        }
    
        
        
    
    
//    productInsertFinal =
//    communicator.productInsert(product: string, imageBase64: imageBase64) { (result, error) in
//    if let error = error {
//    print("Insert product fail: \(error)")
//    return
//    }
//
//    guard let updateStatus = result as? Int else {
//    assertionFailure("modify fail.")
//    return
//    }
//
//    if updateStatus == 1 {
//    // 跳出成功視窗
//    let alertController = UIAlertController(title: "完成", message:
//    "儲存成功", preferredStyle: .alert)
//    let okBtn = UIAlertAction(title: "確認", style: .default,handler: { _ in
//    //let VC = self.storyboard?.instantiateViewController(withIdentifier: "productList") as! ProductTableViewController
//    //self.present(VC, animated: true, completion: nil)
//    self.performSegue(withIdentifier: "goBackFromAddDrinkWithSegue", sender: nil)
//    })
//    alertController.addAction(okBtn)
//    self.present(alertController, animated: true)
//    // 儲存按鈕 消失
//    self.saveBarButtonItem.isEnabled = false
//
//    } else {
//    let alertController = UIAlertController(title: "失敗", message:
//    "儲存失敗", preferredStyle: .alert)
//    let okBtn = UIAlertAction(title: "確認", style: .default)
//    alertController.addAction(okBtn)
//    self.present(alertController, animated: true)
//    }
//    }
    
    


//        category = Category(categoryName: categoryName, products: [Product(productImage: productImage, productName: productName, unitPriceOfMediumSize: unitPriceOfMediumSize, unitPriceOfLargeSize: unitPriceOfLargeSize)])
        //category = Category(id: id, name: categoryName, products: [Product(ID: ID, categoryId: categoryId, categoryNameOnProduct: categoryNameOnProduct, name: productName, priceM: unitPriceOfMediumSize, priceL: unitPriceOfLargeSize)])

        //product = Product(id: 0,categoryId: category!.id,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)

//        category = Category(name: categoryName, products: [Product(name: productName, priceM: unitPriceOfMediumSize, priceL: unitPriceOfLargeSize)])



//        product = Product(productImage: productImage, productName: productName, unitPriceOfMediumSize: unitPriceOfMediumSize, unitPriceOfLargeSize: unitPriceOfLargeSize)

    //}





    @IBAction func pickPictureBtnPressed(_ sender: Any) {
        closeKeyboard()
        let alert = UIAlertController(title: "Please choose source:", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.launchPicker(source: .camera)
        }
        let library = UIAlertAction(title: "Photo library", style: .default) { (action) in
            self.launchPicker(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    func launchPicker(source: UIImagePickerController.SourceType) {
        
        //Check if the source is valid or not?
        guard UIImagePickerController.isSourceTypeAvailable(source)
            else {
                print("Invalid source type")
                return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        // picker.mediaTypes = ["public.image", "public.movie"]
        picker.mediaTypes = [kUTTypeImage] as [String]
        picker.sourceType = source
        
        present(picker, animated: true)
    }
    
    
    //MARK: - UIImagePickerControllerDelegate protocol Method.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info: \(info)")
        guard let type = info[.mediaType] as? String  else {
            assertionFailure("Invalid type")
            return
        }
        if type == kUTTypeImage as String {
            guard let originalImage = info[.originalImage] as? UIImage else {
                assertionFailure("originalImage is nil.")
                return
            }
            let resizedImage = originalImage.resize(maxEdge: 1024)!
            let jpgData = resizedImage.jpegData(compressionQuality: 0.8)//壓縮率:0.0~1之間,為了品質一般都控制在0.7~0.8
            
            let pngData = resizedImage.pngData()
            print("jpgData: \(jpgData!.count)")
            print("pngData: \(pngData!.count)")
            
            
            productImageView.image = resizedImage
            
            picker.dismiss(animated: true) //Important! 加這行picker才會把自己收起來
        }
        
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
}

extension Communicator {
    
    // 取得全部的類別
//    func getAllCategory(completion: @escaping DoneHandler) {
//        let urlString = Communicator.shared.PRODUCTSERVLET_URL
//        let parameters: [String: Any] = [ACTION_KEY: "getAllCategory"]
//        doPost(urlString: urlString, parameters: parameters, completion: completion)
//    }
    
    // 取得全部的商品
//    func getAllProduct(completion: @escaping DoneHandler) {
//        let urlString = Communicator.shared.PRODUCTSERVLET_URL
//        let parameters: [String: Any] = [ACTION_KEY: "getAllProduct"]
//        doPost(urlString: urlString, parameters: parameters, completion: completion)
//    }
    
    
    // 新增商品
    func productInsert(product: String, imageBase64: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        
        var id: Int?
        var categoryId: Int?
        var category: String?
        var name: String?
        var priceM: Int?
        var priceL: Int?

        //let data = try? JSONSerialization.data(withJSONObject: ["id":0, "categoryId":8, "Category":"鮮榨", "Name":"ddd", "MPrice":33, "LPrice": 33], options: [])
        //let productString = String(data: data!, encoding: .utf8)
        //let parameters: [String: Any] = [ACTION_KEY: "productInsert", PRODUCT_KEY: productString, IMAGEBASE64_KEY: imageBase64]
        let parameters: [String: Any] = [ACTION_KEY: "productInsert", PRODUCT_KEY: product, IMAGEBASE64_KEY: imageBase64]
        print("add drink", parameters)
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    // 修改商品
    func productUpdate(product: String, imageBase64: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "productInsert", PRODUCT_KEY: product, IMAGEBASE64_KEY: imageBase64]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
}
