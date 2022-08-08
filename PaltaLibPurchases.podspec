Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibPurchases'
  spec.version               = '3.0.0'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Attribution'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "purchases-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '11.0'
  spec.swift_versions        = '5.3'

  spec.source_files = 'Sources/Purchases/**/*.swift'
  spec.exclude_files = 'Sources/Purchases/Legacy/**'

  spec.dependency 'PaltaLibCore', '>= 2.3.0'
  spec.dependency 'RevenueCat', '~> 4.7.0'
end

