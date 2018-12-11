//
//  ProductEditTableViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/10/8.
//  Copyright © 2018 LinPeko. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ProductEditTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    static let TAG = "ProductEditTableViewController"
    
    let communicator = Communicator.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSaveButtonState()
        
        categoryNames = [""]
        
        communicator.getAllCategory { (result, error) in
            if let error = error {
                PrintHelper.println(tag: ProductEditTableViewController.TAG, line: #line, "Error: \(error)")
                return
            }
            
            guard let result = result else {
                PrintHelper.println(tag: ProductEditTableViewController.TAG, line: #line, "result is nil")
                return
            }
            
            PrintHelper.println(tag: ProductEditTableViewController.TAG, line: #line, "result OK.")
            
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
            PrintHelper.println(tag: ProductEditTableViewController.TAG, line: #line, "SET categorys OK.")
            
            
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
    
    
    @IBAction func addCategory(_ sender: UIButton) {
        let title = "請輸入要新增的類別名稱"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "類別名稱"
        }
        let cancel = UIAlertAction(title: "取消", style: .default)
        let ok = UIAlertAction(title: "新增", style: .default) {(action: UIAlertAction!) -> Void in
            let categoryNameAdd = (alert.textFields?.first)! as UITextField
            
            self.communicator.insertCategory(categoryName: categoryNameAdd.text!) { (result, error) in
                if let error = error {
                    print("Insert categoryNameAdd fail: \(error)")
                    return
                }
            }
            
            // Show Alert with content.
            let alert = UIAlertController(title: "完成", message: "類別新增完成", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true)
            
            self.viewDidLoad()
            
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
        
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
        
        if self.product != nil {
            let id = self.product?.getId()
            
            guard let selectedImage = productImageView.image else {
                print("Image not found!")
                return
            }
            
            let imageBase64 =  convertImageToBase64(image: selectedImage)
            
            let categoryName = categoryNameField.text!
            let productName = productNameField.text!
            let unitPriceOfMediumSize = Int(unitPriceOfMediumSizeField.text!)
            let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text!)
            
            let categoryId = self.categorys.first { (category) -> Bool in
                return category.name == categoryName
                }?.id ?? 0
            
            let product = Product(id: id,categoryId: categoryId,category: categoryName,name: productName, priceM: unitPriceOfMediumSize,priceL: unitPriceOfLargeSize)
            
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
            
        } else {
            
            guard let selectedImage = productImageView.image else {
                print("Image not found!")
                return
            }
            
            let imageBase64 =  convertImageToBase64(image: selectedImage)
            let categoryName = categoryNameField.text!
            let productName = productNameField.text!
            let unitPriceOfMediumSize = Int(unitPriceOfMediumSizeField.text!)
            let unitPriceOfLargeSize = Int(unitPriceOfLargeSizeField.text!)
            
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
            
            communicator.productInsert(product: string, imageBase64: imageBase64) { (result, error) in
                if let error = error {
                    print("Insert product fail: \(error)")
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
        }
        
    }
    
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
    
    // 修改類別
    func insertCategory(categoryName: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "insertCategory", CATEGORYNAME_KEY: categoryName]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    // 新增商品
    func productInsert(product: String, imageBase64: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "productInsert", PRODUCT_KEY: product, IMAGEBASE64_KEY: imageBase64]
        print("add drink", parameters)
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    // 修改商品
    func productUpdate(product: String, imageBase64: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.PRODUCTSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "productUpdate", PRODUCT_KEY: product, IMAGEBASE64_KEY: imageBase64]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
}
