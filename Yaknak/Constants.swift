//
//  Constants.swift
//  Yaknak
//
//  Created by Sascha Melcher on 05/11/2016.
//  Copyright © 2016 Locals Labs. All rights reserved.
//

import Foundation


struct Constants {
    
    
    struct Config {
        
        static let AppName = "Yaknak"
        static let AppVersion = "Beta version"
     //   static let GoogleAPIKey = "AIzaSyBbPO458-GJjN6jF0GnxZ5RF2y8m6z9uyE"
        static let GoogleAPIKey = "AIzaSyDJoCPbv4_qdWJBgmgHfQHUN5JAYPYv_Vo"
        static let ServerAddress = "https://peaceful-earth-12863.herokuapp.com/parse/"
        static let AppId = "8YTAcM4CvhGTGEKw49v6oGwijhT3RvnFTz6hTUEo"
        static let ClientKey = "MgUU2nVHAJNCuEcfIh32G6JDIFRv2rwRN4xqPU0o"
        static let AutomCompleteString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        static let OneSignalAppId = "acdc5690-abe1-43cb-8827-db1b7273b79f"
        
        static let BASE_Url = "https://yaknak-ecc44.firebaseio.com/"
        static let USER_Url = "https://yaknak-ecc44.firebaseio.com/users"
        static let TIP_Url = "https://yaknak-ecc44.firebaseio.com/tips"
        static let GEO_Url = "https://yaknak-ecc44.firebaseio.com/geo"
        static let STORAGE_Url = "gs://yaknak-ecc44.appspot.com"
        
        
    }
    
    struct Counter {
        
        static let CharacterLimit: Int = 140
        
    }
    
    
    struct Tabs {
        
        static let NumberOfTabs = 5
        static let CenterImage = "dashboard-center"
        
    }
    
    struct Settings {
        
        static let Durations = ["5", "10", "15", "30", "45", "60"]
        
    }
    
    struct Notifications {
        
        static let LoadingNotificationText = "Please Wait"
        static let LogInNotificationText = "Logging in..."
        static let LogOutNotificationText = "Logging out..."
        static let TipUploadedMessage = "Thanks for your tip!"
        static let TipUploadedAlertTitle = "Uploaded"
        static let ReportAlertTitle = "Thank you!"
        static let ReportAlertMessage = "We will check your report as soon as possible."
        static let AlertConfirmation = "OK"
        static let AlertLogout = "Logout"
        static let AlertDelete = "Delete"
        static let AlertAbort = "Cancel"
        static let UnlikeTipMessage = "You unliked this tip."
        static let InfoWindow = "There's the tip!"
        static let DefaultAlert = "Alert"
        static let ProfileUpdateTitle = "Update"
        static let ProfileUpdateSuccess = "Profile picture successfully updated"
        static let LogOutTitle = "Logout"
        static let LogOutMessage = "Are you sure you want to logout? We hope you will come back soon."
        static let DeleteTitle = "Delete Account"
        static let DeleteMessage = "Are you sure you want to delete your account?"
        static let ShareSheetMessage = "Get you Yak on. Join me on Yaknak and lets explore on the hoof! www.yaknakapp.com/"
        static let NoCameraTitle = "No Camera"
        static let NoCameraMessage = "Sorry, this device has no camera"
        static let ReportTitle = "Options"
        static let ReportMessage = "Do you want to report this tip?"
        static let ReportOK = "Report"
        static let ReachableNotCreated = "Unable to create Reachability"
        static let NoNotifier = "Could not start reachability notifier"
        static let WiFi = "Reachable via WiFi"
        static let Cellular = "Reachable via Cellular"
        static let NotReachable = "Network not reachable"
        
    }
    
    
    struct Identifier {
        
        static let ReuseIdentifier = "cell"
        static let CategoryIdentifier = "categoryCell"
        static let LicenseIdentifier = "labelCell"
        
    }
    
    struct NibNames {
        
        static let HomeCellNib = "HomeCollectionViewCell"
        static let MainStoryboard = "Main"
        static let TipView = "CustomTipView"
        static let HomeTable = "HomeTableViewCell"
        
    }
    
