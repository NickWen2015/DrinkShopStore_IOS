//
//  ActivitiesTableViewCell.swift
//  DrinkShopStore_IOS
//
//  Created by 周芳如 on 2018/11/6.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

import UIKit

class ActivitiesTableViewCell: UITableViewCell {

    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var activityEDateLabel: UILabel!
    @IBOutlet weak var activitySDateLabel: UILabel!
    var activity: NewsItem?{
        didSet{
//            activityImage.image = 
            activityNameLabel.text = activity?.name
            activitySDateLabel.text = activity?.sDate
            activityEDateLabel.text = activity?.eDate

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

    
