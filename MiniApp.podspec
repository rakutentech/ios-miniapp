#
# Be sure to run `pod lib lint MiniApp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MiniApp'
  s.version          = '2.6.0'
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Mini App SDK"
  s.homepage     = "https://github.com/rakutentech/ios-miniapp"
  s.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.source       = {
    :git => "https://github.com/rakutentech/ios-miniapp.git",
    :tag => 'v' + s.version.to_s,
    :submodules => true
  }
  s.documentation_url = "https://rakutentech.github.io/ios-miniapp/"

  s.ios.deployment_target = '11.0'

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |core|
      core.source_files = 'MiniApp/Classes/**/*.swift'
      core.resources = ['MiniApp/**/*.{xcassets,js,pdf,xib}','js-miniapp/bridge.js']
      core.resource_bundle = {"Localization" => ["MiniApp/*.lproj/*.strings"]}

      core.dependency 'RSDKUtils', '>= 1.1.0'
      core.dependency 'ZIPFoundation'
  end
end
