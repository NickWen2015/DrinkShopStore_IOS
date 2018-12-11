//
//  PrintHelper.swift
//  DrinkShopStore_IOS
//
//  Created by LinPeko on 2018/11/16.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

// 範例
// 在 class 內建立 全域變數 TAG
// static let TAG = "ProductTableViewController"
// PrintHelper.println(tag: TAG, line: #line, "MAG")

// 輸出結果
// 在 ProductTableViewController 的 ? 行,
// 訊息：MAG

import Foundation

final class PrintHelper {
    static func println(tag: String, line: Int, _ msg: String) {
        print("在 \(tag) 的 \(line) 行,\n訊息：\(msg) ")
    }
}
