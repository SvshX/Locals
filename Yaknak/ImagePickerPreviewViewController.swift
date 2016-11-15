//
//  ImagePickerPreviewViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

@objc protocol ImagePickerPreviewDelegate {
    @objc optional func imagePickerPreview(originalImage: UIImage?)
    @objc optional func imagePickerPreviewCancel()
}

class ImagePickerPreviewViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: ImagePickerPreviewDelegate?
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        delegate?.imagePickerPreviewCancel?()
    }
    
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        dismiss(animated: false, completion: nil)
        delegate?.imagePickerPreview?(originalImage: image)
    }
    
    /*
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
        delegate?.imagePickerPreviewCancel?()
        
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        
        dismiss(animated: false, completion: nil)
        delegate?.imagePickerPreview?(originalImage: image)
        
    }
 
 */
    
    func setImage(image im: UIImage?) {
        image = im
    }
    
    private func updateImage() {
        imageView.image = image
    }
   
    
}

