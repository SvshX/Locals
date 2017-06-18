//
//  FullScreenImageView.swift
//  Yaknak
//
//  Created by Sascha Melcher on 26/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

protocol ZoomImageDelegate: class {
    func didTapEdit()
}

class ZoomingImageView: UIImageView {

    
    var bgView: UIView!
    var editLabel: UILabel!
    var closeLabel: UILabel!
    
    var animated: Bool = true
    weak var delegate: ZoomImageDelegate?
    
    //MARK: Life cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
      //  fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private methods
    
    fileprivate func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(fullScreenMe))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    
    fileprivate func createLabel(_ text: String) -> UILabel {
        
        let label = UILabel(frame: CGRect.zero)
        label.text = text
        label.font = UIFont.systemFont(ofSize: 17)
        label.sizeToFit()
    //    label.textAlignment = .center
        label.textColor = UIColor.smokeWhiteColor()
     //   label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.alpha = 0.0
        
        return label
    }
    
   
    
    //MARK: Actions of Gestures
    func exitFullScreen() {
        bgView.removeFromSuperview()
    }
    
    func changePic() {
        self.delegate?.didTapEdit()
        bgView.removeFromSuperview()
    }
    
    func fullScreenMe() {
        
        if let window = UIApplication.shared.delegate?.window {
            bgView = UIView(frame: UIScreen.main.bounds)
            bgView.backgroundColor = UIColor.black
            let imageV = UIImageView(image: self.image)
            imageV.frame = bgView.frame
            imageV.contentMode = .scaleAspectFit
            self.bgView.addSubview(imageV)
            
            self.closeLabel = createLabel("Back")
            self.editLabel = createLabel("Edit")
            
        //    let labelWidth = 100
        //    let labelHeight = closeLabel.frame.size.height + 16
         //   self.closeLabel =  CGRect(x: 16, y: 16, width: 100, height: 20)
         //   self.editLabel.frame = CGRect(x: 16, y: 16, width: 100, height: 20)
            self.closeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitFullScreen)))
            self.editLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePic)))
            self.editLabel.textAlignment = .right
            self.closeLabel.isUserInteractionEnabled = true
            self.editLabel.isUserInteractionEnabled = true
            self.bgView.addSubview(closeLabel)
            self.bgView.addSubview(editLabel)
            
            window?.addSubview(bgView)
            
            closeLabel.translatesAutoresizingMaskIntoConstraints = false
            editLabel.translatesAutoresizingMaskIntoConstraints = false
            
            closeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            closeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
            closeLabel.topAnchor.constraint(equalTo: self.bgView.topAnchor, constant: 32).isActive = true
            closeLabel.leadingAnchor.constraint(equalTo: self.bgView.leadingAnchor, constant: 16).isActive = true
            
            editLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
            editLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
            editLabel.topAnchor.constraint(equalTo: self.bgView.topAnchor, constant: 32).isActive = true
            editLabel.trailingAnchor.constraint(equalTo: self.bgView.trailingAnchor, constant: -16).isActive = true
            
            
            if animated {
                var sx: CGFloat = 0, sy: CGFloat = 0
                if self.frame.size.width > self.frame.size.height {
                    sx = self.frame.size.width/imageV.frame.size.width
                    imageV.transform = CGAffineTransform(scaleX: sx, y: sx)
                } else {
                    sy = self.frame.size.height/imageV.frame.size.height
                    imageV.transform = CGAffineTransform(scaleX: sy, y: sy)
                }
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    imageV.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.closeLabel.alpha = 1
                    self.editLabel.alpha = 1
                })
            }
        }
    }

}
