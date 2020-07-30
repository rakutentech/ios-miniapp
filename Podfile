use_frameworks!

platform :ios, '11.0'
target 'MiniApp_Example' do
  project 'MiniApp.xcodeproj'
  workspace 'MiniApp.xcworkspace'
  pod 'MiniApp', :path => './'

  target 'MiniApp_Tests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  system("./configure-secrets.sh")
end
