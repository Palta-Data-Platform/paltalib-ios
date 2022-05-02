Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibPurchases'
  spec.version               = '0.0.2'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Attribution'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "purchases-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'

  spec.source_files = 'Sources/Purchases/**/*.swift'

  spec.dependency 'PaltaLibCore'
  spec.dependency 'PaltaLibAttribution'
  spec.dependency 'Purchases', '~> 3.13.0'
end

