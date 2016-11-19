//
//  AddTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
//import PXGoogleDirections
import MBProgressHUD
import HTHorizontalSelectionList
import ReachabilitySwift
import RSKPlaceholderTextView
import Photos
import FirebaseStorage
import FirebaseDatabase
import GeoFire
import Firebase


private let selectionListHeight: CGFloat = 50
private let SCREEN_SIZE = UIScreen.main.bounds


@objc protocol ImagePickerDelegate {
    @objc optional func imagePicker(pickedImage image: UIImage?)
}



class AddTipViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Mark: Properties
    
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tipField: RSKPlaceholderTextView!
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var myLocationView: UIImageView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var saveTipButton: UIButton!
    @IBOutlet weak var tipFieldHeightConstraint: NSLayoutConstraint!
    
    // By default make locating album false
    var photos: PHFetchResult<AnyObject>?
    var assetThumbnailSize: CGSize!
    private let collectionReuseIdentifier = "PhotoCell"
    private let cameraReuseIdentifier = "CameraCell"
    var imageArray = [UIImage]()
    var fetchResult : PHFetchResult<PHAsset>?
    var reachability: Reachability?
    //  private var tip = Tip()
    var selectedCategory = Constants.HomeView.DefaultCategory
    let locationManager = CLLocationManager()
    var destination: CLLocation?
    private var responseData: NSMutableData?
    private var selectedPointAnnotation: MKPointAnnotation?
    private var connection: NSURLConnection?
    private var dataTask: URLSessionDataTask?
    private let googleMapsKey = Constants.Config.GoogleAPIKey
    private let baseURLString = Constants.Config.AutomCompleteString
    let picker = UIImagePickerController()
    let reuseIdentifier = Constants.Identifier.CategoryIdentifier
    let tapRec = UITapGestureRecognizer()
    var categories = [String]()
    var selectionList : HTHorizontalSelectionList!
    var finalImageView: UIImageView!
    var finalImageViewContainer: UIView!
    var cancelImageIcon: UIButton!
    var layoutFinalImage: Bool?
    var delegate: ImagePickerDelegate?
    let dataService = DataService()
    var loadingNotification = MBProgressHUD()
    var tipLocation: CLLocation!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //     NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddTipViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        tipFieldHeightConstraint.constant = tipFieldHeightConstraintConstant()
        self.tipField.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        self.tipField.textColor = UIColor.primaryTextColor()
        self.setupPhotoLibrary()
        self.finalImageView = UIImageView()
        self.finalImageViewContainer = UIView()
        tapRec.addTarget(self, action: #selector(AddTipViewController.getCurrentLocationTapped))
        myLocationView.addGestureRecognizer(tapRec)
        myLocationView.isUserInteractionEnabled = true
        self.configureSaveTipButton()
        self.layoutFinalImage = false
        //    self.userProfileImage.image = UIImage(named: "icon-square")
        
        setupReachability(nil, useClosures: true)
        startNotifier()
        
        
        
        // Handle the text field’s user input through delegate callbacks.
        self.tipField.delegate = self
        self.autocompleteTextfield.delegate = self
        
        //    self.imagePickerController.delegate = self
        //    self.imagePickerController.imageLimit = 1
        self.configureNavBar()
        //   let placeholder = UIImage(named: Constants.Images.Placeholder)
        //    self.imagePreview!.image = placeholder
        self.picker.delegate = self
        self.configureTextField()
        self.configureProfileImage()
        self.handleTextFieldInterfaces()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddTipViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        self.characterCountLabel.text = String(Constants.Counter.CharacterLimit)
        self.characterCountLabel.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)
        
        // Enable the Save button only if all fields are valid.
        //   self.checkValidTip()
        
        self.categories = Constants.HomeView.Categories
        
        // category selection list
        
        //   self.edgesForExtendedLayout = .none
        
        // add AutoLayout
        //    self.selectionList = HTHorizontalSelectionList(frame: CGRectMake(0, 280, self.view.frame.size.width, selectionListHeight))
        self.selectionList = HTHorizontalSelectionList()
        self.selectionList.delegate = self
        self.selectionList.dataSource = self
        self.selectionList.translatesAutoresizingMaskIntoConstraints = false
        self.selectionList.selectionIndicatorStyle = .bottomBar
        self.selectionList.selectionIndicatorColor = UIColor.primaryColor()
        self.selectionList.setTitleColor(UIColor.primaryTextColor(), for: .normal)
        self.selectionList.bottomTrimHidden = true
        self.selectionList.centerButtons = true
        self.selectionList.layer.borderWidth = 1
        self.selectionList.layer.borderColor = UIColor.smokeWhiteColor().cgColor
        self.selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);
        
        self.selectionView.addSubview(self.selectionList)
        //     self.view.sendSubviewToBack(self.selectionList)
        //   self.view.insertSubview(self.selectionList, belowSubview: autocompleteTextfield)
        
        let widthConstraint = NSLayoutConstraint(item: selectionList, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
        
        let heightConstraint = NSLayoutConstraint(item: selectionList, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: selectionListHeight)
        
        let topConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.selectionView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0)
        /*
         let bottomConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.selectionView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10.0)
         */
        let leadingConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0)
        
        let trailingConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        /*
         let tipFieldKeyboardConstraint = NSLayoutConstraint(item: self.tipField, attribute: .Height, relatedBy: .Equal,
         toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.view.frame.size.height - keyboardHeight)
         */
        
        /*
         let collectionViewBottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
         */
        
        //     let centerXConstraint = NSLayoutConstraint(item: logoView, attribute: .CenterX, relatedBy: .Equal, toItem: self.header, attribute: .CenterX, multiplier: 1, constant: 0)
        
        //     let centerYConstraint = NSLayoutConstraint(item: logoView, attribute: .CenterY, relatedBy: .Equal, toItem: self.header, attribute: .CenterY, multiplier: 1, constant: 0)
        
        self.view.addConstraints([widthConstraint, heightConstraint, topConstraint, leadingConstraint, trailingConstraint])
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectionList.setSelectedButtonIndex(0, animated: false)
        //    self.configureProfileImage()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        navLogo.contentMode = .scaleAspectFit
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func tipFieldHeightConstraintConstant() -> CGFloat {
        switch(self.screenHeight()) {
        case 568:
            return 205
            
        case 667:
            return 300
            
        case 736:
            return 356
            
        default:
            return 205
        }
    }
    
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                print(Constants.Notifications.WiFi)
                
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    print(Constants.Notifications.NotReachable)
                    self.popUpPrompt()
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            print(Constants.Notifications.NoNotifier)
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            print(Constants.Notifications.WiFi)
        } else {
            print(Constants.Notifications.NotReachable)
            self.popUpPrompt()
        }
    }
    
    deinit {
        stopNotifier()
    }
    
    
    func popUpPrompt() {
        
        let title = Constants.NetworkConnection.NetworkPromptTitle
        let message = Constants.NetworkConnection.NetworkPromptMessage
        let cancelButtonTitle = Constants.NetworkConnection.RetryText
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            //  NSLog(Constants.Logs.CancelAlert)
        }
        
        
        // Add the actions.
        alertController.addAction(cancelAction)
        //     alertController.buttonBgColor[.Cancel] = UIColor(red: 227/255, green:19/255, blue:63/255, alpha:1)
        //     alertController.buttonBgColorHighlighted[.Cancel] = UIColor(red:230/255, green:133/255, blue:153/255, alpha:1)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    private func setupPhotoLibrary() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //    collectionView.layer.borderColor = UIColor.smokeWhiteColor().CGColor
        //    collectionView.layer.borderWidth = 1
        // Get size of the collectionView cell for thumbnail image
        //    if let layout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
        //        let cellSize = layout.itemSize
        self.assetThumbnailSize = CGSize(200, 200)
        //    }
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.loadAssets()
        }
        else { PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            if status == .authorized {
                self.loadAssets()
            } else {
                self.showNeedAccessMessage()
            }
        })
            
        }
        
    }
    
    
    private func loadAssets() {
        
        
        let imgMananager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        self.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResult!.count > 0 {
            
            for i in 0..<fetchResult!.count {
                imgMananager.requestImage(for: fetchResult!.object(at: i) , targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { image, error in
                    self.imageArray.append(image!)
                    
                })
            }
            
        }
        else {
            collectionView.reloadData()
        }
        
        
        // Sorting condition
        //      let options = PHFetchOptions()
        //      options.sortDescriptors = [
        //         NSSortDescriptor(key: "creationDate", ascending: false)
        //     ]
        
        //     photos = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        /*
         if photos!.count > 0 {
         
         collectionView.reloadData()
         collectionView.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
         }
         */
        
    }
    
    private func showNeedAccessMessage() {
        
        
        let alert = UIAlertController(title: "Info", message: "Yaknak needs to get access to your photos", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { (action: UIAlertAction) in
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func configureSaveTipButton() {
        
        self.saveTipButton.backgroundColor = UIColor.smokeWhiteColor()
        self.saveTipButton.setTitleColor(UIColor.secondaryTextColor(), for: .normal)
        self.saveTipButton.layer.cornerRadius = 5
        self.saveTipButton.isEnabled = false
    }
    
    
    
    
    
    
    
    // MARK: - Navigation
    
    func getCurrentLocationTapped() {
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
    
    
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        
        StackObserver.sharedInstance.reloadValue = 3
        
        self.loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingNotification.label.text = Constants.Notifications.LoadingNotificationText
        
        if let resizedImage = self.finalImageView.image?.resizedImage(newSize: CGSize(300, 600)) {
            
            let pictureData = UIImageJPEGRepresentation(resizedImage, 1.0)
            
            self.uploadTip(data: pictureData!)
            
        }
        
        
    }
    
    
    private func uploadTip(data: Data) {
        
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {return}
   //     let tip = Tip(category: self.selectedCategory, description: self.tipField.text, likes: 0, addedByUser: userId)
        
        let tipRef = dataService.TIP_REF.childByAutoId()
   //     tipRef.setValue(tip.toAnyObject())
        let key = tipRef.key
        
        let geoFire = GeoFire(firebaseRef: dataService.GEO_TIP_REF)
       
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.autocompleteTextfield.text!) { (placemarks: [CLPlacemark]?, error: Error?) in
            
            if error == nil {
                
                if let placemark = placemarks?.first {
                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                    
               //     self.tipLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    geoFire?.setLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), forKey: key)
                    
                    //Create Path for the User Image
                    let imagePath = "tipImage\(key)/tipImage.jpg"
                    
                    
                    // Create image Reference
                    
                    let imageRef = self.dataService.STORAGE_REF.child(imagePath)
                    
                    // Create Metadata for the image
                    
                    let metaData = FIRStorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    // Save the user Image in the Firebase Storage File
                    
                    let uploadTask = imageRef.put(data as Data, metadata: metaData) { (metaData, error) in
                        if error == nil {
                            
                            if let photoUrl = metaData?.downloadURL()?.absoluteString {
                                //   tipRef.updateChildValues(["photoUrl": photoUrl])
                                let tip = Tip(category: self.selectedCategory, description: self.tipField.text, likes: 0, addedByUser: userId, tipImageUrl: photoUrl)
                                
                                tipRef.setValue(tip.toAnyObject())
                                //    tipRef.setValue(["tipImageUrl": photoUrl])
                                
                                self.dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { snapshot in
                                    
                                    if let dictionary = snapshot.value as? [String : Any] {
                                        
                                        if let tips = dictionary["totalTips"] as? Int {
                                            var newTipCount = tips
                                            newTipCount += 1
                                            self.dataService.CURRENT_USER_REF.updateChildValues(["totalTips" : newTipCount])
                                            
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.showUploadSuccess()
                                            self.resetFields()
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                })
                                
                                
                            }
                            
                        }
                        else {
                            print(error?.localizedDescription)
                        }
                        
                    }
                    uploadTask.observe(.progress) { snapshot in
                        print(snapshot.progress) // NSProgress object
                    }
                    
                }
                
            }
            else {
                print(error?.localizedDescription)
                return
            }
        }
        
        
    }
    
    
    
    private func getLatLongFromAddress() {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(self.autocompleteTextfield.text!) { (placemarks: [CLPlacemark]?, error: Error?) in
            
            if error == nil {
                
                if let placemark = placemarks?.first {
                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    self.tipLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                }
                
            }
            else {
                print(error?.localizedDescription)
                return
            }
        }
        
    }
    
    
    private func showUploadSuccess() {
    
        self.loadingNotification.hide(animated: true)
        let alert = UIAlertController(title: Constants.Notifications.TipUploadedAlertTitle, message: Constants.Notifications.TipUploadedMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    private func resetFields() {
    
        self.autocompleteTextfield.text = nil
        self.tipField.text = nil
        self.finalImageView!.image = nil
        //    self.cancelImageIcon.removeFromSuperview()
        self.cancelImageIcon.isHidden = true
        self.collectionView.isHidden = false
        self.saveTipButton.isEnabled = false
        self.finalImageView.isHidden = true
        self.finalImageViewContainer.isHidden = true
        self.characterCountLabel.text = String(Constants.Counter.CharacterLimit)
        self.selectionList.setSelectedButtonIndex(0, animated: false)
        self.characterCountLabel.textColor = UIColor.black
       // self.tip = Tip()
        self.configureSaveTipButton()
    }
    
    // MARK: TextViewDelegates
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //    if textView.textColor == UIColor.lightGrayColor() {
        //        textView.text = nil
        //        textView.textColor = UIColor.blackColor()
        //    }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        checkRemainingChars()
        if (textView.text.isEmpty) {
            self.configureSaveTipButton()
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkValidTip()
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        //        let currentText:NSString = textView.text
        //        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        let newLength = (textView.text!.utf16.count) + (text.utf16.count) - range.length
        
        if(newLength <= Constants.Counter.CharacterLimit) {
            
            self.characterCountLabel.text = "\(Constants.Counter.CharacterLimit - newLength)"
            
            if (text == "\n") {
                textView.resignFirstResponder()
            }
            
            
            return true
        } else {
            
            if (text == "\n") {
                textView.resignFirstResponder()
            }
            
            return false
        }
    }
    
    
    
    
    // MARK: TextFieldDelegates
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveTipButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidTip()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.configureSaveTipButton()
        return true
    }
    
    
    func checkValidTip() {
        // Disable the Save button if the text field is empty.
        let text = tipField.text ?? ""
        let locationText = autocompleteTextfield.text ?? ""
        //     let cat = selectedCategory
        //     let image: UIImage = imagePreview!.image!
        //    if (self.finalImageView == nil) {
        //    self.finalImageView = UIImageView()
        //    }
        if (self.finalImageView.image != nil) {
            self.saveTipButton.isEnabled = !text.isEmpty && !locationText.isEmpty && self.finalImageView.image != nil
        }
        
        if (self.saveTipButton.isEnabled == true) {
            
            self.saveTipButton.backgroundColor = UIColor.primaryColor()
            self.saveTipButton.setTitleColor(UIColor.white, for: .normal)
            
        }
        
    }
    
    
    
    
    private func configureProfileImage() {
        
        
        dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String : Any] {
                if let photoUrl = dictionary["photoUrl"] as? String {
                    
                    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2
                    self.userProfileImage.clipsToBounds = true
                    self.userProfileImage.contentMode = .scaleAspectFill
                    self.userProfileImage.loadImageUsingCacheWithUrlString(urlString: photoUrl)
                    
                }
                
            }
            
        })
        
    }
    
    
    private func configureTextField() {
        //     autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        //     autocompleteTextfield.autoCompleteTextFont = UIFont(name: Constants.Fonts.HelvLight, size: 12.0)
        autocompleteTextfield.autoCompleteCellHeight = 50.0
        autocompleteTextfield.maximumAutoCompleteCount = 4
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.backgroundColor = UIColor.smokeWhiteColor()
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.primaryTextColor()
        attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 17.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
    }
    
    
    private func handleTextFieldInterfaces() {
        autocompleteTextfield.onTextChange = { [weak self] text in
            if !text.isEmpty {
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(keyword: text)
            }
        }
        
        autocompleteTextfield.onSelect = { [weak self] text, indexpath in
            Location.geocodeAddressString(address: text, completion: { (placemark, error) -> Void in
                if let coordinate = placemark?.location?.coordinate {
                    self?.addAnnotation(coordinate: coordinate, address: text)
                    //     self?.mapView.setCenterCoordinate(coordinate, zoomLevel: 12, animated: true)
                }
            })
        }
    }
    
    
    private func fetchAutocompletePlaces(keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)"
        let s = NSMutableCharacterSet() //create an empty mutable set
        s.formUnion(with: NSCharacterSet.urlQueryAllowed)
    //    let s = NSCharacterSet.URLQueryAllowedCharacterSet.mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = NSURL(string: encodedString) {
                let request = NSURLRequest(url: url as URL)
                dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    if let data = data {
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            
                            if let status = result["status"] as AnyObject as? String {
                                if status == "OK" {
                                    if let predictions = result["predictions"] as AnyObject as? NSArray {
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary] {
                                            locations.append(dict["description"] as! String)
                                        }
                                        DispatchQueue.main.async(execute: {
                                             self.autocompleteTextfield.autoCompleteStrings = locations
                                        })
                                       
                                        return
                                    }
                                }
                                if status == "REQUEST_DENIED" {
                                print("denied...")
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                self.autocompleteTextfield.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
    
    
    
    
    //MARK: Map Utilities
    
     private func addAnnotation(coordinate:CLLocationCoordinate2D, address:String?) {
     
     selectedPointAnnotation = MKPointAnnotation()
     selectedPointAnnotation!.coordinate = coordinate
     selectedPointAnnotation!.title = address
     }
    
    
    //MARK: Private Methods
    
    func dismissKeyboard() {
        
        self.tipField.resignFirstResponder()
        //  self.autocompleteTextfield.resignFirstResponder()
    }
    
    // MARK: Actions
    
    
    @IBAction func capturePhoto(sender: UIButton) {
        
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    
    
    //MARK: UIImagePickerDelegate
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
        self.setupFinalImage(image: chosenImage)
        
        checkValidTip()
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func noCamera() {
        
        let alertVC = UIAlertController(
            title: Constants.Notifications.NoCameraTitle,
            message: Constants.Notifications.NoCameraMessage,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: Constants.Notifications.AlertConfirmation,
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,
                animated: true,
                completion: nil)
    }
    
    
    
    func checkRemainingChars() {
        
        let allowedChars = Constants.Counter.CharacterLimit
        
        let charsInTextView = -tipField.text!.characters.count
        
        let remainingChars = allowedChars + charsInTextView
        
        
        if remainingChars <= allowedChars {
            characterCountLabel.textColor = UIColor.lightGray
        }
        
        
        if remainingChars <= 20 {
            characterCountLabel.textColor = UIColor(red: 232/255, green: 158/255, blue: 48/255, alpha: 1)
        }
        
        if remainingChars <= 15 {
            characterCountLabel.textColor = UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1)
        }
        
        if remainingChars <= 10 {
            characterCountLabel.textColor = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1)
        }
        
        if remainingChars <= 5 {
            characterCountLabel.textColor = UIColor(red: 227/255, green: 19/255, blue: 63/255, alpha: 1)
        }
        
        
        characterCountLabel.text = String(remainingChars)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if (self.layoutFinalImage == true) {
            self.setUpFinalImageEffects()
        }
    }
    
    func setupFinalImage(image: UIImage) {
        
        self.layoutFinalImage = true
        self.finalImageViewContainer.isHidden = false
        self.finalImageView.isHidden = false
        self.finalImageView.contentMode = .scaleAspectFill
        self.finalImageViewContainer.backgroundColor = UIColor.smokeWhiteColor()
        self.collectionView.isHidden = true
        
        //    if (self.finalImageView == nil) {
        //    self.finalImageView = UIImageView()
        //    }
        self.finalImageView.clipsToBounds = true
        self.finalImageView.image = image
        self.view.addSubview(self.finalImageViewContainer)
        self.view.addSubview(self.finalImageView)
        
        
        
        self.cancelImageIcon = UIButton()
        let cancelImage = UIImage(named: "cross-icon-white")
        self.cancelImageIcon.setBackgroundImage(cancelImage, for: .normal)
        self.cancelImageIcon.addTarget(self, action: #selector(cancelImageIconTapped), for: .touchUpInside)
        
        self.view.addSubview(self.cancelImageIcon)
        
        
        self.finalImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.finalImageView.translatesAutoresizingMaskIntoConstraints = false
        self.cancelImageIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let imageWidthConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: .width, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width/3)
        
        
        
        let imageHeightConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.collectionView.frame.size.height - 4)
        
        
        let imageTopConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 4.0)
        
        
        let imageBottomConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.collectionView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        /*
         let bottomConstraint = NSLayoutConstraint(item: self.selectionList, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.selectionView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10.0)
         */
        let imageXConstraint = NSLayoutConstraint(item: self.finalImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let cancelImageWidthConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: .width, relatedBy: .equal,
                                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 15)
        
        let cancelImageHeightConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: .height, relatedBy: .equal,
                                                             toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 15)
        
        let cancelImageTrailingConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.finalImageView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -8.0)
        
        let cancelImageTopConstraint = NSLayoutConstraint(item: self.cancelImageIcon, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.finalImageView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 8.0)
        
        
        
        
        let containerWidthConstraint = NSLayoutConstraint(item: self.finalImageViewContainer, attribute: .width, relatedBy: .equal,
                                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.width)
        
        let containerHeightConstraint = NSLayoutConstraint(item: self.finalImageViewContainer, attribute: .height, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.collectionView.frame.size.height)
        
        let containerBottomConstraint = NSLayoutConstraint(item: self.finalImageViewContainer, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        
        
        
        self.view.addConstraints([imageWidthConstraint, imageTopConstraint, imageBottomConstraint, imageHeightConstraint, imageXConstraint, cancelImageWidthConstraint, cancelImageHeightConstraint, cancelImageTopConstraint, cancelImageTrailingConstraint, containerWidthConstraint, containerHeightConstraint, containerBottomConstraint])
        
        
        self.checkValidTip()
        
    }
    
    
    private func setUpFinalImageEffects() {
        
        let overlay: CAGradientLayer = CAGradientLayer()
        overlay.frame = self.finalImageView.bounds
        overlay.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        self.finalImageView.layer.insertSublayer(overlay, at: 0)
        
        /*
         self.finalImageView.layer.shadowPath = UIBezierPath(rect: self.finalImageView.bounds).CGPath
         self.finalImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
         self.finalImageView.layer.shadowOpacity = 0.3
         self.finalImageView.layer.shadowRadius = 3
         self.finalImageView.layer.shadowColor = UIColor.blackColor().CGColor
         self.finalImageView.layer.masksToBounds = false
         self.finalImageView.layer.shouldRasterize = true
         
         */
        self.layoutFinalImage = false
        
        
        
    }
    
    
    func displayCurrentLocation( street: String, city: String, zip: String) {
        
        self.autocompleteTextfield.text = (street as String) + " " + (city as String) + " " + (zip as String)
        locationManager.stopUpdatingLocation()
    }
    
    
    func cancelImageIconTapped() {
        
        //   self.finalImageView.removeFromSuperview()
        //   self.cancelImageIcon.removeFromSuperview()
        self.finalImageView.isHidden = true
        self.finalImageViewContainer.isHidden = true
        self.cancelImageIcon.isHidden = true
        self.collectionView.isHidden = false
        finalImageView.image = nil
        self.configureSaveTipButton()
    }
    
    func cameraCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraReuseIdentifier, for: indexPath as IndexPath) as! CameraCell
        //   let cameraImage = UIImage(named: "camera-icon")
        //   cell.setCameraImage(cameraImage!)
        
        return cell
    }
    
    func photoCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: PhotoThumbnail = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath as IndexPath) as! PhotoThumbnail
        
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = imageArray[indexPath.row - 1]
        
        return cell
    }
    
    
}




