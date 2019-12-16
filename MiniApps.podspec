#
# Be sure to run `pod lib lint MiniApps.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MiniApps'
  s.version          = '0.1.0'
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Mini App SDK"
  s.homepage     = "https://github.com/rakutentech/ios-miniapps"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/rakutentech/ios-miniapps.git", :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'MiniApps/Classes/**/*'

end
