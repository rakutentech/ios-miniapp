#
# Be sure to run `pod lib lint MiniApp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MiniApp'
  s.version          = '1.1.0'
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Mini App SDK"
  s.homepage     = "https://github.com/rakutentech/ios-miniapp"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/rakutentech/ios-miniapp.git", :tag => 'v' + s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'MiniApp/Classes/**/*'
  s.resources = "MiniApp/Classes/JavascriptBridge/bridge.js"

end
