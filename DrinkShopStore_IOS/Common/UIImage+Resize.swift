//
//  UIImage+Resize.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/3.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resize(maxEdge: CGFloat) -> UIImage? { //檢查圖片寬高有無超過
        
        //Check if it is necessary to resize.
        guard size.width > maxEdge || size.height >= maxEdge else {
            return self
        }
        
        //Decide final size.
        let finalSize: CGSize
        if size.width >= size.height {
            let ratio = size.width / maxEdge
            finalSize = CGSize(width: maxEdge, height: size.height / ratio)
        } else { // height > width
            let ratio = size.height / maxEdge
            finalSize = CGSize(width: size.width / ratio, height: maxEdge)
        }
        
        //Generate a new image.
        UIGraphicsBeginImageContext(finalSize) //建立一個油畫的畫布,可以疊圖
        let rect = CGRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height) //決定畫布大小
        self.draw(in: rect)//圖片佔滿全區(如果需要的話,也可以不用佔滿)
        let result = UIGraphicsGetImageFromCurrentImageContext() //從油畫畫布輸出變成UIImage
        UIGraphicsEndImageContext() //Important!如果忘了寫這行的話就不會釋放。因為這是C語言程式的東西,凡是碰到c語言程式的東西,有開始就要有結束。
        return result
    }
}

