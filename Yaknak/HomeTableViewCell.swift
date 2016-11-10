//
//  HomeTableViewCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 07/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    
 //   @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
 //   @IBOutlet weak var categoryName: UILabel!
 //   @IBOutlet weak var categoryTipNumber: UILabel!
    @IBOutlet weak var categoryTipNumber: UILabel!
    @IBOutlet weak var categoryName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func draw(_ rect: CGRect) {
        self.categoryImage.layer.cornerRadius = self.categoryImage.frame.size.width / 2
        self.categoryImage.clipsToBounds = true
    }
    
   

    
}
