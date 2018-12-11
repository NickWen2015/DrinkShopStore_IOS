//
//  QRCodeViewController.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/11.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit
import Photos

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    static let TAG = "QRCodeViewController"
    let communicator = Communicator.shared
    
    let supportedTypes: [AVMetadataObject.ObjectType] = [.qr, .code128, .code39, .code93, .upce, .pdf417, .ean13, .aztec]
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraOutput: AVCapturePhotoOutput?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let alert = UIAlertController(title: "結單完成", message: "訂單： \(content) ，結單完成", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
       
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
        previewImageView.image = UIImage(data: data)
        
    }
    
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToOrderListByChangeOrderStatus", sender: nil)
    }
    
}

extension Communicator {
    
    // 修改OrderStatus
    func changeOrderStatusByOrderId(orderId: Int, orderStatus: String, completion: @escaping DoneHandler) {
        let urlString = Communicator.shared.ORDERSSERVLET_URL
        let parameters: [String: Any] = [ACTION_KEY: "changeOrderStatusByOrderId", ORDERID_KEY: orderId, ORDERSTATUS_KEY: orderStatus]
        doPost(urlString: urlString, parameters: parameters, completion: completion)
    }
    
}

