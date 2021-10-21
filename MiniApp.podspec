Pod::Spec.new do |miniapp|
  miniapp.name         = 'MiniApp'
  miniapp.version      = '3.8.0'
  miniapp.authors      = "Rakuten Ecosystem Mobile"
  miniapp.summary      = "Rakuten's Mini App SDK"
  miniapp.description  = "This open-source library allows you to integrate Mini App ecosystem into your iOS applications. Mini App SDK also facilitates communication between a mini app and the host app via a message bridge."
  miniapp.homepage     = "https://github.com/rakutentech/ios-miniapp"
  miniapp.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  miniapp.xcconfig = { "RMA_SDK_VERSION" => miniapp.version }

  miniapp.source   = {
    :git => "https://github.com/rakutentech/ios-miniapp.git",
    :tag => 'v' + miniapp.version.to_s,
    :submodules => true
  }
  miniapp.documentation_url = "https://rakutentech.github.io/ios-miniapp/"
  miniapp.platform = :ios
  miniapp.ios.deployment_target = '13.0'
  miniapp.default_subspec = 'Core'
  miniapp.static_framework = true
  miniapp.swift_versions = [5.0, 5.3, 5.4]

  miniapp.subspec 'Core' do |core|
    core.source_files = 'MiniApp/Classes/core/**/*.{swift,h,m}'
    core.resource_bundle = {
        "Localization" => ["MiniApp/*.lproj/*.strings"],
        "MiniApp" => ['MiniApp/Classes/core/**/*.{xcassets,pdf,xib}','js-miniapp/*.js']
    }
    core.dependency 'ZIPFoundation', '0.9.12'
    core.dependency 'TrustKit', '~>2.0'
  end

  miniapp.subspec 'UI' do |ui|
    ui.source_files = 'MiniApp/Classes/ui/**/*.{swift,h,m}'
    ui.dependency 'MiniApp/Core'
  end

  miniapp.subspec 'Signature' do |signature|
    signature.source_files = 'MiniApp/Classes/signature/**/*.{swift,h,m}'
    signature.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_SIGNATURE' }
    signature.dependency 'MiniApp/Core'
  end

  miniapp.subspec 'Admob' do |admob|
    admob.source_files = 'MiniApp/Classes/admob7/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 7.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB -D RMA_SDK_ADMOB7' }
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end

  miniapp.subspec 'Admob8' do |admob|
    admob.source_files = 'MiniApp/Classes/admob/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 8.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB -D RMA_SDK_ADMOB8'}
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
end
