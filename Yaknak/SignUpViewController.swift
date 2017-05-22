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
    @IBOutlet weak var credentialStackView: UIStackView!
    
    let pickerController = UIImagePickerController()
    let dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
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
    
    
    func setUI() {
        self.emailField.delegate = self
        self.nameField.delegate = self
        self.passwordField.delegate = self
        self.pickerController.delegate = self
        self.emailField.borderTop()
        self.nameField.borderTop()
        self.passwordField.borderTop()
        self.passwordField.borderBottom()
        self.credentialStackView.addBottomBorder(color: UIColor.tertiaryColor(), width: 1.0)
        let placeholderImage = UIImage(named: Constants.Images.ProfilePlaceHolder)
        self.userImageView.image = placeholderImage
        self.view.layoutIfNeeded()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        self.userImageView.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.choosePicture(_:)))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGestureRecognizer)
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
        
        if let email = emailField.text {
            if let password = passwordField.text {
                if let name = nameField.text {
        
        if email.isEmpty || password.isEmpty || name.isEmpty {
            
            self.promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.RequiredFieldsMessage)
        }
            
        else if ValidationHelper.isValidEmail(email) && ValidationHelper.isPwdLength(password) {
            
            self.showLoading(true)
            
            if let resizedImage = self.userImageView.image?.resizeImageAspectFill(newSize: CGSize(200, 200)) {
                
                if let data = UIImageJPEGRepresentation(resizedImage, 1) {
                
                
                self.dataService.signUp(email, name, password, data as NSData, completion: { (success) in
                    
                    if success {
                        self.showLoading(false)
                        let alert = UIAlertController()
                       alert.defaultAlert(nil, Constants.Notifications.VerifyEmailMessage)
                    }
                    else {
                        // TODO
                       self.showLoading(false)
                    }
                })
            }
            }
            dismiss(animated: true, completion: nil)
        }
            
        else {
            self.promptAlert(Constants.Notifications.GenericFailureTitle, Constants.Notifications.NoValidPasswordMessage)
            
        }
            }
    }
}

    }
    
    
    private func showLoading(_ loading: Bool) {
        
        if loading {
            self.signUpButton.showLoading()
            self.signUpButton.backgroundColor = UIColor.primaryColor()
            self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        }
        else {
            self.signUpButton.backgroundColor = UIColor.tertiaryColor()
            self.signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.signUpButton.hideLoading()
        }
    }
    

    
    @IBAction func signUpCancelled(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func linkToTerms(_ sender: Any) {
        if let link = URL(string: Constants.ExternalLinks.YaknakTermsLink) {
        UIApplication.shared.openURL(link)
        }
    }
    
    
    @IBAction func linkToPolicy(_ sender: Any) {
        if let link = URL(string: Constants.ExternalLinks.YaknakPrivacyLink) {
        UIApplication.shared.openURL(link)
        }
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
        self.promptAlert(Constants.Notifications.NoCameraTitle, Constants.Notifications.NoCameraMessage)
    }
    
    func promptAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleMutableString = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(titleMutableString, forKey: "attributedTitle")
        
        let messageMutableString = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.primaryTextColor()
            ])
        
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let defaultAction = UIAlertAction(title: Constants.Notifications.GenericOKTitle, style: .cancel, handler: nil)
        defaultAction.setValue(UIColor.primaryColor(), forKey: "titleTextColor")
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
