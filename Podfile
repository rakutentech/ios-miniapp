source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

sdk_name = "MiniApp"
secrets = ["RMA_API_ENDPOINT", "RAS_PROJECT_SUBSCRIPTION_KEY", "RAS_PROJECT_IDENTIFIER", "RMA_DEMO_APP_BUILD_TYPE", "RMA_GAD_APPLICATION_IDENTIFIER", "RMA_APP_CENTER_SECRET", "RAT_ENDPOINT"]

platform :ios, '13.0'
target sdk_name + '_Example' do
  project sdk_name + '.xcodeproj'
  workspace sdk_name + '.xcworkspace'
  pod 'MiniApp/Admob', :path => './'
  pod 'MiniApp/UI', :path => './'
  pod 'Google-Mobile-Ads-SDK'
  pod 'AppCenter/Crashes'
  pod 'RAnalytics', :source => 'https://github.com/rakutentech/ios-analytics-framework.git'

  target sdk_name + '_Tests' do
    inherit! :search_paths
    pod 'Nimble', '~>9.0.0'
    pod 'Quick', '~>3.1.2'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
    end
  end
  system("./scripts/configure-secrets.sh #{sdk_name} #{secrets.join(" ")}")
end
