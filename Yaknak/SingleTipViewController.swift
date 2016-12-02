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
        let singleTipView = Bundle.main.loadNibNamed("SingleTipView", owner: self, options: nil)![0] as? SingleTipView
        let attributes = [NSParagraphStyleAttributeName : style]
        singleTipView?.tipImage.loadImageUsingCacheWithUrlString(urlString: tip.getTipImageUrl())
        let likes = String(tip.getLikes())
        singleTipView?.likes.text = likes
        singleTipView?.tipDescription?.attributedText = NSAttributedString(string: tip.getDescription(), attributes: attributes)
        singleTipView?.tipDescription.textColor = UIColor.white
        singleTipView?.tipDescription.font = UIFont.systemFont(ofSize: 17)
        
        
        guard singleTipView?.tipImage.image != nil else {return}
        let overlay: CAGradientLayer = CAGradientLayer()
        overlay.frame = self.view.bounds
        overlay.colors = [UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black
            .withAlphaComponent(0.9).cgColor, UIColor.black.cgColor]
        overlay.locations = [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8]
        //    overlay.frame = (singleTipView?.tipImage.bounds)!
        //    overlay.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        singleTipView?.tipImage.layer.insertSublayer(overlay, at: 0)
        
        let geo = GeoFire(firebaseRef: self.dataService.GEO_TIP_REF)
        geo?.getLocationForKey(tip.getKey(), withCallback: { (location, error) in
            
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
                                    let alert = UIAlertController(title: Constants.Config.AppName, message: "Error: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: Constants.Notifications.AlertConfirmation, style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                case let .success(request, routes):
                                    self.request = request
                                    self.result = routes
                                    
                                    
                                    //                        for i in 0 ..< (self.result).count {
                                    //                            if i != self.routeIndex {
                                    //                                self.result[i].drawOnMap(self.mapView, strokeColor: UIColor.blueColor(), strokeWidth: 3.0)
                                    //
                                    //
                                    //                            }
                                    //
                                    //                        }
                                    let totalDuration: TimeInterval = self.result[self.routeIndex].totalDuration
                                    let ti = NSInteger(totalDuration)
                                    let minutes = (ti / 60) % 60
                                    
                                    singleTipView?.walkingDistance.text = String(minutes)
                                    let totalDistance: CLLocationDistance = self.result[self.routeIndex].totalDistance
                                    print("The total distance is: \(totalDistance)")
                                    
                                }
                            })
                        }
                        
                        
                    }
                    
                }
                
                
            }
            else {
                
                print(error?.localizedDescription)
            }
            
            
        })
        
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
        let okButtonTitle = Constants.Notifications.ReportOK
        //     let shareTitle = Constants.Notifications.ShareOk
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        //     let shareButton = UIAlertAction(title: shareTitle, style: .Default) { (Action) in
        //         self.showSharePopUp(self.currentTip)
        //     }
        
        let reportButton = UIAlertAction(title: okButtonTitle, style: .default) { (Action) in
            self.showReportVC(tip: self.tip)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (Action) in
            //  alertController.d
        }
        
        //     alertController.addAction(shareButton)
        alertController.addAction(reportButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    private func showReportVC(tip: Tip) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: Bundle.main)
        
        let previewVC = storyboard.instantiateViewController(withIdentifier: "NavReportVC") as! UINavigationController
        previewVC.definesPresentationContext = true
        previewVC.modalPresentationStyle = .overCurrentContext
        
        let reportVC = previewVC.viewControllers.first as! ReportViewController
        reportVC.data = tip
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
