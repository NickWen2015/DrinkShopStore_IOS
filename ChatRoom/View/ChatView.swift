//
//  ChatView.swift
//  DrinkShopStore_IOS
//
//  Created by Nick Wen on 2018/12/13.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

//MARK: - ChatItem
enum ChatSenderType {
    case fromMe
    case fromOthers
}

struct ChatItem {
    var text: String?
    var image: UIImage?
    var senderType: ChatSenderType//來自於誰
}


//MARK: - ChatView
class ChatView: UIScrollView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    //Constants & Variables.
    let padding: CGFloat = 20.0
    var lastBubbleViewY: CGFloat = 0.0
    private(set) var allItems = [ChatItem]()
    
    func add(chatItem: ChatItem) {
        
        // Create and add bubble view.創建泡泡框
        let bubbleView = ChatBubbleView(item: chatItem, maxWidth: self.frame.width, offsetY: lastBubbleViewY + padding)
        self.addSubview(bubbleView)//貼上泡泡View
        
        // Adjust variables.ChatView調整參數
        lastBubbleViewY = bubbleView.frame.maxY
        contentSize = CGSize(width: self.frame.width, height: lastBubbleViewY)//lastBubbleViewY下緣
        allItems.append(chatItem)
        
        // scroll to bottom.捲到底端,給一個小矩形,要捲到最底端矩形才能全部顯示
        let leftBottonRect = CGRect(x: 0, y: lastBubbleViewY, width: lastBubbleViewY - 1, height: 1)
        scrollRectToVisible(leftBottonRect, animated: true)
        
    }
    
}


//MARK: - ChatBubbleView
fileprivate class ChatBubbleView: UIView {
    
    //Constants
    let sidePaddingRate: CGFloat = 0.02
    let maxBubbleViewWidthRate: CGFloat = 0.6
    let contentMargin: CGFloat = 10.0
    let bubbleTailWidth: CGFloat = 10.0
    let textFontSize: CGFloat = 16.0
    
    //Constants from ChatView.
    let item: ChatItem
    let maxWidth: CGFloat
    let offsetY: CGFloat
    
    //Variables for subviews.
    var imageView: UIImageView?//泡泡框圖片
    var textLabel: UILabel?//泡泡框文字
    var backgroundImageView: UIImageView?//泡泡框底圖
    var currentY: CGFloat = 0.0
    
    init(item: ChatItem, maxWidth: CGFloat, offsetY: CGFloat) {
        self.item = item
        self.maxWidth = maxWidth
        self.offsetY = offsetY
        
        super.init(frame: .zero)//預設值0000
        
        //Step.1: Decide a basic frame.
        self.frame = caculateBasicFrame()//指定臨時frame為現在的frame本身
        
        //Step.2: Caculate imagwViews frame.
        prepareImageView()
        
        //Step.3: Caculate textLabel's frame.
        prepareTextLabel()
        
        //Step.4: Decide final size of bubble view.
        decideFinalSize()
        
        //Step.5: Display background of bubble.
        prepareBackgroundImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //計算一個概略寬高回傳出去
    private func caculateBasicFrame() -> CGRect {
        let sidePadding = maxWidth * sidePaddingRate//0.02%
        let maxBubbleViewWidth = maxWidth * maxBubbleViewWidthRate//0.60%
        let offsetX: CGFloat
        
        if item.senderType == .fromMe {
            offsetX = maxWidth - maxBubbleViewWidth - sidePadding
        } else {//.fromOthers
            offsetX = sidePadding
        }
        //The result is just a assumption.這邊只是一個假設的結果
        return CGRect(x: offsetX, y: offsetY, width: maxBubbleViewWidth, height: 10.0)
    }
    
    private func prepareImageView() {
        //Check if there is a image in this chat item.
        guard let image = item.image else {
            return
        }
        
        // Decide x and y.
        var x = contentMargin
        let y = contentMargin
        if item.senderType == .fromOthers {
            x += bubbleTailWidth
        }
        
        // Decide width and height.
        let displayWidth = min(image.size.width, self.frame.width - 2 * contentMargin - bubbleTailWidth)//判斷圖片跟imageView誰小
        let displayRatio = displayWidth / image.size.width
        let displayHeight = image.size.height * displayRatio
        
        // Decide final frame.
        let dispalyFrame = CGRect(x: x, y: y, width: displayWidth, height: displayHeight)
        
        // Create and add to bubble view.
        let photoImageView = UIImageView(frame: dispalyFrame)
        self.imageView = photoImageView
        photoImageView.image = image
        
        //Make a rounded corner.做圓弧角
        photoImageView.layer.cornerRadius = 5.0
        photoImageView.layer.masksToBounds = true// masksToBounds = true將超出邊界的部分切除
        
        self.addSubview(photoImageView)
        currentY = photoImageView.frame.maxY
    }
    
    private func prepareTextLabel() {
        //check if there is a non-empty text exist.
        guard let text = item.text, !text.isEmpty else {
            return
        }
        
        let index = text.index(of: "(")
        let textMessage = text.prefix(upTo: index!)
        
        // Decide x and y.
        var x = contentMargin
        let y = currentY + textFontSize/2//圖片與文字有間隔距離
        if item.senderType == .fromOthers {
            x += bubbleTailWidth
        }
        
        // Decide width and height. image的最大寬
        let displayWidth = self.frame.width - 2 * contentMargin - bubbleTailWidth
        
        // Decide final frame of text label.
        let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: textFontSize)
        
        // Create and add to bubble view.
        let label = UILabel(frame: displayFrame)
        self.textLabel = label
        label.font = UIFont.systemFont(ofSize: textFontSize)//字體
        label.numberOfLines = 0 //Important! 讓label決定內容有幾行,寬度固定
        label.text = String(textMessage)
        label.sizeToFit() //Important! label處理好寬高部分
        
        self.addSubview(label)//加到泡泡view
        currentY = label.frame.maxY
    }
    
    //決定最後泡泡View的大小
    private func decideFinalSize() {
        let finalHeight: CGFloat = currentY + contentMargin
        var finalWidth:CGFloat = 0.0
        
        //check finalWidth with imageView
        if let imageView = self.imageView {
            if item.senderType == .fromMe {
                finalWidth = imageView.frame.maxX + contentMargin + bubbleTailWidth
            } else {// from others
                finalWidth = imageView.frame.maxX + contentMargin
            }
        }
        
        //check finalWidth with textLabel
        if let textLabel = self.textLabel {
            var textWidth:CGFloat
            if item.senderType == .fromMe {
                textWidth = textLabel.frame.maxX + contentMargin + bubbleTailWidth
            } else {// from others
                textWidth = textLabel.frame.maxX + contentMargin
            }
            finalWidth = max(finalWidth, textWidth)// 比較比較圖片寬與文字誰較寬
        }
        
        // Final adjustment.最後調整,特殊狀況
        if item.senderType == .fromMe, self.frame.width > finalWidth {
            self.frame.origin.x += self.frame.width - finalWidth//向右位移校正
        }
        self.frame.size = CGSize(width: finalWidth, height: finalHeight)
    }
    
    
    private func prepareBackgroundImageView() {
        let image: UIImage?
        if item.senderType == .fromMe {
            let insets = UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28)
            image = UIImage(named: "fromMe.png")?.resizableImage(withCapInsets: insets)
        } else {// from others
            let insets = UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20)
            image = UIImage(named: "fromOthers.png")?.resizableImage(withCapInsets: insets)
        }
        
        //        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let frame = self.bounds// 與上面效果相同
        let imageView = UIImageView(frame: frame)
        self.backgroundImageView = imageView
        imageView.image = image
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        
    }
}

