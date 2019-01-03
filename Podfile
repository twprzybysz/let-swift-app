platform :ios, '12.0'

target 'LetSwift' do
  use_frameworks!

  # Ignore cocoapods warnings
  inhibit_all_warnings!

  # Acknowledgements
  post_install do | installer |
      require 'fileutils'
      FileUtils.cp_r('Pods/Target Support Files/Pods-LetSwift/Pods-LetSwift-acknowledgements.plist', 'LetSwift/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end

  # Host utils
  pod 'SwiftLint', '~> 0.29'

  # Testing
  pod 'HockeySDK', '~> 5.1', :configurations => ['Debug', 'Release']
  pod 'Fabric', '~> 1.9'
  pod 'Crashlytics', '~> 3.12'

  # Facebook SDK
  pod 'FBSDKCoreKit', '~> 4.39'
  pod 'FBSDKLoginKit', '~> 4.39'

  # Networking
  pod 'Alamofire', '~> 4.8'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.3'
  pod 'ModelMapper', '~> 9.0'

  # Views
  pod 'ImageEffects', '~> 1.0'
  pod 'SDWebImage', '~> 4.4'
  pod 'DACircularProgress', '~> 2.3'
end
