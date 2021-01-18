use_frameworks!

sdk_name = "MiniApp"
secrets = ["RMA_API_ENDPOINT", "RAS_PROJECT_SUBSCRIPTION_KEY", "RAS_PROJECT_IDENTIFIER", "RMA_DEMO_APP_BUILD_TYPE"]

platform :ios, '11.0'
target sdk_name + '_Example' do
  project sdk_name + '.xcodeproj'
  workspace sdk_name + '.xcworkspace'
  pod sdk_name , :path => './'

  target sdk_name + '_Tests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  system("./configure-secrets.sh #{sdk_name} #{secrets.join(" ")}")
end
