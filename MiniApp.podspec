Pod::Spec.new do |s|
  s.name         = 'MiniApp'
  s.version      = '2.7.0'
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Mini App SDK"
  s.homepage     = "https://github.com/rakutentech/ios-miniapp"
  s.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.xcconfig = { "RMA_SDK_VERSION" => s.version }

  s.source   = {
    :git => "https://github.com/rakutentech/ios-miniapp.git",
    :tag => 'v' + s.version.to_s,
    :submodules => true
  }
  s.documentation_url = "https://rakutentech.github.io/ios-miniapp/"
  s.ios.deployment_target = '11.0'
  s.default_subspec = 'Core'
  s.resource_bundle = {"Localization" => ["MiniApp/*.lproj/*.strings"]}

  s.subspec 'Core' do |core|
    core.source_files = 'MiniApp/Classes/core/**/*.{swift,h,m}'
    core.resources = ['MiniApp/Classes/core/**/*.{xcassets,js,pdf,xib}','js-miniapp/bridge.js']
    core.dependency 'RSDKUtils', '>= 1.1.0'
    core.dependency 'ZIPFoundation'
  end

  s.subspec 'Admobs' do |admobs|
    admobs.dependency = "MiniApp/Core"
    admobs.static_framework = true
    admobs.dependency 'Google-Mobile-Ads-SDK'
  end
end
