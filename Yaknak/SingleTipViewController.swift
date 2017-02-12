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
        
        if let url = tip.tipImageUrl {
            
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
                                        
                                        switch response {
                                        case let .error(_, error):
                                            
                                            self.showNoDistanceView(url: url)
                                            print(error.localizedDescription)
                                            
                                        case let .success(request, routes):
                                            
                                            self.request = request
                                            self.result = routes
                                            
                                            let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                         //   let ti = NSInteger(totalDuration)
                                            let minutes = LocationService.sharedInstance.minutesFromTimeInterval(interval: totalDuration)
                                            
                                            if (minutes <= 60) {
                                             self.showTipView(url: url, minutes: minutes)
                                            }
                                            else {
                                           self.showNoDistanceView(url: url)
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
                        self.showNoDistanceView(url: url)
                    }
                })
            }
        }
    }
    
    
    private func showTipView(url: String, minutes: Int) {
        
        if let singleTipView = Bundle.main.loadNibNamed("SingleTipView", owner: self, options: nil)![0] as? SingleTipView {
            
            singleTipView.setTipImage(urlString: url, placeholder: nil, completion: { (success) in
                
                if success {
                    self.applyTipViewGradient(view: singleTipView)
                    
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
                    
                    singleTipView.walkingDistance.text = String(minutes)
                    
                    if minutes == 1 {
                        singleTipView.distanceLabel.text = "Min"
                    }
                    else {
                        singleTipView.distanceLabel.text = "Mins"
                    }
                }
                else {
                    print("Test...")
                }
            })
            
        }
    }
    
    
    private func applyTipViewGradient(view: SingleTipView) {
        
        let overlay: CAGradientLayer = CAGradientLayer()
        overlay.frame = self.view.bounds
        overlay.colors = [UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        overlay.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        view.tipImage.layer.insertSublayer(overlay, at: 0)
        
        
    }
    
    
    private func showNoDistanceView(url: String) {
        
        if let noDistanceView = Bundle.main.loadNibNamed("NoDistanceTipView", owner: self, options: nil)![0] as? NoDistanceTipView {
            
            noDistanceView.setTipImage(urlString: url, placeholder: nil, completion: { (success) in
                
                if success {
                    self.applyNoDistanceViewGradient(view: noDistanceView)
                    
                    if let likes = self.tip.likes {
                        noDistanceView.likesNumber.text = String(likes)
                        
                        if likes == 1 {
                            noDistanceView.likesLabel.text = "Like"
                        }
                        else {
                            noDistanceView.likesLabel.text = "Likes"
                        }
                    }
                    
                    if let desc = self.tip.description {
                        
                        let attributes = [NSParagraphStyleAttributeName : self.style]
                        noDistanceView.tipDescription?.attributedText = NSAttributedString(string: desc, attributes: attributes)
                        noDistanceView.tipDescription.textColor = UIColor.white
                        noDistanceView.tipDescription.font = UIFont.systemFont(ofSize: 15)
                        
                    }
                }
                else {
                    print("Test...")
                }
            })
            
        }
        
    }
    
    func applyNoDistanceViewGradient(view: NoDistanceTipView) {
        
        let overlay: CAGradientLayer = CAGradientLayer()
        overlay.frame = self.view.bounds
        overlay.colors = [UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        overlay.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        view.tipImage.layer.insertSublayer(overlay, at: 0)
        
        
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
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.removeAnimate()
    }
    
    
    @IBAction func reportTapped(_ sender: Any) {
        self.popUpReportPrompt()
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
