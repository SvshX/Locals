//
//  SelectionListCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 25/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import HTHorizontalSelectionList


class SelectionListCell: UITableViewCell {
    
    var selectionList: HTHorizontalSelectionList!
    var category: String!
    var index = Int()
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        positionSelectionList()
    }
    
    
    func setTipCategory(_ category: String) {
        
        
        switch category {
        case "eat":
            index = 0
        case "drink":
            index = 1
        case "dance":
            index = 2
        case "free":
            index = 3
        case "coffee":
            index = 4
        case "shop":
            index = 5
        case "deals":
            index = 6
        case "outdoors":
            index = 7
        case "watch":
            index = 8
        case "special":
            index = 9
        default:
            index = 0
        }
      
    
    }
    
    
    func positionSelectionList() {
        self.selectionList = HTHorizontalSelectionList(frame: CGRect(0, 0, self.frame.size.width, 40))
        self.selectionList.delegate = self
        self.selectionList.dataSource = self
        
        self.selectionList.selectionIndicatorStyle = .bottomBar
        self.selectionList.selectionIndicatorColor = UIColor.primaryColor()
        self.selectionList.bottomTrimHidden = true
        self.selectionList.centerButtons = true
        
        self.selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);
        self.contentView.addSubview(self.selectionList)
        self.selectionList.setSelectedButtonIndex(index, animated: false)
    }
    

}


extension SelectionListCell: HTHorizontalSelectionListDelegate {
    
    // MARK: - HTHorizontalSelectionListDelegate Protocol Methods
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, didSelectButtonWith index: Int) {
        
        // update the category for the corresponding index
        self.category = Constants.HomeView.Categories[index]
        
        //      self.selectedFlowerView.image = self.flowers[index].image
    }
    
    
}


extension SelectionListCell: HTHorizontalSelectionListDataSource {
    
    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        
        return Constants.HomeView.Categories.count
    }
    
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, titleForItemWith index: Int) -> String? {
        return Constants.HomeView.Categories[index]
    }
    
}