extension AddTipViewController: HTHorizontalSelectionListDelegate {
    
    // MARK: - HTHorizontalSelectionListDelegate Protocol Methods
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, didSelectButtonWith index: Int) {
        
        // update the category for the corresponding index
        self.selectedCategory = Constants.HomeView.Categories[index]
        
        //      self.selectedFlowerView.image = self.flowers[index].image
    }
    
}


extension AddTipViewController: HTHorizontalSelectionListDataSource {
    
    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        return Constants.HomeView.Categories.count
    }
    
    func selectionList(_ selectionList: HTHorizontalSelectionList, titleForItemWith index: Int) -> String? {
        return Constants.HomeView.Categories[index]
    }
    
}


extension AddTipViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newLocation = locations.last {
            
            Location.sharedInstance.currLat = newLocation.coordinate.latitude
            Location.sharedInstance.currLong = newLocation.coordinate.longitude
            
            let geoFire = GeoFire(firebaseRef: dataService.GEO_REF)
            geoFire?.setLocation(CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude), forKey: FIRAuth.auth()?.currentUser?.uid)
            
            let location: CLLocation = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                // Address dictionary
                print(placeMark.addressDictionary)
                
                
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    print(street)
                    
                    
                    // City
                    if let city = placeMark.addressDictionary!["City"] as? NSString {
                        print(city)
                        
                        
                        // Zip code
                        if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                            print(zip)
                            
                            self.displayCurrentLocation(street: street as String, city: city as String, zip: zip as String)
                        }
                    }
                }
                
            })
            
            locationManager.stopUpdatingLocation()
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error.localizedDescription)")
        let alertVC = UIAlertController(
            title: "Info",
            message: "There is no network connection to get your current location",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: Constants.Notifications.AlertConfirmation,
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,
                animated: true,
                completion: nil)
        
    }
    
    
}


