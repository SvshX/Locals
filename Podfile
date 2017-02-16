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
  pod 'Koloda'
  pod 'MBProgressHUD'
  pod 'HTHorizontalSelectionList'
  pod 'RSKPlaceholderTextView'
  pod 'NVActivityIndicatorView'
  pod 'ReachabilitySwift', '~> 3'
  pod 'PXGoogleDirections'
  pod 'Kingfisher'
  pod 'Nuke', '~> 5.0'
  pod 'Nuke-Toucan-Plugin', :git => 'https://github.com/kean/Nuke-Toucan-Plugin.git'
  pod 'Toucan'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end

