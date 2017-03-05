//
//  ProfileGridCell.swift
//  Yaknak
//
//  Created by Sascha Melcher on 20/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit


class ProfileGridCell: UICollectionViewCell {
    
    
  //  var manager = Nuke.Manager.shared
  
    
    @IBOutlet weak var tipImage: UIImageView!
    
 /*
    func bind(request: Request, indexPath: IndexPath) {
    
        manager.loadImage(with: request, token: nil) { (response) in
            
            self.tipImage.image = response.value
            print("fetch image..." + String(indexPath.row))
        }
        
    }
    
  
    func loadTipImage(request: Request, index: IndexPath) {
        
        manager.loadImage(with: request, into: tipImage) { [weak tipImage] response, _ in
            print("fetch image..." + String(index.row))
            tipImage?.handle(response: response, isFromMemoryCache: true)
            //tipImage = response.value
        }
    }
    */
  /*
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tipImage.image = nil
        manager.cancelRequest(for: self.tipImage)
        
      
    }
 */
  /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   */ 
    
}