    struct NetworkConnection {
        
        static let NetworkStable = "Internet Connection OK"
        static let NetworkInstable = "Internet connection FAILED"
        static let NetworkPromptTitle = "No Connection"
        static let NetworkPromptMessage = "Get in range and try this again!"
        static let RetryText = "Retry"
        
    }
    
    
    struct HomeView {
        
        static let Categories = ["Eat", "Drink", "Dance", "Free", "Coffee", "Shop", "Deals", "Outdoors", "Watch", "Special"]
        static let CategorySelection = ["Eat", "Drink", "Dance", "Free", "Coffee", "Shop", "Deals", "Outdoors", "Watch", "Special"]
        static let DefaultCategory = "Free"
        static let CategoryImages = ["eat_home", "drink_home", "dance_home", "free_home", "coffee_home", "shop_home", "deals_home", "outdoors_home", "watch_home", "special_home"]
        static let CellSpacing = 5
        static let NumberOfColums = 2
        static let EntryEverything = "Everything nearby"
        static let EntryImageName = "everything_home"
        
    }
    
    
    struct Images {
        
        
        static let NavImage = "navLogo"
        static let AppIcon = "roundedIcon"
        static let Placeholder = "imagePlaceholder"
        static let BackButton = "arrow_left"
        static let WalkthroughOne = "walkthrough-one"
        static let WalkthroughTwo = "walkthrough-two"
        static let WalkthroughThree = "walkthrough-three"
        static let WalkthroughFour = "walkthrough-four"
        
        
    }
    
    
    struct Requests {
        
        static let HTTPDeleteRequest = "DELETE"
        
    }
    
    
    
    struct Logs {
        
        
        static let UserRequestFailed = "User not found."
        static let CancelAlert = "cancel action occured."
        static let SuccessAlert = "ok action occured."
        static let TipRequestSuccess = "Successfully retrieved the tip with the related ID."
        static let TipRequestFailure = "There was a problem."
        static let TipIncrementSuccess = "Successfully incremented the like count."
        static let TipDecrementSuccess = "Successfully decremented the like count."
        static let WillSendRequestToAPI = "googleDirectionsWillSendRequestToAPI:withURL:"
        static let DidSendRequestToAPI = "googleDirectionsDidSendRequestToAPI:withURL:"
        static let DidReceiveRawDataFromAPI = "googleDirections:didReceiveRawDataFromAPI:"
        static let RequestDidFail = "googleDirectionsRequestDidFail:withError:"
        static let ReceiveResponseFromAPI = "googleDirections:didReceiveResponseFromAPI:"
        static let SettingsDeinit = "Settings deinited"
        static let SavingError = "Error while saving"
        static let ProfileSetup = "Set up user profile."
        static let ProfileAlreadySetup = "Profile is already set up."
        static let UserUploadSuccess = "User successfully uploaded."
        static let OutOfRange = "No tips in range!"
        static let TipAlreadyLiked = "You already liked this tip."
        static let SwipedLeft = "Pass tip"
        static let SwipeFlag = "Swipe flat is set"
        static let NoItems = "No Tabbar items"
        
    }
    
    
    struct Fonts {
        
    //    static let sysFont = UIFont.systemFont(ofSize: UIFont.sys)
        static let HelvLight = "HelveticaNeue-Light"
        static let HelvRegular = "HelveticaNeue"
        static let HelvBold = "HelveticaNeue-Bold"
        
    }
    
    
    struct ViewControllers {
        
        static let LoginView = "LoginViewController"
        static let TabBar = "TabBarController"
        static let MapView = "MapViewController"
        
    }
    
    struct Blocks {
        
