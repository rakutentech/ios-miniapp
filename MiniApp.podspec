Pod::Spec.new do |s|
  s.name         = 'MiniApp'
  s.version      = '3.4.0'
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Rakuten's Mini App SDK"
  s.description  = "This open-source library allows you to integrate Mini App ecosystem into your iOS applications. Mini App SDK also facilitates communication between a mini app and the host app via a message bridge."
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
  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.default_subspec = 'Core'
  s.static_framework = true
  s.swift_versions = [5.0, 5.3, 5.4]

  s.subspec 'Core' do |core|
    core.source_files = 'MiniApp/Classes/core/**/*.{swift,h,m}'
    core.resource_bundle = {
        "Localization" => ["MiniApp/*.lproj/*.strings"],
        "MiniApp" => ['MiniApp/Classes/core/**/*.{xcassets,js,pdf,xib}','js-miniapp/bridge.js']
    }
    core.dependency 'ZIPFoundation', '0.9.12'
  end
  
  s.subspec 'UI' do |ui|
    ui.source_files = 'MiniApp/Classes/ui/**/*.{swift,h,m}'
    ui.dependency 'MiniApp/Core'
  end


  s.subspec 'Admob' do |admob|
    admob.source_files = 'MiniApp/Classes/admob7/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 7.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB' }
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
end
