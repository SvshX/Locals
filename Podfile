# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Yaknak' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'pop', '~> 1.0'
  pod 'MBProgressHUD'
  pod 'GooglePlaces'
  pod 'GoogleMaps'
  pod 'HTHorizontalSelectionList'
  pod 'NVActivityIndicatorView', '~> 3.6.1'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
  pod 'Kingfisher'
  pod 'SwiftLocation'
  

end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