extension AddTipViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageArray.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            return self.cameraCellForIndexPath(indexPath: indexPath as NSIndexPath)
        }
        else {
            return self.photoCellForIndexPath(indexPath: indexPath as NSIndexPath)
        }
    }
    
    
}


extension AddTipViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                present(picker, animated: true, completion: nil)
            } else {
                noCamera()
            }
        }
        else {
            
            let storyboard = UIStoryboard(name: "Picker", bundle: Bundle.main)
            let showPreviewVC = { (image: UIImage!) -> Void in
                let previewVC = storyboard.instantiateViewController(withIdentifier: "ImagePickerPreviewVC") as! ImagePickerPreviewViewController
                previewVC.definesPresentationContext = true
                previewVC.modalPresentationStyle = .overCurrentContext
                previewVC.setImage(image: image)
                previewVC.delegate = self
                self.show(previewVC, sender: nil)
            }
            
            let width = self.view.bounds.width
            let height = self.view.bounds.height
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            let asset = self.fetchResult![indexPath.item - 1]
            
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width, height), contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                
                if let _image = image {
                    showPreviewVC(_image)
                }
                
            })
            
        }
        
    }
    
    
}


extension AddTipViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 2) / 3
        //    let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
}


extension AddTipViewController: ImagePickerPreviewDelegate {
    
    func imagePickerPreview(originalImage: UIImage?) {
        self.delegate?.imagePicker?(pickedImage: originalImage)
        self.dismiss(animated: true, completion: nil)
        self.setupFinalImage(image: originalImage!)
        
    }
    
}
