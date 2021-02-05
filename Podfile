use_frameworks!

sdk_name = "MiniApp"
secrets = ["RMA_API_ENDPOINT", "RAS_PROJECT_SUBSCRIPTION_KEY", "RAS_PROJECT_IDENTIFIER", "RMA_DEMO_APP_BUILD_TYPE", "RMA_GAD_APPLICATION_IDENTIFIER"]

platform :ios, '11.0'
target sdk_name + '_Example' do
  project sdk_name + '.xcodeproj'
  workspace sdk_name + '.xcworkspace'
  pod 'MiniApp/Admob', :path => './'
  pod 'Google-Mobile-Ads-SDK'

  target sdk_name + '_Tests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  system("./configure-secrets.sh")
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
    end
  end
  system("./scripts/configure-secrets.sh #{sdk_name} #{secrets.join(" ")}")
end
