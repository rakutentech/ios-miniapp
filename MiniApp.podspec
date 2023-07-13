Pod::Spec.new do |miniapp|
  miniapp.name         = 'MiniApp'
  miniapp.version      = '5.3.0-alpha'
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
  miniapp.ios.deployment_target = '14.0'
  miniapp.default_subspec = 'Core'
  miniapp.static_framework = true
  miniapp.swift_versions = [5.0, 5.3, 5.4]

  miniapp.subspec 'Core' do |core|
    core.source_files = 'Sources/Classes/core/**/*.{swift,h,m}'
    core.resource_bundle = {
        "Localization" => ["Sources/Classes/resources/*.lproj/*.strings"],
        "MiniApp" => ['Sources/Classes/core/**/*.{xcassets,pdf,xib}','Sources/Classes/js-miniapp/*.js']
    }
    core.dependency 'ZIPFoundation', '0.9.12'
    core.dependency 'TrustKit', '~>2.0'
    core.dependency 'SQLite.swift', '~> 0.13.3'
  end

  miniapp.subspec 'UI' do |ui|
    ui.source_files = 'Sources/Classes/ui/**/*.{swift,h,m}'
    ui.dependency 'MiniApp/Core'
  end

  miniapp.subspec 'Signature' do |signature|
    signature.source_files = 'Sources/Classes/signature/**/*.{swift,h,m}'
    signature.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_SIGNATURE' }
    signature.dependency 'MiniApp/Core'
  end

  miniapp.subspec 'Admob' do |admob|
    admob.source_files = 'Sources/Classes/admob/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 10.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB -D RMA_SDK_ADMOB10'}
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
  
  miniapp.subspec 'Admob7' do |admob|
    admob.source_files = 'Sources/Classes/admob7/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 7.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB -D RMA_SDK_ADMOB7' }
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end

  miniapp.subspec 'Admob8' do |admob|
    admob.source_files = 'Sources/Classes/admob8/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 8.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB -D RMA_SDK_ADMOB8'}
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end

  miniapp.subspec 'Admob9' do |admob|
    admob.source_files = 'Sources/Classes/admob9/**/*.{swift,h,m}'
    admob.dependency 'MiniApp/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '~> 9.0'
    admob.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D RMA_SDK_ADMOB -D RMA_SDK_ADMOB9'}
    admob.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    admob.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
end