        static let Privacy = "Yaknak is a fast and fun way to share experiences with the world. When you use our service—and any others we roll out—you’ll inevitably share some information with us. We get that that can affect your privacy. So we want to be upfront about the information we collect, how we use it, whom we share it with, and the choices we give you to control, access, and update your information. That’s why we’ve written this privacy policy. And it’s why we’ve tried to write it in a way that’s blissfully free of the legalese that often clouds these documents.\n\nInformation We Collect\n\nThere are three basic ways we collect information: Information you choose to give us. Information we get automatically when you use our services. Information we get from third parties.\n\nInformation You Choose to Give Us\n\nWhen you interact with our services, we collect the information that you choose to share with us. For example, when you set up a Yaknak account we need to collect a few important details about you: a unique username you’d like to go by (the same as your twitter name), a password, an email address. To make it easier for others to find you, we may also ask you to provide us with some additional information that will be publicly visible on our services, such as profile pictures, a name, or other useful identifying information.\n\nInformation We Get Automatically When You Use Our Services\n\nWhen you use our services, we collect information about which of those services you’ve used and how you’ve used them. We might know, for instance, that you watched a particular Live Story, saw a specific ad for a certain period of time, and sent a few Snaps to friends. Here’s a fuller explanation of the types of information we collect when you use our services:\n\nHow you interact with the services.\n\nHow you communicate with other Yaknak users, such as the time, date, sender, recipient of a message, the number of messages you exchange with your friends, which friends you exchange messages with the most, and your interactions with messages (such as when you open a message or capture a screenshot).\n\nWe collect device-specific information, such as the hardware model, operating system version, unique device identifiers, browser type, language, wireless network, and mobile network information (including the mobile phone number).\n\nWe also collect device information that will help us diagnose and troubleshoot problems in the (hopefully rare) event you experience any crash or other problem while using our services, details about how you’ve used our services device information, such as your web browser type and language access times pages viewed IP address. Pages you visited before navigating to our services cookies that may uniquely identify your device or browser.\n\nInformation We Collect from Third Parties\n\nWe may collect information that other users provide about you when they use our services. For example, if another user allows us to collect information from their device phone-book—and you’re one of that user’s contacts—we may combine the information we collect from that user’s phone-book with other information we have collected about you. We may also obtain information from other third-party sources and combine that with the information we collect through our services.\n\nHow We Use Information\n\nWhat do we do with the information we collect? The short answer is: Provide you with an amazing set of products and services that we relentlessly improve. But we do a lot more as well, such as: Develop, improve, deliver, maintain, and protect our products and services communicate with you. Monitor and analyze trends and usage. Personalize the services by, among other things, suggesting friends or profile information or providing advertisements, content, or features that match user profiles, interests, or previous activities. Enhance the safety and security of our services. Verify your identity and prevent fraud or other unauthorized or illegal activity. Use information we’ve collected from cookies and other technology to enhance the services and your experience with them.\n\nWe may also store some information locally on your device. For example, we may store information as local cache so that you can open the app and view content faster.\n\nAlthough we welcome Yaknak users from all over the world, keep in mind that no matter where you live or where you happen to use our services, you consent to us processing and transferring information in and to the United Kingdom and other countries whose data-protection and privacy laws may offer fewer protections than those in your home country.\n\nHow We Share Information\n\nWe may share information about you in the following ways:\n\nPublic information, such as your username, name, and profile pictures. Information about how you have interacted with the services, such as your Yaknak “score,” the names and details of your popular tips that you have created, and other information that will help Yaknak users understand your connections with others using the services.\n\nThe services may also contain third-party links, include third-party integration's, or be a co-branded or third-party-branded service that’s being provided jointly with or by another company. By going to those links, using the third-party integration, or using a co-branded or third-party-branded service, you may be providing information (including personal information) directly to the third party, us, or both.\n\nYou acknowledge and agree that we are not responsible for how those third parties collect or use your information. As always, we encourage you to review the privacy policies of every third-party website or service that you visit or use, including those third parties you interact with through our services.\n\nChoice and Control over Your Information\n\nWe want you to be in control of your information, so we let you update or correct most of your basic Yaknak account information by editing your account settings within the App. Occasionally we may ask you to verify your identity or provide additional information before we let you update your information. And if you later change your mind about our ongoing ability to collect information from certain sources that you have already consented to, such as your phone-book, camera, photos, or location services, you can simply revoke your consent by leaving the services.\n\nChildren\n\nWe don’t direct our Services to anyone under 13. And that’s why we do not knowingly collect personal information from anyone under 13.\n\nRevisions to the Privacy Policy\n\nWe may change this privacy policy from time to time. But when we do, we’ll let you know one way or another. Sometimes, we’ll let you know by revising the date at the top of the privacy policy that’s available on our website and mobile application. Other times, we may provide you with additional notice (such as adding a statement to our websites’ homepages or providing you with an in-app notification)."
        
