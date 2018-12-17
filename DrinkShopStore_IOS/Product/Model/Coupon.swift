//
//  Coupon.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/12/17.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import Foundation

struct Coupon: Codable {
    var coupon_id: Int = 0
    var member_id: Int = 0
    var coupon_no: String = ""
    var coupon_discount: Double = 10.0//預設沒打折
    var coupon_status: String = ""
    var coupon_start: String = ""
    var coupon_end: String = ""
}
