//
//  EditTipViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 24/04/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class EditTipViewController: UITableViewController {
    
    
    @IBOutlet weak var tipPicture: UIImageView!
    @IBOutlet weak var tipDescription: PlaceholderTextView!
    var tip: Tip!


    override func viewDidLoad() {
        super.viewDidLoad()

       self.loadTipPicture()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadTipPicture() {
        
        guard tip != nil else {return}
    
        if let tipPicUrl = tip.tipImageUrl {
            
            if let tipDesc = tip.description {
            
            if let url = URL(string: tipPicUrl) {
                
                tipPicture.kf.indicatorType = .activity
                let processor = RoundCornerImageProcessor(cornerRadius: 20) >> ResizingImageProcessor(targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill)
                tipPicture.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)], progressBlock: { (receivedSize, totalSize) in
                    print("Progress: \(receivedSize)/\(totalSize)")
                    
                }, completionHandler: { (image, error, cacheType, imageUrl) in
                    
                    /*
                     if index == 0 {
                     self.deInitLoader()
                     }
                     */
                    
                    if (image == nil) {
                        self.tipPicture.image = UIImage(named: Constants.Images.TipImagePlaceHolder)
                    }
                    
                    self.tipPicture.layer.cornerRadius = self.tipPicture.frame.size.width / 2
                    self.tipPicture.contentMode = .scaleAspectFill
                    self.tipPicture.clipsToBounds = true
                    //    self.applyGradient(tipView: tipView)
                    
                    //       view.tipImageViewHeightConstraint.setMultiplier(multiplier: self.tipImageViewHeightConstraintMultiplier())
                    self.tipDescription.text = tipDesc
                    self.tipDescription.textColor = UIColor.primaryTextColor()
                    self.tipDescription.font = UIFont.systemFont(ofSize: 15)
                    self.tipDescription.textContainer.lineFragmentPadding = 0
                    })
                
                }
        }
    }
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
    }
    
    
    @IBAction func changeTapped(_ sender: Any) {
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
   
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            let cellIdentifier = "selectionListCell"
         //   var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
         //   if cell == nil{
                let cell: SelectionListCell = SelectionListCell(style:UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
                cell.setTipCategory(tip.category)
        //    }
    
      //  cell.setCell(self.items[indexPath.row])
        return cell
        }
        else {
            let cell: UITableViewCell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"cell")
            //  cell.setCell(self.items[indexPath.row])
            return cell
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
