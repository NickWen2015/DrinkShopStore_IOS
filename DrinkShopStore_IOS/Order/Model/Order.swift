//
//  Order.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/6.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation

struct Order: Codable {
    
    var orderId: Int?
    var invoicePrefix: String?
    var invoiceNo: String?
    var storeId: Int?
    var memberId: Int?
    var memberName: String?
    var orderAcceptTime: String?
    var orderFinishTime: String?
    var orderType: String?
    var deliveryId: Int?
    var couponId: Int?
    var orderStatus: String?
    var orderDetailList: [OrderDetail]?
    //var orderDetailList: List<OrderDetail>?
    
    // 訂單資訊(額外欄位)
    var invoice: String?
//    private String store_name;
//    private String store_telephone;
//    private String store_mobile;
//    private String store_address;
//    private String store_location_x;
//    private String store_location_y;
//    private float coupon_discount;
    
}

extension Order {
    enum CodingKeys: String, CodingKey {
        
        case orderId = "order_id"
        case invoicePrefix = "invoice_prefix"
        case invoiceNo = "invoice_no"
        case storeId = "store_id"
        case memberId = "member_id"
        case memberName = "member_name"
        case orderAcceptTime = "order_accept_time"
        case orderFinishTime = "order_finish_time"
        case orderType = "order_type"
        case deliveryId = "delivery_id"
        case couponId = "coupon_id"
        case orderStatus = "order_status"
        case orderDetailList = "orderDetailList"
        case invoice = "invoice"
        
    }
}

extension Order {
    
    func getOrderId() -> Int {
        guard let orderId = orderId else {
            return 0
        }
        return orderId
    }
    
    
    func getInvoicePrefix() -> String {
        guard let invoicePrefix = invoicePrefix else {
            return ""
        }
        return invoicePrefix
    }
    
    func getInvoiceNo() -> String {
        guard let invoiceNo = invoiceNo else {
            return ""
        }
        return invoiceNo
    }
    
    func getStoreId() -> Int {
        guard let storeId = storeId else {
            return 0
        }
        return storeId
    }
    
    func getMemberId() -> Int {
        guard let memberId = memberId else {
            return 0
        }
        return memberId
    }
    
    func getMemberName() -> String {
        guard let memberName = memberName else {
            return ""
        }
        return memberName
    }
    
    func getOrderAcceptTime() -> String {
        guard let orderAcceptTime = orderAcceptTime else {
            return ""
        }
        return orderAcceptTime
    }
    
    func getOrderFinishTime() -> String {
        guard let orderFinishTime = orderFinishTime else {
            return ""
        }
        return orderFinishTime
    }
    
    func getOrderType() -> String {
        guard let orderType = orderType else {
            return ""
        }
        return orderType
    }
    
    func getDeliveryId() -> Int {
        guard let deliveryId = deliveryId else {
            return 0
        }
        return deliveryId
    }
    
    func getCouponId() -> Int {
        guard let couponId = couponId else {
            return 0
        }
        return couponId
    }
    
    func getOrderStatus() -> String {
        guard let orderStatus = orderStatus else {
            return ""
        }
        return orderStatus
    }

    func getOrderDetailList() -> [OrderDetail] {
        guard let orderDetailList = orderDetailList else {
            return []
        }
        return orderDetailList
    }
    
//    func getOrderDetailList() -> List<OrderDetail> {
//        guard let orderDetailList = orderDetailList else {
//            return ""
//        }
//        return orderDetailList
//    }
    
    func getInvoice() -> String {
        guard let invoice = invoice else {
            return ""
        }
        return invoice
    }
    
}