        static let Terms = "We’re thrilled you’ve decided to use our products and services, all of which we refer to simply as the " + "Services." + "\n\nWe’ve drafted these Terms of Service (which we simply call the “Terms”) so that you’ll know the rules that govern our relationship with you. Although we have tried our best to strip the legalese from the Terms, there are places where these Terms may still read like a traditional contract. There’s a good reason for that: These Terms do indeed form a legally binding contract between you and Local Labs LTD. So please read them carefully. By using the Services, you agree to the Terms. Of course, if you don’t agree with them, then don’t use the Services.\n\nARBITRATION NOTICE: WE WANT TO LET YOU KNOW UP FRONT THAT THESE TERMS CONTAIN AN ARBITRATION CLAUSE A LITTLE LATER ON. EXCEPT FOR CERTAIN TYPES OF DISPUTES MENTIONED IN THAT ARBITRATION CLAUSE, YOU AND YAKNAK LABS AGREE THAT DISPUTES BETWEEN US WILL BE RESOLVED BY MANDATORY BINDING ARBITRATION, AND YOU AND YAKNAK LABS WAIVE ANY RIGHT TO PARTICIPATE IN A CLASS-ACTION LAWSUIT OR CLASS-WIDE ARBITRATION.\n\n#1.Who Can Use the Services\n\nNo one under 13 is allowed to create an account or use the Services. We or our partners may offer additional Services with additional terms that may require you to be even older to use them. So please read all terms carefully. By using the Services, you state that: You can form a binding contract with Yaknak—meaning that if you’re between 13 and 17, your parent or legal guardian has reviewed and agreed to these Terms; You are not a person who is barred from receiving the Services under the laws of the United Kingdom or any other applicable jurisdiction—meaning that you do not appear on the U.K or U.S. Treasury Department’s list of Specially Designated Nationals or face any other similar prohibition; and you will comply with these Terms and all applicable local, state, national, and international laws, rules, and regulations. If you are using the Services on behalf of a business or some other entity, you state that you are authorized to grant all licenses set forth in these Terms and to agree to these Terms on behalf of the business or entity.\n\n#2. Your Content\n\nMany of our Services let you create, upload, post, send, receive, and store content. When you do that, you retain whatever ownership rights in that content you had to begin with. But you grant Yaknak Labs LTD a worldwide, perpetual, royalty-free, sublicensable, and transferable license to host, store, use, display, reproduce, modify, adapt, edit, publish, create derivative works from, publicly perform, broadcast, distribute, syndicate, promote, exhibit, and publicly display that content in any form and in any and all media or distribution methods (now known or later developed). We will use this license for the limited purpose of operating, developing, providing, promoting, and improving the Services; researching and developing new ones; and making content submitted through the Services available to our business partners for syndication, broadcast, distribution, or publication outside the Services. Some Services offer you tools to control who can—and cannot—see your content under this license. For more information about how to tailor who can watch your content, please take a look at our privacy policy and support site.\n\nTo the extent it’s necessary, you also grant Yaknak Labs LTD and our business partners the unrestricted, worldwide, perpetual right and license to use your name, likeness, and voice in any and all media and distribution channels (now known or later developed) in connection with any Live Story or other crowd-sourced content you create, upload, post, send, or appear in. This means, among other things, that you will not be entitled to any compensation from Yaknak or our business partners if your name, likeness, or voice is conveyed through the Services.\n\nWhile we’re not required to do so, we may access, review, screen, and delete your content at any time and for any reason, including if we think your content violates these Terms. You alone though remain responsible for the content you create, post, store, or send through the Services. We always love to hear from our users. But if you volunteer feedback or suggestions, just know that we can use your ideas without compensating you.\n\n#3. The Content of Others\n\nMuch of the content on our Services is produced by users, publishers, and other third parties. Whether that content is posted publicly or sent privately, the content is the sole responsibility of the person or organization that created it. Although Yaknak reserves the right to review all content that appears on the Services and to remove any content that violates these Terms, we do not necessarily review all of it. So we cannot—and do not—take responsibility for any content that others provide through the Services. Through these Terms, we make clear that we do not want the Services put to bad uses. But because we do not review all content, we cannot guarantee that content on the Services will always conform to our Terms or Guidelines.\n\n#4. Respecting Other People’s Rights\n\nYaknak respects the rights of others. And so should you. You therefore may not post or send content that: For example if you are uploading a tip about a local pizzeria you may not use a stock image of a pizza not created in this pizzeria. You must also respect Yaknak rights. These Terms do not grant you any right to use branding, logos, designs, photographs, videos, or any other materials used in our Services. Nor may you download, distribute, syndicate, broadcast, perform, or display any portion of the Services except as set forth in these Terms. In short: You may not use the Services in ways that are not authorized by these Terms.\n\n#5. Respecting Copyright\n\nYaknak honors the requirements set forth in the Digital Millennium Copyright Act. We therefore take reasonable steps to expeditiously remove from our Services any infringing material that we become aware of. And if Yaknak becomes aware that one of its users has repeatedly infringed copyrights, we will take reasonable steps within our power to terminate the user’s account. We make it easy for you to report suspected copyright infringement. If you believe that anything on the Services infringes a copyright that you own or control, please send us an email at hugo.winn@hotmailc.om. If you file a notice with our Copyright Agent, it must comply with the requirements set forth at 17 U.S.C. § 512©(3). That means the notice must: Contain the physical or electronic signature of a person authorized to act on behalf of the copyright owner; identify the copyrighted work claimed to have been infringed; identify the material that is claimed to be infringing or to be the subject of infringing activity and that is to be removed, or access to which is to be disabled, and information reasonably sufficient to let us locate the material; provide your contact information, including your address, telephone number, and an email address; provide a personal statement that you have a good-faith belief that the use of the material in the manner complained of is not authorized by the copyright owner, its agent, or the law; and provide a statement that the information in the notification is accurate and, under penalty of perjury, that you are authorized to act on behalf of the copyright owner.\n\n#6. Safety\n\nWe try hard to keep our Services a safe place for all users. But we can’t guarantee it. That’s where you come in. By using the Services, you agree that: You will not use the Services for any purpose that is illegal or prohibited in these Terms; You will not use any robot, spider, crawler, scraper, or other automated means or interface to access the Services or extract other user’s information; You will not use or develop any third-party applications that interact with other users’ content or the Services without our written consent; You will not use the Services in a way that could interfere with, disrupt, negatively affect, or inhibit other users from fully enjoying the Services, or that could damage, disable, overburden, or impair the functioning of the Services;\n\nYou will not use or attempt to use another user’s account, username, or password without their permission; You will not solicit login credentials from another user; You will not post content that contains pornography, graphic violence, threats, hate speech, or incitements to violence; You will not upload viruses or other malicious code or otherwise compromise the security of the Services; You will not attempt to circumvent any content-filtering techniques we employ, or attempt to access areas or features of the Services that you are not authorized to access; You will not probe, scan, or test the vulnerability of our Services or any system or network; and You will not encourage or promote any activity that violates these Terms. We also care about your safety while using our Services. So do not use our Services in a way that would distract you from obeying traffic or safety laws. And never put yourself or others in harm’s way just to capture a Snap.\n\n#7. Your Account\n\nYou are responsible for any activity that occurs in your account. So it’s important that you keep your account secure. Yaknak uses Facebook login so the security of your account is determinant on the security of your profiles you hold with these third party. By using the Services, you agree that, in addition to exercising common sense: You will not create another account if we have already disabled your account, unless you have our written permission to do so; You will not buy, sell, rent, or lease access to your Yaknak account, of offer to write a Tip for money or any other kind of reward; You will not share your password; and If you think that someone has gained access to your account, please immediately reach out to us on hugo.winn@hotmail.com.\n\n#8. In-App Purchases and Payments\n\nWe may offer various virtual goods and services (all of which we call “Products”) that you can purchase and use through the Services. You don’t own these Products; instead you buy a limited revocable license to use them. You’ll always be shown the price for any Product before you complete the purchase. But Yaknak does not handle payments or payment processing for in-app purchases; those are handled by the app store you use (such as Apple’s App Store or Google’s Play Store). The app store you use may charge you sales tax, depending on where you live. Please check the app store’s relevant terms for details.\n\nAll in-app sales are final and non-refundable. And because our performance begins once you tap “Buy” and we give you immediate access to your purchase, you waive any right you may have under EU or other local law to cancel your purchase once it’s completed or to get a refund. BY ACCEPTING THESE TERMS, YOU AGREE THAT YAKNAK IS NOT REQUIRED TO PROVIDE A REFUND FOR ANY REASON.\n\nSome of the Products we offer are for one-time use only, while others are for repeated use. But please note that “repeated” does not mean “forever.” We may change, modify, or eliminate Products at any time, with or without notice. You agree that we will bear no liability to you or any third party if we do so. If we suspend or terminate your account, you will lose any Products you purchased through the Services.\n\nIt’s your sole responsibility to manage your in-app purchases. For information about how to restrict in-app purchases on your device, please consult your app store’s terms. If you are under 18, you must obtain your parent’s or guardian’s consent before making any purchases.\n\n#9. Your License\n\nYaknak grants you a personal, worldwide, royalty-free, non-assignable, nonexclusive, revocable, and non-sublicensable license to access and use the Services. This license is for the sole purpose of letting you use and enjoy the Service’s benefits in a way that these Terms allow. Any software that we provide you may automatically download and install upgrades, updates, or other new features. You may be able to adjust these automatic downloads through your device’s settings. You may not copy, modify, distribute, sell, or lease any part of our Services, nor may you reverse engineer or attempt to extract the source code of that software, unless applicable laws prohibit these restrictions or you have our written permission to do so.\n\n#10. Data Charges and Mobile Phones\n\nYou are responsible for any mobile charges that you may incur for using our Services, including text-messaging and data charges. If you’re unsure what those charges may be, you should ask your service provider before using the Services. If you change or deactivate the mobile phone number that you used to create a Yaknak account, you must update your account information through Settings within 72 hours to prevent us from sending to someone else messages intended for you.\n\n#11. Third-Party Services\n\nIf you use a service, feature, or functionality that is operated by a third party and made available through our Services (including Services we jointly offer with the third party), each party’s terms will govern the respective party’s relationship with you. Yaknak is not responsible or liable for those third party’s terms or actions taken under the third party’s terms.\n\n#12. Modifying the Services and Termination\n\nWe’re relentlessly improving our Services and creating new ones all the time. That means we may add or remove features or functionalities, and we may also suspend or stop the Services altogether. We may take any of these actions at any time, and when we do, we may not provide you with any notice beforehand. While we hope you remain a life long Yaknak user, you can terminate these Terms at any time and for any reason by deleting your account or uninstalling the app from your device. Yaknak may also terminate these Terms with you at any time, for any reason, and without advance notice. That means that we may stop providing you with any Services, or impose new or additional limits on your ability to use the Services. For example, we may deactivate your account due to prolonged inactivity, and we may reclaim your username at any time for any reason. Regardless of who terminates these Terms, both you and Yaknak continue to be bound by Sections 2, 5, 9, 13-21 of the Terms.\n\n#13. Indemnity\n\nYou agree to indemnify, defend, and hold harmless Yaknak, our managing members, shareholders, employees, affiliates, licensors, and suppliers from and against any and all complaints, charges, claims, damages, losses, costs, liabilities, and expenses (including attorneys’ fees) due to, arising out of, or relating in any way to: (a) your access to or use of the Services; (b) your content; and © your breach of these Terms. If you are agreeing to these Terms on behalf of a business or other entity, this indemnity obligation applies to that business or other entity.\n\n#14. Disclaimers\n\nWe try to keep the Services up and running and free of annoyances. But we make no promises that we will succeed.\n\nTHE SERVICES ARE PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. IN ADDITION, WHILE YAKNAK ATTEMPTS TO PROVIDE A GOOD USER EXPERIENCE, WE DO NOT REPRESENT OR WARRANT THAT: (A) THE SERVICES WILL ALWAYS BE SECURE, ERROR-FREE, OR TIMELY; (B) THE SERVICES WILL ALWAYS FUNCTION WITHOUT DELAYS, DISRUPTIONS, OR IMPERFECTIONS; OR © THAT ANY YAKNAK CONTENT, USER CONTENT, OR INFORMATION YOU OBTAIN ON OR THROUGH THE SERVICES WILL BE TIMELY OR ACCURATE.\n\nYAKNAK TAKES NO RESPONSIBILITY AND ASSUMES NO LIABILITY FOR ANY CONTENT THAT YOU, ANOTHER USER, OR A THIRD PARTY CREATES, UPLOADS, POSTS, SENDS, RECEIVES, OR STORES ON OR THROUGH OUR SERVICES. YOU UNDERSTAND AND AGREE THAT YOU MAY BE EXPOSED TO CONTENT THAT MIGHT BE OFFENSIVE, ILLEGAL, MISLEADING, OR OTHERWISE INAPPROPRIATE, NONE OF WHICH YAKNAK WILL BE RESPONSIBLE FOR.\n\n#15. Limitation of Liability\n\nTO THE MAXIMUM EXTENT PERMITTED BY LAW, YAKNAK AND OUR MANAGING MEMBERS, SHAREHOLDERS, EMPLOYEES, AFFILIATES, LICENSORS, AND SUPPLIERS WILL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM: (A) YOUR ACCESS TO OR USE OF OR INABILITY TO ACCESS OR USE THE SERVICES; (B) THE CONDUCT OR CONTENT OF OTHER USERS OR THIRD PARTIES ON THE SERVICES; OR © UNAUTHORIZED ACCESS, USE, OR ALTERATION OF YOUR CONTENT OR POSTS, EVEN IF YAKNAK HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. IN NO EVENT WILL YAKNAK AGGREGATE LIABILITY FOR ALL CLAIMS RELATING TO THE SERVICES EXCEED THE GREATER OF £100 USD OR THE AMOUNT YOU PAID YAKNAK, IF ANY, IN THE LAST 12 MONTHS. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES, SO SOME OR ALL OF THE EXCLUSIONS AND LIMITATIONS IN THIS SECTION MAY NOT APPLY TO YOU.\n\n#16. Arbitration, Class Waiver, and Jury Waiver\n\nPLEASE READ THE FOLLOWING PARAGRAPHS CAREFULLY BECAUSE THEY REQUIRE YOU TO ARBITRATE DISPUTES WITH YAKNAK, AND LIMIT THE MANNER IN WHICH YOU CAN SEEK RELIEF FROM US.\n\nApplicability of Arbitration Agreement. All claims and disputes arising out of, relating to, or in connection with the Terms or the use the Services that cannot be resolved informally or in small claims court will be resolved by binding arbitration on an individual basis, except that you and Yaknak are not required to arbitrate any dispute in which either party seeks equitable relief for the alleged unlawful use of copyrights, trademarks, trade names, logos, trade secrets, or patents.\n\nWaiver of Jury Trial. YOU AND YAKNAK WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO GO TO COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY.\n\nYou and Yaknak are instead electing to have all claims and disputes resolved by arbitration. Arbitration procedures are typically more limited, more efficient, and less costly than rules applicable in court and are subject to very limited review by a court. If any litigation should arise between you and Yaknak over whether to vacate or enforce an arbitration award or otherwise, YOU AND YAKNAK WAIVE ALL RIGHTS TO A JURY TRIAL, instead electing that the dispute be resolved by a judge.\n\nWaiver of Class or Consolidated Actions. ALL CLAIMS AND DISPUTES WITHIN THE SCOPE OF THIS ARBITRATION AGREEMENT MUST BE ARBITRATED OR LITIGATED ON AN INDIVIDUAL BASIS AND NOT ON A CLASS BASIS, AND CLAIMS OF MORE THAN ONE CUSTOMER OR USER CANNOT BE ARBITRATED OR LITIGATED JOINTLY OR CONSOLIDATED WITH THOSE OF ANY OTHER CUSTOMER OR USER. If, however, this waiver of class or consolidated actions is deemed invalid or unenforceable, neither you nor we are entitled to arbitration and instead all claims and disputes will be resolved in a court as set forth in Section 18.\n\nConfidentiality. No part of the procedures will be open to the public or the media. All evidence discovered or submitted at the hearing is confidential and may not be disclosed, except by written agreement of the parties, pursuant to court order, or unless required by law. Notwithstanding the foregoing, no party will be prevented from submitting to a court of law any information needed to enforce this arbitration agreement, to enforce an arbitration award, or to seek injunctive or equitable relief.\n\nRight to Waive. Any rights and limitations set forth in this arbitration agreement may be waived by the party against whom the claim is asserted. Such waiver will not waive or affect any other portion of this arbitration agreement. Small Claims Court. Notwithstanding the foregoing, either you or Yaknak may bring an individual action in small claims court.\n\nArbitration Agreement Survival. This arbitration agreement will survive the termination of your relationship with Yaknak.\n\n#17. Forum and Venue\n\nTo the extent the parties are permitted under these Terms to initiate litigation in a court, both you and Yaknak agree that all claims and disputes in connection with the Terms or the use of the Services will be litigated exclusively in the United Kingdom. If, however, that court would lack original jurisdiction over the litigation, then all claims and disputes in connection with the Terms or the use of the Services may be litigated elsewhere. You and Yaknak consent to the personal jurisdiction of both courts.\n\n#18. Choice of Law\n\nThe laws of the United Kingdom, other than its conflict-of-laws principles, will govern all disputes between you and Yaknak.\n\n#19. Severability\n\nIf any provision of these Terms is found unenforceable, then that provision will be severed from these Terms and not affect the validity and enforceability of any remaining provisions.\n\n#20. Final Terms\n\nThese Terms make up the entire agreement between you and Yaknak, and supersede any prior agreements. These Terms do no create or confer any third-party beneficiary rights. If we do not enforce a provision in these Terms, it will not be considered a waiver. We reserve all rights not expressly granted to you.\n\n#21.Contact Us\n\nYaknak Labs LTD is registered in the United Kingdom at 3 Western Terrace, Chiswick Mall London W69TX. Email us on hugo.winn@hotmail.com"
        
    }
    
    
    static let AWParsePostsClassName = "Posts"
    static let AWParsePostTextKey = "text"
    static let AWParsePostUserKey = "user"
    static let AWParsePostLocationKey = "location"
    static let AWParsePostUsernameKey = "username"
    static let AWParsePostNameKey = "name"
    
    static let kAWFilterDistanceKey = "filterDistance"
    static let kAWLocationKey = "location"
    
    static let AWFilterDistanceDidChangeNotification = "AWFilterDistanceDidChangeNotification"
    static let AWCurrentLocationDidChangeNotification = "AWCurrentLocationDidChangeNotification"
    static let AWPostCreatedNotification = "AWPostCreatedNotification"
    
    static let kAWWAllCantViewPost = "Can't view post! Get closer."
    static let AWUserDefaultsFilterDistanceKey = "filterDisance"
    
    static func feetToMeters(feet: Double) -> Double {
        return feet * 0.3048
    }
    static func metersToFeet(meters: Double) -> Double {
        return meters * 3.281
    }
    static func metersToKilometers(meters: Double) -> Double {
        return meters / 1000.0
    }
    static let AWDefaultFilterDistance = 1000.0
    static let AWWallPostMaximumSearchDistance = 100.0 //in kilos
    static let AWWallPostsSearchDefaultLimit: Int = 20
    static let AWWallPostsSearchDefaultLimitUInt: UInt = 20
}
