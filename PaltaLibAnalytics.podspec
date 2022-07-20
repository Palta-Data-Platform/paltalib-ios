Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibAnalytics'
  spec.version               = '2.1.5'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Analytics'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "analytics-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'

  spec.source_files = 'Sources/Analytics/**/*.{swift,m}'

  spec.dependency 'PaltaLibCore', '~> 2.2.1'
  spec.dependency 'PaltaLibAnalyticsModel', '1.0.0'
end

