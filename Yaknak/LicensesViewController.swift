//
//  LicensesViewController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 10/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import UIKit

class LicensesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var byLine: UITextView!
    
    
    struct Libs {
    
        var sectionName: String!
        var sectionContent: [String]!
        
    }
    
    var libArray = [Libs]()

    let contentOne = "Copyright (c) 2014-present, Facebook, Inc. All rights reserved. You are hereby granted a non-exclusive, worldwide, royalty-free license to use, copy, modify, and distribute this software in source code or binary form for use in connection with the web services and APIs provided by Facebook. As with any software that integrates with the Facebook platform, your use of this software is subject to the Facebook Developer Principles and Policies [http:developers.facebook.com/policy/]. This copyright notice shall beincluded in all copies or substantial portions of the software. THE SOFTWARE IS PROVIDED" + " AS IS " + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    let contentTwo = "Copyright (c) 2014-present, Facebook, Inc. All rights reserved. You are hereby granted a non-exclusive, worldwide, royalty-free license to use, copy, modify, and distribute this software in source code or binary form for use in connection with the web services and APIs provided by Facebook. As with any software that integrates with the Facebook platform, your use of this software is subject to the Facebook Developer Principles and Policies [http:developers.facebook.com/policy/]. This copyright notice shall beincluded in all copies or substantial portions of the software. THE SOFTWARE IS PROVIDED" + " AS IS " + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    let contentThree = "The MIT License (MIT)\n\nCopyright (c) 2015 Yalantis\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the " + "Software" + "), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED " + "AS IS" + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    
    let contentFour = "Copyright (c) 2009-2015 Matej Bukovinski\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the " + "Software" + "), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED " + "AS IS" + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    let contentFive = "The MIT License (MIT)\n\nCopyright (c) 2014 Hightower, Inc.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the " + "Software" + "), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nTHE SOFTWARE IS PROVIDED " + "AS IS" + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    let contentSix = "The MIT License (MIT)\n\nCopyright (c) 2016 Nguyen Vinh\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the " + "Software" + "), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED " + "AS IS" + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    
    let contentSeven = "The MIT License (MIT)\n\nCopyright (c) 2017 Wei Wang\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the " + "Software" + "), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED " + "AS IS" + ", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsSelection = false
        byLine.textContainerInset = UIEdgeInsets.zero
        byLine.textContainer.lineFragmentPadding = 0
        configureNavBar()
        
        libArray = [Libs(sectionName: "FBSDKLoginKit", sectionContent: [contentOne]), Libs(sectionName: "FBSDKCoreKit", sectionContent: [contentTwo]), Libs(sectionName: "Koloda", sectionContent: [contentThree]), Libs(sectionName: "MBProgressHUD", sectionContent: [contentFour]), Libs(sectionName: "HTHorizontalSelectionList", sectionContent: [contentFive]), Libs(sectionName: "NVActivityIndicatorView", sectionContent: [contentSix]), Libs(sectionName: "Kingfisher", sectionContent: [contentSeven])]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func configureNavBar() {
        
        if let navHeight = navigationController?.navigationBar.frame.size.height {
        let navLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: navHeight / 2))
        navLogo.contentMode = .scaleAspectFill
        let image = UIImage(named: Constants.Images.NavImage)
        navLogo.image = image
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-3.0, for: .default)
        self.navigationItem.titleView = navLogo
        self.navigationItem.setHidesBackButton(false, animated: false)
        let backImage = UIImage(named: Constants.Images.BackButton)
        
        let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.goBack))
        newBackButton.tintColor = UIColor.primaryColor()
        navigationItem.leftBarButtonItem = newBackButton
        }
        
    }
    
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libArray[section].sectionContent.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return libArray.count
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          return libArray[section].sectionName
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.smokeWhiteColor()
        header.textLabel!.textColor = UIColor.primaryTextColor()
        header.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.LicenseIdentifier, for: indexPath as IndexPath) as UITableViewCell
        cell.textLabel?.text = libArray[indexPath.section].sectionContent[indexPath.row]
        cell.textLabel?.textColor = UIColor.secondaryTextColor()
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        return cell
    }

}
