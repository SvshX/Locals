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
        static let GoogleAPIKey = "AIzaSyBbPO458-GJjN6jF0GnxZ5RF2y8m6z9uyE"
     //   static let GoogleAPIKey = "AIzaSyDJoCPbv4_qdWJBgmgHfQHUN5JAYPYv_Vo"
        static let ServerAddress = "https://peaceful-earth-12863.herokuapp.com/parse/"
        static let AppId = "8YTAcM4CvhGTGEKw49v6oGwijhT3RvnFTz6hTUEo"
        static let ClientKey = "MgUU2nVHAJNCuEcfIh32G6JDIFRv2rwRN4xqPU0o"
        static let AutomCompleteString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        static let OneSignalAppId = "acdc5690-abe1-43cb-8827-db1b7273b79f"
        
        static let BASE_Url = "https://yaknak-ecc44.firebaseio.com/"
        static let USER_Url = "https://yaknak-ecc44.firebaseio.com/users"
        static let TIP_Url = "https://yaknak-ecc44.firebaseio.com/tips"
        static let CATEGORY_Url = "https://yaknak-ecc44.firebaseio.com/categories"
        static let USER_TIPS_Url = "https://yaknak-ecc44.firebaseio.com/userTips"
        static let GEO_Url = "https://yaknak-ecc44.firebaseio.com/geo"
        static let GEO_TIP_Url = "https://yaknak-ecc44.firebaseio.com/geo/tipLocation"
        static let GEO_USER_Url = "https://yaknak-ecc44.firebaseio.com/geo/userLocation"
        static let STORAGE_Url = "gs://yaknak-ecc44.appspot.com"
        static let STORAGE_PROFILE_IMAGE_Url = "gs://yaknak-ecc44.appspot.com/profileImage"
        static let STORAGE_TIP_IMAGE_Url = "gs://yaknak-ecc44.appspot.com/tipImage"
        
        
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
        static let DefaultCategory = "Eat"
        static let CategoryImages = ["eat_home", "drink_home", "dance_home", "free_home", "coffee_home", "shop_home", "deals_home", "outdoors_home", "watch_home", "special_home"]
        static let CellSpacing = 5
        static let NumberOfColums = 2
        static let EntryEverything = "Everything"
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
        
        static let Privacy = "Your privacy matters!\nYaknak is a fast and fun way to share experiences with your friends and the world around you. When you use these services — and any others we at Yaknak roll out, whether in the Yaknak app or elsewhere — you'll share some information with us. We get that that can affect your privacy. So we want to be upfront about the information we collect, how we use it, whom we share it with, and the choices we give you to control, access, and update your information. That's why we've written this Privacy Policy. And it's why we’ve tried to write it in a way that's blissfully free of the legalese that often clouds these documents. Of course, if you still have questions about anything in our Privacy Policy, just contact us at hugo.winn@hotmail.com. One final point before we dive in: We're happy to report that we participate in the EU-U.S. Privacy Shield.\n\nINFORMATION WE COLLECT\n\nThere are three basic categories of information we collect:\nInformation you choose to give us.\nInformation we get when you use our services.\nInformation we get from third parties.\n\nHere's a little more detail on each of these categories.\n\nINFORMATION YOU CHOOSE TO GIVE US\n\nWhen you interact with our services, we collect the information that you choose to share with us. For example, most of our services require you to set up a basic Yaknak account, so we need to collect a few important details about you, such as: a unique username you'd like to go by, a password, an email address, a phone number, and your date of birth. To make it easier for others to find you, we may also ask you to provide us with some additional information that will be publicly visible on our services, such as profile pictures, a name, or other useful identifying information. Other services, such as commerce products, may also require you to provide us with a debit or credit card number and its associated account information. It probably goes without saying, but we'll say it anyway: When you contact Yaknak Support or communicate with us in any other way, we'll collect whatever information you volunteer.\n\nINFORMATION WE GET WHEN YOU USE OUR SERVICES\n\nWhen you use our services, we collect information about which of those services you've used and how you've used them. We might know.\n\nUsage Information. We collect information about your activity through our services.\nContent Information. We collect information about the content you provide, such as whether your Tip information has viewed the content and the metadata that is provided with the content.\nDevice Information. We collect device-specific information, such as the hardware model, operating system version, advertising identifier, unique application identifiers, unique device identifiers, browser type, language, wireless network, and mobile network information (including the mobile phone number).\nDevice Phonebook. Because Yaknak is all about communicating with friends, we may — with your consent — collect information from your device’s phonebook.\nCamera and Photos. Many of our services require us to collect images and other information from your device’s camera and photos.\nLocation Information. When you use our services we may collect information about your location. With your consent, we may also collect information about your precise location using methods that include GPS, wireless networks, cell towers, Wi-Fi access points, and other sensors, such as gyroscopes, accelerometers, and compasses.\nInformation Collected by Cookies and Other Technologies. Like most online services and mobile applications, we may use cookies and other technologies, such as web beacons, web storage, and unique advertising identifiers, to collect information about your activity, browser, and device. We may also use these technologies to collect information when you interact with services we offer through one of our partners, such as commerce features. Most web browsers are set to accept cookies by default. If you prefer, you can usually remove or reject browser cookies through the settings on your browser or device. Keep in mind, though, that removing or rejecting cookies could affect the availability and functionality of our services.\nLog Information. We also collect log information when you use our website. That information includes, among other things:\n\ndetails about how you've used our services.\ndevice information, such as your web browser type and language.\naccess times.\npages viewed.\nIP address.\nidentifiers associated with cookies or other technologies that may uniquely identify your device or browser.\npages you visited before or after navigating to our website.\n\nINFORMATION WE COLLECT FROM THIRD PARTIES\n\nWe may collect information that other users provide about you when they use our services. For example, if another user allows us to collect information from their device phonebook—and you're one of that user's contacts—we may combine the information we collect from that user’s phonebook with other information we have collected about you. We may also obtain information from other companies that are owned or operated by us, or any other third-party sources, and combine that with the information we collect through our services.\n\nHow We Use Information\n\nWhat do we do with the information we collect? The short answer is: Provide you with an amazing set of products and services that we relentlessly improve. Here are some of the ways we do that:\n\ndevelop, operate, improve, deliver, maintain, and protect our products and services.communicate with you.monitor and analyze trends and usage.\npersonalize the services by, among other things, suggesting friends or profile information, or customizing the content we show you, including ads.\ncontextualize your experience by, among other things, tagging your Memories content using your precise location data (if, of course, you’ve consented to us collecting that data) and applying other labels based on the content.\nimprove ad targeting and measurement, including through the use of your precise location data (again, if you've consented to us collecting that data). See the 'Control Over Your Information' section below for more information about Locals Labs LTD.'s advertising practices and your choices.\nenhance the safety and security of our products and services.\nverify your identity and prevent fraud or other unauthorized or illegal activity.\nuse information we've collected from cookies and other technology to enhance the services and your experience with them.\nenforce our Terms of Service and other usage policies.\nWe may also store some information locally on your device. For example, we may store information as local cache so that you can open the app and view content faster.\n\nHow We Share Information\n\nWe may share information about you in the following ways:\nWith our affiliates. We may share information with entities within the Local Labs LTD. family of companies.\nWith third parties. We may share your information with the following third parties:\nWith service providers, sellers, and partners. We may share information about you with service providers who perform services on our behalf, sellers that provide goods through our services, and business partners that provide services and functionality.\nWith third parties for legal reasons. We may share information about you if we reasonably believe that disclosing the information is needed to:\ncomply with any valid legal process, governmental request, or applicable law, rule, or regulation.\ninvestigate, remedy, or enforce potential Terms of Service violations.\nprotect the rights, property, and safety of us, our users, or others.\ndetect and resolve any fraud or security concerns.\nWith third parties as part of a merger or acquisition. If Local Labs LTD. gets involved in a merger, asset sale, financing, liquidation or bankruptcy, or acquisition of all or some portion of our business to another company, we may share your information with that company before and after the transaction closes.\nIn the aggregate or after de-identification. We may also share with third parties, such as advertisers, aggregated or de-identified information that cannot reasonably be used to identify you.\n\nINFORMATION YOU CHOOSE TO SHARE WITH THIRD PARTIES\n\nThe services may also contain third-party links and search results, include third-party integrations, or offer a co-branded or third-party-branded service. By going to those links, using the third-party integration, or using a co-branded or third-party-branded service, you may be providing information (including personal information) directly to the third party, us, or both. You acknowledge and agree that we are not responsible for how those third parties collect or use your information. As always, we encourage you to review the privacy policies of every third-party website or service that you visit or use, including those third parties you interact with through our services.\n\nControl over Your Information\n\nWe want you to be in control of your information, so we provide you with the following tools.\nAccess and Updates. We strive to let you access and update most of the personal information that we have about you. There are limits though to the requests we'll accommodate. We may reject a request for a number of reasons, including, for example, that the request risks the privacy of other users, requires technical efforts that are disproportionate to the request, is repetitive, or is unlawful. You can access and update most of your basic account information right in the app by visiting the app's Settings page. Because your privacy is important to us, we may ask you to verify your identity or provide additional information before we let you access or update your personal information. We will try to update and access your information for free, but if it would require a disproportionate effort on our part, we may charge a fee. We will of course disclose the fee before we comply with your request.\nRevoking Permissions. If you change your mind about our ongoing ability to collect information from certain sources that you have already consented to, such as your phonebook or location services, you can simply revoke your consent by changing the settings on your device if your device offers those options. Of course, if you do that, certain services may lose full functionality.\nAccount Deletion. While we hope you’ll remain a lifelong Yaknaker. If you ask to delete your account, you will have up to 30 days to restore your account before we delete your information from our servers. During this period of time, your account will not be visible to other Yaknakers.\nAdvertising Preferences\n. We try to show you ads that we think will be relevant to your interests. If you would like to modify the information we and our advertising partners use to select these ads, go here to learn about the choices available to you.\n\nANALYTICS AND ADVERTISING SERVICES PROVIDED BY OTHERS\n\nWe may let other companies use cookies, web beacons, and similar tracking technologies on the services. These companies may collect information about how you use the services and other websites and online services over time and across different services. This information may be used to, among other things, analyze and track data, determine the popularity of certain content, and better understand your online activity. Additionally, some companies may use information collected on our services to deliver targeted advertisements on behalf of us or other companies, including on third-party websites and apps.\n\nUSERS OUTSIDE THE UNITED KINGDOM\n\nAlthough we welcome Yaknakers from all over the world, keep in mind that no matter where you live or where you happen to use our services, your information may be shared within the Locals Labs LTD. family of companies. This means that we may collect your personal information from, transfer it to, and store and process it in the United States and other countries outside of where you live.\n\nChildren\n\nOur services are not intended for — and we don’t direct them to — anyone under 13. And that’s why we do not knowingly collect personal information from anyone under 13.\n\nREVISIONS TO THE PRIVACY POLICY\n\nWe may change this Privacy Policy from time to time. But when we do, we’ll let you know one way or another. Sometimes, we'll let you know by revising the date at the top of the Privacy Policy that’s available on our website and mobile application. Other times, we may provide you with additional notice (such as adding a statement to our websites or providing you with an in-app notification)."
        
        static let Terms = "Our terms and conditions\nWe’re thrilled you’ve decided to use Yaknak and our other products and services, all of which we refer to simply as the 'Services'. We’re thrilled you’ve decided to use Yaknak and our other products and services, all of which we refer to simply as the “Services.”We’ve drafted these Terms of Service (which we call the 'Terms') so you’ll know the rules that govern our relationship with you. Although we have tried our best to strip the legalese from the Terms, there are places where these Terms may still read like a traditional contract. There’s a good reason for that: These Terms do indeed form a legally binding contract between you and Locals Labs LTD (the 'company' that makes\n\nWe’ve drafted these Terms of Service (which we call the 'Terms') so you’ll know the rules that govern our relationship with you. Although we have tried our best to strip the legalese from the Terms, there are places where these Terms may still read like a traditional contract. There’s a good reason for that: These Terms do indeed form a legally binding contract between you and Locals Labs LTD (the 'company' that makes Yaknak) So please read them carefully.\n\nBy using the Services, you agree to the Terms. Of course, if you don’t agree with them, then don’t use the Services.\n\nARBITRATION NOTICE: THESE TERMS CONTAIN AN ARBITRATION CLAUSE A LITTLE LATER ON. EXCEPT FOR CERTAIN TYPES OF DISPUTES MENTIONED IN THAT ARBITRATION CLAUSE, YOU AND LOCALS LABS LTD. AGREE THAT DISPUTES BETWEEN US WILL BE RESOLVED BY MANDATORY BINDING ARBITRATION, AND YOU AND LOCALS LABS LTD. WAIVE ANY RIGHT TO PARTICIPATE IN A CLASS-ACTION LAWSUIT OR CLASS-WIDE ARBITRATION.\n\n1. Who Can Use the Services\n\nNo one under 13 is allowed to create an account or use the Services. We may offer additional Services with additional terms that may require you to be even older to use them. So please read all terms carefully.\nBy using the Services, you state that:\nYou can form a binding contract with Locals Labs LTD.\nYou are not a person who is barred from receiving the Services under the laws of the United Kingdom or any other applicable jurisdiction—meaning that you do not appear on the U.K.'s list of Specially Designated Nationals or face any other similar prohibition.\nYou will comply with these Terms and all applicable local, state, national, and international laws, rules, and regulations.\nIf you are using the Services on behalf of a business or some other entity, you state that you are authorized to grant all licenses set forth in these Terms and to agree to these Terms on behalf of the business or entity.\n\n2. Rights We Grant You\n\nLocals Labs LTD. grants you a personal, worldwide, royalty-free, non-assignable, nonexclusive, revocable, and non-sublicensable license to access and use the Services. This license is for the sole purpose of letting you use and enjoy the Services’ benefits in a way that these Terms and our usage policies, such as our Community Guidelines, allow.\nAny software that we provide you may automatically download and install upgrades, updates, or other new features. You may be able to adjust these automatic downloads through your device’s settings.You may not copy, modify, distribute, sell, or lease any part of our Services, nor may you reverse engineer or attempt to extract the source code of that software, unless applicable laws prohibit these restrictions or you have our written permission to do so.\n\n3. Rights You Grant Us\n\nMany of our Services let you create, upload, post, send, receive, and store content. When you do that, you retain whatever ownership rights in that content you had to begin with. But you grant us a license to use that content. How broad that license is depends on which Services you use and the Settings you have selected. For all Services you grant Locals Labs LTD a worldwide, royalty-free, sublicensable, and transferable license to host, store, use, display, reproduce, modify, adapt, edit, publish, and distribute that content. This license is for the limited purpose of operating, developing, providing, promoting, and improving the Services and researching and developing new ones.\nIn addition to granting us the rights mentioned in the previous paragraph, you also grant us a perpetual license to create derivative works from, promote, exhibit, broadcast, syndicate, sublicense, publicly perform, and publicly display content submitted to Yaknak, or any other crowd-sourced Services in any form and in any and all media or distribution methods (now known or later developed). To the extent it’s necessary, when you appear in, create, upload, post, or send Tips, or other crowd-sourced content, you also grant Locals Labs LTD. and our business partners the unrestricted, worldwide, perpetual right and license to use your name, likeness, and voice. This means, among other things, that you will not be entitled to any compensation from Locals Labs LTD. or our business partners if your name, likeness, or voice is conveyed Tips or other crowd-sourced Services, either on the Yaknak application or on one of our business partner’s platforms.For more information about how to tailor who can watch your content, please take a look at our Privacy Policy. While we’re not required to do so, we may access, review, screen, and delete your content at any time and for any reason, including if we think your content violates these Terms. You alone, though, remain responsible for the content you create, upload, post, send, or store through the Service.\nThe Services may contain advertisements. In consideration for Locals Labs LTD. letting you access and use the Services, you agree that we, our affiliates, and our third-party partners may place advertising on the Services. Because the Services contain content that you and other users provide us, advertising may sometimes appear near your content.\nWe always love to hear from our users. But if you volunteer feedback or suggestions, just know that we can use your ideas without compensating you.\n\n4. The Content of Others\n\nMuch of the content on our Services is produced by users, publishers, and other third parties. Whether that content is posted publicly or sent privately, the content is the sole responsibility of the person or organization that submitted it. Although Locals Labs LTD. reserves the right to review all content that appears on the Services and to remove any content that violates these Terms, we do not necessarily review all of it. So we cannot—and do not—take responsibility for any content that others provide through the Services. Through these Terms, we make clear that we do not want the Services put to bad uses. But because we do not review all content, we cannot guarantee that content on the Services will always conform to our Terms.\n\n5. Privacy\n\nYour privacy matters to us. You can learn how we handle your information when you use our Services by reading our Privacy Policy. We encourage you to give the Privacy Policy a careful look because, by using our Services, you agree that Locals Labs LTD. can collect, use, and transfer your information consistent with that policy.\n\n6. Respecting Other People's Rights\n\nLocals Labs LTD. respects the rights of others. And so should you. You therefore may not upload, post, send, or store content that:\nviolates or infringes someone else’s rights of publicity, privacy, copyright, trademark, or other intellectual-property right.\nbullies, harasses, or intimidates.\ndefames.\nspams or solicits our users.\n\nYou must also respect Locals Labs LTD.’s rights. These Terms do not grant you any right to:\nuse branding, logos, designs, photographs, videos, or any other materials used in our Services other than those contained within our 'http://yaknakapp.com/press/' section of our website.\ncopy, archive, download, upload, distribute, syndicate, broadcast, perform, display, make available, or otherwise use any portion of the Services or the content on the Services except as set forth in these Terms.\nuse the Services, any tools provided by the Services, or any content on the Services for any commercial purposes without our consent.\nIn short: You may not use the Services or the content on the Services in ways that are not authorized by these Terms. Nor may you help anyone else in doing so.\n\n7. Respecting Copyright\n\nLocals Labs LTD. honors the requirements set forth in the Digital Millennium Copyright Act. We therefore take reasonable steps to expeditiously remove from our Services any infringing material that we become aware of. And if Locals Labs LTD. becomes aware that one of its users has repeatedly infringed copyrights, we will take reasonable steps within our power to terminate the user’s account.\n\n8. Safety\n\nWe try hard to keep our Services a safe place for all users. But we can’t guarantee it. That’s where you come in. By using the Services, you agree that:\nYou will not use the Services for any purpose that is illegal or prohibited in these Terms.\nYou will not use any robot, spider, crawler, scraper, or other automated means or interface to access the Services or extract other user’s information.\nYou will not use or develop any third-party applications that interact with the Services or other users’ content or information without our written consent.\nYou will not use the Services in a way that could interfere with, disrupt, negatively affect, or inhibit other users from fully enjoying the Services, or that could damage, disable, overburden, or impair the functioning of the Services.\nYou will not use or attempt to use another user’s account, username, or password without their permission.\nYou will not solicit login credentials from another user.\nYou will not post content that contains pornography, graphic violence, threats, hate speech, or incitements to violence.\nYou will not upload viruses or other malicious code or otherwise compromise the security of the Services.\nYou will not attempt to circumvent any content-filtering techniques we employ, or attempt to access areas or features of the Services that you are not authorized to access.\nYou will not probe, scan, or test the vulnerability of our Services or any system or network.\nYou will not encourage or promote any activity that violates these Terms.\nWe also care about your safety while using our Services. So do not use our Services in a way that would distract you from obeying traffic or safety laws. For example, never make tips and drive. And never put yourself or others in harm’s way just to capture a tip.\n\n9. Your Account\n\nYou are responsible for any activity that occurs in your Yaknak account. So it’s important that you keep your account secure. One way to do that is to select a strong password that you don’t use for any other account.\nBy using the Services, you agree that, in addition to exercising common sense:\nYou will not create more than one account for yourself.\nYou will not create another account if we have already disabled your account, unless you have our written permission to do so.\nYou will not buy, sell, rent, or lease access to your Yaknak account or a friend link without our written permission.\nYou will not share your password.\nYou will not log in or attempt to access the Services through unauthorized third-party applications or clients.\n\n11. Data Charges and Mobile Phones\nYou are responsible for any mobile charges that you may incur for using our Services, including text-messaging and data charges. If you’re unsure what those charges may be, you should ask your service provider before using the Services.\n\n12. Third-Party Services\n\nIf you use a service, feature, or functionality that is operated by a third party and made available through our Services (including Services we jointly offer with the third party), each party’s terms will govern the respective party’s relationship with you. Locals Labs LTD. is not responsible or liable for a third party’s terms or actions taken under the third party’s terms.\n\n13. Modifying the Services and Termination\n\nWe’re relentlessly improving our Services and creating new ones all the time. That means we may add or remove features, products, or functionalities, and we may also suspend or stop the Services altogether. We may take any of these actions at any time, and when we do, we may not provide you with any notice beforehand.\nWhile we hope you remain a lifelong Yaknaker, you can terminate these Terms at any time and for any reason by deleting your account. Locals Labs LTD. may also terminate these Terms with you at any time, for any reason, and without advanced notice. That means that we may stop providing you with any Services, or impose new or additional limits on your ability to use the Services. For example, we may deactivate your account due to prolonged inactivity, and we may reclaim your username at any time for any reason. Regardless of who terminates these Terms, both you and Locals Labs LTD. continue to be bound by Sections 3, 6, 9, 10, and 13-22 of the Terms.\n\n14. Indemnity\n\nYou agree, to the extent permitted under applicable law, to indemnify, defend, and hold harmless Locals Labs LTD., our directors, officers, employees, and affiliates from and against any and all complaints, charges, claims, damages, losses, costs, liabilities, and expenses (including attorneys’ fees) due to, arising out of, or relating in any way to: (a) your access to or use of the Services; (b) your content; and (c) your breach of these Terms.\n\n15. Disclaimers\n\nWe try to keep the Services up and running and free of annoyances. But we make no promises that we will succeed.\n\nTHE SERVICES ARE PROVIDED “AS IS” AND “AS AVAILABLE” AND TO THE EXTENT PERMITTED BY APPLICABLE LAW WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. IN ADDITION, WHILE LOCALS LABS LTD. ATTEMPTS TO PROVIDE A GOOD USER EXPERIENCE, WE DO NOT REPRESENT OR WARRANT THAT: (A) THE SERVICES WILL ALWAYS BE SECURE, ERROR-FREE, OR TIMELY; (B) THE SERVICES WILL ALWAYS FUNCTION WITHOUT DELAYS, DISRUPTIONS, OR IMPERFECTIONS; OR (C) THAT ANY CONTENT, USER CONTENT, OR INFORMATION YOU OBTAIN ON OR THROUGH THE SERVICES WILL BE TIMELY OR ACCURATE.\n\nLOCALS LABS LTD. TAKES NO RESPONSIBILITY AND ASSUMES NO LIABILITY FOR ANY CONTENT THAT YOU, ANOTHER USER, OR A THIRD PARTY CREATES, UPLOADS, POSTS, SENDS, RECEIVES, OR STORES ON OR THROUGH OUR SERVICES. YOU UNDERSTAND AND AGREE THAT YOU MAY BE EXPOSED TO CONTENT THAT MIGHT BE OFFENSIVE, ILLEGAL, MISLEADING, OR OTHERWISE INAPPROPRIATE, NONE OF WHICH LOCALS LABS LTD. WILL BE RESPONSIBLE FOR.\n\n16. Limitation of Liability\n\nTO THE MAXIMUM EXTENT PERMITTED BY LAW, LOCALS LABS LTD. AND OUR MANAGING MEMBERS, SHAREHOLDERS, EMPLOYEES, AFFILIATES, LICENSORS, AND SUPPLIERS WILL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, PUNITIVE, OR MULTIPLE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM: (A) YOUR ACCESS TO OR USE OF OR INABILITY TO ACCESS OR USE THE SERVICES; (B) THE CONDUCT OR CONTENT OF OTHER USERS OR THIRD PARTIES ON OR THROUGH THE SERVICES; OR (C) UNAUTHORIZED ACCESS, USE, OR ALTERATION OF YOUR CONTENT, EVEN IF LOCALS LABS LTD. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. IN NO EVENT WILL LOCAL LABS.’S AGGREGATE LIABILITY FOR ALL CLAIMS RELATING TO THE SERVICES EXCEED THE GREATER OF $100 USD OR THE AMOUNT YOU PAID LOCALS LABS., IF ANY, IN THE LAST 12 MONTHS.\n\nSOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES, SO SOME OR ALL OF THE EXCLUSIONS AND LIMITATIONS IN THIS SECTION MAY NOT APPLY TO YOU.\n\n17. Arbitration, Class-Action Waiver, and Jury Waiver\n\nPLEASE READ THE FOLLOWING PARAGRAPHS CAREFULLY BECAUSE THEY REQUIRE YOU AND LOCALS LABS LTD. TO AGREE TO RESOLVE ALL DISPUTES BETWEEN US THROUGH BINDING INDIVIDUAL ARBITRATION.\n\nApplicability of Arbitration Agreement. You and Locals Labs LTD. agree that all claims and disputes, including all statutory claims and disputes, arising out of or relating to these Terms or the use of the Services that cannot be resolved in small claims court will be resolved by binding arbitration on an individual basis, except that you and Locals Labs LTD. are not required to arbitrate any dispute in which either party seeks equitable relief for the alleged unlawful use of copyrights, trademarks, trade names, logos, trade secrets, or patents. To be clear: The phrase “all claims and disputes” includes claims and disputes that arose between us before the effective date of these Terms.\nArbitration Rules. The arbitration will be conducted by a single neutral arbitrator. Any claims or disputes where the total amount sought is less than £10,000 GBP may be resolved through binding non-appearance-based arbitration, at the option of the party seeking relief. For claims or disputes where the total amount sought is £10,000 GBP or more, the right to a hearing will be determined by the arbitral forum’s rules. Any judgment on the award rendered by the arbitrator may be entered in any court of competent jurisdiction.\nAdditional Rules for Non-appearance Arbitration. If non-appearance arbitration is elected, the arbitration will be conducted by telephone, online, written submissions, or any combination of the three; the specific manner will be chosen by the party initiating the arbitration. The arbitration will not involve any personal appearance by the parties or witnesses unless the parties mutually agree otherwise.\nFees. If you choose to arbitrate with Locals Labs LTD., you will not have to pay any fees to do so. That is because Locals Labs LTD. will reimburse you for your filing fee and the AAA’s Consumer Arbitration Rules provide that any hearing fees and arbitrator compensation are our responsibility. To the extent another arbitral forum is selected, Locals Labs LTD. will pay that forum’s fees as well.\nAuthority of the Arbitrator. The arbitrator will decide the jurisdiction of the arbitrator and the rights and liabilities, if any, of you and Locals Labs LTD. The dispute will not be consolidated with any other matters or joined with any other cases or parties. The arbitrator will have the authority to grant motions dispositive of all or part of any claim or dispute. The arbitrator will have the authority to award monetary damages and to grant any non-monetary remedy or relief available to an individual under applicable law, the arbitral forum’s rules, and the Terms. The arbitrator will issue a written award and statement of decision describing the essential findings and conclusions on which the award is based, including the calculation of any damages awarded. The arbitrator has the same authority to award relief on an individual basis that a judge in a court of law would have. The award of the arbitrator is final and binding upon you and Locals Labs LTD.\nWaiver of Jury Trial. YOU AND LOCALS LABS LTD. WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO GO TO COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY. You and Locals Labs LTD. are instead electing to have claims and disputes resolved by arbitration. Arbitration procedures are typically more limited, more efficient, and less costly than rules applicable in court and are subject to very limited review by a court. In any litigation between you and Locals Labs LTD. over whether to vacate or enforce an arbitration award, YOU AND LOCALS LABS LTD. WAIVE ALL RIGHTS TO A JURY TRIAL, and elect instead to have the dispute be resolved by a judge.\nWaiver of Class or Consolidated Actions. ALL CLAIMS AND DISPUTES WITHIN THE SCOPE OF THIS ARBITRATION AGREEMENT MUST BE ARBITRATED OR LITIGATED ON AN INDIVIDUAL BASIS AND NOT ON A CLASS BASIS. CLAIMS OF MORE THAN ONE CUSTOMER OR USER CANNOT BE ARBITRATED OR LITIGATED JOINTLY OR CONSOLIDATED WITH THOSE OF ANY OTHER CUSTOMER OR USER. If, however, this waiver of class or consolidated actions is deemed invalid or unenforceable, neither you nor we are entitled to arbitration; instead all claims and disputes will be resolved in a court as set forth in Section 18.\nRight to Waive. Any rights and limitations set forth in this arbitration agreement may be waived by the party against whom the claim is asserted. Such waiver will not waive or affect any other portion of this arbitration agreement.\nOpt-out. You may opt out of this arbitration agreement. If you do so, neither you nor Locals Labs LTD. can force the other to arbitrate. To opt out, you must notify Locals Labs LTD. in writing no later than 30 days after first becoming subject to this arbitration agreement. Your notice must include your name and address, your Yaknak username and the email address you used to set up your Yaknak account (if you have one), and an unequivocal statement that you want to opt out of this arbitration agreement. You must either mail your opt-out notice to this address: Locals Labs LTD, 23D St Michael's Road, SW90SN\nSmall Claims Court. Notwithstanding the foregoing, either you or Locals Labs LTD. may bring an individual action in small claims court.\nArbitration Agreement Survival. This arbitration agreement will survive the termination of your relationship with Locals Labs LTD.\n\n18. Exclusive Venue\n\nTo the extent the parties are permitted under these Terms to initiate litigation in a court, both you and Locals Labs LTD. agree that all claims and disputes, including statutory claims and disputes, arising out of or relating to the Terms or the use of the Services will be litigated exclusively in the United Kingdom. You and Locals Labs LTD. consent to the personal jurisdiction of courts in the United Kingdom.\n\n19. Choice of Law\n\nExcept to the extent they are preempted by U.K. law, other than its conflict-of-laws principles, govern these Terms and any claims and disputes arising out of or relating to these Terms or their subject matter, including tort and statutory claims and disputes.20. Severability\nIf any provision of these Terms is found unenforceable, then that provision will be severed from these Terms and not affect the validity and enforceability of any remaining provisions.\n\n21. Additional Terms for Specific Services\n\nGiven the breadth of our Services, we sometimes need to craft additional terms and conditions for specific Services. Those additional terms and conditions, which will be available with the relevant Services, then become part of your agreement with us if you use those Services.\n\n22. Final Terms\n\nThese Terms make up the entire agreement between you and Locals Labs LTD., and supersede any prior agreements.\nThese Terms do not create or confer any third-party beneficiary rights.\nIf we do not enforce a provision in these Terms, it will not be considered a waiver.\nWe reserve all rights not expressly granted to you.\nYou may not transfer any of your rights or obligations under these Terms without our consent.\nThese Terms were written in English and to the extent the translated version of these Terms conflict with the English version, the English version will control.\n\nContact Us\n\nLocals Labs LTD. welcomes comments, questions, concerns, or suggestions. Please send feedback to us by visiting hugo.winn@hotmail.com\nLocals Labs LTD. is located in the United Kingdom at 23D St Michael's Road, SW90SN"
        
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
