//
//  SingleTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 21/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit
import GeoFire
import PXGoogleDirections


class SingleTipViewController: UIViewController, PXGoogleDirectionsDelegate {
    
    
    var tip: Tip!
    let dataService = DataService()
    var style = NSMutableParagraphStyle()
    var request: PXGoogleDirections!
    var result: [PXGoogleDirectionsRoute]!
    var routeIndex: Int = 0
    
    var directionsAPI: PXGoogleDirections {
        return (UIApplication.shared.delegate as! AppDelegate).directionsAPI
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        directionsAPI.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.style.lineSpacing = 2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpUI()
    }
    
    
    func setUpUI() {
    
        if let singleTipView = Bundle.main.loadNibNamed("SingleTipView", owner: self, options: nil)![0] as? SingleTipView {
            
            if let url = tip.tipImageUrl {
                
                singleTipView.setTipImage(urlString: url, placeholder: nil, completion: { (success) in
                    
                    if success {
                        
                        self.applyGradient(view: singleTipView)
                        
                        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
                        if let key = self.tip.key {
                            geo?.getLocationForKey(key, withCallback: { (location, error) in
                                
                                if error == nil {
                                    
                                    if let lat = location?.coordinate.latitude {
                                        
                                        if let long = location?.coordinate.longitude {
                                            
                                            self.directionsAPI.from = PXLocation.coordinateLocation(CLLocationCoordinate2DMake((LocationService.sharedInstance.currentLocation?.coordinate.latitude)!, (LocationService.sharedInstance.currentLocation?.coordinate.longitude)!))
                                            self.directionsAPI.to = PXLocation.coordinateLocation(CLLocationCoordinate2DMake(lat, long))
                                            self.directionsAPI.mode = PXGoogleDirectionsMode.walking
                                            
                                            self.directionsAPI.calculateDirections { (response) -> Void in
                                                DispatchQueue.main.async(execute: {
                                                    //      })
                                                    //   dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                    switch response {
                                                    case let .error(_, error):
                                                        self.reArrangeUI(view: singleTipView)
                                                        print(error.localizedDescription)
                                                    case let .success(request, routes):
                                                        self.request = request
                                                        self.result = routes
                                                        
                                                        if let likes = self.tip.likes {
                                                            singleTipView.likes.text = String(likes)
                                                            
                                                            if likes == 1 {
                                                                singleTipView.likesLabel.text = "Like"
                                                            }
                                                            else {
                                                                singleTipView.likesLabel.text = "Likes"
                                                            }
                                                        }
                                                        
                                                        if let desc = self.tip.description {
                                                            
                                                            let attributes = [NSParagraphStyleAttributeName : self.style]
                                                            singleTipView.tipDescription?.attributedText = NSAttributedString(string: desc, attributes: attributes)
                                                            singleTipView.tipDescription.textColor = UIColor.white
                                                            singleTipView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                                                            
                                                        }
                                                        
                                                        let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                                        let ti = NSInteger(totalDuration)
                                                        let minutes = (ti / 60) % 60
                                                        
                                                        singleTipView.walkingDistance.text = String(minutes)
                                                        
                                                        if minutes == 1 {
                                                            singleTipView.distanceLabel.text = "Min"
                                                        }
                                                        else {
                                                            singleTipView.distanceLabel.text = "Mins"
                                                        }
                                                        
                                                        let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                                        print("The total distance is: \(totalDistance)")
                                                        
                                                    }
                                                })
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                else {
                                    self.reArrangeUI(view: singleTipView)
                                }
                            })
                        }
                        
                    }
                })
                
            }
            
        }
        
    }
    
    func applyGradient(view: SingleTipView) {
    
        let overlay: CAGradientLayer = CAGradientLayer()
        overlay.frame = self.view.bounds
        overlay.colors = [UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        overlay.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        //    overlay.frame = (singleTipView?.tipImage.bounds)!
        //    overlay.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        view.tipImage.layer.insertSublayer(overlay, at: 0)

        
    }
    
    
    private func reArrangeUI(view: SingleTipView) {
        
        view.likes.isHidden = true
        view.likesIcon.isHidden = true
        view.likesLabel.isHidden = true
        view.distanceLabel.isHidden = true
        view.walkingIcon.isHidden = true
        view.walkingDistance.isHidden = true
        view.tipDescription.isHidden = true
        
        if let desc = self.tip.description {
            
            let attributes = [NSParagraphStyleAttributeName : self.style]
            let tipDesc = UITextView()
            tipDesc.attributedText = NSAttributedString(string: desc, attributes: attributes)
            tipDesc.textColor = UIColor.white
            tipDesc.backgroundColor = nil
            tipDesc.isUserInteractionEnabled = false
            tipDesc.allowsEditingTextAttributes = false
            tipDesc.isEditable = false
            tipDesc.isSelectable = false
            tipDesc.font = UIFont.systemFont(ofSize: 15)
            view.addSubview(tipDesc)
            
            tipDesc.translatesAutoresizingMaskIntoConstraints = false
            
            let icon = UIImageView(frame: CGRect(0, 0, 14, 14))
            icon.image = UIImage(named: "heartLikes")
            icon.backgroundColor = UIColor.white
            icon.contentMode = .scaleAspectFill
            view.addSubview(icon)
            
            icon.translatesAutoresizingMaskIntoConstraints = false
            
            if let likes = self.tip.likes {
            
            let likesNumber = UILabel()
                likesNumber.text = String(likes)
                likesNumber.textColor = UIColor.white
                likesNumber.font = UIFont.systemFont(ofSize: 13)
                view.addSubview(likesNumber)
                
                likesNumber.translatesAutoresizingMaskIntoConstraints = false
            
            
            /*
            NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 8.0).isActive = true
            NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20.0).isActive = true
            NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 20.0).isActive = true
            NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 95.0).isActive = true
 */
            
            let descLeadingConstraint = NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 20.0)
            
            let descTrailingConstraint = NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20.0)
            
            let descBottomConstraint = NSLayoutConstraint(item: tipDesc, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 8.0)
            
            let descHeightConstraint = NSLayoutConstraint(item: tipDesc, attribute: .height, relatedBy: .equal,
                                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 95)
            
            let leadingIconConstraint = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 20.0)
            
            let widthIconConstraint = NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal,
                                                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14)
            
            let heightIconConstraint = NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal,
                                                          toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14)
            
            let bottomIconConstraint = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: tipDesc, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 12.0)
                
            let leadingLikesConstraint = NSLayoutConstraint(item: likesNumber, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 40.0)
                
            let bottomLikesConstraint = NSLayoutConstraint(item: likesNumber, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 115.0)
            
            view.addConstraints([descLeadingConstraint, descTrailingConstraint, descBottomConstraint, descHeightConstraint, leadingIconConstraint, widthIconConstraint, heightIconConstraint, bottomIconConstraint, leadingLikesConstraint, bottomLikesConstraint])
            
        }
        }
        
       
        
    }
    
    
    func showOutOfDistanceAlert(view: SingleTipView) {
        
        /*
        view.likesIcon.translatesAutoresizingMaskIntoConstraints = false
        view.likesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.tipDescription.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        let descLeadingConstraint = NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 20.0)
        
        let descTrailingConstraint = NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20.0)
        
        let descBottomConstraint = NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 8.0)
        
        let descHeightConstraint = NSLayoutConstraint(item: view.tipDescription, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 95)
        
        let leadingIconConstraint = NSLayoutConstraint(item: view.likesIcon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 20.0)
        
        let widthIconConstraint = NSLayoutConstraint(item: view.likesIcon, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14)
        
        let heightIconConstraint = NSLayoutConstraint(item: view.likesIcon, attribute: .height, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 14)
        
        let bottomIconConstraint = NSLayoutConstraint(item: view.likesIcon, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view.tipDescription, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 12.0)
        
        let leadingLikesConstraint = NSLayoutConstraint(item: view.likes, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view.likesIcon, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 4.0)
        
        let centerLikesConstraint = NSLayoutConstraint(item: view.likes, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view.likesIcon, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        
        let leadingLabelConstraint = NSLayoutConstraint(item: view.likesLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view.likes, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 2.0)
        
        let centerLabelConstraint = NSLayoutConstraint(item: view.likesLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view.likes, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraints([descLeadingConstraint, descTrailingConstraint, descBottomConstraint, descHeightConstraint, leadingIconConstraint, leadingLabelConstraint, widthIconConstraint, heightIconConstraint, bottomIconConstraint, centerLabelConstraint, leadingLikesConstraint, centerLikesConstraint])
        
 
        
        
   //     let alert = UIAlertController()
   //     alert.defaultAlert(title: "Info", message: Constants.Notifications.TipTooFarAway)
        
        
        NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 8.0).isActive = true
        NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20.0).isActive = true
        NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 20.0).isActive = true
        NSLayoutConstraint(item: view.tipDescription, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 95.0).isActive = true
        
         NSLayoutConstraint(item: view.likesIcon, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 14.0).isActive = true
        NSLayoutConstraint(item: view.likesIcon, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 14.0).isActive = true
        NSLayoutConstraint(item: view.likesIcon, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 115.0).isActive = true
        NSLayoutConstraint(item: view.likesIcon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20.0).isActive = true
        
        NSLayoutConstraint(item: view.likes, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 38.0).isActive = true
        NSLayoutConstraint(item: view.likes, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view.likesIcon, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view.likesLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view.likes, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 2.0).isActive = true
        NSLayoutConstraint(item: view.likesLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view.likes, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0.0).isActive = true
        
        */
        
    }
    
    
    func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }
    
    
    @IBAction func reportButtonTapped(_ sender: AnyObject) {
        self.popUpReportPrompt()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.removeAnimate()
    }
    
    
    private func popUpReportPrompt() {
        
        let title = Constants.Notifications.ReportMessage
        //   let message = Constants.Notifications.ShareMessage
        let cancelButtonTitle = Constants.Notifications.AlertAbort
        let okButtonTitle = Constants.Notifications.ReportTip
        //     let shareTitle = Constants.Notifications.ShareOk
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        //     let shareButton = UIAlertAction(title: shareTitle, style: .Default) { (Action) in
        //         self.showSharePopUp(self.currentTip)
        //     }
        
        let reportButton = UIAlertAction(title: okButtonTitle, style: .default) { (Action) in
            self.showReportVC(tipId: self.tip.key!)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (Action) in
            //  alertController.d
        }
        
        //     alertController.addAction(shareButton)
        alertController.addAction(reportButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    private func showReportVC(tipId: String) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportViewController
        reportVC.data = tipId
        self.show(previewVC, sender: nil)
        
        //    self.showViewController(previewVC, sender: nil)
        
    }
    
    
    
    func googleDirectionsWillSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) -> Bool {
        return true
    }
    
    func googleDirectionsDidSendRequestToAPI(_ googleDirections: PXGoogleDirections, withURL requestURL: URL) {
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveRawDataFromAPI data: Data) {
        
    }
    
    func googleDirectionsRequestDidFail(_ googleDirections: PXGoogleDirections, withError error: NSError) {
    }
    
    func googleDirections(_ googleDirections: PXGoogleDirections, didReceiveResponseFromAPI apiResponse: [PXGoogleDirectionsRoute]) {
    }
    
}
