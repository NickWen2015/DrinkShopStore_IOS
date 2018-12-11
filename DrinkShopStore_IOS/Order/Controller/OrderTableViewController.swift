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
    
    @IBOutlet weak var previewImageView: UIImageView!
    var orders: [Order] = []
    
    static let TAG = "OrderTableViewController"
    let communicator = Communicator.shared
    
    // qr code
    let supportedTypes: [AVMetadataObject.ObjectType] = [.qr, .code128, .code39, .code93, .upce, .pdf417, .ean13, .aztec]
    // qr code
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput: AVCapturePhotoOutput?
    
    // Unwind Segue
//    @IBAction func unwindToOrderListByChangeOrderStatus(segue: UIStoryboardSegue) {
//        communicator.getAllOrder { (result, error) in
//            if let error = error {
//                PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "Error: \(error)")
//                return
//            }
//
//            guard let result = result else {
//                PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "result is nil")
//                return
//            }
//
//            PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "result OK.")
//
//            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
//                print("\(#line) Fail to generate jsonData.")
//                return
//            }
//
//            let decoder = JSONDecoder()
//            guard let orderObject = try? decoder.decode([Order].self, from: jsonData) else {
//                print("\(#line) Fail to decode [Order] jsonData.")
//                return
//            }
//
//            self.orders = orderObject
//            PrintHelper.println(tag: OrderTableViewController.TAG, line: #line, "SET orders OK.")
//
//            self.tableView.reloadData()
//
//        }
//
//    }
    
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
            
            
            
//            // 取得下一頁
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
            
        }
    }
    
    
    
    @IBAction func scanBtnPressed(_ sender: Any) {
        
        // Prepare Input.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Fail to create captureDevice.")
            return
        }
        guard let inputDevice = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Fail to create inputDevice")
            return
        }
        
        // Prepare Session.
        session = AVCaptureSession()
        session?.addInput(inputDevice)
        
        // Prepare output.
        let metadataOutput = AVCaptureMetadataOutput()
        session?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = supportedTypes
        
        cameraOutput = AVCapturePhotoOutput()
        session?.addOutput(cameraOutput!)
        
        // Prepare preview.
        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = CGRect(origin: .zero, size: previewImageView.frame.size)
        previewImageView.layer.addSublayer(previewLayer!)
        
        // Start Capture.
        session?.startRunning()
        previewImageView.image = nil
        
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Protocol Methods.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            //      assertionFailure("Invalid metadataObjects")
            return
        }
        
        guard let content = metadataObject.stringValue else {
            print("metadataObject.stringValue is nil.")
            return
        }
        
        // Stop output's report to delegate.
        output.setMetadataObjectsDelegate(nil, queue: nil)
        
        // Output image.
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        cameraOutput?.capturePhoto(with: settings, delegate: self)
        
        
        communicator.changeOrderStatusByOrderId(orderId: Int(content)!, orderStatus:  String(1)) { (result, error) in
            if let error = error {
                print("Change orderStatus fail: \(error)")
                return
            }
            
        }
        
        // Show Alert with content.
        let alert = UIAlertController(title: metadataObject.type.rawValue, message: "訂單： \(content) ,結單完成", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
        viewDidLoad()
        
    }
    
    
    // MARK: - AVCapturePhotoCaptureDelegate Methods.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        defer {
            // Clean up!
            session?.stopRunning()
            session = nil
            
            previewLayer?.removeFromSuperlayer()
            previewLayer = nil
            
            cameraOutput = nil
        }
        
        if let error = error {
            print("didFinishProcessingPhoto error: \(error)")
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            assertionFailure("Fail to get photo data.")
            return
        }
        //previewImageView.image = UIImage(data: data)
        
    }
    
}

extension Communicator {
    
    // 取得全部的未結訂單
    func getAllOrder(completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.ORDERSSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "getAllOrder"]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
    // 修改OrderStatus
    func changeOrderStatusByOrderId(orderId: Int, orderStatus: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.ORDERSSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "changeOrderStatusByOrderId", ORDERID_KEY: orderId, ORDERSTATUS_KEY: orderStatus]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
}

