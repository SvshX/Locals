//
//  SignUpViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var nameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var changeProfileButton: UIButton!
    @IBOutlet weak var signUpButton: LoadingButton!
    
    
    
    let pickerController = UIImagePickerController()
    let dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.delegate = self
        self.nameField.delegate = self
        self.passwordField.delegate = self
        self.pickerController.delegate = self
        
        self.emailField.borderTop()
        self.nameField.borderTop()
        self.passwordField.borderTop()
        self.passwordField.borderBottom()
        
        let placeholderImage = UIImage(named: "placeholder_profile")
        self.userImageView.image = placeholderImage
        
        
        self.view.layoutIfNeeded()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        self.userImageView.clipsToBounds = true
        
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.choosePicture(_:)))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.signUpButton.backgroundColor = UIColor.smokeWhiteColor()
        self.signUpButton.setTitleColor(UIColor.primaryTextColor(), for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.nameField.becomeFirstResponder()
        }
        if textField == self.nameField {
            self.passwordField.becomeFirstResponder()
        }
        if textField == self.passwordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    
    @IBAction func choosePicture(_ sender: Any) {
        
        pickerController.allowsEditing = false
        var cameraAction = UIAlertAction()
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        
        
        cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.pickerController.sourceType = .camera
            self.pickerController.cameraCaptureMode = .photo
            
            self.present(self.pickerController, animated: true, completion: nil)
        }
        
        
        
        
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            self.pickerController.sourceType = .photoLibrary
            self.present(self.pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            self.pickerController.sourceType = .savedPhotosAlbum
            self.present(self.pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            alertController.addAction(cameraAction)
            
        }
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func signUpTapped(_ sender: AnyObject) {
        
        if emailField.text == "" || passwordField.text == "" || nameField.text == "" {
            
            let title = "Oops!"
            let message = "Please fill in all required fields."
            self.promptAlert(title: title, message: message)
        }
            
        else if ValidationHelper.isValidEmail(candidate: self.emailField.text!) && ValidationHelper.isPwdLength(password: self.passwordField.text!) {
            
            self.showLoading()
            
            if let resizedImage = self.userImageView.image?.resizeImageAspectFill(newSize: CGSize(200, 200)) {
                
                let data = UIImageJPEGRepresentation(resizedImage, 1)
                
                
                self.dataService.signUp(email: self.emailField.text!, name: self.nameField.text!, password: self.passwordField.text!, data: data! as NSData, completion: { (success) in
                    
                    if success {
                        self.hideLoading()
                        let alert = UIAlertController()
                        let title = "Info"
                        let message = "Please verify your email using the link we just sent you."
                       alert.defaultAlert(title: title, message: message)
                    }
                    else {
                       self.hideLoading()
                        
                    }
                    
                    
                })
            }
            dismiss(animated: true, completion: nil)
        }
            
        else {
            let title = "Oops!"
            let message = "The password has to be 6 characters long or more."
            self.promptAlert(title: title, message: message)
            
        }
        
    }
    
    
    private func showLoading() {
        self.signUpButton.showLoading()
        self.signUpButton.backgroundColor = UIColor.primaryColor()
        self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }
    
    
    private func hideLoading() {
        self.signUpButton.backgroundColor = UIColor.tertiaryColor()
        self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.signUpButton.hideLoading()
    }
    
    
    @IBAction func signUpCancelled(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func linkToTerms(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "http://yaknakapp.com/terms/")! as URL)
    }
    
    
    @IBAction func linkToPolicy(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "http://yaknakapp.com/privacy/")! as URL)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
        self.userImageView.image = chosenImage
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func noCamera() {
        self.promptAlert(title: Constants.Notifications.NoCameraTitle, message: Constants.Notifications.NoCameraMessage)
    }
    
    func promptAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
